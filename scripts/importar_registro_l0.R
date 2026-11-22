# scripts/importar_registro_l0.R
#
# Uso (terminal, desde la raiz de SIE-sv):
#   Rscript scripts/importar_registro_l0.R <ruta a SIE-el-salvador> <ruta al almacen SIE-el-salvador-L0> [plan]
# Con `plan` solo informa que filas se importarian. Sin `plan`, agrega las filas a data/L0_raw/manifiesto.csv y a
# catalogos/08_vintages.csv y copia sus archivos a data/L0_raw/ (sha256 verificados). Despues:
# Rscript scripts/check_l0_integrity.R y make sincronizar-l0, que sube los archivos al almacen de SIE-sv.
# Manual de actualizacion, seccion 7.3.

source("src/adquisicion/importar_registro_lib.R")
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  stop("FALLO VISIBLE [importar-registro]: uso: importar_registro_l0.R <SIE-el-salvador> <SIE-el-salvador-L0> [plan]",
       call. = FALSE)
}
importar_registro_l0(args[1], ".", escribir = !identical(args[3], "plan"), almacen_origen = args[2])
