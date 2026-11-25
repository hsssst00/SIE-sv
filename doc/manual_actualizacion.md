# Manual de actualización de SIE-sv

**Estado:** borrador de la Fase 0 de SIE-sv (2026-11-22). Sale del borrador de la Fase 7 de `SIE-el-salvador` e
incorpora los defectos que encontró el ensayo con el 2026-T2: dónde va cada comando, cómo configurar `SIE_L0_STORE` y
la captura fuera de ventana en dos llamadas. Además se adapta a SIE-sv: sin pronósticos y sin FRED, FMI, BM ni CBO.

## 0. Para quién es y qué cubre

Para quien **opera** SIE-sv: incorpora una publicación nueva y deja la L3 vigente al día. Quien solo **usa** las series
va a tener el paquete `siesv` (Fases 1 y 2 de SIE-sv).

**Resultado al terminar:** `data/L3_master/` contiene la publicación nueva, validada y con su trazabilidad
certificada, y un PR contra `main` tiene el CI en verde.

**Dónde va cada comando.** Cada bloque dice dónde se escribe:

- **Consola de R**: la consola de RStudio con el proyecto abierto. Es la vía principal en Windows. Los objetivos de
  `make` se corren desde ahí con `system("make <objetivo>")`. Al final se imprime el código de salida: `[1] 0` es
  éxito y cualquier otro número es un fallo.
- **Terminal**: PowerShell, o la pestaña *Terminal* de RStudio, parada en la raíz del repositorio. Solo se usa para
  `git`.

Al arrancar, `renv` imprime mensajes como «Dependency discovery took N seconds» o «Some listed binary packages have no
source». Son inofensivos. Lo que importa es una línea `Error:` y el código de salida.

**Cómo leer cada paso.** Cada paso trae el comando, lo que debe salir y qué hacer si no sale así. Si algo no coincide
y el manual no dice qué hacer, detente y anótalo en tu bitácora (anexo C). Eso es un defecto del manual, no tuyo.

**Cinco reglas que no se rompen** (de `CLAUDE.md`):
1. Nunca edites a mano `data/L0_raw/` ni las capas L1 a L3. Todo se genera por código.
2. Los catálogos (`catalogos/`) solo se editan dentro de su esquema (`catalogos/datapackage.json`).
3. Ante una decisión de método que el manual no cubre (una serie nueva, un dato faltante raro), detente y pregunta.
4. La validación falla, no advierte: si un paso se detiene, no lo saltes.
5. Una sola pasada de captura por ventana. Nunca evadas un bloqueo de una fuente (regla 9).

## 1. Requisitos previos (una sola vez)

| Requisito | Para qué | Cómo comprobarlo (Consola de R) |
|---|---|---|
| R 4.6.1 | Es la versión de `renv.lock` y del CI | `R.version.string` |
| Git y una cuenta de GitHub | Clonar y abrir el PR | `system("git --version")` |
| Windows: Rtools (trae GNU Make) | Correr los objetivos del `Makefile` | `system("make --version")` |
| Google Chrome o Chromium | `chromote` abre el portal del BCR, que arma las tablas en el navegador | Chrome abre normalmente |
| Acceso al almacén privado de L0 de SIE-sv (`hsssst00/SIE-sv-L0`, ADR-012) | Reconstruir L3. Los archivos crudos no están en el repo (ADR-008) | Sección 3 |
| Locale UTF-8 | Las tildes de catálogos y mensajes, y la regla que reconoce los índices. Sin él, `make master` se detiene al empezar | `l10n_info()` debe decir `UTF-8` `TRUE` |

X-13ARIMA-SEATS no se instala aparte: lo trae el paquete `x13binary` de `renv.lock`. SIE-sv no necesita ninguna clave
de API.

## 2. Instalar el entorno

1. **Terminal:** `git clone https://github.com/hsssst00/SIE-sv.git`. Abre en RStudio el archivo `.Rproj` de la raíz
   (se llama `SIE-el-salvador.Rproj`, por el repositorio de origen). Todo lo que sigue se corre con ese proyecto
   abierto.
