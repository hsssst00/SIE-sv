# Registro de decisiones de arquitectura (ADR)

Proyecto: SIE-sv — servicio de estadísticas macroeconómicas de El Salvador (derivado de `SIE-el-salvador`, ADR-011)

Cada decisión fundacional (D1–D8, senda metodológica §2) se registra como un ADR independiente, más D9 (stack tecnológico) y D10 (transformaciones L3 de la matriz de predictores), adiciones propias del proyecto no enumeradas en §2 — ver ADR-009 y ADR-010. Formato: contexto, alternativas consideradas, decisión, consecuencias. Un ADR se enmienda, no se reescribe, cuando una decisión posterior lo afecta.

| ADR | Decisión | Estado |
|---|---|---|
| [001](./ADR-001-variable-objetivo.md) | Definición operativa de la variable objetivo | Cerrado |
| [002](./ADR-002-horizonte-y-diseno.md) | Horizonte y diseño de los dos ejercicios | Cerrado |
| [003](./ADR-003-empalme-cuentas-nacionales.md) | Tratamiento del empalme de cuentas nacionales | Cerrado |
| [004](./ADR-004-shock-2020.md) | Tratamiento de quiebres estructurales y shock de 2020 | Cerrado |
| [005](./ADR-005-soporte-catalogos.md) | Soporte tecnológico de los catálogos | Cerrado |
| [006](./ADR-006-vocabulario-metadatos.md) | Vocabulario de metadatos | Cerrado |
| [007](./ADR-007-politica-vintages.md) | Política de versiones de publicación (vintages) | Cerrado |
| [008](./ADR-008-licencias.md) | Licencias y condiciones de redistribución | Parcial — BCR (corte 2026-10-12 vencido sin pronunciamiento: default conservador), FMI, FRED, Banco Mundial y BID resueltos; CBO resuelta por dominio público (2026-10-17); ISSS, MH, ONEC/DIGESTYC, SECMCA y UT resueltos por decisión de no perseguir esclarecimiento; política de L0 por fuente (2026-10-14); CEPAL (corte 2026-10-16 vencido sin pronunciamiento: default conservador; obras derivadas sin resolver, condición para admitir cualquier serie de CEPAL) |
| [009](./ADR-009-stack-tecnologico.md) | Stack tecnológico | Cerrado |
| [010](./ADR-010-transformaciones-l3-predictores.md) | Método de transformación L3 de la matriz de predictores (desagregación temporal, deflactación, outliers, ajuste estacional) | Cerrado |
| [011](./ADR-011-origen-y-alcance-sie-sv.md) | Origen y alcance de SIE-sv (repositorio nuevo, sin pronósticos; cliente `siesv`) | Cerrado |
| [012](./ADR-012-alcance-fuentes-sin-api.md) | Alcance de SIE-sv: fuentes sin API, catálogo de lo que se sirve y almacén propio | Cerrado |

> **Regla de este índice.** La celda "Estado" de cada fila es copia literal de la línea
> `**Estado:**` del ADR correspondiente. Si divergen, el ADR manda y el índice está
> desactualizado. Se verifica con un `grep`; en Fase 3 corresponde un `test_that()` que
> lo compruebe automáticamente.

**Estado general:** nueve de diez ADR cerrados. Solo ADR-008 queda parcial. Su alcance pendiente se redujo en tres tandas. El 2026-08-12: los tramos FMI y FRED quedaron resueltos con el default conservador, y el tramo Banco Mundial quedó relevado con decisión aplazada. El 2026-08-17: el tramo ISSS quedó resuelto por decisión de no perseguir esclarecimiento —no por relevamiento pendiente—, se abrió el tramo CEPAL con consulta enviada y fecha de corte 2026-10-16, y se registró el tramo BID, enganchado al mismo disparador que el del Banco Mundial. El 2026-08-18: los tramos MH, ONEC/DIGESTYC y SECMCA quedaron resueltos por decisión de no perseguir esclarecimiento, mismo patrón que ISSS. La decisión entre una política única de L0 y una por fuente, aplazada hasta el corte del BCR (2026-10-12), se tomó el 2026-10-14: política por fuente. El 2026-10-17 se registró el tramo CBO (Fase 6), resuelto por dominio público; el estado vigente por fuente es la línea **Estado:** de ADR-008. El corte de CEPAL (2026-10-16) venció sin pronunciamiento, y se registró el 2026-10-19 (default conservador; queda abierta la condición sobre obras derivadas).

ADR-007 y ADR-009 permanecen cerrados y llevan, desde el 2026-08-12, notas de seguimiento con disparador explícito: clientes de API externa en ADR-009 (se decide antes del primer *script* de `src/adquisicion/` que consuma una API), y alcance de *vintages* de predictores externos en ADR-007 (fuera del núcleo mínimo viable).

El 2026-09-24, la planificación de Fase 4 agregó notas a seis ADR sin reabrir ninguno:
aclaración de la convención de indexación del origen en ADR-002; enmienda del vintage de
referencia del ejercicio retrospectivo en ADR-001, con referencia cruzada en ADR-007;
seguimiento del ajuste estacional del objetivo dentro de cada origen en ADR-004, con referencia
cruzada en ADR-001; dependencias del motor de evaluación en ADR-009; y unidad de modelación de
las predictoras en ADR-010. Los diez siguen con el mismo estado.

## Historia heredada de SIE-el-salvador

Los cierres de las Fases 0 a 6 de `SIE-el-salvador`, con sus sprints y remediaciones, están en
[`doc/historico/cierres_SIE-el-salvador.md`](../historico/cierres_SIE-el-salvador.md). Sus tags (`v0.1.0-fase0` a
`v0.9.1-fase6`) existen solo en ese repositorio. Desde el 2026-11-22, en este índice se registran solo los cierres de
SIE-sv, con encabezado «## Cierre de Fase N de SIE-sv (AAAA-MM-DD)». `tests/test-adr-indice.R` cuenta solo esos.
