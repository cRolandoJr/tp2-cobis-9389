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

# mkdir como semáforo: preguntar si existe y crear son una sola operación del kernel
if ! mkdir "${DIRECTORIO_BLOQUEO}" 2>/dev/null; then
    # mkdir también falla por permisos: sin distinguir, informaría un bloqueo que no existe
    if [ -d "${DIRECTORIO_BLOQUEO}" ]; then
        echo "ERROR: ya hay una instancia en ejecución (bloqueo: ${DIRECTORIO_BLOQUEO})." >&2
        echo "Si está seguro de que no es así, elimine ese directorio a mano." >&2
        exit 9
    fi
    echo "ERROR: no pude crear el bloqueo en ${DIRECTORIO_BLOQUEO}." >&2
    echo "/var/lock pertenece a root: ejecute el script con sudo." >&2
    exit 7
fi

# El trap se registra recién acá: antes, una salida temprana borraría el bloqueo ajeno
trap 'rmdir "${DIRECTORIO_BLOQUEO}"' EXIT

echo "Bloqueo tomado: ${DIRECTORIO_BLOQUEO}"

if ! mkdir -p "${DIRECTORIO_TEMPORAL}" "${DIRECTORIO_LOGS}"; then
    echo "ERROR: no pude preparar los directorios de trabajo." >&2
    exit 1
fi

cd -- "${RAIZ_REPO}" || { echo "ERROR: no pude entrar a ${RAIZ_REPO}." >&2; exit 1; }

copiados=0
while IFS= read -r -d '' archivo; do
    # --parents conserva la ruta: sin eso, dos homónimos en carpetas distintas se pisan
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

# -C para guardar rutas relativas al temporal y no recrear tmp/backup_9389/ al restaurar
if ! tar -czf "${TARBALL}" -C "${DIRECTORIO_TEMPORAL}" .; then
    echo "ERROR: falló el empaquetado en ${TARBALL}." >&2
    exit 1
fi

echo "Respaldo generado: ${TARBALL} ($(du -h "${TARBALL}" | cut -f1))"

# Corriendo con sudo todo queda a nombre de root, incluido el tarball dentro del repositorio
if [ "${EUID}" -eq 0 ] && [ -n "${SUDO_USER:-}" ]; then
    chown -R -- "${SUDO_USER}" "${TARBALL}" "${DIRECTORIO_TEMPORAL}"
    echo "Propiedad de los artefactos devuelta a ${SUDO_USER}."
fi

exit 0