2. **Consola de R:** `renv::restore()`. Instala las versiones exactas de `renv.lock` y debe terminar sin `Error:`.
3. **Consola de R:** `seasonal::checkX13()`. Debe decir que X-13 funciona.
4. **Consola de R:** `system("make validate")`. Debe terminar en `[1] 0`. Valida los catálogos contra su esquema y su
   integridad referencial.
5. **Consola de R:** `testthat::test_dir("tests")`. Todas las pruebas deben pasar. En Windows, `make test` puede
   terminar con `Segmentation fault` después de mostrar las pruebas en verde (`doc/entorno_windows.md`): por eso se
   usa esta forma.

Si en una terminal prefieres `Rscript`, van comillas dobles por fuera: `Rscript -e "testthat::test_dir('tests')"`. Si
Windows no encuentra `Rscript`, usa la ruta completa:
`& "C:\Program Files\R\R-4.6.1\bin\Rscript.exe" -e "testthat::test_dir('tests')"`.

## 3. Poner L0 en la máquina

1. **Terminal**, en la carpeta donde quieras guardar el almacén:
   `git clone https://github.com/hsssst00/SIE-sv-L0.git`. Es un repositorio privado: necesitas que Harold te dé
   acceso.
2. **Consola de R:** `usethis::edit_r_environ("project")`. Abre (o crea) el archivo `.Renviron` en la raíz de SIE-sv.
   Copia ahí el contenido de `.Renviron.example`, quita el `#` de la línea `SIE_L0_STORE=` y pon la ruta del almacén
   **con barras normales**, por ejemplo `SIE_L0_STORE=D:/harold/Documents/SIE-sv-L0`. Guarda el archivo, que
   tiene que terminar con una línea en blanco.
3. Reinicia R (en RStudio: *Session > Restart R*). R lee `.Renviron` solo al arrancar. `Sys.setenv()` no alcanza,
   porque `make` abre su propio proceso de R.
4. **Consola de R:** comprueba la variable.
   ```r
   Sys.getenv("SIE_L0_STORE")             # tiene que mostrar la ruta, no ""
   dir.exists(Sys.getenv("SIE_L0_STORE")) # TRUE
   ```
5. **Consola de R:** `system("make materializar-l0")`. Copia los archivos que falten y verifica la integridad. Qué
   esperar:
   - Integridad **N/N**, donde N es el número de filas de `data/L0_raw/manifiesto.csv` (79 al 2026-11-22), y `[1] 0`,
     sin avisos.
   - Si sale `FALTA_EN_ALMACEN`, el almacén no tiene un archivo del manifiesto. Haz `git pull` en el almacén y repite.
     Si sigue, avisa y no sigas.
   - Si sale `FALLO VISIBLE [materializar-l0]: la variable de entorno SIE_L0_STORE no esta definida`, vuelve al
     paso 2.

Si L0 ya está completa en la máquina, basta con `system("make raw-fisico")`. Nunca sobrescribas un archivo de
`data/L0_raw/`: si uno está corrupto, `verificar_l0_fisico.R` lo dice y no se reemplaza a mano.

## 4. Antes de capturar: guardar la huella de la L3 actual

Sirve para separar lo que trae la publicación nueva de una diferencia de entorno. **Consola de R:**

```r
huella_l3 <- function() {
  f <- list.files("data/L3_master", pattern = "\\.csv$", full.names = TRUE)
  data.frame(archivo = basename(f),
             sha256 = unname(vapply(f, function(x) digest::digest(file = x, algo = "sha256"), "")))
}
write.csv(huella_l3(), "~/huella_l3_antes.csv", row.names = FALSE)
```

La huella se guarda fuera del repo (`~` es tu carpeta de usuario) para que no entre en ningún commit. Si
`data/L3_master/` está vacía (máquina nueva), corre primero `system("make master")` y toma la huella después.

## 5. Dónde y cuándo se captura

