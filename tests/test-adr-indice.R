# tests/test-adr-indice.R
#
# Guard anti-regresión para el índice de ADR.
#
# La celda "Estado" de cada fila de doc/adr/README.md debe ser copia literal de
# la línea **Estado:** del ADR correspondiente. Es una regla ya escrita en ese
# índice ("Se verifica con un grep; en Fase 3 corresponde un test_that() que lo
# compruebe automáticamente"); este archivo la implementa.
#
# Ataca el modo de falla que recurrió en las auditorías: una enmienda a un ADR
# que no se propaga al índice (Fase 0, hallazgos C2/C3; verificación de Fase 1,
# hallazgo C1). Cuando pasa, dos archivos del mismo directorio afirman cosas
# opuestas sobre el mismo hecho y sólo una auditoría manual lo detecta. Con este
# test lo detecta CI en el commit que introduce la deriva.
#
# No depende de los .xlsx (sólo lee texto), así que corre en CI vía
# testthat::test_dir("tests") sin ningún cambio en .github/workflows/ci.yml.

library(testthat)

.leer_utf8 <- function(ruta) readLines(ruta, encoding = "UTF-8", warn = FALSE)

test_that("la celda Estado del índice coincide con la línea **Estado:** de cada ADR", {
  ruta_indice <- here::here("doc", "adr", "README.md")
  expect_true(file.exists(ruta_indice), info = "falta doc/adr/README.md")

  lineas_indice <- .leer_utf8(ruta_indice)

  # Fila de la tabla: | [008](./ADR-008-....md) | Decisión | <estado> |
  # Grupos: 1 = número, 2 = archivo del ADR, 3 = celda de estado.
  patron_fila <- "^\\|\\s*\\[(\\d{3})\\]\\(\\./(ADR-\\d{3}[^)]+\\.md)\\)\\s*\\|.*\\|\\s*(.*?)\\s*\\|\\s*$"
  m <- regmatches(lineas_indice, regexec(patron_fila, lineas_indice, perl = TRUE))
  filas <- Filter(function(x) length(x) == 4L, m)

  # El índice debe tener filas parseables; si el formato de la tabla cambió y
  # ninguna fila matchea, esto es un fallo — no un pase vacío silencioso.
  expect_gt(length(filas), 0L)

  archivos      <- vapply(filas, function(x) x[[3]], character(1))
  estado_indice <- vapply(filas, function(x) trimws(x[[4]]), character(1))
  names(estado_indice) <- archivos

  for (archivo_adr in archivos) {
    ruta_adr <- here::here("doc", "adr", archivo_adr)
    expect_true(
      file.exists(ruta_adr),
      info = paste("el índice referencia un ADR inexistente:", archivo_adr)
    )

    lineas_adr   <- .leer_utf8(ruta_adr)
    linea_estado <- grep("^\\*\\*Estado:\\*\\*", lineas_adr, value = TRUE)

    # Exactamente una línea **Estado:** por ADR (assertion explícita).
    expect_length(linea_estado, 1L)

    estado_adr <- if (length(linea_estado) == 1L) {
      trimws(sub("^\\*\\*Estado:\\*\\*", "", linea_estado[[1]]))
    } else {
      NA_character_
    }

    expect_identical(
      estado_indice[[archivo_adr]], estado_adr,
      info = paste0(
        "divergencia en ", archivo_adr, "\n",
        "  índice: ", estado_indice[[archivo_adr]], "\n",
        "  ADR:    ", estado_adr, "\n",
        "El ADR manda: actualizar la celda del índice en doc/adr/README.md."
      )
    )
  }
})

# Guard hermano: ataca la reincidencia del modo de falla en CLAUDE.md y el README.md raíz -- los dos archivos que un
# tercero lee primero, y que el test de arriba no cubre porque no son un ADR (auditoría independiente de Fase 2 de
# SIE-el-salvador, hallazgo C1, 2026-09-15).
#
# SIE-sv (2026-11-22, ADR-011): se cuentan solo los cierres «## Cierre de Fase N de SIE-sv (AAAA-MM-DD)». Los cierres
# heredados de SIE-el-salvador están en doc/historico/cierres_SIE-el-salvador.md y no entran. Mientras no haya ningún
# cierre de SIE-sv, la Fase 0 de SIE-sv tiene que figurar como abierta en los dos archivos.
.PATRON_CIERRE_SV <- "^## Cierre de Fase (\\d+) de SIE-sv"

