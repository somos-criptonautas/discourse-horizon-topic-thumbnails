# Horizon Topic Thumbnails

[ENGLISH](README.md) | **ESPAÑOL**

Mantenido por Criptonautas. Sin afiliación ni respaldo de Discourse (Civilized Discourse Construction Kit, Inc.).

Añade miniaturas de tema a las **tarjetas de tema de alto contexto** de Horizon, al final de la
tarjeta, sin bifurcar ni editar el tema Horizon.

## Cómo funciona

El diseño de alto contexto de Horizon registra una sola columna de lista de temas,
`high-context-card`, cuyo elemento renderiza toda la tarjeta como un único
`<td class="hc-topic-card">`. El núcleo renderiza el componente de cada columna como hijo directo
del `<tr>`, así que este componente registra su propia columna inmediatamente *antes* de la de
Horizon:

```js
columns.add("htt-thumbnail", { item: ThumbnailCell }, { before: "high-context-card" });
```

Eso da un `<td>` real hermano de la tarjeta, y la fila se maqueta como un contenedor
flex: primero la tarjeta y después la miniatura, sin posicionamiento absoluto.
Intercambia los dos valores de `order` en `common/common.scss` para ponerla a la izquierda.

`about.json` declara `modifiers.topic_thumbnail_sizes`, que es lo que hace que el
servidor serialice `topic.thumbnails` en absoluto. El componente muestra entonces
`thumbnails[0]`, la **subida original**, en lugar de alguno de esos tamaños generados:
la celda es estrecha pero ocupa toda la altura de la tarjeta y se recorta con cover, así que en una
pantalla retina necesita muchos más píxeles de los que sugiere su ancho, y los tamaños generados
se amplían hasta quedar borrosos. El navegador reduce el original gratis. El componente oficial Topic List Thumbnails
no es necesario y no debe instalarse junto a este: pelea con el diseño de tarjetas de
Horizon.

## Requisitos

- Tema Horizon con **tarjetas de tema de alto contexto** activadas
  (`/admin/config/upcoming-changes`; activado por defecto en versiones recientes)
- Ajuste del sitio `create thumbnails` activado

## Instalación

1. Admin -> Personalizar -> Temas -> **Componentes** -> Instalar -> *Desde un repositorio git*
   (o sube este directorio como `.zip`).
2. Abre el tema **Horizon** -> Componentes -> añade *Horizon Topic Thumbnails*.

No se toca nada de Horizon. Quitar el componente revierte el cambio por completo.

Los tamaños de miniatura recién declarados se generan en segundo plano, así que los temas existentes
pueden mostrar el marcador de posición un tiempo antes de que aparezcan sus imágenes.

## Ajustes

| Ajuste | Por defecto | |
|---|---|---|
| `thumbnail_size` | `240` | Ancho de la columna de miniatura en px; la imagen ocupa toda la altura de la tarjeta y se recorta para ajustarse. |
| `mobile_thumbnails` | `true` | Muestra miniaturas en móvil, como un banner de ancho completo. Ver más abajo. |
| `placeholder_icon` | `comments` | Icono para temas sin imagen, para que las tarjetas mantengan un ancho uniforme. Sirve cualquier nombre de icono. Si se deja vacío, esas tarjetas ocupan el ancho completo. |
| `enabled_categories` | *(vacío)* | Muestra miniaturas solo al navegar estas categorías. Vacío = todas las listas de temas. |

### Móvil

Horizon fuerza su diseño de columnas de escritorio en móvil para los contextos de tarjeta, así que la
columna de miniatura también se renderiza en teléfonos. Su tarjeta móvil va deliberadamente de borde a
borde (`padding: var(--space-4) 0`, un pie a sangre completa con superposición de degradado,
una franja de etiquetas con desplazamiento horizontal) y nada de eso sobrevive a apretarse
en una fila más estrecha.

Así que no se aprieta. Por debajo del punto de corte `sm` de Horizon (40rem) la fila pasa a
`flex-direction: column`: la miniatura se convierte en un banner de ancho completo y la tarjeta
recupera todo el ancho de la fila, exactamente como la dibuja Horizon. Ese es todo el tratamiento
móvil: una propiedad, sin un segundo diseño que mantener.

`--htt-size` es el flex-basis de la celda en ambas direcciones, así que es el ancho de la columna
en escritorio y la altura del banner en móvil (140px).

Pon `mobile_thumbnails` en false para omitirlo: la comprobación está en JS, así que la columna nunca
se registra y la fila queda idéntica byte a byte al Horizon original.

### Alcance por categoría

El alcance es **a nivel de lista**, igual que el componente oficial: con
`enabled_categories` configurado, las miniaturas aparecen en `/c/<categoría>` para las
categorías elegidas y en ningún otro lugar; `/latest` y `/top` no tienen categoría y quedan
excluidos.

La comprobación lee `discovery.category` desde la celda al renderizar, *no*
`context.category` en el transformer `topic-list-columns`. Hay dos razones por las que ese
transformer no puede hacerlo: el núcleo construye su contexto a partir de
`topicTrackingState.filterCategory`, que no es la categoría de la ruta y
suele ser undefined, y `TopicList#columns` es `@cached`, así que el conjunto de columnas resuelto
no se reconstruye al navegar entre categorías.

Las celdas fuera de alcance se renderizan como `.htt-empty` (`display: none`), y la fila solo
se convierte en contenedor flex cuando hay una celda visible, así que una lista fuera de alcance se
maqueta exactamente como el Horizon original.

Las celdas dentro de alcance también llevan `.htt-scoped`, tenga o no imagen el tema.
Eso es lo que oculta `.topic-excerpt` en toda una categoría habilitada: basarlo en el alcance
y no en que la celda sea visible mantiene las filas sin imagen coherentes con
el resto de la lista.

**Las subcategorías no se dan por incluidas.** Listar una categoría padre no habilita a sus
hijas; añade cada subcategoría explícitamente. (Si quieres que los padres se propaguen, es
un cambio de dos líneas en `enabledForCategory`.)

## Alcance del componente

La columna solo se registra cuando existe `high-context-card`. Las listas de temas sugeridos y
relacionados usan la tarjeta simple de Horizon, y los temas que no son Horizon no registran esa
columna, así que ninguno recibe una celda de miniatura.

## Prueba

```
node scripts/thumbnail-source.test.mjs
```

Cubre la selección de srcset/src (miniaturas ausentes, redimensiones no generadas, tamaños de visualización
mayores que cualquiera producido por el servidor) y la lista de categorías permitidas.

## Techo conocido

Depende de tres nombres de Horizon: la clave de columna `high-context-card` y las clases
`--high-context` y `.hc-topic-card`. Si Horizon renombra alguno, las miniaturas
dejan de renderizarse en silencio; la tarjeta en sí no se ve afectada. La solución es un renombrado en
`api-initializers/horizon-topic-thumbnails.gjs` y `common/common.scss`.

## Licencia

MIT. Consulta [LICENSE](LICENSE).

Texto de este README bajo [CC BY-NC-SA 4.0](CC-BY-NC-SA-4.0.txt).
