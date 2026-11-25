# Orquestación del pipeline. Ver CLAUDE.md antes de añadir objetivos nuevos.
# Cada objetivo tiene su orden detrás. Los de pronósticos salieron en la Fase 0 de SIE-sv (ADR-011).

.PHONY: setup raw raw-rapido raw-calendario raw-plan raw-fisico materializar-l0 sincronizar-l0 clean master validate test audit trace

setup:
	Rscript scripts/bootstrap_renv.R

# Fase 2 — verificación de integridad de L0, en dos pasos que responden preguntas distintas
# (Decisión 1b, 2026-08-25; cobertura corregida 2026-08-28, hallazgos A1 y B1 de la auditoría
# de Fase 2). Objetivo LOCAL: el segundo paso usa navegador headless y sale a la red, no corre
# en CI. La captura de un vintage nuevo es un acto deliberado vía descargar_*(), no desde aquí
# (ADR-007).
#   1. ¿Están los archivos en disco, íntegros?      -> verificar_l0_fisico.R (offline)
#   2. ¿La fuente sigue sirviendo lo mismo?         -> verificar_l0.R        (en vivo)
# El paso 1 va primero para fallar barato: si L0 está rota en disco no tiene sentido
# levantar un navegador 16 veces.
raw: raw-fisico
	Rscript scripts/verificar_l0.R

# Precheck barato del portal del BCR (NO reemplaza a `raw`): nivel 1 por calendario + nivel 2
# por sondeo del ultimo periodo, sin renderizar tablas. No ve revisiones de valores viejos.
raw-rapido: raw-fisico
	Rscript scripts/verificar_l0_rapido.R

# Solo el nivel 1 (calendario): sin red ni navegador.
raw-calendario:
	Rscript scripts/verificar_l0_rapido.R calendario

# Solo el disco. Sin red, sin navegador.
raw-fisico:
	Rscript scripts/verificar_l0_fisico.R

# No pide nada a ninguna fuente: solo lista qué se verificaría y qué está excluido.
raw-plan:
	Rscript scripts/verificar_l0.R plan

# Repuebla data/L0_raw/ desde el almacén canónico local (copia de trabajo del repo privado
# de L0), luego verifica integridad. Requiere SIE_L0_STORE apuntando a ese directorio. No
# descarga de ninguna fuente ni toca el manifiesto — ver scripts/materializar_l0.R.
materializar-l0:
	Rscript scripts/materializar_l0.R
	Rscript scripts/verificar_l0_fisico.R

# F7-14: sincroniza data/L0_raw/ con el almacen en las dos direcciones; sube lo nuevo con commit y push.
# Correr despues de cada captura, antes del PR que registra el manifiesto. Requiere SIE_L0_STORE.
sincronizar-l0:
	Rscript scripts/sincronizar_l0.R
	Rscript scripts/verificar_l0_fisico.R

# Fase 3 — L0 -> L1 -> L2 -> L3, transformaciones y series maestras.
#
# Conjunto de vintages declarado (PR-3): `make master CONJUNTO=<ruta.csv> SALIDA=<dir>` construye
# L1, L2 y L3 con los vintages que declara el CSV (publicacion_id,vintage_id) y los escribe en
# <dir>/L1_staging, <dir>/L2_validated y <dir>/L3_master, sin tocar la L1/L2/L3 vigentes. Ambas
# variables se exigen juntas; SALIDA no puede caer en una capa vigente de data/ (se recomienda
# data/conjuntos/<nombre>/, en .gitignore). Sin ellas, todo igual que siempre. El primer paso
# valida el conjunto ENTERO antes de escribir nada (src/transformacion/validar_conjunto.R).
# Los nombres CONJUNTO/SALIDA llegan a los scripts como SIE_CONJUNTO/SIE_SALIDA.
ifneq ($(strip $(CONJUNTO)$(SALIDA)),)
export SIE_CONJUNTO := $(CONJUNTO)
export SIE_SALIDA := $(SALIDA)
endif

master: validate
	Rscript src/transformacion/validar_conjunto.R
	Rscript src/transformacion/extraer_bcr_pib.R
	Rscript src/transformacion/ut_demanda_serie.R
	Rscript src/transformacion/extraer_bcr_ivae.R
	Rscript src/transformacion/extraer_bcr_remesas.R
	Rscript src/transformacion/extraer_onec_ipc.R
	Rscript src/transformacion/extraer_bcr_ipp.R
	Rscript src/transformacion/extraer_bcr_balanza_comercial.R
	Rscript src/transformacion/extraer_bcr_itcer.R
	Rscript src/transformacion/extraer_bcr_indices_precios_comercio_exterior.R
	Rscript src/validacion/validar_l2_pib.R
	Rscript src/validacion/validar_l2_predictores.R
	Rscript src/transformacion/l3_pib_objetivo.R
	Rscript src/transformacion/l3_predictores.R

# Validación de esquema de catálogos (columnas/tipos) e integridad referencial entre ellos.
validate:
	Rscript src/validacion/validate_catalogs.R
	Rscript src/validacion/validar_integridad_catalogos.R

# Fase 3 — G1/G2 del checklist de cierre: trazabilidad valor -> celda contra L0, certificada
# como target y no solo a mano (senda §4, "cada valor de la base maestra puede rastrearse hasta
# la celda del archivo original"). Deliberadamente FUERA de `validate`/`master`: exige los
# .xlsx de L0 en disco, que están en .gitignore (ADR-008) y no existen en CI ni en una máquina
# recién clonada -- mismo motivo que separa `raw` de `validate`. Las filas NO_VERIFICABLE son
# informativas (salida 0), así que correrlo sin L0 completa no rompe nada, pero tampoco prueba
# nada: para cobertura real hace falta L0 materializada (`make materializar-l0`). Regla 8 de
# CLAUDE.md: cada corrida real se asienta en doc/bitacora_verificaciones.md, en el mismo commit
# que usa su resultado -- correr este target no exime de esa entrada.
trace:
	Rscript src/validacion/verificar_fuente_celda.R

test:
	Rscript -e 'testthat::test_dir("tests")'

# Factsheet de orientación pre-auditoría: conteos, integridad referencial,
# L0, ADR, auditorías, claves y licencias. No es validación — no detiene nada.
audit:
	Rscript scripts/auditoria_mecanica.R

clean:
	rm -rf data/L1_staging/* data/L2_validated/* data/L3_master/*
	@echo "Capas L1-L3 limpiadas. L0_raw nunca se toca desde este objetivo."
