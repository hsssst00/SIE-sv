# ADR-011: Origen y alcance de SIE-sv

**Estado:** Cerrado

**Fecha:** 2026-11-22 · **Decide:** Harold

## Contexto

`SIE-el-salvador` nació como un sistema de información estadística con una demostración de uso: la comparación de
modelos de proyección del PIB trimestral (Fases 4 a 6). La parte de datos ya funciona como gestor de estadísticas
macroeconómicas de El Salvador: captura (L0), normalización (L1), validación (L2) y series maestras (L3), con
*vintages*, manifiesto con sha256, catálogos y trazabilidad por celda.

El paso siguiente es otro producto: un sistema que procesa la información, la cura y la sirve a un cliente, que es un
paquete de R. Ese producto no hace pronósticos.

## Decisión

1. **Repositorio propio.** El producto nuevo vive en `hsssst00/SIE-sv`. Parte del historial de `main` de
   `hsssst00/SIE-el-salvador` en el commit `7cbca83` (2026-11-22). Se copió solo `main`, sin tags, porque los tags
   `vX.Y.Z-faseN` describen el otro producto y su numeración chocaría con la de este. GitHub no permite hacer fork de un
   repositorio propio en la misma cuenta.
2. **`SIE-el-salvador` sigue como sistema de proyección del PIB.** Cierra en su Fase 7 y conserva su DOI de Zenodo,
   sus auditorías y sus tags. Los pronósticos no pasan a SIE-sv.
3. **Fases propias.** SIE-sv empieza en su **Fase 0**, con su propia senda (`doc/senda_sie_sv.md`). Para no
   confundirlas con las fases heredadas, en este repositorio se escriben «Fase N de SIE-sv». Las fases 0 a 7 de
   `SIE-el-salvador` son historia heredada.
4. **Cliente.** Es el paquete de R `siesv`. **Reconstruye localmente**: descarga de las fuentes originales en la
   máquina del usuario y aplica allí la curación de SIE-sv. No redistribuye L0 ni L3, así que el default conservador de
   ADR-008 sigue intacto y no hace falta enmendarlo.
5. **Decisiones de diseño.** Están en `doc/metodologia/decisiones_sv_fase0.md` (SV0-01 a SV0-09).

## Herencia

| ADR | En SIE-sv |
|---|---|
| 001 Variable objetivo | Histórico. Define el objetivo de los pronósticos, que este producto no tiene. |
| 002 Horizonte y diseño | Histórico. Mismo motivo. |
| 003 Empalme de cuentas nacionales | **Vigente.** Rige la curación del PIB. |
| 004 Shock de 2020 | Histórico para los modelos. Lo que fija sobre *outliers* en el ajuste estacional propio sigue vigente vía ADR-010. |
| 005 Soporte de catálogos | **Vigente.** |
| 006 Vocabulario de metadatos | **Vigente.** |
| 007 Política de *vintages* | **Vigente.** También rige las *vintages* locales del cliente (SV0-03). |
| 008 Licencias | **Vigente**, sin cambios. Con el cliente que reconstruye localmente no se redistribuye nada. |
| 009 Stack tecnológico | **Vigente.** Las dependencias de modelos (fable, BVAR, lightgbm, etc.) salen en la Fase 0 de SIE-sv. |
| 010 Transformaciones L3 | **Vigente** para las familias que pasan a la v1 del cliente. |

Los ADR históricos no se editan. Esta tabla es la lectura que rige en SIE-sv.

## Consecuencias

- El código de modelos, evaluación, proyección y análisis posteriores se retira en la Fase 0 de SIE-sv. Queda en el
  historial y en `SIE-el-salvador`.
- Las correcciones que entren en `SIE-el-salvador` después de la copia y que afecten la captura o la curación se
  llevan a SIE-sv por PR aparte.
- Las pruebas de guarda que leen «## Cierre de Fase N» en `doc/adr/README.md` cuentan hoy las fases heredadas. Se
  adaptan en la Fase 0 de SIE-sv, junto con el traslado de la historia heredada.

## Nota (2026-11-22): fuentes externas fuera del registro (bloque B2)

**Decidido por Harold el 2026-11-22.** FRED, FMI, BM y CBO salen del registro de SIE-sv; no se marcan como históricas.
Se borran 18 filas de `data/L0_raw/manifiesto.csv` y de `catalogos/08_vintages.csv`, 22 publicaciones de
`01_publicaciones/`, 11 series de `03_series.csv`, 11 series maestras de `05_series_master.csv` (diez de rol `escenario` y
la `referencia` del WEO), 9 transformaciones de `04_transformaciones.csv` y 4 instituciones de `00_instituciones.csv`.
Es una excepción explícita a la inmutabilidad del registro de L0 de ADR-007. Ningún archivo crudo se pierde: siguen en el
almacén privado de L0, que comparte con `SIE-el-salvador`, y en el historial de git. Como el almacén no cambia,
`materializar-l0` y `sincronizar-l0` avisan (no fallan) de 18 archivos sin fila en el manifiesto. Ese aviso es esperado.