**Mientras `SIE-el-salvador` no cierre su Fase 7, la captura se hace allá, no aquí** (decisión de Harold,
2026-11-22). Esa fase todavía necesita el PIB 2026-T3 para su prueba externa, y una publicación se captura una sola
vez (regla 9). SIE-sv toma las filas y los archivos que le sirven con la sección 7.3. Cuando la Fase 7 de `SIE-el-salvador` cierre,
SIE-sv pasa a ser el único lugar de captura y la sección 6 rige aquí.

**Qué le sirve a SIE-sv** (ADR-012, anexo E): solo lo que no se consigue por una API. Son las 20 publicaciones con
ficha en `catalogos/01_publicaciones/`. Doce alimentan la
L3 de la v1. Ocho se registran sin L3 todavía y son candidatas para después de la v1 (SV0-02). FRED, FMI, BM y CBO no
le sirven (SV0-05).

**Cuándo:**
- **Ventanas:** días 1 a 3 de cada mes (`make raw` completo), más la captura de UT en enero, abril, julio y octubre.
  El calendario y la última ventana cumplida están en `doc/calendario_make_raw.md`.
- **Calendario del BCR:** `doc/calendario_divulgacion_bcr.csv` anuncia día y mes de cada publicación.
  `system("make raw-calendario")` lo lee sin red y marca cada publicación `TOCA`, `NO_TOCA` o `SIN_CALENDARIO`.
- **Fuera de ventana:** una publicación del BCR se puede capturar después de publicada si cumple las condiciones de
  la sección 6.3.

## 6. Capturar

### 6.1 Ventana mensual

1. **Consola de R:** `system("make raw")`. Primero verifica L0 en disco (debe pasar) y después consulta en vivo el
   portal del BCR. Cada publicación sale como:
   - `PASS`: la fuente sirve lo mismo que ya tienes. No hay nada que hacer.
   - `CAMBIO`: hay un vintage nuevo. Se captura en el paso 2.
   - `ERROR`: la fuente no respondió o respondió algo inesperado, y `make raw` se detiene. Ver la sección 10.
   - `MANUAL_PENDIENTE`: UT, que se captura a mano (6.4).
2. Por cada `CAMBIO`, **Consola de R**: carga `src/adquisicion/bcr.R` y llama a la función de la publicación
   (anexo D) con `fecha_publicacion` = `AAAA-MM-01` del mes en que la fuente la publicó. Ejemplo:
   ```r
   source("src/adquisicion/bcr.R")
   descargar_bcr_pib_sa("2026-12-01")
   ```
   Cada función guarda el archivo en `data/L0_raw/` y agrega una fila a `data/L0_raw/manifiesto.csv` y a
   `catalogos/08_vintages.csv`. Si el `vintage_id` ya existe, `registrar_descarga()` se detiene: **no lo fuerces**;
   anótalo.
3. **Vintages intermedios.** Compara el `periodo_referencia_max` del vintage nuevo con el del anterior de la misma
   publicación en `catalogos/08_vintages.csv`. Si avanzó más de un período, se perdieron vintages que el portal ya no
   sirve: anótalo en `doc/backlog_captura_vintages.md`.
4. `system("make raw")` otra vez. Lo capturado debe salir `PASS`. Lo que siga en `CAMBIO` se movió durante la ventana y
   queda para la siguiente. **No repitas** la pasada.

### 6.2 El trimestre nuevo del PIB

Las publicaciones del PIB trimestral del BCR (`BCR.PIB_T.INDICES_VOLUMEN_ENCADENADOS_NSA`, `_SA` y `BCR.PIB_T.NOMINAL`)
se capturan como cualquier `CAMBIO`. No hay que editar `fin` ni `col_fin` de esas series en `catalogos/03_series.csv`:
el extractor lee hasta el último período del vintage vigente (F6-19).

### 6.3 Fuera de ventana (ADR-007 D3)

