#!/usr/bin/env bash
# chequear_paginas.sh - Tarea 4: verifica la disponibilidad HTTP de una lista de sitios.
# Uso    : ./chequear_paginas.sh [url ...]
#          Sin argumentos, lee las URL de sitios_9389.txt
# Códigos: 0 si anduvo
#          1 si no hay argumentos y tampoco existe el archivo de sitios
#          4 si el archivo de sitios existe pero no tiene ninguna URL utilizable

LEGAJO="9389"

# Las rutas se resuelven contra la ubicación del script, no contra el directorio
# desde el que me invocan: así el log siempre cae en el mismo lugar del
# repositorio, se corra desde donde se corra.
DIR_SCRIPT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
RAIZ_REPO="$(dirname -- "${DIR_SCRIPT}")"
ARCHIVO_SITIOS="${RAIZ_REPO}/sitios_${LEGAJO}.txt"
ARCHIVO_LOG="${RAIZ_REPO}/logs/chequeo_${LEGAJO}.log"

TIEMPO_MAXIMO=10        # segundos que espero a cada servidor

# ─── Colores ────────────────────────────────────────────────────────────────
# Solo se emiten si la salida es una terminal. Cuando redirijo a un archivo o a
# un pipe, las secuencias ANSI quedarían escritas como basura literal.
if [ -t 1 ]; then
    VERDE=$'\033[0;32m'; AMARILLO=$'\033[0;33m'; ROJO=$'\033[0;31m'; NEUTRO=$'\033[0m'
else
    VERDE=""; AMARILLO=""; ROJO=""; NEUTRO=""
fi

# ─── Armado de la lista de URL ──────────────────────────────────────────────
urls=()

if [ "$#" -gt 0 ]; then
    urls=("$@")
    origen="argumentos de la línea de comandos"
else
    if [ ! -r "${ARCHIVO_SITIOS}" ]; then
        echo "ERROR: no se pasaron URL y no puedo leer '${ARCHIVO_SITIOS}'." >&2
        echo "Uso: $0 [url ...]" >&2
        exit 1
    fi
    # Se saltean las líneas vacías y las que empiezan con # , para poder dejar
    # comentarios dentro del archivo de sitios.
    while IFS= read -r linea; do
        linea="${linea#"${linea%%[![:space:]]*}"}"      # recorta espacios al inicio
        linea="${linea%"${linea##*[![:space:]]}"}"      # y al final
        [ -z "${linea}" ] && continue
        [ "${linea:0:1}" = "#" ] && continue
        urls+=("${linea}")
    done < "${ARCHIVO_SITIOS}"
    origen="${ARCHIVO_SITIOS}"
fi

if [ "${#urls[@]}" -eq 0 ]; then
    echo "ERROR: la lista de URL quedó vacía (origen: ${origen})." >&2
    exit 4
fi

if ! mkdir -p "$(dirname -- "${ARCHIVO_LOG}")"; then
    echo "ERROR: no pude crear el directorio del log." >&2
    exit 1
fi

# ─── Chequeo ────────────────────────────────────────────────────────────────
{
    echo "═══ Chequeo del $(date '+%Y-%m-%d %H:%M:%S') ═══"
    echo "Origen de la lista: ${origen}"
} >> "${ARCHIVO_LOG}"

echo "Chequeando ${#urls[@]} sitio(s). Origen: ${origen}"
echo

for url in "${urls[@]}"; do
    # Sin -L a propósito: siguiendo las redirecciones vería el 200 del destino
    # final y el 3xx nunca aparecería. Lo que se pide informar es la respuesta
    # del servidor consultado, no la del último de la cadena.
    codigo="$(curl -s -o /dev/null -w '%{http_code}' --max-time "${TIEMPO_MAXIMO}" "${url}" 2>/dev/null)"

    # curl devuelve 000 cuando no llegó a hablar con nadie: DNS que no resuelve,
    # conexión rechazada o timeout. No es un código HTTP, es la ausencia de
    # respuesta, y por eso va en su propia rama y no dentro del 5xx.
    # Las etiquetas van sin tildes por una razón concreta: printf rellena a
    # ancho fijo contando BYTES, y en UTF-8 una vocal acentuada ocupa dos. Con
    # "REDIRECCIÓN" la columna siguiente se corre un lugar y la tabla se
    # desalinea solo en esa fila.
    case "${codigo}" in
        2*)  color="${VERDE}";    estado="OK"            ;;
        3*)  color="${AMARILLO}"; estado="REDIRIGE"      ;;
        4*)  color="${ROJO}";     estado="ERROR CLIENTE" ;;
        5*)  color="${ROJO}";     estado="ERROR SERVIDOR";;
        000) color="${ROJO}";     estado="SIN RESPUESTA" ;;
        *)   color="${ROJO}";     estado="DESCONOCIDO"   ;;
    esac

    printf '%s%-3s%s  %-14s  %s\n' "${color}" "${codigo}" "${NEUTRO}" "${estado}" "${url}"
    printf '%-3s  %-14s  %s\n' "${codigo}" "${estado}" "${url}" >> "${ARCHIVO_LOG}"
done

echo
echo "Reporte agregado a ${ARCHIVO_LOG}"
exit 0
