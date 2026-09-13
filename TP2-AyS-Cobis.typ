#set document(title: "Trabajo Práctico N.º 2 - Automatización y Scripting", author: "Rolando Cobis")
#set text(font: "Liberation Serif", size: 11pt, lang: "es")
#set par(justify: true, leading: 0.62em, spacing: 1.1em)
#set heading(numbering: "1.1.")

#let codigo(archivo) = raw(read(archivo), lang: "bash", block: true)

#show table: set par(justify: false)

#show raw.where(block: false): set text(font: "Liberation Mono", size: 9.5pt)

#show raw.where(block: true): it => block(
  inset: (left: 12pt, y: 4pt),
  width: 100%,
  breakable: true,
  text(font: "Liberation Mono", size: 7.5pt, it),
)

#show heading.where(level: 1): it => [
  #v(0.6em)
  #block(text(size: 14pt, weight: "bold", it))
  #v(0.3em)
]
#show heading.where(level: 2): it => [
  #v(0.4em)
  #block(text(size: 11.5pt, weight: "bold", it))
]

#page(header: none, footer: none, margin: (x: 3cm, y: 3.5cm))[
  #align(center)[
    #text(size: 13pt)[Universidad Nacional del Comahue]

    #text(size: 12pt)[Centro Regional Zona Atlántica]

    #text(size: 11pt)[Tecnicatura Superior en Administración de Sistemas y Software Libre]

    #v(3cm)

    #text(size: 13pt)[Automatización y Scripting]

    #v(0.5cm)
    #text(size: 20pt, weight: "bold")[Trabajo Práctico N.º 2]

    #v(0.4cm)
    #text(size: 12pt, style: "italic")[Scripts avanzados en Bash]

    #v(3cm)
  ]

  #align(center)[
    #block(width: 85%)[
      #set align(left)
      #grid(
        columns: (auto, 1fr),
        row-gutter: 0.6em,
        column-gutter: 1em,
        text(weight: "bold")[Alumno:], [Rolando Cobis],
        text(weight: "bold")[Legajo:], [CURZA-9389],
        text(weight: "bold")[DNI:], [96.495.580],
        text(weight: "bold")[Token de Autenticidad:], [`93895580`],
        text(weight: "bold")[Repositorio:],
        text(font: "Liberation Mono", size: 9pt, hyphenate: false)[github.com/cRolandoJr/tp2-cobis-9389],
        text(weight: "bold")[Docente:], [Ramiro García Poggi],
        text(weight: "bold")[Fecha de entrega:], [17 de septiembre de 2026],
      )
    ]
  ]
]

#counter(page).update(1)

#set page(
  paper: "a4",
  margin: (x: 2.5cm, top: 2.8cm, bottom: 2.4cm),
  header: [
    #set text(size: 9pt)
    #grid(
      columns: (1fr, 1fr),
      align(left)[Rolando Cobis],
      align(right)[Trabajo Práctico N.º 2],
    )
  ],
  footer: context [
    #set text(size: 9pt)
    #align(center)[
      Página #counter(page).display("1") de #counter(page).final().at(0)
    ]
  ],
)

#outline(title: [Índice], depth: 2, indent: 1.2em)

#pagebreak()

= Enunciado del Trabajo Práctico

*Objetivo.* Implementar scripts en Bash de nivel intermedio-avanzado, utilizando bucles
complejos, arreglos, manipulación de cadenas en variables, control de procesos con archivos
de bloqueo (lockfiles), interacción con servicios web externos mediante cURL, y creación de
interfaces interactivas en terminal (`select` y `case`).

*Descripción del caso práctico.* Como administrador de la red de laboratorios del CURZAS, se
le solicita automatizar la gestión y monitoreo diario de los servidores de archivos de la
universidad. Debe estructurar scripts que procesen extensiones de archivos de los alumnos,
verifiquen el estado de servicios web locales, limpien directorios temporales de forma
ordenada y prevengan colisiones al ejecutar tareas de respaldo redundantes.

== Tarea 1: Buscador de versiones en PDF (`pdf_version.sh`)

Los archivos PDF almacenan su versión de formato en la primera línea de texto plano
(ej: `%PDF-1.4`).

