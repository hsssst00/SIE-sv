# src/adquisicion/importar_registro_lib.R
#
# Importa a SIE-sv las filas nuevas del registro de L0 de SIE-el-salvador (data/L0_raw/manifiesto.csv y
# catalogos/08_vintages.csv). Mientras SIE-el-salvador no cierre su Fase 7, la captura se hace allá y SIE-sv toma solo
# las publicaciones que tiene en su catálogo (decisión de Harold, 2026-11-22; manual de actualización, sección 7.3).
#
# Regla: una fila pasa si su publicacion_id tiene ficha en catalogos/01_publicaciones/ de SIE-sv y su vintage_id no
# está todavía en SIE-sv. Las filas de otras publicaciones (FRED, FMI, BM, CBO) se informan y se ignoran.
# Falla visible (regla 6) si:
#   - un vintage_id ya existe en SIE-sv con otro sha256 (el registro divergió);
#   - una fila del manifiesto de origen no tiene su par en 08_vintages de origen, o al revés;
#   - un archivo no tiene el mismo número de filas que de líneas (campo con salto de línea: no se puede copiar
#     línea por línea sin cambiar el formato).
# Copia las líneas tal como están en el origen, sin reescribir comillas ni formatos. Pura salvo leer/escribir archivos.

.leer_registro <- function(ruta) {
  lineas <- readLines(ruta, encoding = "UTF-8", warn = FALSE)
  lineas <- lineas[nzchar(lineas)]
  datos <- utils::read.csv(text = paste(lineas, collapse = "\n"), colClasses = "character",
                           na.strings = character(0), check.names = FALSE)
  if (nrow(datos) != length(lineas) - 1L) {
    stop("FALLO VISIBLE [importar-registro]: ", ruta, " tiene ", nrow(datos), " filas pero ", length(lineas) - 1L,
         " lineas de datos; no se puede copiar linea por linea.", call. = FALSE)
  }
  list(encabezado = lineas[1], lineas = lineas[-1], datos = datos)
}

#' Planea la importación sin escribir nada. Devuelve las líneas a agregar a cada archivo y lo ignorado.
planear_importacion <- function(man_origen, vin_origen, man_destino, vin_destino, publicaciones_destino) {
  if (!identical(man_origen$encabezado, man_destino$encabezado) ||
      !identical(vin_origen$encabezado, vin_destino$encabezado)) {
    stop("FALLO VISIBLE [importar-registro]: los encabezados de origen y destino no coinciden.", call. = FALSE)
  }
  solo_man <- setdiff(man_origen$datos$vintage_id, vin_origen$datos$vintage_id)
  solo_vin <- setdiff(vin_origen$datos$vintage_id, man_origen$datos$vintage_id)
  if (length(solo_man) || length(solo_vin)) {
    stop("FALLO VISIBLE [importar-registro]: en el origen, manifiesto y 08_vintages no coinciden: ",
         paste(c(solo_man, solo_vin), collapse = ", "), call. = FALSE)
  }
  # Divergencia: mismo vintage_id con otro sha256.
  comun <- intersect(man_origen$datos$vintage_id, man_destino$datos$vintage_id)
  sha_o <- setNames(man_origen$datos$sha256, man_origen$datos$vintage_id)
  sha_d <- setNames(man_destino$datos$sha256, man_destino$datos$vintage_id)
  distintos <- comun[sha_o[comun] != sha_d[comun]]
  if (length(distintos)) {
    stop("FALLO VISIBLE [importar-registro]: vintage_id con otro sha256 en SIE-sv: ",
         paste(distintos, collapse = ", "), call. = FALSE)
  }
  nuevo <- !(man_origen$datos$vintage_id %in% man_destino$datos$vintage_id)
  sirve <- man_origen$datos$publicacion_id %in% publicaciones_destino
  ids <- man_origen$datos$vintage_id[nuevo & sirve]
  list(
    vintage_ids = ids,
    lineas_manifiesto = man_origen$lineas[nuevo & sirve],
    lineas_vintages = vin_origen$lineas[match(ids, vin_origen$datos$vintage_id)],
    ignorados = man_origen$datos$vintage_id[nuevo & !sirve]
  )
}

#' Publicaciones del catálogo de SIE-sv: un YAML por publicación en catalogos/01_publicaciones/.
publicaciones_catalogo <- function(dir_catalogo) {
  f <- list.files(dir_catalogo, pattern = "\\.yaml$")
  sub("\\.yaml$", "", setdiff(f, "_plantilla.yaml"))
}

.agregar_lineas <- function(ruta, lineas) {
  if (length(lineas) == 0) return(invisible())
  actual <- readLines(ruta, encoding = "UTF-8", warn = FALSE)
  actual <- actual[nzchar(actual)]
  con <- file(ruta, open = "wb")
  on.exit(close(con))
  writeLines(enc2utf8(c(actual, lineas)), con, sep = "\n", useBytes = TRUE)
}

#' Importa. `origen` y `destino` son raíces de repositorio. Con `escribir = FALSE` solo informa.
importar_registro_l0 <- function(origen, destino = ".", escribir = TRUE) {
  rutas <- function(r) list(man = file.path(r, "data", "L0_raw", "manifiesto.csv"),
                            vin = file.path(r, "catalogos", "08_vintages.csv"))
  o <- rutas(origen); d <- rutas(destino)
  for (p in c(o, d)) if (!file.exists(p)) stop("FALLO VISIBLE [importar-registro]: no existe ", p, call. = FALSE)
  plan <- planear_importacion(.leer_registro(o$man), .leer_registro(o$vin),
                              .leer_registro(d$man), .leer_registro(d$vin),
                              publicaciones_catalogo(file.path(destino, "catalogos", "01_publicaciones")))
  message("Filas nuevas para SIE-sv: ", length(plan$vintage_ids))
  for (v in plan$vintage_ids) message("   + ", v)
  if (length(plan$ignorados)) {
    message("Ignoradas (publicacion sin ficha en SIE-sv): ", length(plan$ignorados))
    for (v in plan$ignorados) message("   - ", v)
  }
  if (escribir) {
    .agregar_lineas(d$man, plan$lineas_manifiesto)
    .agregar_lineas(d$vin, plan$lineas_vintages)
  }
  invisible(plan)
}
