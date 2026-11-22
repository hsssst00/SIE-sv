# Checklist de la Fase 0 de SIE-sv — Separación

Criterio de cierre (senda de SIE-sv): SIE-sv no tiene código de pronósticos y el CI está en verde. `make master`
reconstruye la L3 vigente y cada CSV de las familias de la v1 tiene el mismo sha256 que en `SIE-el-salvador` sobre la
misma L0.

## A. Apertura
- [x] Repositorio `hsssst00/SIE-sv` creado; `main` = `SIE-el-salvador@7cbca83`, sin tags.
- [x] ADR-011, senda de SIE-sv y registro de decisiones SV0-01..SV0-09 (este PR).
- [ ] Harold fusiona el PR de apertura.

## B. Retiro de pronósticos (PR aparte)
- [ ] Sacar `src/modelos`, `src/evaluacion`, `src/proyeccion`, `src/analisis`, `src/analisis_posterior` y `src/reportes`
  si solo sirven a los pronósticos, junto con sus pruebas.
- [ ] Sacar las transformaciones de escenarios (`extraer_escenarios.R`, `l3_escenarios*.R`) y la captura FRED, FMI y CBO
  (SV0-05).
- [ ] Sacar los objetivos de `Makefile` de evaluación, proyección y corte congelado (`CONJUNTO`).
- [ ] CI: sacar el paso `verificar_motor_sintetico.R`.
- [ ] `DESCRIPTION` y `renv.lock`: sacar fable, fabletools, tsibble, vars, tsDyn, BVAR, midasr, glmnet, ranger,
  lightgbm, urca, MCS y scoringRules, si nada de lo que queda los usa.
- [ ] Catálogos `06_modelos` y `07_experimentos`: retirar, ajustando `datapackage.json` y `validate_catalogs.R`.

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
