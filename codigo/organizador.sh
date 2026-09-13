#!/usr/bin/env bash
# organizador.sh - Tarea 2: clasifica archivos en carpetas según su extensión.
# Uso    : ./organizador.sh <directorio_destino>
# Códigos: 0 si anduvo
#          1 si no le paso el directorio, o no existe, o no puedo escribir en él

if [ "$#" -ne 1 ]; then
    echo "ERROR: se esperaba exactamente 1 argumento y se recibieron $#." >&2
    echo "Uso: $0 <directorio_destino>" >&2
    exit 1
fi

DESTINO="$1"

if [ ! -d "${DESTINO}" ]; then
    echo "ERROR: '${DESTINO}' no existe o no es un directorio." >&2
    exit 1
fi

if [ ! -w "${DESTINO}" ] || [ ! -x "${DESTINO}" ]; then
    echo "ERROR: no tengo permiso para escribir dentro de '${DESTINO}'." >&2
    exit 1
fi

for carpeta in imagenes documentos comprimidos otros; do
    if ! mkdir -p "${DESTINO}/${carpeta}"; then
        echo "ERROR: no pude crear '${DESTINO}/${carpeta}'." >&2
        exit 1
    fi
done

renombrados=0
movidos=0

# Los .old van primero: después de mover habría que buscarlos en las cuatro carpetas
for archivo in "${DESTINO}"/*.old; do
    [ -e "${archivo}" ] || continue           # el glob sin coincidencias queda literal
    nuevo="${archivo%.old}.backup"
    if mv -n -- "${archivo}" "${nuevo}"; then
        echo "Renombrado: $(basename "${archivo}") -> $(basename "${nuevo}")"
        renombrados=$(( renombrados + 1 ))
    else
        echo "AVISO: no pude renombrar '$(basename "${archivo}")'." >&2
    fi
done

for archivo in "${DESTINO}"/*; do
    [ -f "${archivo}" ] || continue           # las carpetas recién creadas no se tocan

    nombre="$(basename "${archivo}")"

    # *.tar.gz va antes que cualquier patrón que también matchee .gz: el case corta en la primera
    case "${nombre,,}" in
        *.jpg|*.jpeg|*.png)          carpeta="imagenes"    ;;
        *.pdf|*.txt|*.docx)          carpeta="documentos"  ;;
        *.tar.gz|*.zip|*.rar)        carpeta="comprimidos" ;;
        *)                           carpeta="otros"       ;;
    esac

    if mv -n -- "${archivo}" "${DESTINO}/${carpeta}/"; then
        echo "Movido: ${nombre} -> ${carpeta}/"
        movidos=$(( movidos + 1 ))
    else
        echo "AVISO: no pude mover '${nombre}' (¿ya existe en destino?)." >&2
    fi
done

echo
echo "Renombrados: ${renombrados} | Movidos: ${movidos}"
exit 0
