# Contexto del proyecto para Claude Code

## Qué es esto

SIE-sv: servicio de estadísticas macroeconómicas de El Salvador. Captura las publicaciones de las fuentes (L0), las
normaliza (L1), las valida (L2) y construye series maestras (L3), con *vintages*, manifiesto con sha256, catálogos y
trazabilidad de cada valor hasta la celda de origen. El cliente es el paquete de R `siesv`, que **reconstruye las series
en la máquina del usuario**: no se redistribuye ni L0 ni L3 (ADR-008, ADR-011). Solo se sirve lo que no se
consigue por una API (ADR-012). **Aquí no hay pronósticos.** Los
modelos y las proyecciones quedaron en `hsssst00/SIE-el-salvador`, del que este repositorio se separó el 2026-11-22
(ADR-011).

## Estado del proyecto

Fase 0 de SIE-sv cerrada el 2026-11-22 (separación; tag `v0.1.0-fase0` propuesto). La Fase 1 (núcleo `siesv`) todavía no se abre.
Senda en `doc/senda_sie_sv.md`, decisiones en `doc/metodologia/decisiones_sv_fase0.md` y tablero en
`doc/checklist_sv_fase0.md`. Las Fases 0 a 7 de `SIE-el-salvador` son historia heredada (`doc/historico/`, con sus
cierres en `doc/historico/cierres_SIE-el-salvador.md`). Ver `doc/adr/README.md` para el estado de cada ADR y ADR-011
para cuáles de los heredados siguen vigentes.

**Antes de escribir código de captura o transformación, lee los ADR vigentes en `doc/adr/`.** Son la especificación.

## Reglas no negociables

1. **Nunca edites manualmente `data/L0_raw/`.** Es inmutable. Todo archivo ahí llega vía script de descarga, con entrada correspondiente en `data/L0_raw/manifiesto.csv` (checksum SHA-256, URL, fecha, código HTTP). Excepción explícita, no una violación de la regla: la captura prospectiva de vintages inició de forma manual, antes de que existiera automatización de Fase 2 — así lo previó ADR-007 ("hasta entonces, la captura es manual"). Mientras eso dure, el requisito no negociable es el mismo manifiesto con procedencia trazable, no que el archivo haya llegado por script. Segunda excepción explícita (2026-11-22, ADR-011, bloque B2): por decisión de Harold se borraron del registro las 18 filas de FRED, FMI, BM y CBO; los archivos siguen en el almacén privado.
2. **Nunca edites los catálogos en `catalogos/` a mano fuera de lo declarado en su esquema.** Cualquier cambio de esquema pasa primero por `catalogos/datapackage.json`.
3. **Ninguna capa de datos (`L1`–`L3`) se edita directamente.** Cada una se genera por código a partir de la anterior. Si necesitas cambiar un valor derivado, cambias el código que lo genera, no el archivo.
4. **Ante una decisión metodológica no cubierta por un ADR existente, detente y pregunta.** No la resuelvas por inferencia ni la dejes implícita en el código. Esto incluye: definiciones de variables nuevas, tratamiento de datos faltantes no contemplado, elección de hiperparámetros no especificada, cualquier cosa que debería ser su propio ADR.

   **Delegaciones.** Si Harold delega, la autorización se registra aquí antes de usarse y nombra por código las fichas
   que cubre. Nunca cubre las lecturas de un criterio de cierre, los cambios posteriores a un congelamiento, los
   desvíos de un ADR cerrado ni las fichas que Harold no haya visto redactadas: esas decisiones se preguntan siempre.
   Las delegaciones de las Fases 5 a 7 de `SIE-el-salvador` terminaron y están en
   `doc/historico/CLAUDE_SIE-el-salvador.md`. La delegación de la Fase 0 de SIE-sv (2026-11-22: el agente ejecutó los
   bloques B y C; detalles rotulados «delegada al agente; se puede reabrir») terminó con su cierre, el 2026-11-22. Desde
   ahí la regla 4 rige sin excepciones.

   **Bloques nuevos (2026-11-23, auditoría independiente de la Fase 0 de SIE-sv, hallazgo I1).** Una delegación
   cubre solo los bloques o fichas que nombra al registrarse. Un bloque que se agrega después al checklist (como C2
   en la Fase 0) queda fuera hasta que se registre aquí. Lo que haga falta fijar antes de registrar una delegación
   se pregunta.
5. **El stack es R, cerrado (ADR-009).** No introduzcas Python u otro lenguaje salvo que exista un ADR posterior que lo autorice explícitamente.
6. **Todo script de descarga (`src/adquisicion/`) debe fallar de forma visible, no silenciosa**, ante cambios de estructura de la fuente — conforme al principio de inmutabilidad de L0.
7. **La validación falla, no advierte** (§3.5 de la senda metodológica heredada, `doc/historico/senda_metodologica.md`). Un catálogo que no cumple su esquema detiene el pipeline.
8. **Toda corrida de `src/validacion/verificar_fuente_celda.R` se asienta en
   `doc/bitacora_verificaciones.md`**, en el mismo commit en que se usa su resultado. El
   verificador no corre en CI (los `.xlsx` están en `.gitignore`, ver ADR-008): esa bitácora es
   su única evidencia. Una entrada corresponde a una corrida real, nunca a la intención de
   correrla.
