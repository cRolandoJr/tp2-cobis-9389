#!/usr/bin/env bash
# pdf_version.sh - Tarea 1: informa la versión de formato de cada PDF del árbol.
# Uso    : ./pdf_version.sh [directorio]   (por defecto, el directorio actual)
# Códigos: 0 si anduvo
#          1 si el directorio que le paso no existe o no puedo entrar

DIRECTORIO_BASE="${1:-.}"
INICIALES="RC"          # se omiten los PDF cuyo nombre las contenga
PALABRA_EXCLUIR="excluir"

# ─── Validación del directorio ──────────────────────────────────────────────
if [ ! -d "${DIRECTORIO_BASE}" ] || [ ! -x "${DIRECTORIO_BASE}" ]; then
    echo "ERROR: '${DIRECTORIO_BASE}' no es un directorio accesible." >&2
    exit 1
fi

encontrados=0
omitidos=0

# ─── Recorrido del árbol ────────────────────────────────────────────────────
# El find va con -print0 y el read con -d '' porque un nombre de archivo puede
# tener espacios o saltos de línea. Recorrer la salida de find con un for común
# parte esos nombres en pedazos y el script termina buscando archivos que no
# existen.
while IFS= read -r -d '' archivo; do
    nombre="$(basename "${archivo}")"

    # El filtro es estricto a propósito: compara la cadena exacta "RC", sensible
    # a mayúsculas. Con "rc" insensible se llevaría puestos archivos legítimos
    # como "marco.pdf" o "fuentes.pdf", porque el patrón matchea DENTRO de la
    # palabra.
    if [[ "${nombre}" == *"${INICIALES}"* || "${nombre}" == *"${PALABRA_EXCLUIR}"* ]]; then
        omitidos=$(( omitidos + 1 ))
        continue
    fi

    if [ ! -r "${archivo}" ]; then
        echo "AVISO: '${nombre}' no se puede leer, se omite." >&2
        continue
    fi

    # La versión viaja en la primera línea de la cabecera, en texto plano:
    # %PDF-1.4 . El resto del archivo es binario, así que recorto con una
    # expresión regular en vez de confiar en el corte de línea.
    primera_linea="$(head -n 1 "${archivo}" 2>/dev/null)"

    if [[ "${primera_linea}" =~ %PDF-([0-9]+\.[0-9]+) ]]; then
        version="${BASH_REMATCH[1]}"
        echo "Archivo: [${nombre}] - Versión PDF: [${version}]"
        encontrados=$(( encontrados + 1 ))
    else
        echo "AVISO: '${nombre}' no declara una cabecera %PDF válida." >&2
    fi
done < <(find "${DIRECTORIO_BASE}" -type f -name '*.pdf' -print0 2>/dev/null)

echo
echo "Total analizados: ${encontrados} | Omitidos por filtro: ${omitidos}"
exit 0
