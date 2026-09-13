#!/usr/bin/env bash
# pdf_version.sh - Tarea 1: informa la versión de formato de cada PDF del árbol.
# Uso    : ./pdf_version.sh [directorio]   (por defecto, el directorio actual)
# Códigos: 0 si anduvo
#          1 si el directorio que le paso no existe o no puedo entrar

DIRECTORIO_BASE="${1:-.}"
INICIALES="RC"
PALABRA_EXCLUIR="excluir"

if [ ! -d "${DIRECTORIO_BASE}" ] || [ ! -x "${DIRECTORIO_BASE}" ]; then
    echo "ERROR: '${DIRECTORIO_BASE}' no es un directorio accesible." >&2
    exit 1
fi

encontrados=0
omitidos=0

while IFS= read -r -d '' archivo; do          # -print0 y -d '' por los nombres con espacios
    nombre="$(basename "${archivo}")"

    # "RC" exacto y sensible a mayúsculas: con "rc" caerían marco.pdf y fuentes.pdf
    if [[ "${nombre}" == *"${INICIALES}"* || "${nombre}" == *"${PALABRA_EXCLUIR}"* ]]; then
        omitidos=$(( omitidos + 1 ))
        continue
    fi

    if [ ! -r "${archivo}" ]; then
        echo "AVISO: '${nombre}' no se puede leer, se omite." >&2
        continue
    fi

    # El resto del archivo es binario: recorto con regex en vez de confiar en el corte de línea
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
