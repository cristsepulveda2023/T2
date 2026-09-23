
# =============================================================================
# T2 — Limpieza y agregación con dplyr #
# Autor: Cristóbal Ignacio Sepúlveda Sepúlveda
# Fecha: 2026-09-21
# Qué hace: compara el ingreso por año de educación entre Ñuble y el resto
#           de las regiones, usando los cinco verbos de dplyr.
#
# PREGUNTA: ¿Rinde más cada año de educación en Ñuble que en las demás
#           regiones del centro-sur, y cuánto vale esa diferencia en pesos?
# =============================================================================

library(dplyr)

casen    <- read.csv("data/raw/casen_reducido.csv")
ingresos <- read.csv("data/raw/casen_ingresos.csv")

# --- Auditoría antes de analizar --------------------------------------------

str(casen) 
# verifico que ingreso y educ no lleguen como texto -> ambas numéricas, ok

dim(casen) 
# verifico las 60 observaciones -> 60 x 6, coincide con el enunciado

summary(casen$ingreso)
# reviso coherencia -> rango 180.000 a 1.093.000, sin negativos

sum(is.na(casen$ingreso)) 
# registro los NA -> 5

nrow(filter(casen, !is.na(ingreso))) 
# quedan 55 tras botar los NA

nrow(filter(casen, !is.na(ingreso) & edad >= 25)) 
# quedan 48 tras los dos filtros

# Uso edad >= 25 para quedarme con gente que ya terminó sus estudios; si no,
# la experiencia de Mincer daría 0 o negativa y el ingreso por año de educación
# estaría medido sobre personas que aún estudian.

# --- 2b. Elegir columnas por patrón -----------------------------------------

names(ingresos) 

names(select(ingresos, starts_with("ing")))  

# por el NOMBRE -> 4 columnas, starts_with("ing") → filtra por nombre, 
# ignora el tipo

names(select(ingresos, where(is.numeric)))    
# por el TIPO -> 7 columnas, where(is.numeric) → filtra por tipo, ignora 
# el nombre

setdiff(names(select(ingresos, where(is.numeric))),
        names(select(ingresos, starts_with("ing"))))
# Las 3 de diferencia son educ, edad y horas. Son numéricas (por eso el
# selector por tipo las toma), pero NO están en pesos: son años de estudio,
# años de vida y horas de trabajo. R conoce el tipo de dato, no su significado
# económico, así que si promediara "todas las numéricas" mezclaría pesos con
# años y me entregaría el resultado sin dar ningún error.
# Por eso para trabajar con ingresos uso starts_with("ing").

# --- Variables derivadas -----------------------------------------------------

min(casen$educ, na.rm = TRUE)   # ¿hay alguien con 0 años de educación?
sum(is.na(casen$educ))          # ¿educ tiene faltantes?
table(casen$region)             # ¿qué regiones hay realmente?

#Verificaciones previas: min(educ)=6 (nadie en 0, así que ingreso/educ no da Inf),
# 0 NA en educ (ningún faltante se cuela en el case_when) y solo 5 regiones en la
# base (Araucanía, Biobío, Maule, Metropolitana, Ñuble), que suman las 60 filas.

casen <- casen |>
  mutate(
    # Experiencia potencial de Mincer: años que lleva alguien en el mercado
    # laboral suponiendo que entró al terminar de estudiar. El pmax() la deja
    # en 0 en vez de negativa para quien todavía estudia.
  experiencia  = pmax(edad - educ - 6, 0),
  
  # Variable central de mi pregunta: cuánto ingreso rinde cada año de estudio.
  # Es segura porque verifiqué que educ nunca vale 0.
    ing_por_educ = ingreso / educ,
  
  # Agrupo las 5 regiones en las 3 zonas que mi pregunta compara.
    zona = case_when(
      region == "Ñuble"                             ~ "Ñuble",
      region %in% c("Biobío", "Maule", "Araucanía") ~ "Resto centro-sur",
      TRUE                                          ~ "Metropolitana"
    ),
  
  # Tramos educativos. Uso factor() con levels para fijar el orden: sin él,
  # las tablas ordenarían alfabéticamente ("Media completa" antes que
  # "Sin media completa"), que no es el orden lógico.
    nivel_educ = factor(
      case_when(
        educ <  12 ~ "Sin media completa",
        educ == 12 ~ "Media completa",
        TRUE       ~ "Superior"
      ),
      levels = c("Sin media completa", "Media completa", "Superior")
    )
  )

# Verifico que ningún caso quedó en NA tras los case_when:

table(casen$zona, useNA = "ifany")         # 12 / 15 / 33, suman 60, ningún NA
table(casen$nivel_educ, useNA = "ifany")   # 23 / 7 / 30, suman 60; ojo: "Media
                                           # completa" son solo 7 casos
summary(casen$experiencia)                 # 0 a 53 años, mediana 27

# --- Tratamiento explícito de los NA ----------------------------------------

mean(casen$ingreso)                 # sin na.rm -> devuelve NA, no un promedio:
                                    # R no avisa de los faltantes, solo contagia
