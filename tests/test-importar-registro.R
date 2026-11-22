# tests/test-importar-registro.R
# Importacion de filas del registro de L0 desde SIE-el-salvador (src/adquisicion/importar_registro_lib.R).

source(here::here("src", "adquisicion", "importar_registro_lib.R"))

.reg <- function(enc, filas) {
  t <- tempfile(fileext = ".csv"); writeLines(c(enc, filas), t)
  .leer_registro(t)
}
ENC_M <- '"archivo","sha256","vintage_id","publicacion_id"'
ENC_V <- '"vintage_id","publicacion_id","periodo_referencia_max"'
fm <- function(v, p, sha = "aa") sprintf('"%s.xlsx","%s","%s","%s"', v, sha, v, p)
fv <- function(v, p) sprintf('"%s","%s","2026-M10"', v, p)

test_that("importa solo publicaciones del catalogo de destino y no repite vintages", {
  mo <- .reg(ENC_M, c(fm("BCR.IVAE.v2026-10", "BCR.IVAE"), fm("BCR.IVAE.v2026-11", "BCR.IVAE"), fm("FRED.X.v2026-11", "FRED.X")))
  vo <- .reg(ENC_V, c(fv("BCR.IVAE.v2026-10", "BCR.IVAE"), fv("BCR.IVAE.v2026-11", "BCR.IVAE"), fv("FRED.X.v2026-11", "FRED.X")))
  md <- .reg(ENC_M, fm("BCR.IVAE.v2026-10", "BCR.IVAE"))
  vd <- .reg(ENC_V, fv("BCR.IVAE.v2026-10", "BCR.IVAE"))
  p <- planear_importacion(mo, vo, md, vd, "BCR.IVAE")
  expect_identical(p$vintage_ids, "BCR.IVAE.v2026-11")
  expect_identical(p$lineas_manifiesto, fm("BCR.IVAE.v2026-11", "BCR.IVAE"))
  expect_identical(p$lineas_vintages, fv("BCR.IVAE.v2026-11", "BCR.IVAE"))
  expect_identical(p$ignorados, "FRED.X.v2026-11")
})

test_that("falla si un vintage existe en destino con otro sha256", {
  mo <- .reg(ENC_M, fm("BCR.IVAE.v2026-10", "BCR.IVAE", "aa")); vo <- .reg(ENC_V, fv("BCR.IVAE.v2026-10", "BCR.IVAE"))
  md <- .reg(ENC_M, fm("BCR.IVAE.v2026-10", "BCR.IVAE", "bb")); vd <- .reg(ENC_V, fv("BCR.IVAE.v2026-10", "BCR.IVAE"))
  expect_error(planear_importacion(mo, vo, md, vd, "BCR.IVAE"), "otro sha256")
})

test_that("falla si en el origen manifiesto y 08_vintages no coinciden", {
  mo <- .reg(ENC_M, fm("BCR.IVAE.v2026-11", "BCR.IVAE")); vo <- .reg(ENC_V, character(0))
  md <- .reg(ENC_M, character(0)); vd <- .reg(ENC_V, character(0))
  expect_error(planear_importacion(mo, vo, md, vd, "BCR.IVAE"), "no coinciden")
})

test_that("importar_registro_l0 agrega las lineas tal cual y una segunda corrida no agrega nada", {
  raiz <- function() {
    r <- tempfile(); dir.create(file.path(r, "data", "L0_raw"), recursive = TRUE)
    dir.create(file.path(r, "catalogos", "01_publicaciones"), recursive = TRUE); r
  }
  o <- raiz(); d <- raiz()
  writeLines(c(ENC_M, fm("BCR.IVAE.v2026-10", "BCR.IVAE"), fm("BCR.IVAE.v2026-11", "BCR.IVAE")), file.path(o, "data", "L0_raw", "manifiesto.csv"))
  writeLines(c(ENC_V, fv("BCR.IVAE.v2026-10", "BCR.IVAE"), fv("BCR.IVAE.v2026-11", "BCR.IVAE")), file.path(o, "catalogos", "08_vintages.csv"))
  writeLines(c(ENC_M, fm("BCR.IVAE.v2026-10", "BCR.IVAE")), file.path(d, "data", "L0_raw", "manifiesto.csv"))
  writeLines(c(ENC_V, fv("BCR.IVAE.v2026-10", "BCR.IVAE")), file.path(d, "catalogos", "08_vintages.csv"))
  writeLines("publicacion_id: BCR.IVAE", file.path(d, "catalogos", "01_publicaciones", "BCR.IVAE.yaml"))
  suppressMessages(importar_registro_l0(o, d))
  expect_identical(readLines(file.path(d, "data", "L0_raw", "manifiesto.csv")),
                   c(ENC_M, fm("BCR.IVAE.v2026-10", "BCR.IVAE"), fm("BCR.IVAE.v2026-11", "BCR.IVAE")))
  p2 <- suppressMessages(importar_registro_l0(o, d))
  expect_length(p2$vintage_ids, 0L)
  expect_length(readLines(file.path(d, "catalogos", "08_vintages.csv")), 3L)
})