Solo para las 18 publicaciones del portal del BCR del anexo D, de a una. Una publicación se captura si se cumplen tres
condiciones: `make raw-rapido` la marca `NUEVO_PERIODO`; el calendario la anuncia para hoy o antes; y es el primer
vintage de ese período. No las compruebas a mano: lo hace el código. **Consola de R:**

```r
source("src/adquisicion/captura_d3.R")
planear_d3()                         # una pasada de raw-rapido; muestra qué cumple las condiciones hoy
capturar_d3("BCR.PANORAMA_BANCO_CENTRAL")   # una sola publicación del plan de hoy
nota_d3()                            # imprime la nota para doc/backlog_captura_vintages.md
```

`capturar_d3()` rechaza lo siguiente: un plan que no sea de hoy, más de una publicación, una que no cumpla las
condiciones, una ya capturada, y el reintento de una que falló ese mismo día. Para otra publicación del mismo plan,
vuelve a llamar a `capturar_d3()` con su `publicacion_id`.

### 6.4 UT (trimestral, a mano)

El `robots.txt` de ut.com.sv prohíbe la captura automática, así que se baja a mano.
1. `system("make raw")` muestra UT como `MANUAL_PENDIENTE`, con los años anteriores que no llegan a diciembre.
2. Baja un CSV por año desde el formulario de Reportes Estadísticos de UT: el año en curso (salvo en enero) y cada año
   anterior que no llegue a diciembre.
3. **Consola de R:** `source("src/adquisicion/ut.R")` y registra cada archivo con `registrar_ut_demanda_anual(ruta,
   anio)`, o varios a la vez con `registrar_ut_demanda_lote()`. La salida dice si fue vintage nuevo, fecha de captura
   por colisión o idéntico al anterior (este último no se registra).
4. Si entró el primer archivo de un año nuevo, actualiza `fin` de `UT.DEMANDA_ELEC.GWH.NSA.M` en
   `catalogos/03_series.csv`; si no, `make trace` falla.

## 7. Registrar lo capturado

### 7.1 Subir los archivos al almacén

**Consola de R:** `system("make sincronizar-l0")`. Compara `data/L0_raw/` con el almacén, sube lo nuevo con commit y
push, y verifica sha256. Se detiene ante `FALTA` o `CONFLICTO`.

### 7.2 Registrar en el repositorio

1. **Terminal:** `git status`. Solo deben haber cambiado `data/L0_raw/manifiesto.csv`, `catalogos/08_vintages.csv` y,
   si aplica, `catalogos/03_series.csv`. Los crudos no se versionan.
2. Crea una rama (por ejemplo `l0/capturas-2026-12-01`) y haz commit de esos archivos. Agrega una nota fechada en
   `doc/backlog_captura_vintages.md` que cite el commit del almacén, y los fallos de captura en
   `doc/bitacora_fuentes_fragiles.md` (con el mensaje de error, o «mensaje no conservado»).
3. Abre un PR y espera el CI en verde.
4. Después de fusionar, en tu copia, **Terminal:**
   ```
   git checkout main
   git checkout -- data/L0_raw/manifiesto.csv catalogos/08_vintages.csv
   git pull
   ```
   El `checkout --` es necesario si tu rama local quedó con esos archivos modificados: si no, `git pull` se niega a
   sobrescribirlos.

### 7.3 Mientras se captura en SIE-el-salvador: importar el registro

Después de cada PR de captura fusionado en `SIE-el-salvador`:

1. **Terminal:** `git pull` en tu copia de `SIE-el-salvador`, en la del almacén `SIE-el-salvador-L0` y en la de SIE-sv.
2. **Consola de R** (en SIE-sv): primero el plan, que no escribe nada.
   ```r
   source("src/adquisicion/importar_registro_lib.R")
   importar_registro_l0("D:/harold/Documents/SIE-el-salvador", ".", escribir = FALSE)
   ```
   Lista las filas nuevas que sirven a SIE-sv (`+`) y las ignoradas (`-`, publicaciones sin ficha en SIE-sv: FRED,
   FMI, BM y CBO). Se detiene si un `vintage_id` ya existe en SIE-sv con otro sha256, o si en el origen el manifiesto y
   `08_vintages` no coinciden.
