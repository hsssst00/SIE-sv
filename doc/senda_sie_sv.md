# Senda de SIE-sv (v0.1, 2026-11-22)

> Propuesta del agente sobre las decisiones de Harold del 2026-11-22 (ADR-011). **Se puede reabrir.** Cada fase cierra
> como en `SIE-el-salvador`: sección «Cierre de Fase N de SIE-sv» en el índice de ADR, revisión independiente y tag.

## Propósito

Capturar, curar, validar y servir las estadísticas macroeconómicas de El Salvador. El cliente es el paquete de R
`siesv`, que reconstruye las series en la máquina del usuario.

## Fases

| Fase | Nombre | Criterio de cierre |
|---|---|---|
| 0 | Separación | SIE-sv no tiene código de pronósticos y el CI está en verde. `make master` reconstruye la L3 vigente y cada CSV de las familias de la v1 tiene el mismo sha256 que en `SIE-el-salvador` sobre la misma L0. |
| 1 | Núcleo `siesv` | La captura, la curación (L1→L3) y la validación viven en `R/` del paquete. El pipeline del repositorio llama al paquete, sin copias de la lógica (SV0-01). `make master` sigue dando los mismos sha256 que al cierre de la Fase 0. |
| 2 | Cliente | La API pública (`sie_catalogo()`, `sie_actualizar()`, `sie_serie()`, `sie_metadatos()`) funciona, con caché y *vintages* locales según ADR-007 (SV0-03). Cuando algo falla, se detiene con un error visible (SV0-04). |
| 3 | Referencia publicada | El repositorio publica los catálogos y una huella sha256 de L3 por *vintage*, y `sie_verificar()` compara contra ella (SV0-06). Hay documentación de usuario. |
| 4 | Prueba externa y v1.0.0 | Un usuario externo, en una máquina limpia, instala `siesv` con `pak`, reconstruye las series de la v1 y estas pasan la validación L2/L3 (SV0-09). |

## Fuera de alcance

Pronósticos, escenarios y las fuentes que solo los alimentaban (FRED, FMI, CBO; SV0-05). Tampoco se publican en CRAN
(SV0-08).
