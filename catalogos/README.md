# Catálogos

Puerta de entrada legible a los catálogos del proyecto (convención de `CLAUDE.md`, §Convenciones:
"cada directorio de catálogo lleva su propio README.md con diccionario de variables" — ausente
hasta esta remediación, hallazgo M4 de la revisión independiente 2026-09-17).

El esquema formal, machine-readable, es `datapackage.json` (Frictionless Data Table Schema) —
tipos, `required`/`unique`/`enum` y las dos foreign keys declaradas. Este README no lo duplica
campo por campo salvo cuando el nombre del campo por sí solo no basta para entenderlo; para el
detalle exacto de una restricción, `datapackage.json` es la fuente de verdad. Ningún catálogo
aquí se edita a mano fuera de lo que su esquema declara (regla 2, `CLAUDE.md`); cualquier cambio
de esquema pasa primero por `datapackage.json`.

## `00_instituciones.csv`

Una fila por institución fuente (BCR, ONEC/MH, FMI, etc.). `institucion_id` es la clave que
referencian `01_publicaciones/*.yaml`.

## `01_publicaciones/` (directorio de YAML, uno por publicación)

Una publicación es una tabla o serie identificable en la fuente (ej. `BCR.IVAE.VIGENTE`). Campos
(ver `_plantilla.yaml`): `publicacion_id`, `institucion_id` (FK a `00_instituciones`), `nombre`,
`periodicidad` (trimestral | mensual | anual), `formato` (xlsx | csv | pdf | api), `url`,
`cobertura_temporal`, `condiciones_uso` (ADR-008 — pendiente para fuentes distintas de BCR),
`notas`.

**Nota de SIE-sv (2026-11-25, auditoría independiente de la Fase 0 de SIE-sv, hallazgos M3 y M4).** Desde ADR-012
quedan 20 fichas. Algunas nombran en `notas` una publicación predecesora que salió del catálogo (por ejemplo,
`BCR.IPP` cita `BCR.IPRI.BASE_1990`): esas publicaciones están en `doc/pendientes_fuentes.md`, y sus fichas completas,
en `SIE-el-salvador`. El campo `condiciones_uso` conserva el texto de agosto de 2026: las 18 fichas del BCR dicen «En
gestión» con corte el 2026-10-12, y la de UT, «No verificado». El estado vigente por fuente es la línea **Estado:** de
ADR-008: el corte del BCR venció sin pronunciamiento (default conservador) y UT quedó resuelta el 2026-09-16.

## `02_metodologias/` (directorio de YAML, uno por marco metodológico)

Un marco metodológico con vigencia temporal (ej. `SCN2008`). Campos (ver `_plantilla.yaml`):
`metodologia_id`, `nombre`, `vigencia_desde`/`vigencia_hasta` (vacío si no determinada / si sigue
vigente), `documento_referencia`, `predecesor_id`/`sucesor_id` (encadenan metodologías que se
sustituyen entre sí — ambos vacíos si no aplica), `notas`.

## `03_series.csv`

Una fila por serie admitida al proyecto — la unidad atómica de dato (ej. `BCR.PIB.VOL.SA.Q`).
`serie_id` sigue la convención `{fuente}.{concepto}.{unidad}.{ajuste}.{frecuencia}` (senda
§3.4). Campos que no son autoexplicativos por el nombre:

- `unit_mult`: multiplicador de la unidad publicada (ej. `1`, `1000000` si la fuente publica en
  millones).
- `adjustment`: ajuste declarado por la fuente sobre la serie misma — `SA` (desestacionalizada
  por la fuente), `NSA` (sin ajustar) — no confundir con el ajuste que este proyecto pueda
  aplicar en L3 (ver `04_transformaciones.csv`).
- `base_year` / `anio_referencia_indice`: año base del índice cuando `unit_measure` es un índice
  (ej. `2005`).
- `fuente_celda`, `hoja`, `fila_dato`, `col_inicio`, `col_fin`, `fila_anios`, `fila_trimestres`:
  ubicación mecánica de la celda en el archivo de L0 (hoja de cálculo, fila de datos, rango de
  columnas, fila de años y fila de trimestres/meses) — lo que permite a un extractor de
  `src/transformacion/` leer la celda sin volver a parsear `fuente_celda` en texto libre. Ver
  cualquier `extraer_bcr_*.R` para el uso real de estos seis campos.
  **Nota (2026-10-20, F6-19).** `col_fin` (igual que `fin` y el rango que cita `fuente_celda`) es la columna final
  del vintage en que se registró la serie. Los extractores ya no leen hasta `col_fin`: leen cada vintage hasta la
  columna cuyo encabezado es su `periodo_referencia_max` en `08_vintages.csv` (`src/transformacion/fin_lectura_lib.R`).
  Una captura nueva no cambia `03`.
  **`fila_dato` es el índice de fila según `readxl`, no la fila física de Excel.** Cuando una
  hoja tiene filas iniciales sin ninguna celda (`<row/>` vacía), `readxl` las omite y el resto
  queda corrido: hoy difieren en las 13 series `*.RETRO`, con desfase +1, porque las hojas
  T1/T2 de `BCR_pib_t_retropolado_1990_2005_2026-08-06.xlsx` tienen la fila 1 vacía. La
  explicación completa —y por qué el verificador lee con la misma librería que el extractor—
  está en la cabecera de `src/validacion/verificar_fuente_celda.R`.