mean(casen$ingreso, na.rm = TRUE)   # con na.rm -> 655.291
sum(is.na(casen$ingreso))           # 5 faltantes, los que el enunciado avisó

table(casen$region[is.na(casen$ingreso)])
# Dónde caen esos 5: Ñuble 2, Araucanía 1, Maule 1, Metropolitana 1, Biobío 0.
# Están repartidos, no concentrados en una región. Eso importa: si los 5 hubieran
# caído en Ñuble, botarlos habría vaciado justo el grupo que quiero estudiar.

# COMENTARIO: de las 60 filas pierdo 5 por NA en ingreso y 7 por el filtro de
# edad -> quedan 48. De esas, excluyo las 8 de Metropolitana porque mi pregunta
# compara Ñuble con el resto del CENTRO-SUR, y la RM no lo es: esa exclusión es
# una decisión de alcance, no una pérdida de datos.
# Trabajo entonces con 40 casos: Ñuble 12, Maule 10, Biobío 9, Araucanía 9.
# Ñuble pierde 2 de sus 15 por NA y aun así es la región con más casos.

# --- Muestra de trabajo ------------------------------------------------------

# Defino el subconjunto una sola vez y lo reutilizo en todas las agregaciones,
# así no puedo desincronizar los filtros entre una tabla y otra.
# Condición combinada: los paréntesis son obligatorios porque & se evalúa antes
# que |. Sin ellos R leería "Ñuble a cualquier edad O resto centro-sur de 25+",
# que responde otra pregunta.

base <- casen |>
  filter((zona == "Ñuble" | zona == "Resto centro-sur") &
           edad >= 25 & !is.na(ingreso))

nrow(base)                 # 40
table(base$region)         # Ñuble 12, Maule 10, Biobío 9, Araucanía 9

# --- Agregación 1: ingreso por año de educación, por región -----------------

# Primera agregación: UN grupo (region). Colapsa las 40 personas en 4 filas.
# Reporto n() junto a cada promedio porque un promedio de 9 personas no merece
# la misma confianza que uno de 12.

resultado <- base |>
  # Reduzco a las columnas que uso: con 6 la tabla se lee, con 60 no.
  select(region, zona, nivel_educ, educ, ingreso, ing_por_educ) |>
  group_by(region) |>
  summarise(
    n        = n(),
    ing_prom = mean(ingreso, na.rm = TRUE),
    # Promedio de los cocientes individuales, no cociente de los promedios:
    # cada persona pesa igual, así que mido el rendimiento de la persona típica
    # y no el del agregado regional. Son números distintos.
    ipe_prom = mean(ing_por_educ, na.rm = TRUE)
  ) |>
  # Ordeno por ipe_prom porque es la variable que responde mi pregunta.
  arrange(desc(ipe_prom))

resultado

# --- Agregación 2: zona x nivel educativo -----------------------------------

# Segunda agregación: DOS grupos cruzados. Cada fila es una combinación
# zona x nivel educativo, así que veo si la ventaja de Ñuble se sostiene
# dentro de cada tramo de educación o solo aparece en el promedio general.

resultado2 <- base |>
  group_by(zona, nivel_educ) |>
  summarise(
    n        = n(),
    ing_prom = mean(ingreso, na.rm = TRUE),
    ipe_prom = mean(ing_por_educ, na.rm = TRUE),
    # .groups = "drop" desagrupa el resultado. Sin esto la tabla queda agrupada
    # por zona y cualquier cálculo posterior se haría por grupo sin avisarme.
    .groups  = "drop"
  ) |>
  # Ordeno por las dos variables de agrupación para leer la tabla como grilla.
  arrange(zona, nivel_educ)

resultado2

# OJO: la celda Ñuble / Media completa tiene n = 1. Ese "promedio" es una sola
# persona, así que no la uso como evidencia. Las celdas con Sin media completa
# (7 y 8 casos) y Superior (4 y 16) son las únicas comparables, y aun así la de
# Ñuble / Superior son solo 4 personas.

# --- Comparación: cada persona vs. el promedio de su región -----------------

# Aquí uso group_by() + mutate() en vez de summarise(): mutate() NO colapsa,
# devuelve las 40 filas originales pero con la cifra de su grupo pegada al lado.

casen_brecha <- base |>
  group_by(region) |>
  mutate(ing_prom_region = mean(ingreso, na.rm = TRUE),
         brecha          = ingreso - ing_prom_region) |>
  # ungroup() quita la agrupación: si no lo hago, la tabla queda agrupada por
  # región y el arrange() de abajo ordenaría dentro de cada región, no global.
  ungroup() |>
  select(region, ingreso, ing_prom_region, brecha) |>
  arrange(desc(brecha))

head(casen_brecha, 5)
nrow(casen_brecha)   # 40: mutate conserva todas las filas, summarise las colapsa a 4

# Esto responde algo que resultado (con summarise) no puede: identifica a
# personas específicas por sobre o bajo el promedio de SU región, no solo
# compara regiones entre sí.