3. Si el plan está bien:
   ```r
   importar_registro_l0("D:/harold/Documents/SIE-el-salvador", ".",
                        almacen_origen = "D:/harold/Documents/SIE-el-salvador-L0")
   ```
   Agrega las líneas tal como están en el origen y copia sus archivos a `data/L0_raw/`, con cada sha256 verificado
   contra el manifiesto. Se detiene si el almacén de origen no tiene un archivo (haz `git pull` allí) o si un sha256
   no coincide.
4. **Consola de R:** `system("Rscript scripts/check_l0_integrity.R")` y después `system("make sincronizar-l0")`, que
   sube los archivos nuevos al almacén de SIE-sv. Integridad N/N.
5. Rama, commit de `manifiesto.csv` y `08_vintages.csv`, una nota en `doc/backlog_captura_vintages.md` que cite el PR
   de origen, y PR con el CI en verde.

## 8. Reconstruir y certificar

1. **Consola de R:** `system("make validate")` → `[1] 0`.
2. **Consola de R:** `system("make master")`, **sin** `CONJUNTO=` ni `SALIDA=`. Reconstruye L1, valida L2 y escribe
   la L3 vigente con el vintage más reciente de cada publicación. Qué esperar:
   - `PIB_SA_OFICIAL_Q.csv` y `PIB_SA_PROPIO_Q.csv` ganan el trimestre nuevo.
   - `PIB_SA_PROPIO_Q.csv` (ajuste estacional propio) **revisa su historia**, porque X-13 se reestima con el dato
     nuevo. Es lo esperado, no un error.
   - Las demás series ganan los meses o trimestres de sus vintages nuevos y conservan sus valores previos, salvo que
     la fuente los haya revisado.
3. **Consola de R:** compara con la huella de la sección 4 (vuelve a definir `huella_l3()` si reiniciaste R).
   ```r
   antes <- read.csv("~/huella_l3_antes.csv")
   ahora <- huella_l3()
   x <- merge(antes, ahora, by = "archivo", all = TRUE, suffixes = c("_antes", "_ahora"))
   x[is.na(x$sha256_antes) | is.na(x$sha256_ahora) | x$sha256_antes != x$sha256_ahora, "archivo"]
   ```
   Los archivos que cambiaron tienen que ser los de las publicaciones capturadas.
4. **Consola de R:** `system("make trace")`. Rastrea cada serie hasta su celda en el archivo de L0 y debe dar 0 FAIL.
   Las filas `NO_VERIFICABLE` indican que falta un archivo en L0 (vuelve a la sección 3).
5. **Asienta la corrida de `make trace` en `doc/bitacora_verificaciones.md`**, en el mismo commit que la usa
   (regla 8): fecha, commit, archivos de L0 usados con su sha256 y el resultado (`N PASS / 0 FAIL`). Copia el formato
   de la última entrada.
6. **Consola de R:** `testthat::test_dir("tests")`.

## 9. Publicar la actualización

1. Rama (por ejemplo `actualizacion/2026-T3`) con commit de la bitácora y de lo que haya cambiado en los catálogos.
   `data/L1_staging`, `data/L2_validated` y `data/L3_master` no se versionan.
2. PR contra `main` y espera el CI en verde: validación de catálogos, pruebas y consistencia de L0. Se fusiona solo con
   el CI en verde (`CONTRIBUTING.md`).
3. Actualiza «Última ventana cumplida» en `doc/calendario_make_raw.md`.

## 10. Cuando algo falla

