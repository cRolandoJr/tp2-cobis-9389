#!/usr/bin/env bash
# monitorear.sh - Tarea 3: panel interactivo de monitoreo de recursos.
# Uso    : ./monitorear.sh
# Códigos: 0 siempre; el script sale únicamente por la opción "Salir" o por EOF.

LEGAJO="9389"
ALUMNO="Rolando Cobis"
MUESTRAS_RAM=5          # cuántas lecturas toma la opción 1
INTERVALO_RAM=2         # segundos entre lectura y lectura

PS3=$'\n'"Elija una opción (1-4): "

# ─── Opción 1: memoria RAM ──────────────────────────────────────────────────
# "Tiempo real" acá es un muestreo acotado, no un bucle infinito: con free -m -s
# el script quedaría colgado hasta un Ctrl-C y el menú no volvería nunca. Cinco
# lecturas alcanzan para ver la variación y el control regresa solo.
monitorear_ram() {
    echo "Memoria RAM: ${MUESTRAS_RAM} lecturas cada ${INTERVALO_RAM}s (en MB)"
    printf '%-10s %10s %10s %10s\n' "Lectura" "Total" "Usada" "Libre"

    local i total usada libre
    for (( i = 1; i <= MUESTRAS_RAM; i++ )); do
        # La línea "Mem:" de free -m trae total, usada y libre en las columnas
        # 2, 3 y 4. Leo las tres de una sola invocación: llamar a free tres
        # veces daría tres fotos distintas y los números no cerrarían entre sí.
        read -r total usada libre < <(free -m | awk '/^Mem:/ {print $2, $3, $4}')
        printf '%-10s %10s %10s %10s\n' "${i}/${MUESTRAS_RAM}" "${total}" "${usada}" "${libre}"
        [ "${i}" -lt "${MUESTRAS_RAM}" ] && sleep "${INTERVALO_RAM}"
    done
}

# ─── Opción 2: archivos grandes ─────────────────────────────────────────────
buscar_archivos_grandes() {
    echo "Los 5 archivos de más de 10 MB más grandes dentro de ${HOME}:"

    # El 2>/dev/null se come los "Permiso denegado" de los directorios ajenos;
    # sin eso la salida del find queda enterrada entre errores. El -printf da
    # el tamaño en bytes para poder ordenar numéricamente, y numfmt lo vuelve
    # legible recién al final.
    local resultado
    resultado="$(find "${HOME}" -type f -size +10M -printf '%s\t%p\n' 2>/dev/null \
        | sort -rn | head -n 5)"

    if [ -z "${resultado}" ]; then
        echo "  (no se encontraron archivos de más de 10 MB)"
        return
    fi

    printf '%s\n' "${resultado}" | while IFS=$'\t' read -r bytes ruta; do
        printf '  %8s  %s\n' "$(numfmt --to=iec --suffix=B "${bytes}")" "${ruta}"
    done
}

# ─── Opción 3: particiones ──────────────────────────────────────────────────
espacio_particiones() {
    echo "Uso de disco de las particiones físicas montadas:"
    # El filtro por /dev/ deja afuera tmpfs, devtmpfs y los montajes del store,
    # que no son particiones físicas y ensucian la lectura.
    df -h -x tmpfs -x devtmpfs | awk 'NR == 1 || /^\/dev\//'
}

# ─── Menú ───────────────────────────────────────────────────────────────────
echo "═══ Panel de monitoreo - ${ALUMNO} (legajo ${LEGAJO}) ═══"

select opcion in "Monitorear memoria RAM" \
                 "Buscar archivos grandes" \
                 "Espacio en particiones" \
                 "Salir"; do
    # Un Ctrl-D deja REPLY vacío y select vuelve a mostrar el menú para siempre.
    # Sin esta guarda el script no se puede cerrar más que matándolo.
    if [ -z "${REPLY}" ]; then
        echo
        echo "Entrada cerrada. Hasta luego, ${ALUMNO} (legajo ${LEGAJO})."
        break
    fi

    # El case va sobre el TEXTO que devuelve select, no sobre el número que
    # tecleó el usuario: si mañana cambia el orden del menú, las ramas siguen
    # apuntando a la opción correcta. Ante un número fuera de rango select deja
    # esta variable vacía, y por eso el caso vacío es el de entrada inválida.
    case "${opcion}" in
        "Monitorear memoria RAM")  echo; monitorear_ram          ;;
        "Buscar archivos grandes") echo; buscar_archivos_grandes ;;
        "Espacio en particiones")  echo; espacio_particiones     ;;
        "Salir")
            echo
            echo "Hasta luego, ${ALUMNO} (legajo ${LEGAJO}). Panel cerrado."
            break
            ;;
        *)
            echo "Opción inválida: '${REPLY}'. Elija un número del 1 al 4." >&2
            ;;
    esac
done

exit 0