- Escriba un script que busque todos los archivos con extensión `.pdf` en el directorio
  actual y subdirectorios.
- Por cada archivo encontrado, extraiga la primera línea utilizando el comando `head -n 1`.
- Imprima el nombre del archivo y su versión en formato:
  `Archivo: [nombre.pdf] - Versión PDF: [1.X]`.
- Personalización: el script debe filtrar y omitir cualquier archivo PDF cuyo nombre contenga
  la palabra «excluir» o las iniciales del alumno.

== Tarea 2: Renombrador y organizador automático (`organizador.sh`)

Cree un script que ordene y clasifique archivos en carpetas según su extensión.

+ Requisitos: debe recibir un directorio destino como argumento. Validar que el directorio
  exista y sea accesible. Si no se pasa o no existe, fallar con código `1`.
+ Lógica:
  - Crear dentro del directorio destino las carpetas `imagenes/` (para `.jpg`, `.png`),
    `documentos/` (para `.pdf`, `.txt`, `.docx`) y `comprimidos/` (para `.zip`, `.tar.gz`,
    `.rar`).
  - Mover cada archivo a la carpeta correspondiente utilizando bucles `for` y condicionales.
  - Si encuentra archivos con extensión `.old`, renombrarlos masivamente eliminando la
    extensión `.old` y reemplazándola por `.backup` usando la sustitución de cadenas en
    variables de Bash (`${archivo%.old}.backup`).
  - Los archivos que no encajen en ninguna categoría deben moverse a `otros/`.

== Tarea 3: Monitoreo interactivo de recursos (`monitorear.sh`)

Implemente un panel interactivo utilizando `select` y `case`.

+ El script debe mostrar un menú interactivo con las siguientes opciones:
  - Opción 1, monitorear memoria RAM: muestra la RAM libre y usada en megabytes en tiempo real.
  - Opción 2, buscar archivos grandes: busca archivos mayores a 10 MB en el directorio `$HOME`
    y muestra los 5 más grandes.
  - Opción 3, espacio en particiones: muestra el uso de disco formateado de las particiones
    físicas montadas.
  - Opción 4, salir: termina la ejecución con un saludo personalizado con el legajo del alumno.
+ El menú debe repetirse indefinidamente hasta que el usuario elija la opción de salir.

== Tarea 4: Verificador de sitios web (`chequear_paginas.sh`)

Cree un script que verifique la disponibilidad de servidores mediante HTTP.

+ Entrada: el script debe aceptar una lista de URL separadas por espacios como argumentos. Si
  no se ingresa ninguna, debe leer las URL desde un archivo de texto llamado
  `sitios_[LEGAJO].txt` (que debe crear previamente en el repositorio).
+ Lógica: para cada URL, realice una petición HTTP silenciosa usando cURL para obtener
  únicamente el código de estado. Imprima la URL y su código en colores en la terminal: verde
  si el código es `200`, amarillo si es un redireccionamiento `3xx`, rojo si es `4xx` o `5xx`.
+ Guardar el reporte en `logs/chequeo_[LEGAJO].log`.

== Tarea 5: Respaldador con prevención de ejecución simultánea (`backup_manager.sh`)

Cree un script de respaldo seguro para evitar que dos instancias del script se ejecuten al
mismo tiempo (lo cual corrompería el backup).

+ Mecanismo de lockfile:
  - Utilice la creación atómica de directorios (`mkdir "/var/lock/backup_[LEGAJO].lock"`) al
    inicio del script para actuar como semáforo de bloqueo.
  - Si el comando `mkdir` falla, significa que el script ya se está ejecutando. Debe imprimir
    un mensaje de error y terminar inmediatamente con código `9`.
  - Si tiene éxito, asegure la eliminación del directorio de bloqueo en caso de finalización
    normal o interrupción imprevista utilizando `trap`.
+ Respaldo:
  - El script debe buscar todos los archivos en su directorio de código modificados en las
    últimas 24 horas (`find . -mtime -1 -type f`).
  - Copiar los archivos encontrados a un directorio temporal llamado `/tmp/backup_[LEGAJO]/`.
  - Empaquetar y comprimir dicho directorio en un archivo tarball llamado
    `backup_[LEGAJO]_[FECHA].tar.gz` dentro de la carpeta `logs/`.