FKs (`datapackage.json`): `publicacion_id` → `01_publicaciones`, `metodologia_id` →
`02_metodologias`. Nota: estas dos FKs no son resolubles por un validador Frictionless genérico
(`01_publicaciones/`/`02_metodologias/` son directorios de YAML, no un recurso tabular único) —
`src/validacion/validar_integridad_catalogos.R` las cubre igual, corriendo en `make validate`
junto a `validate_catalogs.R` (esquema de columnas). La única arista que ninguno de los dos
cubre es la de `01_publicaciones/*.yaml` hacia sí mismo, que se queda en
`tests/test-integridad-referencial.R` (ver su cabecera).

## `04_transformaciones.csv`

Una fila por transformación L1→L3 — es la especificación ejecutable que
`src/transformacion/l3_predictores.R` recorre y resuelve con `match.fun()` (no una bitácora
paralela al código; desde 2026-10-19 también `src/transformacion/l3_escenarios.R`, cada uno con las
filas cuyo `script_path` es él, y en este segundo `series_insumo` lleva hasta 3 series: historia,
crecimiento o nivel anual del WEO y desvío del escenario). `series_insumo` es una lista separada por comas de `serie_id` (1 o 2);
`funcion` nombra una función de `src/transformacion/*_reglas.R` con la firma
`fn(insumo(s), etiqueta)`. `reversible` documenta si `valor_producto` puede reconstruir
`valor_insumo` exactamente (ver `notas` de cada fila para el porqué).

**Nota de SIE-sv (2026-11-25, auditoría independiente de la Fase 0 de SIE-sv, hallazgo M4).** `l3_escenarios.R` y
`extraer_escenarios.R` ya no existen (bloque B2). Las 11 filas que quedan tienen `script_path`
`src/transformacion/l3_pib_objetivo.R` (T001 y T002) o `src/transformacion/l3_predictores.R` (T003 a T011).

## `05_series_master.csv`

Una fila por serie que entra a la matriz de modelado (Fase 4+). `series_master_id` es el
identificador que usará el motor de evaluación; `rol` distingue `target_primary` /
`target_robustness` / `predictor`. `linaje_l0` documenta de qué archivo(s) de `data/L0_raw/`
desciende la serie, vía `transf_id` → `04_transformaciones.csv` → `series_insumo`.

**Nota de SIE-sv (2026-11-25, auditoría independiente de la Fase 0 de SIE-sv, hallazgo M3).** «Matriz de modelado» y
«motor de evaluación» describen el uso que tenía `SIE-el-salvador`. En SIE-sv, las 19 filas son las 18 series de L3 de
la v1 (SV0-02) y un insumo intermedio (`PIB.NSA.CONCAT.Q`); los roles conservan sus nombres. La nota de B2 de abajo
vale para las dos notas que le siguen (F6-18 y F6-10): las dos son históricas, y «Hoy es una» se refiere a
`SIE-el-salvador` antes de la separación.

**Nota de SIE-sv (2026-11-22, ADR-011, bloque B2).** En SIE-sv no quedan series de rol `escenario` ni `referencia`, ni sus
transformaciones T012, T013 y T014: salieron con FRED, FMI, BM y CBO. El vocabulario se conserva en `datapackage.json`, y la
nota siguiente es histórica.

**Nota (2026-10-19, Fase 6, F6-18).** `rol` admite además `escenario` (y `intermediate`, ya en el
esquema): variables exógenas de la proyección condicional, fuera de la matriz de predictores de Fase 5.
Son la historia trimestral del PIB y del IPC de EE. UU. y del petróleo en USD, y las series
`ESC.<variable>.<unidad>.<ajuste>.Q.<ESCENARIO>` (historia + sendero hasta 2031-Q4, con columna
`tramo` en L3; el sufijo nombra el escenario, F6-18-a). Las construye
`src/transformacion/l3_escenarios.R` a partir de `src/transformacion/extraer_escenarios.R`, que son
también filas de `04_transformaciones.csv` (T012, T013 y las siete `T014_SENDERO_ESCENARIO_*`, una
por serie producto). Una publicación de `03_series.csv` que solo alimenta series de rol `escenario`
es «publicación de escenario» (`publicaciones_de_escenario()` en `conjunto_lib.R`): un conjunto de
vintages las declara todas o ninguna (F6-18-d), y `corte_fase5.csv` no declara ninguna.

**Nota (2026-10-22, Fase 6, F6-10).** `rol` admite además `referencia`, por decisión de Harold: una cifra
publicada que solo sirve de comparación informativa en la coherencia de Fase 6 y no entra a ningún modelo ni
sendero. Hoy es una: `FMI.PIB_SLV_VAR.PCT.NSA.A` (`SLV.NGDP_RPCH` del WEO), un pass-through anual que
materializa `src/transformacion/l3_escenarios.R`. Para `publicaciones_de_escenario()` cuenta como `escenario`:
comparte la publicación `FMI.WEO` y la misma etapa.

## `08_vintages.csv`

Una fila por captura (vintage) de una publicación en un momento dado — la unidad que hace
posible la evaluación pseudo-real-time de Fase 4. `archivo_raw` referencia `data/L0_raw/` y su
entrada en `data/L0_raw/manifiesto.csv`; `sha256`/`sha256_norm` son los dos checksums (archivo
crudo y contenido normalizado) que sostienen la trazabilidad de la regla 1 de `CLAUDE.md`.

## `09_rupturas.csv`

Una fila por ruptura conocida en una serie o publicación (cambio de metodología, rebase de
índice, recodificación) — `tipo_referencia` distingue si `series_afectadas` contiene `serie_id`
(→ `03_series.csv`) o `publicacion_id` (→ `01_publicaciones/`).