9. **Ningún mecanismo de captura desatendido (`chromote` u otro, ver ADR-009) se usa para
   scraping de volumen.** Captura solo lo necesario, al ritmo real de publicación de cada
   fuente (trimestral para el PIB, mensual para la mayoría de series del BCR, etc.) — nunca
   como recolección exhaustiva o repetida más allá de lo que la actualización del catálogo
   exige. Que un mecanismo evada técnicamente una restricción (ej. detección de bots, o el
   propio `robots.txt`) no es motivo para ignorarla: la posibilidad técnica no es la pregunta
   relevante bajo esta regla. Decisión de Harold, 2026-08-20.

## Consideraciones sobre fuentes de datos

> **Nota (2026-11-25, auditoría independiente de la Fase 0 de SIE-sv, hallazgo M3).** MH salió del catálogo con
> ADR-012. Lo que sigue queda como antecedente para cuando se evalúe una fuente de `doc/pendientes_fuentes.md`.

- **Ministerio de Hacienda (MH): sin repositorio sistemático.** A diferencia del BCR (URLs `/serie/` individuales por publicación, mismo patrón estructural), el Portal de Transparencia Fiscal (PTF) expone múltiples tablas estáticas como widgets independientes dentro de una misma página HTML (ej. `PTF2-Ingresos.html`), cada una con su propia fecha de "Actualizado" y sin API ni endpoint por serie. Confirmado empíricamente (2026-08-11): 4 tablas en esa página con fechas de actualización entre sep-2019 y jun-2026. Trata cada tabla de Hacienda como un artefacto aislado que requiere verificación individual — la vigencia de una tabla en esa página NO implica la vigencia de otra. Consecuencia de diseño ya aplicada: BCR es la fuente primaria sobre Hacienda para series con equivalente (ver notas cruzadas en `01_publicaciones` y en `00_instituciones.csv`, entrada MH).

## Convenciones (senda metodológica heredada §3.4)

- Identificadores legibles y estables: `{fuente}.{concepto}.{unidad}.{ajuste}.{frecuencia}` — ej. `BCR.PIB.VOL.SA.Q`. Sufijo adicional opcional tras `{frecuencia}` para distinguir un tramo de captura distinta de la misma serie conceptual — ej. `BCR.PIB.VOL.NSA.Q.RETRO` (tramo retropolado) — ver `doc/historico/senda_metodologica.md` §3.4.
- Períodos en ISO 8601: `2024-Q3`, `2024-07`.
- UTF-8, separador decimal punto, sin separador de miles, ausentes como celda vacía (nunca `0`, `-`, `n.d.`).
- `snake_case` en nombres de campo, sin acentos ni espacios.
- Cada directorio de catálogo lleva su propio `README.md` con diccionario de variables.

## Comandos

Ver `Makefile`. Objetivos: `setup`, `raw`, `raw-rapido`, `raw-calendario`, `raw-fisico`, `raw-plan`,
`materializar-l0`, `sincronizar-l0`, `master`, `validate`, `trace`, `test`, `audit` y `clean`.

- `make raw-rapido`: precheck barato del portal del BCR (nivel 1 por calendario, nivel 2 por sondeo del último
  período). `make raw-calendario` es solo el nivel 1, sin red. No reemplaza a `make raw`. Una pasada por ventana
  (regla 9).
- `make materializar-l0`: repuebla `data/L0_raw/` desde el almacén privado de SIE-sv (`hsssst00/SIE-sv-L0`,
  `SIE_L0_STORE`; ADR-012) y verifica la integridad. `make sincronizar-l0` sincroniza en las dos direcciones después
  de capturar. Mientras `SIE-el-salvador` no cierre su Fase 7, la captura se hace allá y se importa con
  `scripts/importar_registro_l0.R` (manual, sección 7.3).
- `make master`: L0 → L1 → L2 → L3. Con `CONJUNTO=<csv> SALIDA=<dir>` construye desde un conjunto declarado de
  *vintages*, sin tocar las capas vigentes.
- `make audit`: resumen de orientación (conteos, integridad referencial, L0 y *vintages*, ADR, auditorías y
  licencias). No es validación y no detiene nada.

## Stack (ADR-009)

R vía `renv`. `renv.lock` está fijado y verificado en CI sobre `ubuntu-24.04`. `DESCRIPTION` es la fuente de los
paquetes declarados; no se transcriben aquí. Los paquetes de modelos salieron en la Fase 0 de SIE-sv (notas en ADR-009).
`scripts/bootstrap_renv.R` documenta cómo se genera el lockfile.

## Orden de fases (no te lo saltes)

Fase 0 de SIE-sv (separación) → 1 (núcleo `siesv`) → 2 (cliente) → 3 (referencia publicada) → 4 (prueba externa y
v1.0.0). El criterio de cierre de cada una está en `doc/senda_sie_sv.md`.

## Guards de CI activos

- `tests/test-adr-indice.R`: la celda Estado del índice de ADR es copia literal de la línea `**Estado:**` de cada ADR.
  CLAUDE.md y README.md declaran el estado de la última fase de SIE-sv que certifica el índice, y `CITATION.cff` lleva
  la versión y la fecha de ese cierre (0.0.x antes del primero).
- `tests/test-integridad-referencial.R`: aristas de clave foránea entre catálogos.
