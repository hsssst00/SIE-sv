# ADR-012: Alcance de SIE-sv: fuentes sin API, catálogo de lo que se sirve y almacén propio

**Estado:** Cerrado

**Fecha:** 2026-11-22 · **Decide:** Harold

## Contexto

Después de la separación (ADR-011), SIE-sv seguía arrastrando el catálogo completo de `SIE-el-salvador`: 65
publicaciones, de las cuales solo 20 se capturan, y compartía con ese proyecto el almacén privado de L0. Por eso
`materializar-l0` y `sincronizar-l0` avisaban de 18 archivos ajenos. Harold fijó el propósito: SIE-sv existe para
mejorar el flujo de trabajo con los datos que **no se pueden conseguir desde una API**.

## Decisión

1. **Criterio de alcance.** SIE-sv captura, cura y sirve solo publicaciones que no ofrecen una API: tablas que el portal
   arma en el navegador, archivos estáticos o descargas manuales. Lo que tiene API lo obtiene el usuario directamente
   de la fuente. Es el mismo criterio que sacó a FRED, FMI, BM y CBO en el bloque B2 (ADR-011).
2. **El catálogo describe lo que se sirve.** `catalogos/01_publicaciones/` queda con las 20 publicaciones que SIE-sv
   captura: 17 del portal del BCR, el PIB retropolado 1990-2005 (archivo estático del BCR), el IPC base 2009 de la ONEC
   (servido por el portal del BCR) y la demanda eléctrica de la UT (captura manual). Salen 45 fichas que nunca se
   capturaron (BCR 23, MH 7, ISSS 5, SECMCA 5, ONEC 2, BID 2, CEPAL 1); quedan listadas en
   `doc/pendientes_fuentes.md`. Se recortan además:
   - `02_metodologias`: salen las 2 de deuda pública. Quedan las que describen una publicación que se queda y sus
     predecesoras por `predecesor_id`.
   - `09_rupturas`: salen R007, R012 y R014. En R006, R008, R009, R010, R011 y R013, `series_afectadas` conserva solo
     las publicaciones que se quedan.
   - `00_instituciones`: quedan BCR, ONEC y UT.
3. **Almacén propio.** Los archivos crudos de SIE-sv viven en `hsssst00/SIE-sv-L0`, un repositorio privado (ADR-008:
   conservación, no redistribución). Se creó el 2026-11-22 con los 79 archivos del manifiesto, copiados de
   `hsssst00/SIE-el-salvador-L0`, y cada sha256 se verificó contra el manifiesto. `SIE_L0_STORE` apunta a una copia de
   trabajo de ese repositorio.
4. **Transición.** Mientras `SIE-el-salvador` no cierre su Fase 7, se captura allá (decisión del 2026-11-22). SIE-sv
   importa las filas de sus 20 publicaciones y sus archivos con `scripts/importar_registro_l0.R`, y los sube a su
   almacén con `make sincronizar-l0`.

## Consecuencias

- `materializar-l0` y `sincronizar-l0` dejan de avisar archivos ajenos.
- Agregar una fuente exige comprobar que no tiene API, crear su ficha y preguntar (regla 4). `doc/pendientes_fuentes.md`
  es el punto de partida, no un compromiso.
- `SIE-el-salvador` y su almacén no cambian.