== Consideraciones acerca de los scripts

- La interfaz solo podrá utilizar modo texto plano.
- Salvo indicación expresa no puede utilizarse código externo de ningún tipo.
- El script no deberá abortar en ningún momento de su ejecución. Por este motivo se exige la
  validación de todos los datos de entrada.
- Debe haber un historial de al menos 3 commits con mensajes claros.

#pagebreak()

= Hipótesis, supuestos y aclaraciones

== Entorno de ejecución

Los cinco scripts fueron desarrollados y probados sobre *NixOS* con *Bash 5.3.15*, no sobre
el Ubuntu que asume la cátedra. De ahí se desprenden dos desvíos, ambos deliberados:

- *El shebang es `#!/usr/bin/env bash` y no `#!/bin/bash`.* En NixOS los intérpretes viven
  bajo `/nix/store` y `/bin/bash` no existe, de modo que la ruta absoluta produciría un error
  de intérprete no encontrado. La forma con `env` resuelve el binario por `PATH` y funciona en
  las dos distribuciones.
- *El directorio `/var/lock` pertenece a `root`.* Se detalla en el apartado siguiente.

== La ejecución del respaldo requiere privilegios

El enunciado fija la ruta del bloqueo en `/var/lock/backup_9389.lock`. En este sistema
`/var/lock` es un enlace simbólico a `/run/lock`, propiedad de `root` y con permisos
`drwxr-xr-x`, por lo que un usuario común no puede crear nada allí:

```
$ ls -ld /var/lock
lrwxrwxrwx - root 16 may 09:12 /var/lock -> ../run/lock

$ mkdir /var/lock/_probe_9389
mkdir: cannot create directory '/var/lock/_probe_9389': Permiso denegado
```

Se conservó la ruta que indica el enunciado y el script se ejecuta con `sudo`. Eso trae una
consecuencia que hubo que atender: todo lo que el script escribe queda a nombre de `root`,
incluido el tarball que cae dentro del repositorio, y el usuario no podría borrarlo ni
versionarlo. Por eso el script devuelve la propiedad de los artefactos a `$SUDO_USER` antes
de terminar.

== Un fallo de `mkdir` no implica que el bloqueo esté tomado

El enunciado dice que si `mkdir` falla es porque el script ya se está ejecutando. Eso es
cierto solo en el caso normal: `mkdir` falla también por falta de permisos sobre `/var/lock`,
que es exactamente lo que ocurre al olvidar el `sudo`. Informar que hay una instancia en
ejecución en ese caso sería un diagnóstico falso, con un código de salida que lo respalda.

El script distingue los dos casos preguntando, después del fallo, si el directorio de bloqueo
existe. Si existe, el bloqueo está tomado y sale con *9*, como pide el enunciado. Si no
existe, el problema es de permisos y sale con *7*, informando que hace falta `sudo`.

== Alcance de «tiempo real» en el monitoreo de RAM

La opción 1 del panel toma cinco lecturas separadas por dos segundos en lugar de refrescar de
forma continua. Un `free -m -s 2` no termina nunca por sí solo: exige un `Ctrl-C` del usuario,
y el menú, que debe repetirse hasta que se elija salir, no volvería a mostrarse. El muestreo
acotado deja ver la variación de la memoria y devuelve el control al menú.

== Criterio del filtro de iniciales

El filtro de la Tarea 1 compara la cadena exacta `RC`, sensible a mayúsculas. Un filtro
insensible sobre `rc` omitiría archivos legítimos como `marco.pdf` o `fuentes.pdf`, porque el
patrón también coincide dentro de una palabra. En la captura de la Tarea 1 puede verse que
`marco.pdf` sí se analiza y `informe-RC.pdf` no.

== Otras decisiones menores

- *El `case` de la Tarea 2 evalúa `*.tar.gz` antes que cualquier patrón que también coincida
  con `.gz`*, porque corta en la primera coincidencia y una doble extensión se clasificaría
  mal en el orden inverso.
- *La Tarea 4 no sigue las redirecciones* (no se usa `curl -L`). Siguiéndolas se vería el
  `200` del destino final y el `3xx` nunca aparecería, que es justamente uno de los tres
  colores pedidos.
