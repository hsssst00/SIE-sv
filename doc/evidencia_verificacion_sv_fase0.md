# Evidencia de la verificación de la Fase 0 de SIE-sv (bloque D)

Fecha de la corrida: 2026-11-22. Máquina: PC de Harold (`D:\harold`), Windows, R 4.6.1, con la biblioteca de `renv` de
cada repositorio. Corrió Harold, paso a paso; el agente verificó los resultados leyendo los archivos de su disco.

Criterio (senda de SIE-sv, Fase 0): `make master` reconstruye la L3 vigente y cada CSV de las familias de la v1 (SV0-02)
tiene el mismo sha256 que en `SIE-el-salvador` sobre la misma L0.

**Resultado: 19 de 19 CSV con el mismo sha256. No hay archivos que estén de un solo lado.**

## Estado de partida

| Repositorio | Commit |
|---|---|
| `hsssst00/SIE-sv` (copia de Harold) | `405b1a4` (merge del PR #7) |
| `hsssst00/SIE-sv-L0` (copia de Harold, `SIE_L0_STORE`) | `23a5ca3` |
| `hsssst00/SIE-el-salvador` (copia de Harold) | `7cbca83` (merge del PR #115) |

Antes de correr, el agente comprobó que las 79 filas de `catalogos/08_vintages.csv` de SIE-sv son idénticas en
`SIE-el-salvador` (archivo, sha256, sha256_norm y periodo), que las 12 publicaciones que necesita el pipeline son las
mismas en los dos repositorios, que el vintage vigente de cada una coincide, y que en `src/transformacion/`,
`src/validacion/` y `catalogos/` las diferencias entre los dos repositorios son solo comentarios y textos de `notas`.
Las 5 publicaciones que solo tiene `SIE-el-salvador` (FRED y FMI) alimentan solo la etapa de escenario.

## Procedimiento

Se eligió una corrida vigente en SIE-sv y una corrida con conjunto declarado en `SIE-el-salvador`, para no tocar la L3
vigente de este último (generada el 2026-09-30 y usada por su Fase 7). Decisión de Harold (procedimiento A, 2026-11-22).

1. SIE-sv: `make materializar-l0` desde `SIE-sv-L0` → 79 copiados; `verificar_l0_fisico.R` → 79 PASS, 0 FAIL, 0 AUSENTE.
2. SIE-sv: `make master`, sin `CONJUNTO` → código 0; 19 CSV en `data/L3_master/`.
3. SIE-sv: `Rscript scripts/armar_conjunto.R data/conjuntos/bloque_d.csv BCR.PIB_T.NOMINAL.v2026-09` → «36 vintages de 12
   publicaciones». Es el conjunto exacto de vintages que usó la L3 del paso 2.
4. `SIE-el-salvador`: el mismo `bloque_d.csv` (sha256 `31ff0e20efc073ba476f0d5278c5b8a363e0f5e3c49682fd9675e1e7eee30a74`
   en las dos copias), `make master CONJUNTO=data/conjuntos/bloque_d.csv SALIDA=data/conjuntos/bloque_d` → código 0. La
   etapa de escenario se omitió (el conjunto no declara FRED ni FMI). `git status` quedó limpio.
5. Comparación en R con `digest::digest(file = …, algo = "sha256")` sobre la unión de los nombres de las dos carpetas.

Vintages del conjunto: los 25 anuales de `UT.DEMANDA_TOTAL_MENSUAL` (`v2002-12` … `v2025-12` y `v2026-08`) y

- `BCR.BALANZA_COMERCIAL.v2026-10`
- `BCR.INDICES_PRECIOS_COMERCIO_EXTERIOR.v2026-10`
- `BCR.IPP.v2026-10`
- `BCR.ITCER.v2026-10`
- `BCR.IVAE.VIGENTE.v2026-10`
- `BCR.PIB_T.INDICES_VOLUMEN_ENCADENADOS_NSA.v2026-09`
- `BCR.PIB_T.INDICES_VOLUMEN_ENCADENADOS_SA.v2026-09`
- `BCR.PIB_T.NOMINAL.v2026-09`
- `BCR.PIB_T.SERIE_RETROPOLADA_1990_2005.v2019-03`
- `BCR.REMESAS_FAMILIARES_MENSUAL.v2026-10`
- `ONEC.IPC.BASE_2009.v2026-11`

## sha256 de la L3 vigente de SIE-sv al cierre del bloque D

Iguales en `data/conjuntos/bloque_d/L3_master/` de `SIE-el-salvador`, en las dos columnas. Es la referencia que la Fase 1
debe seguir reproduciendo (senda, Fase 1) mientras no entre una captura nueva en L0.

`write.csv()` de R en Windows termina las líneas en CRLF, así que el sha256 de los bytes (columna «sha256») solo vale para
comparar con otra corrida en Windows. En Linux o macOS las líneas terminan en LF y el sha256 de los bytes cambia aunque
el contenido sea el mismo: para comparar entre plataformas se usa «sha256 sin CR», calculado tras reemplazar cada CRLF
por LF (la misma convención que el «sha256 sin CR» de los cortes heredados). La comparación del bloque D se hizo en una
sola máquina y no prueba que la L3 salga igual en otra plataforma.

| Archivo | Filas | sha256 | sha256 sin CR |
|---|---|---|---|
| `BCR_EXPORT_FOB_NOM_NSA_M.csv` | 393 | `a9268de39ae6ecc4c63f5cce89925bd04ca49dd1f99e0f84149a822bcc09c0cb` | `06510034d32bef21245d01874300e676554529b5d9a9b0f1d3b3c40a48200b95` |
| `BCR_EXPORT_FOB_NOM_NSA_Q.csv` | 131 | `f13c413a9d219fbe6c38b3a64910c2041a65bc512a4ec69f28380bed88f03b00` | `16a2a0e853d6ab12e5b0a5803cac5e0344536dccc5b7ef78587e7b4e725283c8` |
| `BCR_IPM_IDX_NSA_M.csv` | 260 | `e27ff8d2e770f36ae0454259648ec3666b99dbcc60ad44821c4611552f114c39` | `597cac70d868d9803f566e7bfb7611c3070970c0f7ba5952f208a61d5a0b19b6` |
| `BCR_IPM_IDX_NSA_Q.csv` | 86 | `b3d15db71a63f576ffdbe0722dfc60df558f6de63133bf679dce6e422175d121` | `3e21b76e18775f401c8f515f75c52fddc39287dac702cea2b42d76a6d84ee8bf` |
| `BCR_IPP_IDX_NSA_M.csv` | 202 | `aede8d36c8577278c5ed41a225490374a8d2906862fa457c2e6dd35560f76960` | `a2aaea37f3f9ecff8cce633aa4251bdcab8ccd3549656640f8e5a2763bdf50ba` |
| `BCR_IPP_IDX_NSA_Q.csv` | 67 | `3722cc6ca55ec3f6dd325bf34862c142f45fb0dafbcc38b8880fc26b1304b802` | `7d788b1c319331c1456d0d1f2f2ff6f4c0f1faa3214cf59da24aacd56da3b29d` |
| `BCR_ITCER_IDX_NSA_M.csv` | 321 | `9e781d84c7a4d0a42b91d2292acf92dc4354e51aef09fa0694471cb4e1faff59` | `830991b825b7bf914b92000ed5420f4233fb3d85b8f148c3907949e806b89668` |
| `BCR_ITCER_IDX_NSA_Q.csv` | 107 | `a926fb66232d2fa1267e239aa6aca6506c2efd39fc2725fce1d38cdc6126390d` | `021ea8518a74858d3412ade467962abafca8d4ac2cdd6d5c39c9c32f77d26c94` |
| `BCR_IVAE_VOL_SA_M.csv` | 260 | `878e5c91171c6ee839f57ba9fdc8317e3babc5a995d9b2786333a3b6d09bbe02` | `9375a34d814a1a674f5440e1890f7462e52aa23073b4c2ef8bf001f9f09ba7bb` |
| `BCR_IVAE_VOL_SA_Q.csv` | 86 | `cc6e827fb7af4e901caba5545b3ce53f77aa9599463f8f98dd233506418ca26d` | `99243b94f3ba7ad9f9d2397a4616f65b1fa0223fcceada4729f5e3fc25305181` |
| `BCR_REMESAS_NOM_NSA_M.csv` | 429 | `070946bccc0e8583a48357f19e5e2f2bff773767e29012e9d13e7be763c60bf9` | `9fb11e005a5b8c91eea027d08104fdb34480aad3c38545f55e88f4eba824f096` |
| `BCR_REMESAS_NOM_NSA_Q.csv` | 143 | `0c7ab86cec0d6e8d5fb4ad05c493c9b264df59848865dbb7b92ed93d51017143` | `87f0abedd21bd3fce982faa7dc9480dff34ae4c0013c554d3ae695a49a3607b1` |
| `BCR_REMESAS_REAL_NSA_M.csv` | 202 | `a55bc3a57e968f72992bb3fc202ba44941923276c17b4c2e9bf79499067a2627` | `a6abf806115fbf604b74cc78480bf3e1792d671f51076c94d1e5748a2cd27d6c` |
| `BCR_REMESAS_REAL_NSA_Q.csv` | 67 | `778189dc16adbc4fa391c61a14076d843cf56ef511f543beb58676d589ee0ec7` | `f2346aa7e2eb929626f025f9d13da57d9243bf556a962cac9e25b9587890e060` |
| `PIB_SA_OFICIAL_Q.csv` | 86 | `a3e2f182cfae1aa3e20949df723d82b70dbe7a8ee6814d45e46aa22a8e6fcc83` | `07bfc88c259a6cb6e92ac0672f5ec52df56dea15d348135c3d612aa2d52f7c34` |
| `PIB_SA_PROPIO_Q.csv` | 146 | `885939d87be63baac9abaa5c558fa15e23e9d5951bfef46659c9a489142c3db4` | `1fd3cdca9a73812382512c2cae3e634fb92443dbed0227afe1955f5f855cd143` |
| `PIB_SA_PROPIO_Q_outliers.csv` | 2 | `65fc34434a9c49d507a0ac92523b2fd54d7917bfb8d2190099ae8a71fe82b772` | `d602ec2d70899f3cdd78165ea62f583be2ada999a76216f3e56647877ffbe6db` |
| `UT_DEMANDA_ELEC_GWH_NSA_M.csv` | 296 | `042a70497332a21627657733fb626096bc8584469cb53737e2b4997968f47834` | `e296b6a4cb89becbc78787519aaf00edd99415af70ad9031e9f25e91a4df9c72` |
| `UT_DEMANDA_ELEC_GWH_NSA_Q.csv` | 98 | `3d6691488d9c8198ae003b55aeb90a0d0956e28b63d2556caf6b85da63b0c076` | `fd69e38acc76746c8ef7355180099456bd1effbd2812dd0f1088504f0d672fcf` |
