#!/usr/bin/env bash
# organizador.sh - Tarea 2: clasifica archivos en carpetas según su extensión.
# Uso    : ./organizador.sh <directorio_destino>
# Códigos: 0 si anduvo
#          1 si no le paso el directorio, o no existe, o no puedo escribir en él

# ─── Validación del argumento ───────────────────────────────────────────────
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

# ─── Creación de las carpetas de destino ────────────────────────────────────
# El -p hace que no falle si la carpeta ya existe, que es el caso normal a
# partir de la segunda corrida.
for carpeta in imagenes documentos comprimidos otros; do
    if ! mkdir -p "${DESTINO}/${carpeta}"; then
        echo "ERROR: no pude crear '${DESTINO}/${carpeta}'." >&2
        exit 1
    fi
done

renombrados=0
movidos=0

# ─── Renombrado de los .old ─────────────────────────────────────────────────
# Va primero y por separado: si lo hiciera después de mover, tendría que ir a
# buscar los archivos a las cuatro carpetas nuevas. Acá todavía están todos en
# el mismo lugar.
# La sustitución ${archivo%.old} recorta el sufijo más corto que matchee al
# final del valor; es expansión de la propia shell, sin llamar a ningún
# programa externo.
for archivo in "${DESTINO}"/*.old; do
    [ -e "${archivo}" ] || continue          # el glob sin coincidencias queda literal
    nuevo="${archivo%.old}.backup"
    if mv -n -- "${archivo}" "${nuevo}"; then
        echo "Renombrado: $(basename "${archivo}") -> $(basename "${nuevo}")"
        renombrados=$(( renombrados + 1 ))
    else
        echo "AVISO: no pude renombrar '$(basename "${archivo}")'." >&2
    fi
done

# ─── Clasificación por extensión ────────────────────────────────────────────
for archivo in "${DESTINO}"/*; do
    [ -f "${archivo}" ] || continue          # las carpetas que acabo de crear no se tocan

    nombre="$(basename "${archivo}")"

    # El case evalúa de arriba hacia abajo y corta en la primera coincidencia,
    # así que *.tar.gz tiene que ir ANTES que cualquier patrón que también
    # matchee un .gz. Ese es el motivo del orden, no la estética.
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