- *Se agregó un cuarto estado a la Tarea 4 para el código `000`*, que cURL devuelve cuando no
  hubo respuesta alguna (el DNS no resuelve, la conexión se rechaza o expira el tiempo de
  espera). No es un código HTTP, así que no corresponde tratarlo como error del servidor.
- *Las etiquetas de estado de la Tarea 4 se escriben sin tildes.* `printf` rellena las columnas
  contando bytes y en UTF-8 una vocal acentuada ocupa dos, de modo que la palabra
  correspondiente al `3xx` corría la columna siguiente y desalineaba esa única fila.
- *Los recorridos de archivos usan `find -print0` con `read -d ''`.* Recorrer la salida de
  `find` con un `for` común parte en pedazos los nombres que contienen espacios.
- *El archivo `sitios_9389.txt` contiene dominios de la Universidad Nacional del Comahue*
  elegidos para cubrir los cuatro estados que distingue el script.

#pagebreak()

= Resolución

== Tarea 1: Buscador de versiones en PDF

El script recibe opcionalmente un directorio (por omisión, el actual), valida que exista y sea
accesible, y recorre el árbol buscando archivos `.pdf`. De cada uno lee la primera línea con
`head -n 1` y recorta la versión con una expresión regular, porque el resto del archivo es
binario y no se puede confiar en el corte de línea. Los archivos filtrados y los que no
declaran una cabecera válida se informan sin interrumpir el recorrido.

=== Código de `pdf_version.sh`

#codigo("codigo/pdf_version.sh")

=== Salida obtenida

Sobre un árbol de prueba con cuatro PDF, dos de ellos alcanzados por el filtro:

#figure(
  image("capturas/pdf_version.png", width: 100%),
  caption: [Ejecución de `pdf_version.sh`. `marco.pdf` se analiza; `informe-RC.pdf` y `algo-excluir.pdf` se omiten.],
)

== Tarea 2: Renombrador y organizador automático

El script valida que se haya pasado exactamente un argumento, que sea un directorio existente
y que se pueda escribir dentro de él; en cualquier otro caso termina con código 1. Luego crea
las cuatro carpetas de destino, renombra los archivos `.old` con la sustitución
`${archivo%.old}.backup` y recorre el directorio clasificando por extensión.

El renombrado va antes de la clasificación por una razón práctica: después de mover los
archivos habría que ir a buscarlos a las cuatro carpetas nuevas.

=== Código de `organizador.sh`

#codigo("codigo/organizador.sh")

=== Salida obtenida

#figure(
  image("capturas/organizador.png", width: 100%),
  caption: [Ejecución de `organizador.sh` sobre diez archivos de prueba y un `.old`.],
)

== Tarea 3: Monitoreo interactivo de recursos

El panel se construye con `select`, que se encarga de imprimir el menú y repetirlo hasta que
se ejecute un `break`. El `case` discrimina sobre el texto que devuelve `select` y no sobre el
número tecleado, de modo que un cambio en el orden del menú no rompe las ramas.

El cuerpo del bucle se ejecuta únicamente cuando la entrada es una línea con contenido: ante un
Enter vacío `select` vuelve a imprimir el menú y lee de nuevo, y ante un fin de entrada
(`Ctrl-D`) termina el bucle. Ninguno de los dos casos llega al `case`. La única entrada que sí
lo alcanza y exige validación es un número fuera de rango, que deja vacía la variable del
`select` y se informa como opción inválida sin interrumpir el menú.

=== Código de `monitorear.sh`

#codigo("codigo/monitorear.sh")

=== Salida obtenida

#figure(
  image("capturas/monitorear.png", width: 82%),
  caption: [Panel interactivo: opción 1, opción 3, rechazo de la opción inválida 9 y salida por la opción 4.],
)

== Tarea 4: Verificador de sitios web

El script arma la lista de URL desde los argumentos o, si no hay ninguno, desde
`sitios_9389.txt`, salteando líneas vacías y comentarios. Por cada URL pide a cURL únicamente
el código de estado y lo clasifica por su primer dígito. Las secuencias de color solo se
emiten si la salida es una terminal: redirigida a un archivo quedarían escritas como texto
literal, y el log tiene que ser legible.