.cierres_sv <- function() {
  indice <- .leer_utf8(here::here("doc", "adr", "README.md"))
  ini <- grep(.PATRON_CIERRE_SV, indice)
  list(indice = indice, ini = ini,
       fases = as.integer(sub(paste0(.PATRON_CIERRE_SV, ".*$"), "\\1", indice[ini])))
}

test_that("CLAUDE.md y README.md declaran el estado de la última fase de SIE-sv que certifica el índice", {
  c <- .cierres_sv()
  texto_claude <- paste(.leer_utf8(here::here("CLAUDE.md")), collapse = " ")
  texto_readme <- paste(.leer_utf8(here::here("README.md")), collapse = " ")

  if (length(c$ini) == 0L) {
    for (txt in list(claude = texto_claude, readme = texto_readme)) {
      expect_true(grepl("Fase 0 de SIE-sv abierta", txt, fixed = TRUE),
                  info = "sin cierres de SIE-sv, CLAUDE.md y README.md deben decir «Fase 0 de SIE-sv abierta»")
    }
    return(invisible())
  }

  fase_max <- max(c$fases)
  patron_cerrada <- sprintf("Fase %d de SIE-sv[^.]*?cerrada", fase_max)
  expect_true(grepl(patron_cerrada, texto_claude, ignore.case = TRUE, perl = TRUE),
              info = sprintf("CLAUDE.md no declara cerrada la Fase %d de SIE-sv.", fase_max))
  expect_true(grepl(patron_cerrada, texto_readme, ignore.case = TRUE, perl = TRUE),
              info = sprintf("README.md no declara cerrada la Fase %d de SIE-sv.", fase_max))
  for (n in c$fases) {
    patron_en_curso <- sprintf("Fase %d de SIE-sv[^.]*?en curso", n)
    expect_false(grepl(patron_en_curso, texto_claude, ignore.case = TRUE, perl = TRUE),
                 info = sprintf("CLAUDE.md describe la Fase %d de SIE-sv como \"en curso\".", n))
    expect_false(grepl(patron_en_curso, texto_readme, ignore.case = TRUE, perl = TRUE),
                 info = sprintf("README.md describe la Fase %d de SIE-sv como \"en curso\".", n))
  }
})

# Guard hermano (hallazgo M1 de la auditoría independiente de Fase 4 de SIE-el-salvador). CITATION.cff declara la
# versión del tag y la fecha del último cierre de SIE-sv. Antes del primer cierre, la versión es 0.0.x. No usa
# `git tag`: actions/checkout no trae tags. El tag acepta vX.Y.Z-faseN o vX.Y.Z-sv-faseN (el nombre se decide al
# cerrar la Fase 0 de SIE-sv).
test_that("CITATION.cff declara la versión y la fecha del último cierre de SIE-sv", {
  c <- .cierres_sv()
  cff <- .leer_utf8(here::here("CITATION.cff"))
  version_cff <- trimws(sub("^version:\\s*", "", grep("^version:", cff, value = TRUE)))
  fecha_cff   <- trimws(sub("^date-released:\\s*", "", grep("^date-released:", cff, value = TRUE)))
  expect_length(version_cff, 1L)

  if (length(c$ini) == 0L) {
    expect_match(version_cff, "^0\\.0\\.\\d+$",
                 info = "sin cierres de SIE-sv, CITATION.cff lleva una versión 0.0.x")
    return(invisible())
  }

  k <- c$ini[which.max(c$fases)]
  fecha_cierre <- sub("^.*\\((\\d{4}-\\d{2}-\\d{2})\\).*$", "\\1", c$indice[k])
  expect_match(fecha_cierre, "^\\d{4}-\\d{2}-\\d{2}$")
  sig <- grep("^## ", c$indice)
  fin <- min(c(sig[sig > k], length(c$indice) + 1L)) - 1L
  seccion <- paste(c$indice[k:fin], collapse = " ")
  tag <- regmatches(seccion, regexpr(sprintf("v\\d+\\.\\d+\\.\\d+-(sv-)?fase%d", max(c$fases)), seccion, perl = TRUE))
  expect_length(tag, 1L)
  version_tag <- sub("^v(\\d+\\.\\d+\\.\\d+)-.*$", "\\1", tag)
  expect_identical(version_cff, version_tag,
    info = sprintf("CITATION.cff dice version %s; el último cierre de SIE-sv certifica %s", version_cff, tag))
  expect_identical(fecha_cff, fecha_cierre,
    info = sprintf("CITATION.cff dice date-released %s; el último cierre es del %s", fecha_cff, fecha_cierre))
})
