# scripts/importar_registro_l0.R
#
# Uso (terminal, desde la raiz de SIE-sv):
#   Rscript scripts/importar_registro_l0.R <ruta a SIE-el-salvador> [plan]
# Con `plan` solo informa que filas se importarian. Sin `plan`, las agrega a data/L0_raw/manifiesto.csv y a
# catalogos/08_vintages.csv. Despues: Rscript scripts/check_l0_integrity.R y make materializar-l0 (los archivos
# vienen del almacen privado, que comparten los dos repositorios). Manual de actualizacion, seccion 7.3.

source("src/adquisicion/importar_registro_lib.R")
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) stop("FALLO VISIBLE [importar-registro]: falta la ruta a SIE-el-salvador.", call. = FALSE)
importar_registro_l0(args[1], ".", escribir = !identical(args[2], "plan"))
