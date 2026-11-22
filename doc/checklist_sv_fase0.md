# Checklist de la Fase 0 de SIE-sv — Separación

Criterio de cierre (senda de SIE-sv): SIE-sv no tiene código de pronósticos y el CI está en verde. `make master`
reconstruye la L3 vigente y cada CSV de las familias de la v1 tiene el mismo sha256 que en `SIE-el-salvador` sobre la
misma L0.

## A. Apertura
- [x] Repositorio `hsssst00/SIE-sv` creado; `main` = `SIE-el-salvador@7cbca83`, sin tags.
- [x] ADR-011, senda de SIE-sv y registro de decisiones SV0-01..SV0-09 (este PR).
- [ ] Harold fusiona el PR de apertura.

## B. Retiro de pronósticos

B1 (código de modelos; este PR) y B2 (escenarios y fuentes externas; pendiente de decidir qué pasa con sus filas
en el registro de L0).
- [x] B1. Salen `src/modelos`, `src/evaluacion`, `src/proyeccion`, `src/analisis`, `src/analisis_posterior` y
  `src/reportes`, 34 pruebas y cinco scripts (`armar_corte_fase6`, `armar_preregistro_fase6`, `evidencia_insumos_fase4`,
  `referencia_paridad_bvar` y `verificar_corte_g6`).
- [ ] B2. Sacar las transformaciones de escenarios (`extraer_escenarios.R`, `l3_escenarios*.R`) y la captura FRED, FMI y CBO
  (SV0-05).
- [x] B1. Salen de `Makefile` los objetivos de exploración, evaluación, proyección y fases 5 y 6. El mecanismo
  `CONJUNTO=`/`SALIDA=` de `make master` **se queda**: construye L1–L3 desde un conjunto de *vintages* declarado y sirve
  al servicio de datos (SV0-03). Detalle delegado al agente; se puede reabrir.
- [x] B1. CI: sale el paso `verificar_motor_sintetico.R`.
- [x] B1. `DESCRIPTION`, `bootstrap_renv.R` y `renv.lock`: salen los 13 paquetes de modelos (nota en ADR-009).
- [ ] `renv::snapshot()` para podar las dependencias transitivas que quedaron sin uso.
- [x] B1. Salen los catálogos `06_modelos` (58 YAML) y `07_experimentos.csv`, de `datapackage.json`, de
  `catalogos/README.md` y del conteo de `auditoria_mecanica.R`.

## C. Historia heredada
- [ ] Llevar a `doc/historico/` lo de las fases 0–7 de `SIE-el-salvador` (decisiones, checklists, evidencias,
  auditorías, senda). Las auditorías de las fases 0–3 cubren la capa de datos y conviene dejarlas citadas.
- [ ] Adaptar `tests/test-adr-indice.R` para que cuente los cierres «de SIE-sv» y no los heredados.
- [ ] Reescribir `README.md`, `CLAUDE.md`, `CITATION.cff` y `CONTRIBUTING.md` para SIE-sv.

## D. Verificación
- [ ] `make master` en SIE-sv sobre la misma L0: los sha256 de los CSV de las familias de la v1 coinciden con los de
  `SIE-el-salvador`.
- [ ] CI en verde.

## E. Cierre
- [ ] «Cierre de Fase 0 de SIE-sv» en el índice de ADR, revisión independiente y tag (nombre a decidir).
