# T2 — Limpieza y agregación con dplyr

**Autor:** Cristóbal Ignacio Sepúlveda Sepúlveda
**Curso:** Fundamentos de Programación para Análisis Económico · UdeC-EAN

**Pregunta:** ¿Rinde más cada año de educación en Ñuble que en las demás
regiones del centro-sur, y cuánto vale esa diferencia en pesos?

**Respuesta:** En Ñuble cada año de educación se asocia a $58.136 de ingreso,
$10.690 más que en Maule (el más bajo) y $7.833 más que el promedio del resto
del centro-sur. La ventaja se concentra en quienes no completaron la media.
Con 40 casos y sin factor de expansión, el resultado describe a estas personas
y no a la población.

**Cómo correr:** abrir `T2.Rproj` en RStudio y ejecutar `scripts/tarea_t2.R`
completo. Requiere el paquete `dplyr`. Las rutas son relativas a la raíz del
proyecto.

## Declaración de autoría y uso de IA

- **Herramienta utilizada:** Claude (Anthropic)
- **Para qué la usé:** depurar errores de rutas y de paquetes; entender por qué
  `starts_with()` y `where(is.numeric)` no devuelven lo mismo; redactar
  comentarios explicativos del script; revisar la estructura y la redacción de
  mi interpretación.
- **Qué hice yo:** definí la pregunta, escribí y verifiqué el código, tomé las
  decisiones metodológicas (filtros, exclusión de la RM, tratamiento de los NA,
  promedio de cocientes) y escribí la interpretación.
- **Verificación:** confirmo que entiendo y puedo explicar todo lo que entrego.
