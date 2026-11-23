# Checklist de la Fase 0 de SIE-sv — Separación

Criterio de cierre (senda de SIE-sv): SIE-sv no tiene código de pronósticos y el CI está en verde. `make master`
reconstruye la L3 vigente y cada CSV de las familias de la v1 tiene el mismo sha256 que en `SIE-el-salvador` sobre la
misma L0.

## A. Apertura
- [x] Repositorio `hsssst00/SIE-sv` creado; `main` = `SIE-el-salvador@7cbca83`, sin tags.
- [x] ADR-011, senda de SIE-sv y registro de decisiones SV0-01..SV0-09 (este PR).
- [x] Harold fusiona el PR de apertura (#1, 2026-11-22).

## B. Retiro de pronósticos

B1 (código de modelos, PR #2) y B2 (escenarios y fuentes externas, PR #3).
- [x] B1. Salen `src/modelos`, `src/evaluacion`, `src/proyeccion`, `src/analisis`, `src/analisis_posterior` y
  `src/reportes`, 34 pruebas y cinco scripts (`armar_corte_fase6`, `armar_preregistro_fase6`, `evidencia_insumos_fase4`,
  `referencia_paridad_bvar` y `verificar_corte_g6`).
- [x] B2. Salen las transformaciones de escenarios (`extraer_escenarios.R`, `l3_escenarios*.R` y su prueba), la captura
  de FRED, FMI, BM y CBO (`fred.R`, `fmi.R`, `bm.R` y `cbo.R`), el alcance `api` de `verificar_l0.R` (`make raw-api`) y
  `FRED_API_KEY` de `.Renviron.example`. **Las filas se borran del registro** por decisión de Harold (2026-11-22; nota en
  ADR-011): 18 de L0 y 08_vintages, 22 publicaciones, 11 series, 11 series maestras, 9 transformaciones y 4 instituciones.
  `httr2` y `tempdisagg` salen de `DESCRIPTION`.
- [ ] Limpiar en `conjunto_lib.R` la lógica de la etapa de escenario (`publicaciones_de_escenario()` y
  `etapa_escenario_activa()`). Sin series de rol `escenario` ya no se activa nunca; se hace en la Fase 1, al mover el
  código a `siesv`.
- [x] B1. Salen de `Makefile` los objetivos de exploración, evaluación, proyección y fases 5 y 6. El mecanismo
  `CONJUNTO=`/`SALIDA=` de `make master` **se queda**: construye L1–L3 desde un conjunto de *vintages* declarado y sirve
  al servicio de datos (SV0-03). Detalle delegado al agente; se puede reabrir.
- [x] B1. CI: sale el paso `verificar_motor_sintetico.R`.
- [x] B1. `DESCRIPTION`, `bootstrap_renv.R` y `renv.lock`: salen los 13 paquetes de modelos (nota en ADR-009).
- [x] `renv::snapshot()` (Harold, en su PC, sobre `a08ebf1`): salen 50 dependencias transitivas huérfanas y quedan 125
  paquetes, sin altas ni cambios de versión. Además completa los campos de 26 registros que estaban incompletos.
- [x] B1. Salen los catálogos `06_modelos` (58 YAML) y `07_experimentos.csv`, de `datapackage.json`, de
  `catalogos/README.md` y del conteo de `auditoria_mecanica.R`.

## C. Historia heredada
- [x] Pasan a `doc/historico/` 90 documentos de `SIE-el-salvador`, como renombres al 100 % y sin editar: senda,
  checklists 3–7, evidencias, auditorías, y decisiones, protocolos, preregistros, cortes y reportes de las Fases 3–7.
  Los cierres de las Fases 0–6 salen del índice de ADR a `doc/historico/cierres_SIE-el-salvador.md`. El README y el
  CLAUDE.md viejos se guardan completos. Las referencias en código, catálogos, ADR y manual apuntan a las rutas
  nuevas; las bitácoras y el backlog conservan las rutas de cada entrada, porque son registros fechados. Quedan en su
  lugar: `doc/adr/`, `doc/auditorias/` (para las de SIE-sv), bitácoras, calendarios, `entorno_windows.md`,
  `captura_bcr_livewire_hallazgo.md`, `manual_actualizacion.md` y `metodologia/empalme_cuentas_nacionales.md`.
  Delegada al agente; se puede reabrir.
- [x] `tests/test-adr-indice.R` cuenta solo «## Cierre de Fase N de SIE-sv». Sin cierres, exige «Fase 0 de SIE-sv
  abierta» en README y CLAUDE.md y una versión 0.0.x en `CITATION.cff`. El tag de cierre acepta `vX.Y.Z-faseN` o
  `vX.Y.Z-sv-faseN`.
- [x] Se reescriben `README.md`, `CLAUDE.md` (reglas 1–9 intactas, más la excepción B2 en la regla 1 y la delegación
  vigente en la regla 4), `CITATION.cff` (título y resumen nuevos, versión 0.0.0, repositorio SIE-sv) y
  `CONTRIBUTING.md`.
- [x] Se reescribe `doc/manual_actualizacion.md` para SIE-sv. Incorpora los defectos del ensayo 2026-T2 (consola o
  terminal en cada comando, `SIE_L0_STORE`, captura D3 en dos llamadas, mensajes de `renv`) y la regla de transición:
  mientras `SIE-el-salvador` no cierre su Fase 7, se captura allá y SIE-sv importa las filas que le sirven con
  `scripts/importar_registro_l0.R` (decisión de Harold, 2026-11-22). Anexo E: qué publicaciones sirven a SIE-sv.

## C2. Alcance y almacén propio (ADR-012, 2026-11-22)
- [x] Criterio de alcance: SIE-sv sirve solo lo que no se consigue por una API.
- [x] Catálogo recortado a las 20 publicaciones que se capturan: salen 45 fichas (a `doc/pendientes_fuentes.md`), 2
  metodologías de deuda pública, 3 rupturas (R007, R012, R014) y 5 instituciones (MH, SECMCA, ISSS, CEPAL, BID). En 6
  rupturas, `series_afectadas` conserva solo lo que se queda.
- [x] Almacén privado propio `hsssst00/SIE-sv-L0`: 79 archivos copiados de `SIE-el-salvador-L0`, con sha256
  verificados contra el manifiesto. `.Renviron.example`, el manual, README y CLAUDE.md apuntan a él.
- [x] `importar_registro_l0()` también copia los archivos desde el almacén de origen (sha256 verificado); después,
  `make sincronizar-l0` los sube al almacén de SIE-sv.
- [x] Harold clona `hsssst00/SIE-sv-L0` y cambia `SIE_L0_STORE` en su `.Renviron` de SIE-sv (2026-11-22; `make
  materializar-l0` → 79/79 PASS).

## D. Verificación
- [x] `make master` en SIE-sv sobre la misma L0: los sha256 de los CSV de las familias de la v1 coinciden con los de
  `SIE-el-salvador` (2026-11-22, 19/19; procedimiento y sha256 en `doc/evidencia_verificacion_sv_fase0.md`).
- [x] CI en verde: `main` en `405b1a4`, run 45083384498 (`success`).

## E. Cierre
- [x] «Cierre de Fase 0 de SIE-sv» en el índice de ADR, propagado a README, CLAUDE.md y CITATION.cff (0.1.0).
- [ ] Revisión independiente en `doc/auditorias/` y tag `v0.1.0-fase0` (Harold).
