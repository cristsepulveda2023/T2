# =============================================================================
# Laboratorio Semana 5 — Un análisis completo con dplyr
# Fundamentos de Programación para Análisis Económico · UdeC-EAN
#
# Autor: [TU NOMBRE]
# Fecha: [FECHA]
#
# Objetivo: responder UNA pregunta económica de principio a fin usando los
#           cinco verbos, group_by() y el pipe. Es el ensayo directo de la
#           T2 (calificada, 13 %): el mismo formato, otra pregunta.
#
# Regla IA: ChatGPT es CONSULTOR, no escritor. Debes poder explicar cada línea.
# =============================================================================

library(dplyr)

# Se ejecuta desde la RAÍZ del proyecto
casen    <- read.csv("data/raw/casen_reducido.csv")
ingresos <- read.csv("data/raw/casen_ingresos.csv")   # mismas 60 personas,
                                                      # con el ingreso desagregado


# -----------------------------------------------------------------------------
# PASO 1 — Tu pregunta
# -----------------------------------------------------------------------------
# Antes de escribir código: ¿qué quieres saber? Debe ser respondible con estas
# 6 columnas (region, sector, educ, edad, ingreso, genero).
#
# Prueba de calidad: si puedes describir en una frase el GRÁFICO que sería la
# respuesta, la pregunta está bien planteada.
#
# TODO: escribe tu pregunta aquí.
#
# MI PREGUNTA: ______________________________________________________________
#
# Ejemplos del nivel esperado (elige otra, no copies):
#   - ¿En qué región rinde más cada año de educación?
#   - ¿La brecha de ingreso por género es igual en todos los sectores?
#   - ¿Los trabajadores con más experiencia ganan más, o llega un punto donde no?


# -----------------------------------------------------------------------------
# PASO 2 — Auditar antes de analizar
# -----------------------------------------------------------------------------
# TODO: completa las cuatro líneas de inspección.

str(casen)
dim(casen)
summary(casen$ingreso)      # fíjate en la línea NA's
sum(is.na(casen$____))      # ¿cuántos faltantes hay en ingreso?

# TODO: anota lo que encontraste.
# FILAS: ____   COLUMNAS: ____   FALTANTES EN INGRESO: ____


# -----------------------------------------------------------------------------
# PASO 2b — Elegir columnas cuando son muchas
# -----------------------------------------------------------------------------
# `ingresos` trae el ingreso abierto por fuente. En una base real esto no son
# 4 columnas sino 40: escribirlas a mano deja de ser opción.
# TODO: completa los dos selectores.

names(ingresos)

names(select(ingresos, ____("ing")))       # por cómo EMPIEZA el nombre
names(select(ingresos, where(____)))       # por el TIPO de contenido (numérico)

# ✅ Deberías ver 4 columnas en el primero y 7 en el segundo.
#
# TODO: responde en un comentario.
# ¿Por qué el segundo devuelve MÁS columnas que el primero? ___________________
#
# ⚠️ Elegir mal el selector NO da error: el código corre igual, sobre columnas
#    que no querías. Revisa siempre los nombres antes de seguir.
#
# 💡 where(is.numeric) es lo primero que se escribe al calcular descriptivos:
#    nadie quiere el promedio de la columna `region`.


# -----------------------------------------------------------------------------
# PASO 3 — Preparar las variables (mutate)
# -----------------------------------------------------------------------------
# TODO: crea la experiencia potencial de Mincer y AL MENOS una variable propia
#       que tu pregunta necesite.

casen <- casen |>
  mutate(
    experiencia = pmax(edad - ____ - 6, 0),
    # TODO: tu variable derivada (ej. ingreso_por_educ, superior, tramo_edad...)
    ____ = ____
  )

# Recuerda las dos herramientas para clasificar (S5S1):
#   if_else()   -> cuando hay SOLO DOS casos
#   case_when() -> cuando hay TRES O MÁS
#
# TODO (si tu variable tiene 3+ categorías): complétala con case_when().
#       Ojo: gana la PRIMERA condición que se cumple, y conviene cerrar
#       con TRUE ~ "..." para que nada quede en NA.

casen <- casen |>
  mutate(
    nivel_educ = case_when(
      educ <  12 ~ "Sin media completa",
      educ == 12 ~ "____",
      TRUE       ~ "Superior"
    )
  )

# TODO: verifica que quedaron bien creadas y que NINGUNA quedó en NA.
summary(casen$experiencia)
table(casen$nivel_educ, useNA = "ifany")

# ✅ Deberías ver, en table(): 23 sin media completa, 7 media completa,
#    30 superior. Si aparece una columna <NA>, tu case_when() dejó filas fuera.


# -----------------------------------------------------------------------------
# PASO 4 — Responder con una cadena de verbos
# -----------------------------------------------------------------------------
# TODO: escribe UNA cadena que responda tu pregunta. Debe incluir al menos
#       group_by() + summarise() + arrange(), y reportar n().

resultado <- casen |>
  filter(____) |>            # ¿a quiénes necesitas? (¡ojo con los NA!)
  group_by(____) |>          # ¿por qué grupo se parte la pregunta?
  summarise(
    n   = n(),               # NUNCA lo omitas
    ____ = ____
  ) |>
  arrange(desc(____))

resultado

# TODO: tu filter() de arriba debe incluir AL MENOS UNA condición combinada,
#       con & (Y) o con | (O). Por ejemplo:
#         filter(casen, !is.na(ingreso) & edad >= 25)
#         filter(casen, region == "Ñuble" | region == "Biobío")
#
# ⚠️ EL ERROR QUE MÁS PASA INADVERTIDO: & se evalúa ANTES que |, igual que la
#    multiplicación antes que la suma. Compruébalo:

nrow(filter(casen, (region == "Ñuble" | region == "Biobío") & educ > 12))
nrow(filter(casen, region == "Ñuble" | region == "Biobío" & educ > 12))

# ✅ Deberías ver: 10 y 20. R no avisa: la segunda responde OTRA pregunta.
#    REGLA: si mezclas & con |, pon paréntesis SIEMPRE.


# -----------------------------------------------------------------------------
# PASO 5 — Mirar el resultado con desconfianza
# -----------------------------------------------------------------------------
# Antes de interpretar, revisa la columna n.
#
# TODO: responde en comentarios.
# ¿Algún grupo tiene n muy chico (menos de 8)? ¿Cuál? ____
# ¿Ese promedio es confiable? ¿Qué haces al respecto? ____
#
# TODO (si corresponde): agrega un filter(n >= 8) después del summarise y
#       compara. ¿Cambia el ranking?


# -----------------------------------------------------------------------------
# PASO 6 — Interpretar (la parte que de verdad importa)
# -----------------------------------------------------------------------------
# TODO: escribe 5 a 8 líneas respondiendo tu pregunta.
#
# Tres exigencias no negociables:
#   1. Cifras EN PESOS, no "es más alto".
#   2. "Se asocia", NUNCA "causa".
#   3. Al menos una limitación de estos datos.
#
# INTERPRETACIÓN:
# ____________________________________________________________________________
# ____________________________________________________________________________
# ____________________________________________________________________________
# ____________________________________________________________________________
#
# LIMITACIÓN: __________________________________________________________________


# -----------------------------------------------------------------------------
# PASO 7 — Guardar el dataset limpio
# -----------------------------------------------------------------------------
# Los datos CRUDOS nunca se tocan: se leen desde data/raw/ y se dejan como
# están. Lo que tú construiste (experiencia, nivel_educ, tu variable) es un
# producto NUEVO, y va a data/processed/.
#
# TODO: completa el nombre del archivo y guárdalo.

dir.create("data/processed", showWarnings = FALSE)
write.csv(casen, "data/processed/____.csv", row.names = FALSE)

# ⚠️ NO lo llames casen_limpio.csv: ese nombre lo ocupa el laboratorio de la
#    Semana 6 y lo sobrescribirías. Usa algo como casen_s5_derivadas.csv.

# TODO: comprueba que el archivo quedó y que se puede volver a leer.
file.exists("data/processed/____.csv")

# ✅ Deberías ver: TRUE
#
# 💡 Este es el corte entre "explorar" y "producir". El archivo de
#    data/processed/ es el que alimentaría un informe o una regresión, sin
#    tener que volver a correr toda la limpieza.
#
# TODO: responde en un comentario.
# ¿Por qué NO guardamos encima de data/raw/casen_reducido.csv? ______________


# -----------------------------------------------------------------------------
# PASO 8 (desafío opcional) — Cruzar dos variables
# -----------------------------------------------------------------------------
# Agrupa por DOS variables y mira si el patrón que encontraste se mantiene en
# todos los subgrupos, o si aparece algo inesperado.
#
# TODO (opcional):

# casen |>
#   group_by(____, ____) |>
#   summarise(n = n(), ing = mean(ingreso, na.rm = TRUE), .groups = "drop") |>
#   arrange(desc(ing))


# -----------------------------------------------------------------------------
# PASO 9 (desafío opcional) — La brecha de cada persona (S5S2)
# -----------------------------------------------------------------------------
# Hasta aquí comparaste GRUPOS entre sí. Ahora compara a cada PERSONA con el
# promedio de su grupo: group_by() + mutate() conserva las 60 filas.
#
# TODO (opcional): ¿quiénes están más por debajo del promedio de su sector?

# casen |>
#   group_by(sector) |>
#   mutate(brecha = ingreso - mean(ingreso, na.rm = TRUE)) |>
#   ungroup() |>
#   arrange(____) |>
#   select(sector, ingreso, brecha) |>
#   head(5)


# -----------------------------------------------------------------------------
# AUTOEVALUACIÓN antes de entregar
# -----------------------------------------------------------------------------
# [ ] El script corre COMPLETO de una vez (prueba: reinicia R y córrelo todo).
# [ ] Mi pregunta está escrita y mi cadena la responde.
# [ ] Usé los 5 verbos + group_by + arrange.
# [ ] Usé un selector por patrón (starts_with / where) al menos una vez.
# [ ] Mi filter() combina condiciones, y si mezcla & con | lleva paréntesis.
# [ ] Mi clasificación usa case_when() si tiene 3+ categorías, y no dejó NA.
# [ ] Reporté n() en cada resumen.
# [ ] Traté los NA explícitamente.
# [ ] Guardé el dataset derivado en data/processed/, sin tocar data/raw/.
# [ ] Interpreté en pesos, sin lenguaje causal, con una limitación.
# [ ] Mis comentarios explican POR QUÉ, no repiten el QUÉ.


# -----------------------------------------------------------------------------
# ENTREGA: guarda este script y súbelo a tu repositorio de GitHub.
# Commit sugerido: "Lab S5: análisis con dplyr"
#
# Este laboratorio es el ensayo de la T2. Si lo completaste bien, la tarea
# calificada es la misma cosa con tu propia pregunta.
# -----------------------------------------------------------------------------
