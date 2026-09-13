#!/usr/bin/env bash
# backup_manager.sh - Tarea 5: respalda lo modificado en las últimas 24 h,
#                     impidiendo que dos instancias corran a la vez.
# Uso    : sudo ./backup_manager.sh
# Códigos: 0 si anduvo
#          7 si no puedo escribir en /var/lock (falta sudo)
#          9 si ya hay otra instancia en ejecución

LEGAJO="9389"
DIRECTORIO_BLOQUEO="/var/lock/backup_${LEGAJO}.lock"
DIRECTORIO_TEMPORAL="/tmp/backup_${LEGAJO}"

DIR_SCRIPT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
RAIZ_REPO="$(dirname -- "${DIR_SCRIPT}")"
DIRECTORIO_LOGS="${RAIZ_REPO}/logs"
FECHA="$(date '+%Y%m%d_%H%M%S')"
TARBALL="${DIRECTORIO_LOGS}/backup_${LEGAJO}_${FECHA}.tar.gz"

# ─── Toma del bloqueo ───────────────────────────────────────────────────────
# mkdir es la pieza clave de toda la tarea: preguntar "¿existe?" y crear son una
# sola operación del kernel, indivisible. Con un archivo común
# ( [ -e lock ] || touch lock ) hay una ventana entre la pregunta y la escritura
# en la que dos procesos pasan el test antes de que ninguno de los dos haya
# creado nada, y ambos se creen dueños del bloqueo.
if ! mkdir "${DIRECTORIO_BLOQUEO}" 2>/dev/null; then
    # Que mkdir falle no significa por sí solo que el bloqueo esté tomado:
    # también falla por falta de permisos sobre /var/lock. Informar "ya se está
    # ejecutando" sin mirar cuál de los dos casos es sería un diagnóstico falso.
    if [ -d "${DIRECTORIO_BLOQUEO}" ]; then
        echo "ERROR: ya hay una instancia en ejecución (bloqueo: ${DIRECTORIO_BLOQUEO})." >&2
        echo "Si está seguro de que no es así, elimine ese directorio a mano." >&2
        exit 9
    fi
    echo "ERROR: no pude crear el bloqueo en ${DIRECTORIO_BLOQUEO}." >&2
    echo "/var/lock pertenece a root: ejecute el script con sudo." >&2
    exit 7
fi

# El trap se registra recién DESPUÉS de haber tomado el bloqueo. Si lo pusiera
# antes, una salida temprana de este script borraría el bloqueo del proceso que
# realmente lo tiene tomado.
trap 'rmdir "${DIRECTORIO_BLOQUEO}"' EXIT

echo "Bloqueo tomado: ${DIRECTORIO_BLOQUEO}"

# ─── Búsqueda de los archivos recientes ─────────────────────────────────────
if ! mkdir -p "${DIRECTORIO_TEMPORAL}" "${DIRECTORIO_LOGS}"; then
    echo "ERROR: no pude preparar los directorios de trabajo." >&2
    exit 1
fi

cd -- "${RAIZ_REPO}" || { echo "ERROR: no pude entrar a ${RAIZ_REPO}." >&2; exit 1; }

copiados=0
while IFS= read -r -d '' archivo; do
    # --parents conserva la ruta relativa dentro del temporal. Sin eso, dos
    # archivos con el mismo nombre en carpetas distintas se pisarían y el
    # respaldo guardaría uno solo, en silencio.
    if cp -a --parents -- "${archivo}" "${DIRECTORIO_TEMPORAL}/" 2>/dev/null; then
        copiados=$(( copiados + 1 ))
    else
        echo "AVISO: no pude copiar '${archivo}'." >&2
    fi
done < <(find . -type f -mtime -1 -not -path './.git/*' -print0 2>/dev/null)

if [ "${copiados}" -eq 0 ]; then
    echo "No hay archivos modificados en las últimas 24 horas. No se genera tarball."
    exit 0
fi

echo "Archivos copiados a ${DIRECTORIO_TEMPORAL}: ${copiados}"

# ─── Empaquetado ────────────────────────────────────────────────────────────
# El -C hace que el tar guarde rutas relativas al temporal. Sin eso quedarían
# guardadas como tmp/backup_9389/... y al restaurar recrearía ese árbol.
if ! tar -czf "${TARBALL}" -C "${DIRECTORIO_TEMPORAL}" .; then
    echo "ERROR: falló el empaquetado en ${TARBALL}." >&2
    exit 1
fi

echo "Respaldo generado: ${TARBALL} ($(du -h "${TARBALL}" | cut -f1))"

# ─── Devolución de la propiedad de los artefactos ───────────────────────────
# Consecuencia de correr con sudo: todo lo que el script escribe queda a nombre
# de root, incluido el tarball que cae dentro del repositorio. Sin este paso el
# usuario no puede borrar ni versionar sus propios archivos.
if [ "${EUID}" -eq 0 ] && [ -n "${SUDO_USER:-}" ]; then
    chown -R -- "${SUDO_USER}" "${TARBALL}" "${DIRECTORIO_TEMPORAL}"
    echo "Propiedad de los artefactos devuelta a ${SUDO_USER}."
fi

exit 0
