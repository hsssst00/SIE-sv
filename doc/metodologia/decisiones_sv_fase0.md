# Fase 0 de SIE-sv — registro de decisiones

Decisiones de Harold del 2026-11-22, tomadas en el chat sobre las fichas F8-01..F8-09 de `SIE-el-salvador`. Al pasar
a este repositorio se renumeran SV0-01..SV0-09. El origen y el alcance están en ADR-011.

| Ficha | Tema | Decisión |
|---|---|---|
| SV0-01 | Forma del cliente | Un paquete núcleo, `siesv`, que **mueve** (no copia) desde `src/` la captura, la curación L1→L3 y la validación. El pipeline del repositorio llama al paquete. Así hay una sola fuente de verdad. |
| SV0-02 | Cobertura de la v1 | Las familias de la L3 vigente: PIB (oficial SA y SA propio), IVAE, remesas nominales y reales, exportaciones FOB, IPM, IPP, ITCER y demanda eléctrica de la UT, en versión mensual y trimestral. Los bloques fiscal, monetario, RIN y balanza de pagos quedan para después de la v1. |
| SV0-03 | *Vintages* | Cada reconstrucción del cliente registra su propia *vintage* local (`vintage_id`, fecha de captura y sha256 del crudo) según ADR-007. El cliente no promete reproducir *vintages* históricas, porque esas viven solo en el almacén privado de L0. |
| SV0-04 | Fallos | Ante un fallo de captura o de validación, se detiene con un error visible y nunca entrega una serie a medias. Los reintentos son acotados. |
| SV0-05 | Fuentes excluidas | FRED, FMI, CBO y los escenarios de L3 quedan fuera. El usuario no necesita `FRED_API_KEY`. |
| SV0-06 | Referencia publicada | Sin datos: el repositorio publica los catálogos y una huella sha256 de cada serie de L3 por *vintage*. `sie_verificar()` compara la reconstrucción del usuario con esa huella. |
| SV0-07 | Pronósticos | Van a otro producto: este repositorio nuevo, copiado de `SIE-el-salvador` (ADR-011). Aquí se retira el código de pronósticos. |
| SV0-08 | Distribución | GitHub, con `pak::pak("hsssst00/SIE-sv")`; r-universe después. CRAN no. |
| SV0-09 | Criterio de cierre del producto | Un usuario externo instala, reconstruye las series de la v1 y estas pasan la validación L2/L3. La comparación con la huella (SV0-06) es un entregable, pero no forma parte del criterio. |

## Detalles fijados por el agente (2026-11-22; delegada al agente; se puede reabrir)

- **Nombre del repositorio y del paquete:** `SIE-sv` y `siesv` (Harold).
- **Momento de la copia:** ahora, desde `main` (`7cbca83`), no desde el tag de cierre de la Fase 7 del otro
  repositorio. Harold pidió ejecutar sin esperar.
- **Copia sin tags:** ver ADR-011, punto 1.
- **Visibilidad:** pública, igual que `SIE-el-salvador`. El contenido copiado ya era público.
- **Fases de la senda (`doc/senda_sie_sv.md`):** propuesta del agente.
- **CI sin caché:** la primera corrida de SIE-sv falló en `renv::restore()` porque V8 no encuentra `libnode.so.109`.
  Se agrega `libnode-dev` a las dependencias de sistema de `ci.yml`. El mismo defecto está latente en
  `SIE-el-salvador`: aparecería allí si su caché de Actions vence.
- **Dónde se captura en la transición (Harold, 2026-11-22):** en `SIE-el-salvador`, hasta que cierre su Fase 7.
  SIE-sv importa las filas de las publicaciones que tiene en su catálogo. Regla de implementación (delegada al agente;
  se puede reabrir): una fila pasa si su `publicacion_id` tiene ficha en `catalogos/01_publicaciones/` de SIE-sv. Así
  entran también las 8 publicaciones registradas sin L3, para que su historial de *vintages* quede completo. El script
  es `scripts/importar_registro_l0.R`, con su lógica en `src/adquisicion/importar_registro_lib.R`.
- **Alcance y almacén (Harold, 2026-11-22; ADR-012):** SIE-sv sirve solo lo que no se consigue por una API. El
  catálogo queda en las 20 publicaciones que se capturan, y SIE-sv tiene su propio almacén privado,
  `hsssst00/SIE-sv-L0`. Detalles fijados por el agente (delegada al agente; se puede reabrir): en `02_metodologias` se
  conservan las predecesoras por `predecesor_id`, para no romper la cadena; en `09_rupturas` se recortan
  `series_afectadas` en lugar de borrar las rupturas mixtas; el nombre del almacén es `SIE-sv-L0`.