Las rutas del archivo de sitios y del log se resuelven contra la ubicación del script, de modo
que el reporte siempre cae dentro del repositorio sin importar desde dónde se lo invoque.

=== Código de `chequear_paginas.sh`

#codigo("codigo/chequear_paginas.sh")

=== Salida obtenida

#figure(
  image("capturas/chequear_paginas.png", width: 100%),
  caption: [Los cuatro estados: `200` en verde, `301` en amarillo, `404` y `000` en rojo.],
)

=== Contenido de `logs/chequeo_9389.log`

#codigo("logs/chequeo_9389.log")

== Tarea 5: Respaldador con prevención de ejecución simultánea

El bloqueo se toma con `mkdir`, que es la pieza central de la tarea: preguntar si el directorio
existe y crearlo son una sola operación del núcleo, indivisible. Con un archivo común la
comprobación y la escritura serían dos pasos separados, y entre uno y otro hay una ventana en
la que dos procesos pueden superar la comprobación antes de que ninguno haya escrito nada; los
dos se creerían dueños del bloqueo.

El `trap` se registra recién después de haber tomado el bloqueo. Registrado antes, una salida
temprana del script (por ejemplo, la que ocurre al detectar que el bloqueo ya estaba tomado)
borraría el directorio de bloqueo del proceso que realmente lo tiene.

El respaldo copia con `cp --parents` para conservar la ruta relativa de cada archivo: sin eso,
dos archivos homónimos en carpetas distintas se pisarían dentro del temporal y el respaldo
guardaría uno solo, en silencio. El empaquetado usa `tar -C` para que el tarball no recree el
árbol `tmp/backup_9389/` al restaurarse.

=== Código de `backup_manager.sh`

#codigo("codigo/backup_manager.sh")

=== Salida obtenida

La primera ejecución toma el bloqueo, copia los archivos modificados en las últimas 24 horas y
genera el tarball. A continuación se crea el directorio de bloqueo a mano, simulando una
instancia en curso, y la segunda ejecución rebota con el mensaje de error y el código 9.

#figure(
  image("capturas/backup_manager.png", width: 100%),
  caption: [Respaldo exitoso y rechazo de la segunda instancia por bloqueo tomado.],
)

= Pruebas realizadas

#table(
  columns: (1.6fr, 2.2fr, 1.4fr),
  stroke: 0.5pt,
  inset: 5pt,
  align: left,
  table.header(
    [*Script*], [*Caso probado*], [*Resultado*],
  ),
  [`pdf_version.sh`], [Directorio inexistente], [Código 1],
  [`pdf_version.sh`], [Archivo sin cabecera `%PDF`], [Aviso, sin abortar],
  [`pdf_version.sh`], [`marco.pdf` frente al filtro `RC`], [Se analiza],
  [`organizador.sh`], [Sin argumentos], [Código 1],
  [`organizador.sh`], [Directorio inexistente], [Código 1],
  [`organizador.sh`], [`paquete.tar.gz`], [A `comprimidos/`],
  [`organizador.sh`], [`foto.JPG` en mayúsculas], [A `imagenes/`],
  [`organizador.sh`], [`datos.csv` sin categoría], [A `otros/`],
  [`monitorear.sh`], [Opción fuera de rango (9)], [Aviso, menú sigue],
  [`monitorear.sh`], [Línea vacía (Enter)], [Reimprime el menú],
  [`monitorear.sh`], [Fin de entrada (`Ctrl-D`)], [Termina el bucle],
  [`chequear_paginas.sh`], [URL que responde 200], [Verde],
  [`chequear_paginas.sh`], [URL que redirige 301], [Amarillo],
  [`chequear_paginas.sh`], [URL inexistente 404], [Rojo],
  [`chequear_paginas.sh`], [Dominio que no resuelve], [`000`, rojo],
  [`backup_manager.sh`], [Sin `sudo`], [Código 7],
  [`backup_manager.sh`], [Bloqueo ya tomado], [Código 9],
  [`backup_manager.sh`], [Ejecución normal], [Tarball en `logs/`],
)

Los cinco scripts pasan `shellcheck` 0.11.0 sin advertencias.
