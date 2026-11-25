# Registro de decisiones de arquitectura (ADR)

Proyecto: SIE-sv — servicio de estadísticas macroeconómicas de El Salvador (derivado de `SIE-el-salvador`, ADR-011)

Cada decisión fundacional (D1–D8, senda metodológica §2) se registra como un ADR independiente, más D9 (stack tecnológico) y D10 (transformaciones L3 de la matriz de predictores), adiciones propias del proyecto no enumeradas en §2 — ver ADR-009 y ADR-010. ADR-011 y ADR-012 son propios de SIE-sv. La «senda metodológica» que cita este párrafo es la heredada (`doc/historico/senda_metodologica.md`). Formato: contexto, alternativas consideradas, decisión, consecuencias. Un ADR se enmienda, no se reescribe, cuando una decisión posterior lo afecta.

| ADR | Decisión | Estado |
|---|---|---|
| [001](./ADR-001-variable-objetivo.md) | Definición operativa de la variable objetivo | Cerrado |
| [002](./ADR-002-horizonte-y-diseno.md) | Horizonte y diseño de los dos ejercicios | Cerrado |
| [003](./ADR-003-empalme-cuentas-nacionales.md) | Tratamiento del empalme de cuentas nacionales | Cerrado |
| [004](./ADR-004-shock-2020.md) | Tratamiento de quiebres estructurales y shock de 2020 | Cerrado |
| [005](./ADR-005-soporte-catalogos.md) | Soporte tecnológico de los catálogos | Cerrado |
| [006](./ADR-006-vocabulario-metadatos.md) | Vocabulario de metadatos | Cerrado |
| [007](./ADR-007-politica-vintages.md) | Política de versiones de publicación (vintages) | Cerrado |
| [008](./ADR-008-licencias.md) | Licencias y condiciones de redistribución | Cerrado — en SIE-sv no queda ningún tramo abierto (nota del 2026-11-25). La condición de CEPAL sobre obras derivadas aplica si una serie de CEPAL se propone para SIE-sv. Estado por fuente en las enmiendas. |
| [009](./ADR-009-stack-tecnologico.md) | Stack tecnológico | Cerrado |
| [010](./ADR-010-transformaciones-l3-predictores.md) | Método de transformación L3 de la matriz de predictores (desagregación temporal, deflactación, outliers, ajuste estacional) | Cerrado |
| [011](./ADR-011-origen-y-alcance-sie-sv.md) | Origen y alcance de SIE-sv (repositorio nuevo, sin pronósticos; cliente `siesv`) | Cerrado |
| [012](./ADR-012-alcance-fuentes-sin-api.md) | Alcance de SIE-sv: fuentes sin API, catálogo de lo que se sirve y almacén propio | Cerrado |

> **Regla de este índice.** La celda "Estado" de cada fila es copia literal de la línea
> `**Estado:**` del ADR correspondiente. Si divergen, el ADR manda y el índice está
> desactualizado. Se verifica con un `grep`; en Fase 3 corresponde un `test_that()` que
> lo compruebe automáticamente.

**Estado general (SIE-sv, 2026-11-25):** doce de doce ADR cerrados; ADR-008 se cerró para SIE-sv el 2026-11-25 (enmienda en el propio ADR). **Historia heredada de `SIE-el-salvador`:** nueve de diez ADR cerrados. Solo ADR-008 quedaba parcial. Su alcance pendiente se redujo en tres tandas. El 2026-08-12: los tramos FMI y FRED quedaron resueltos con el default conservador, y el tramo Banco Mundial quedó relevado con decisión aplazada. El 2026-08-17: el tramo ISSS quedó resuelto por decisión de no perseguir esclarecimiento —no por relevamiento pendiente—, se abrió el tramo CEPAL con consulta enviada y fecha de corte 2026-10-16, y se registró el tramo BID, enganchado al mismo disparador que el del Banco Mundial. El 2026-08-18: los tramos MH, ONEC/DIGESTYC y SECMCA quedaron resueltos por decisión de no perseguir esclarecimiento, mismo patrón que ISSS. La decisión entre una política única de L0 y una por fuente, aplazada hasta el corte del BCR (2026-10-12), se tomó el 2026-10-14: política por fuente. El 2026-10-17 se registró el tramo CBO (Fase 6), resuelto por dominio público; el estado vigente por fuente es la línea **Estado:** de ADR-008. El corte de CEPAL (2026-10-16) venció sin pronunciamiento, y se registró el 2026-10-19 (default conservador; queda abierta la condición sobre obras derivadas).