| Síntoma | Qué significa | Qué hacer |
|---|---|---|
| `ERROR` en `make raw` | El portal no respondió o cambió su estructura | No reintentes en bucle (regla 9). Busca la publicación en `doc/bitacora_fuentes_fragiles.md` |
| Timeout de 240 s en `filtrar()` (portal del BCR) | El portal tardó en armar la tabla. Pasa a menudo con `GOBIERNO_CENTRAL_CONSOLIDADO` y `PANORAMA_SOCIEDADES_DEPOSITO` | Déjala para la ventana siguiente y anótala en la bitácora de fuentes frágiles |
| `registrar_descarga()` se detiene porque el vintage ya existe | Ya estaba capturado | No lo fuerces; anótalo |
| `FALLO VISIBLE [materializar-l0]: ... SIE_L0_STORE no esta definida` | Falta la variable o R no se reinició | Sección 3, pasos 2 a 4 |
| `AVISO: N archivo(s) en el almacen sin fila en el manifiesto` | El almacén de SIE-sv tiene archivos que el manifiesto no registra | No borres nada; anótalo y pregunta |
| `FALTA_EN_ALMACEN` | El almacén no tiene un archivo del manifiesto | `git pull` en el almacén; si sigue, avisa |
| `FALLO VISIBLE [importar-registro]` | El registro de SIE-sv divergió del de origen | No edites nada; anótalo y pregunta |
| La L3 de UT se detiene | Un año anterior al último no trae 12 meses | Sección 6.4, paso 2 |
| `make trace` da `FAIL` | Una serie no coincide con su celda en L0 | No edites nada; anótalo y pregunta |
| `unexpected string constant` en la consola | Se pegó en la consola de R un comando de terminal (`Rscript -e '...'`) | En la consola usa `testthat::test_dir("tests")` |
| `Segmentation fault` al final de `make test` en Windows | Fallo al cerrar R, no de las pruebas | `testthat::test_dir("tests")` en la consola |

## 11. Qué no hacer nunca

- Editar `data/L0_raw/` o las capas L1 a L3 a mano.
- Capturar en SIE-sv mientras `SIE-el-salvador` no cierre su Fase 7 (sección 5).
- Agregar una serie o una fuente nueva sin preguntar (regla 4). En particular, ninguna serie de CEPAL entra sin
  resolver antes su condición sobre obras derivadas (ADR-008).
- Repetir una pasada de captura dentro de la misma ventana o evadir un bloqueo de una fuente (regla 9).

## Anexo A — Glosario

- **Vintage:** una versión publicada de una serie. Su `vintage_id` es `{publicacion_id}.v{AAAA-MM}`, por el mes de
  publicación.
- **L0 … L3:** capas de datos. L0, archivos tal como se publicaron (inmutable); L1, formato largo; L2, validación (no
  guarda datos, solo el reporte); L3, series maestras.
- **Almacén de L0:** repositorio privado con los archivos crudos. SIE-sv tiene el suyo, `hsssst00/SIE-sv-L0`
  (ADR-012); `SIE-el-salvador` usa `hsssst00/SIE-el-salvador-L0`.
- **`PASS`, `CAMBIO`, `ERROR`, `MANUAL_PENDIENTE`:** resultados de `make raw` (sección 6.1). **`NUEVO_PERIODO`:**
  resultado de `make raw-rapido`.

## Anexo B — Objetivos del `Makefile` que usa este manual

`validate`, `materializar-l0`, `sincronizar-l0`, `raw`, `raw-rapido`, `raw-calendario`, `raw-fisico`, `master`, `trace`
y `test`. Los demás (`setup`, `raw-plan`, `audit`, `clean`) no son parte de una actualización.

## Anexo C — Bitácora de la actualización

Una línea por paso: fecha y hora, sección del manual, comando, dónde se corrió (consola de R o terminal), código de
salida, duración y dudas. La bitácora no se edita después; las correcciones van como líneas nuevas.

## Anexo D — Publicaciones del portal del BCR y su función de captura

Todas están en `src/adquisicion/bcr.R` y reciben un solo argumento, `fecha_publicacion` (`"AAAA-MM-01"`). Es la tabla
`FUNCION_DESCARGA_D3` de `src/adquisicion/captura_d3_lib.R`. El tramo retropolado del PIB
(`BCR.PIB_T.SERIE_RETROPOLADA_1990_2005`) es un archivo estático de captura manual y no está en esta tabla. UT se
registra con `registrar_ut_demanda_anual()` o `registrar_ut_demanda_lote()` (sección 6.4).

