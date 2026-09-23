# T2 — Limpieza y agregación con dplyr
### Módulo II · Semana 5 · **Tarea calificada — 13 % de la nota final**
#### Fundamentos de Programación para Análisis Económico · UdeC-EAN

**Tipo:** calificada.
**Entrega:** script `.R` comentado + `README.md`, en tu repositorio de GitHub.
**Vienes preparado si hiciste:** [A1 (S3, vectores)](tarea_semana3.md) y
[A2 (S4, data frames)](tarea_semana4.md).
**Uso de IA:** restringido (ver el final de este documento).

---

## Objetivo

Responder una **pregunta económica propia** usando los cinco verbos de dplyr y
`group_by()`, y **explicar en palabras** lo que muestran los números.

> Datos: `data/raw/casen_reducido.csv` (60 filas · `region`, `sector`, `educ`,
> `edad`, `ingreso`, `genero`). Recuerda: hay **5 valores faltantes en `ingreso`**
> puestos a propósito — parte de la tarea es tratarlos bien.
>
> Datos de apoyo: `data/raw/casen_ingresos.csv` — **las mismas 60 personas**, con
> el ingreso abierto por fuente (`ing_trabajo`, `ing_capital`, `ing_subsidios`,
> `ing_total`) más `horas`. Se usa en el punto 2b.
>
> Apoyo: [referencia de dplyr y ggplot2](../materiales/referencia_tidyverse_ggplot.R)
> y el [cheatsheet de data frames](../materiales/cheatsheet_dataframes.md).

---

## Qué debes hacer

Crea un script `scripts/tarea_t2.R` con encabezado (autor, fecha, qué hace).

### 1. Declara tu pregunta (en un comentario, arriba)

Una pregunta que **estos datos puedan responder**. Por ejemplo:

- ❌ «Voy a analizar la CASEN.» → no es una pregunta.
- ✅ «¿En qué sector económico es mayor la brecha de ingreso entre hombres y
  mujeres, y cuánto vale esa brecha en pesos?»

### 2. Carga y explora

```r
casen    <- read.csv("data/raw/casen_reducido.csv")   # desde la raíz del proyecto
ingresos <- read.csv("data/raw/casen_ingresos.csv")   # base de apoyo (punto 2b)
```

Reporta dimensiones, tipos y **cuántos `NA` hay en `ingreso`**.

### 2b. Elige columnas por patrón

Sobre `casen_ingresos.csv`, usa **los dos selectores** y explica en un comentario
por qué no devuelven lo mismo:

```r
names(select(ingresos, starts_with("ing")))   # por el NOMBRE  -> 4 columnas
names(select(ingresos, where(is.numeric)))    # por el TIPO    -> 7 columnas
```

El segundo incluye `educ`, `edad` y `horas`. Elegir el selector equivocado **no
da error**: el código corre y calcula sobre columnas que no querías.

### 3. Usa los cinco verbos — al menos una vez cada uno

| Verbo | Qué debe hacer en tu script |
|---|---|
| `filter()` | quedarte con el subconjunto que tu pregunta necesita, con **al menos una condición combinada** (`&` o `\|`) |
| `select()` | reducir a las columnas que usas |
| `mutate()` | crear **al menos una** variable derivada |
| `arrange()` | ordenar el resultado por algo informativo |
| `summarise()` | calcular los estadísticos que responden tu pregunta |

En `mutate()` incluye obligatoriamente la **experiencia potencial de Mincer**:

```r
experiencia = pmax(edad - educ - 6, 0)
```

> ⚠️ **El paréntesis que cambia la respuesta.** `&` se evalúa **antes** que `|`,
> igual que la multiplicación antes que la suma:
>
> ```r
> nrow(filter(casen, (region == "Ñuble" | region == "Biobío") & educ > 12))  # 10
> nrow(filter(casen,  region == "Ñuble" | region == "Biobío"  & educ > 12))  # 20
> ```
>
> R no advierte nada: la segunda responde **otra pregunta**, correctamente. Si
> mezclas `&` con `|`, **pon paréntesis siempre**.

### 3b. Clasifica con `case_when()`

Crea **una variable categórica de tres o más niveles** que tu pregunta necesite
(tramos de edad, niveles educativos, categorías de ingreso…):

```r
nivel_educ = case_when(
  educ <  12 ~ "Sin media completa",
  educ == 12 ~ "Media completa",
  TRUE       ~ "Superior"        # cierra con TRUE: "todo lo demás"
)
```