ADR-007 y ADR-009 permanecen cerrados y llevan, desde el 2026-08-12, notas de seguimiento con disparador explícito: clientes de API externa en ADR-009 (se decide antes del primer *script* de `src/adquisicion/` que consuma una API), y alcance de *vintages* de predictores externos en ADR-007 (fuera del núcleo mínimo viable).

El 2026-09-24, la planificación de Fase 4 agregó notas a seis ADR sin reabrir ninguno:
aclaración de la convención de indexación del origen en ADR-002; enmienda del vintage de
referencia del ejercicio retrospectivo en ADR-001, con referencia cruzada en ADR-007;
seguimiento del ajuste estacional del objetivo dentro de cada origen en ADR-004, con referencia
cruzada en ADR-001; dependencias del motor de evaluación en ADR-009; y unidad de modelación de
las predictoras en ADR-010. Los diez siguen con el mismo estado.

**Nota de SIE-sv (2026-11-25, auditoría independiente de la Fase 0 de SIE-sv, hallazgo M2).** Los tres párrafos
anteriores son la historia de `SIE-el-salvador` hasta el 2026-11-19. En SIE-sv, FMI, FRED, Banco Mundial y CBO
salieron en el bloque B2 (ADR-011), y MH, SECMCA, ISSS, CEPAL y BID con ADR-012. SIE-sv no consume ninguna API
(ADR-012): el disparador de ADR-009 sobre clientes de API externa no tiene objeto mientras ADR-012 rija. «Los diez»
son ADR-001 a ADR-010; ADR-011 y ADR-012 se agregaron el 2026-11-22.

## Historia heredada de SIE-el-salvador

Los cierres de las Fases 0 a 6 de `SIE-el-salvador`, con sus sprints y remediaciones, están en
[`doc/historico/cierres_SIE-el-salvador.md`](../historico/cierres_SIE-el-salvador.md). Sus tags (`v0.1.0-fase0` a
`v0.9.1-fase6`) existen solo en ese repositorio. Desde el 2026-11-22, en este índice se registran solo los cierres de
SIE-sv, con encabezado «## Cierre de Fase N de SIE-sv (AAAA-MM-DD)». `tests/test-adr-indice.R` cuenta solo esos.

## Cierre de Fase 0 de SIE-sv (2026-11-22)

**Criterio de cierre de la Fase 0 de SIE-sv (`doc/senda_sie_sv.md`): SATISFECHO.** «SIE-sv no tiene código de
pronósticos y el CI está en verde. `make master` reconstruye la L3 vigente y cada CSV de las familias de la v1 tiene el
mismo sha256 que en `SIE-el-salvador` sobre la misma L0». Lecturas, decididas por Harold el 2026-11-22: «la L3 vigente»
es lo que `make master` sin `CONJUNTO` escribe en `data/L3_master/`; «las familias de la v1» son las de SV0-02, que dan
19 CSV (18 series y `PIB_SA_PROPIO_Q_outliers.csv`); «sobre la misma L0» quiere decir los mismos archivos, por sha256,
de los vintages que usó esa L3 (36 vintages de 12 publicaciones), pasados a `SIE-el-salvador` como conjunto declarado.

**Evidencia.**

- **Sin código de pronósticos:** PR #2 (B1, `6825482`) y PR #3 (B2, `a08ebf1`). `src/` contiene solo `adquisicion/`,
  `transformacion/` y `validacion/`. El `Makefile` ya no tiene objetivos de exploración, evaluación, proyección ni de
  las Fases 5 y 6. `DESCRIPTION` y `renv.lock` no tienen los 13 paquetes de modelos; el `renv.lock` del PR #4
  (`2d80137`) tiene 125 paquetes. Buscar `pronostic|forecast|bvar|arimax` en `src/`, `scripts/`, `Makefile`,
  `DESCRIPTION` y `.github/` da solo un comentario de `scripts/bootstrap_renv.R`, que registra la salida de esos
  paquetes.