| `publicacion_id` | Función |
|---|---|
| `BCR.BALANZA_COMERCIAL` | `descargar_bcr_balanza_comercial()` |
| `BCR.BALANZA_PAGOS_TRIMESTRAL` | `descargar_bcr_balanza_pagos_trimestral()` |
| `BCR.GOBIERNO_CENTRAL_CONSOLIDADO` | `descargar_bcr_gobierno_central_consolidado()` |
| `BCR.INDICES_PRECIOS_COMERCIO_EXTERIOR` | `descargar_bcr_indices_precios_comercio_exterior()` |
| `BCR.IPI.VIGENTE` | `descargar_bcr_ipi_vigente()` |
| `BCR.IPP` | `descargar_bcr_ipp()` |
| `BCR.ISI` | `descargar_bcr_isi()` |
| `BCR.ITCER` | `descargar_bcr_itcer()` |
| `BCR.IVAE.VIGENTE` | `descargar_bcr_ivae_vigente()` |
| `BCR.PANORAMA_BANCO_CENTRAL` | `descargar_bcr_panorama_banco_central()` |
| `BCR.PANORAMA_SOCIEDADES_DEPOSITO` | `descargar_bcr_panorama_sociedades_deposito()` |
| `BCR.PIB_T.INDICES_VOLUMEN_ENCADENADOS_NSA` | `descargar_bcr_pib_nsa()` |
| `BCR.PIB_T.INDICES_VOLUMEN_ENCADENADOS_SA` | `descargar_bcr_pib_sa()` |
| `BCR.PIB_T.NOMINAL` | `descargar_bcr_pib_nominal()` |
| `BCR.REMESAS_FAMILIARES_MENSUAL` | `descargar_bcr_remesas()` |
| `BCR.RESERVAS_INTERNACIONALES_NETAS` | `descargar_bcr_reservas_internacionales_netas()` |
| `BCR.SPNF_VIGENTE` | `descargar_bcr_spnf_vigente()` |
| `ONEC.IPC.BASE_2009` | `descargar_onec_ipc_base2009()` |

## Anexo E — Qué publicaciones sirven a SIE-sv

Calculado el 2026-11-22 desde `catalogos/03_series.csv`, `catalogos/05_series_master.csv` y el código de
`src/transformacion/`.

**Alimentan la L3 de la v1 (12):** `BCR.BALANZA_COMERCIAL`, `BCR.INDICES_PRECIOS_COMERCIO_EXTERIOR`, `BCR.IPP`, `BCR.ITCER`, `BCR.IVAE.VIGENTE`, `BCR.PIB_T.INDICES_VOLUMEN_ENCADENADOS_NSA`, `BCR.PIB_T.INDICES_VOLUMEN_ENCADENADOS_SA`, `BCR.PIB_T.NOMINAL`, `BCR.PIB_T.SERIE_RETROPOLADA_1990_2005`, `BCR.REMESAS_FAMILIARES_MENSUAL`, `ONEC.IPC.BASE_2009`, `UT.DEMANDA_TOTAL_MENSUAL`.

**Se registran sin L3 todavía (8), candidatas para después de la v1 (SV0-02):** `BCR.BALANZA_PAGOS_TRIMESTRAL`, `BCR.GOBIERNO_CENTRAL_CONSOLIDADO`, `BCR.IPI.VIGENTE`, `BCR.ISI`, `BCR.PANORAMA_BANCO_CENTRAL`, `BCR.PANORAMA_SOCIEDADES_DEPOSITO`, `BCR.RESERVAS_INTERNACIONALES_NETAS`, `BCR.SPNF_VIGENTE`.

**No sirven a SIE-sv:** todas las de FRED, FMI, BM y CBO. Salieron del registro en el bloque B2 (ADR-011) y
`importar_registro_l0()` las ignora.
