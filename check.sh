#!/usr/bin/env bash
# Checks whether the player escaped the vim escape room.
# Usage: bash check.sh

file="escape.txt"

if [[ ! -f "$file" ]]; then
    echo "no encuentro $file. ¿estás dentro de la carpeta vim-escape-room?"
    exit 1
fi

# Return the first line that starts with the given label (e.g. "llave:").
line_of() {
    grep -m1 "^$1" "$file"
}

# Door 1: something written after "nombre:".
name_line="$(line_of 'nombre')"
name_value="${name_line#nombre}"
name_value="${name_value//[:[:space:]]/}"
[[ -n "$name_value" ]] && door1=1 || door1=0

# Door 2: the key "despacio" on the "llave:" line.
line_of 'llave' | grep -qi 'despacio' && door2=1 || door2=0

# Door 3: doors 1 and 2 are in the file, so they were saved with :w.
(( door1 && door2 )) && door3=1 || door3=0

# Door 4: the "trampa:" line exists and the trap word was NOT saved.
trap_line="$(line_of 'trampa')"
trap_count="$(grep -oi 'trampa' <<< "$trap_line" | wc -l)"
[[ -n "$trap_line" && "$trap_count" -eq 1 ]] && door4=1 || door4=0

# Door 5: "salgo" on the "salida:" line.
line_of 'salida' | grep -qi 'salgo' && door5=1 || door5=0

hints=(
    ""
    "escribe tu nombre en la línea \"nombre:\" y guarda con :w"
    "la llave va en la línea \"llave:\". búscala con /puerta2"
    "guarda con :w antes de seguir"
    "la trampa se guardó. bórrala, o sal con :q! la próxima vez"
    "escribe salgo en la línea \"salida:\" y sal con :wq"
)

doors=("" "$door1" "$door2" "$door3" "$door4" "$door5")
escaped=1

for n in 1 2 3 4 5; do
    if (( doors[n] )); then
        echo "puerta $n ✓"
    else
        echo "puerta $n ✕   ${hints[n]}"
        escaped=0
    fi
done

echo
if (( escaped )); then
    echo "saliste."
else
    echo "todavía no. vuelve a entrar: vim escape.txt"
fi
