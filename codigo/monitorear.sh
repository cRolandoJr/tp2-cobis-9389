#!/usr/bin/env bash
# monitorear.sh - Tarea 3: panel interactivo de monitoreo de recursos.
# Uso    : ./monitorear.sh
# Códigos: 0 siempre; sale por la opción "Salir" o por EOF.

LEGAJO="9389"
ALUMNO="Rolando Cobis"
MUESTRAS_RAM=5
INTERVALO_RAM=2

PS3=$'\n'"Elija una opción (1-4): "

# Muestreo acotado en vez de free -s: con un bucle infinito el menú no vuelve nunca
monitorear_ram() {
    echo "Memoria RAM: ${MUESTRAS_RAM} lecturas cada ${INTERVALO_RAM}s (en MB)"
    printf '%-10s %10s %10s %10s\n' "Lectura" "Total" "Usada" "Libre"

    local i total usada libre
    for (( i = 1; i <= MUESTRAS_RAM; i++ )); do
        # Las tres columnas de una sola invocación: tres llamadas darían tres fotos distintas
        read -r total usada libre < <(free -m | awk '/^Mem:/ {print $2, $3, $4}')
        printf '%-10s %10s %10s %10s\n' "${i}/${MUESTRAS_RAM}" "${total}" "${usada}" "${libre}"
        [ "${i}" -lt "${MUESTRAS_RAM}" ] && sleep "${INTERVALO_RAM}"
    done
}

buscar_archivos_grandes() {
    echo "Los 5 archivos de más de 10 MB más grandes dentro de ${HOME}:"

    # %s en bytes para poder ordenar numéricamente; numfmt lo vuelve legible recién al final
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

espacio_particiones() {
    echo "Uso de disco de las particiones físicas montadas:"
    # El filtro por /dev/ deja afuera tmpfs y los montajes del store, que no son particiones
    df -h -x tmpfs -x devtmpfs | awk 'NR == 1 || /^\/dev\//'
}

echo "═══ Panel de monitoreo - ${ALUMNO} (legajo ${LEGAJO}) ═══"

select opcion in "Monitorear memoria RAM" \
                 "Buscar archivos grandes" \
                 "Espacio en particiones" \
                 "Salir"; do
    # El case va sobre el texto y no sobre el número: sobrevive a un cambio de orden del menú
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
