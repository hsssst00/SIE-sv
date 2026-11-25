# SIE-sv — Servicio de estadísticas macroeconómicas de El Salvador

SIE-sv captura, cura y valida estadísticas macroeconómicas de El Salvador, y las sirve a un cliente: el paquete de R
`siesv`. El cliente **reconstruye las series en la máquina del usuario** desde las fuentes originales, con la misma
curación y validación que este repositorio. Por eso no se redistribuyen los archivos de las fuentes ni las series
derivadas (ADR-008, ADR-011). SIE-sv no hace pronósticos, y sirve solo lo que no se consigue por una API (ADR-012).

Se separó el 2026-11-22 de [`hsssst00/SIE-el-salvador`](https://github.com/hsssst00/SIE-el-salvador), que sigue como
sistema de proyección del PIB trimestral y conserva sus modelos, su DOI y sus tags.

## Estado

**Fase 0 de SIE-sv cerrada el 2026-11-22** (separación; tag `v0.1.0-fase0` propuesto). La Fase 1 (núcleo `siesv`) todavía no se
abre. Senda en [`doc/senda_sie_sv.md`](doc/senda_sie_sv.md), decisiones en
[`doc/metodologia/decisiones_sv_fase0.md`](doc/metodologia/decisiones_sv_fase0.md) y tablero de la Fase 0 en
[`doc/checklist_sv_fase0.md`](doc/checklist_sv_fase0.md). El paquete `siesv` todavía no existe: se construye en la Fase
1 (núcleo) y la Fase 2 (cliente).

## Qué contiene

| Capa | Qué es | Dónde |
|---|---|---|
| L0 | Archivos tal como los publicó la fuente, con sha256 y *vintage* (ADR-007) | `data/L0_raw/`. Solo se versiona `manifiesto.csv`; los archivos viven en un almacén privado. |
| L1 | Series normalizadas en formato largo | `data/L1_staging/` (generada, no versionada) |
| L2 | Validación que falla, no advierte | `src/validacion/` |
| L3 | Series maestras | `data/L3_master/` (generada, no versionada) |

Los catálogos (`catalogos/`, esquema Frictionless en `datapackage.json`) describen instituciones, publicaciones,
series, transformaciones, series maestras, *vintages* y rupturas.

**Fuentes.** Portal de estadísticas del BCR (incluido el IPC de la ONEC, que se sirve desde ahí) y demanda eléctrica de
la Unidad de Transacciones (UT, captura manual).

**Series maestras de la v1 (SV0-02).** PIB trimestral (oficial SA y SA propio), IVAE, remesas nominales y reales,
exportaciones FOB, índice de precios de importación (IPM), índice de precios al productor (IPP), tipo de cambio real
(ITCER) y demanda eléctrica de la UT, en versión mensual y trimestral.

## Uso (hasta que exista `siesv`)

En la consola de R, con el proyecto abierto:

```r
renv::restore()                     # paquetes fijados en renv.lock
system("make materializar-l0")      # L0 desde el almacén privado hsssst00/SIE-sv-L0 (SIE_L0_STORE en .Renviron)
system("make master")               # L0 -> L1 -> L2 -> L3
testthat::test_dir("tests")         # pruebas
```

`.Renviron.example` es la plantilla de configuración. Sin acceso al almacén privado de L0 no se puede reconstruir L3:
justamente eso es lo que va a resolver el cliente `siesv`, que descarga de las fuentes.

## Documentación

- [`doc/adr/`](doc/adr/): decisiones de arquitectura. [ADR-011](doc/adr/ADR-011-origen-y-alcance-sie-sv.md) dice cuáles de las heredadas siguen vigentes.
- [`doc/manual_actualizacion.md`](doc/manual_actualizacion.md): actualización de L0 a L3. Es un borrador de la Fase 0 de SIE-sv, reescrito desde el de la Fase 7 de `SIE-el-salvador`.
- [`doc/historico/`](doc/historico/): historia de `SIE-el-salvador`, con decisiones, auditorías, evidencias y la senda original.
- `CLAUDE.md`: reglas no negociables del pipeline. `CONTRIBUTING.md`: flujo de trabajo.

## Licencias

Código bajo MIT (`LICENSE`). Documentación bajo CC-BY-4.0 (`LICENSE-docs`). Los archivos de las fuentes no se
redistribuyen: se publican su script de captura y su checksum (ADR-008).