Verifica con `table(casen$tu_variable, useNA = "ifany")` que **ninguna fila
quedó en `NA`**. Un `case_when()` incompleto no da error: deja huecos en
silencio, y esos huecos aparecen después como un grupo `NA` en tu tabla.

### 4. Agrega con `group_by()`

**(a) Dos agregaciones con `summarise()`**, que colapsan a una tabla de grupos:

- una por **un** grupo (ej. por `sector`),
- una por **dos** grupos cruzados (ej. `sector` × `genero`).

En cada una reporta `n()` además del promedio: un promedio de 2 personas no dice
lo mismo que uno de 20.

**(b) Una comparación con `group_by()` + `mutate()`**, que conserva las filas:
sitúa a cada persona respecto del promedio de su propio grupo.

```r
casen |>
  group_by(sector) |>
  mutate(brecha = ingreso - mean(ingreso, na.rm = TRUE)) |>
  ungroup()
```

Comenta qué responde esto que `summarise()` no puede responder. La distinción es
el punto central de la semana: `summarise()` entrega una tabla **de grupos**;
`mutate()` agrupado entrega una tabla **de personas** con la cifra de su grupo.

### 5. Trata los `NA` explícitamente

Usa `na.rm = TRUE` **y** deja un comentario que responda: ¿cuántos casos pierdes
y por qué es (o no es) aceptable perderlos? Comparar `mean(ingreso)` sin
`na.rm` contra el que sí lo tiene es una buena manera de mostrarlo.

### 6. Encadena con el pipe

Al menos **una** cadena de tres o más verbos con `|>`, escrita legible (un verbo
por línea).

### 7. Interpreta (esto es lo que más pesa)

En un comentario final de **5 a 10 líneas**, responde tu pregunta con los números
que obtuviste. Exigencias:

- Cifras **en pesos**, no solo «es más alto».
- Di «**se asocia**», nunca «causa».
- Menciona **una limitación** de tus datos (n pequeño, faltantes, sin controles).

---

## Rúbrica (13 % de la nota final)

| Criterio | Puntos |
|---|---:|
| Pregunta económica clara y respondible con estos datos | 10 |
| Los cinco verbos usados correctamente y con propósito | 10 |
| Variable derivada + experiencia de Mincer bien calculada | 8 |
| `case_when()` con 3+ categorías, **sin `NA` silenciosos** | 7 |
| Selector por patrón + condición combinada `&`/`\|` con paréntesis correctos | 6 |
| Dos agregaciones con `group_by()` + `summarise()`, incluyendo `n()` | 12 |
| Una comparación con `group_by()` + `mutate()`, comentada | 6 |
| Tratamiento explícito y comentado de los `NA` | 7 |
| Cadena con pipe, legible | 4 |
| **Interpretación económica** honesta, en pesos, con una limitación | 20 |
| Script reproducible (corre de principio a fin sin editar) + commits claros | 10 |
| **Total** | **100** |

> **Descuento por reproducibilidad:** si el script no corre de cero en otra
> máquina (rutas absolutas, objetos que no existen), se descuentan 15 puntos.
> Pruébalo cerrando R y corriéndolo completo antes de entregar.

---

## Entrega

1. `scripts/tarea_t2.R` en tu repositorio.
2. En el `README.md`, tres líneas: tu pregunta, tu respuesta y cómo correr el script.
3. **Avanza por commits** (no subas todo en uno): el historial es tu evidencia de trabajo.
4. Pega el enlace del repositorio en Canvas.

---

## Declaración de autoría y uso de IA

Copia este bloque al final de tu `README.md` y complétalo:

```markdown
## Declaración de autoría y uso de IA
- Herramienta utilizada: ____ (o «ninguna»)
- Para qué la usé: ____ (ej.: entender un error de group_by)
- Qué hice yo: ____ (ej.: escribí y verifiqué todo el código)
- Verificación: confirmo que entiendo y puedo explicar todo lo que entrego.
```

**Uso permitido:** pedir que te expliquen un error, preguntar qué hace una
función, pedir alternativas a un código que ya escribiste, revisar la redacción
de tu interpretación.

**Uso no permitido:** pegar este enunciado y entregar lo que devuelva; entregar
código que no puedes explicar línea por línea; pedirle que **interprete** los
resultados por ti — esa es justamente la habilidad que se evalúa.

Declarar el uso **no baja la nota**; ocultarlo constituye falta a la ética
académica (Guía de uso ético de tecnologías digitales, UdeC).