- **L3 (bloque D):** `doc/evidencia_verificacion_sv_fase0.md` (PR #8, `af35530`). En la PC `D:\harold` (R 4.6.1), el
  2026-11-22, SIE-sv `405b1a4` corrió `make master` sin `CONJUNTO` y `SIE-el-salvador` `7cbca83` corrió `make master`
  con `CONJUNTO=data/conjuntos/bloque_d.csv`. Los 19 CSV tienen el mismo sha256, tanto el de los bytes como el calculado
  sin CR. La L0 de SIE-sv salió de su almacén propio `hsssst00/SIE-sv-L0` (`23a5ca3`; 79/79 PASS en
  `verificar_l0_fisico.R`).
- **Separación (checklist A a C2):**
  - PR #1 (`fccea38`): apertura, ADR-011, senda y SV0-01..SV0-09.
  - PR #5 (`b66df79`): historia heredada en `doc/historico/`.
  - PR #6 (`b8bbcbf`): manual e importador del registro de L0.
  - PR #7 (`405b1a4`): ADR-012, catálogo de 20 publicaciones y almacén propio.
- **Decisiones:** SV0-01..SV0-09 en `doc/metodologia/decisiones_sv_fase0.md`, de Harold. Los detalles de ejecución de
  los bloques B y C están rotulados «delegada al agente; se puede reabrir». Están en la sección «Detalles fijados por el
  agente» de ese archivo y en `doc/checklist_sv_fase0.md` (el mecanismo `CONJUNTO=`/`SALIDA=`, B1, y el reparto de
  documentos, C).
- **CI:** run [#29](https://github.com/hsssst00/SIE-sv/actions/runs/45099077983) en verde sobre `af35530`, el último
  commit de `main` antes de este registro.

**Lo que queda abierto y NO bloquea este cierre** (declarado, no silenciado):

- **`conjunto_lib.R`** conserva la lógica de la etapa de escenario (`publicaciones_de_escenario()` y
  `etapa_escenario_activa()`). Sin series de rol `escenario` ya no se activa nunca. Se limpia en la Fase 1.
- **Captura en la transición:** mientras `SIE-el-salvador` no cierre su Fase 7, se captura allá y SIE-sv importa las
  filas de sus 20 publicaciones (manual, sección 7.3). SIE-sv todavía no capturó nada por su cuenta.
- **Reproducción por terceros:** la L0 es privada (ADR-008), así que un tercero no puede rehacer la comparación del
  bloque D. La referencia publicada (SV0-06) es de la Fase 3.
- **Plataforma:** la comparación se hizo en una sola máquina con Windows. La evidencia trae el sha256 sin CR para
  comparar con otras plataformas, pero que la L3 sale igual en Linux no está probado.
- **ADR-008** sigue «Parcial»; es un estado heredado y no cambia con este cierre.
- **`SIE-el-salvador`:** el PR #116 (retiro de AP-2) sigue abierto allá y no toca nada de lo que verifica este cierre.

**Delegación.** La delegación del 2026-11-22 (bloques B y C; `CLAUDE.md`, regla 4) termina con este cierre. Desde aquí
la regla 4 rige sin excepciones.

**Tag: `v0.1.0-fase0` (propuesto)**, sobre el commit que ya contiene este registro, nunca antes. Antes de crear el tag
hay que confirmar que el CI de ese commit queda en verde. En el mismo commit, `CITATION.cff` pasa a la versión 0.1.0 con
fecha 2026-11-22. La revisión independiente en `doc/auditorias/` y el tag quedan a cargo de Harold.

### Nota de corrección (2026-11-23) — auditoría independiente de la Fase 0 de SIE-sv, hallazgo I1

La viñeta «Decisiones» dice que la sección «Detalles fijados por el agente» de `decisiones_sv_fase0.md` guarda los
detalles de ejecución de los bloques B y C. No es así: de sus ocho puntos, seis son del bloque A, uno de C2 y uno de
C. Los rótulos de B y C están en `doc/checklist_sv_fase0.md`. La delegación se registró en `CLAUDE.md` en el PR #5
y ya se había usado en los PR #1 a #3. El texto de arriba se conserva sin editar.

### Adopción del criterio y de los detalles delegados (2026-11-23) — auditoría independiente de la Fase 0 de SIE-sv, hallazgo I1

Harold adopta la senda v0.1 (`doc/senda_sie_sv.md`, «Adopción», v0.2) y los detalles de los bloques A y C2
(`doc/metodologia/decisiones_sv_fase0.md`, sección del 2026-11-23). El criterio que este registro declara SATISFECHO deja de
ser una propuesta del agente que se puede reabrir.

### Nota de fechas (2026-11-23) — auditoría independiente de la Fase 0 de SIE-sv, hallazgo M1

`7cbca83` es del 2026-11-21 21:59:43 -0600; `aa8089f` y `d172a53`, del 2026-11-21 a las 22:53 y 22:59 -0600. ADR-011,
el registro de decisiones, el comentario de `libnode-dev` en `ci.yml` y la cabecera de
`doc/historico/cierres_SIE-el-salvador.md` los fechan el 2026-11-22, que es la fecha UTC. La fecha verificable es la
del commit. El texto de arriba se conserva sin editar.

### ADR-008 (2026-11-25) — auditoría independiente de la Fase 0 de SIE-sv, hallazgo M2

«Lo que queda abierto» dice que ADR-008 sigue «Parcial». Desde el 2026-11-25 está cerrado para SIE-sv (nota en el propio ADR). El texto de arriba se conserva sin editar.
