#!/bin/bash
# Acest scripr 


# #1 Verifica:
# - existenta fisierului:

# Daca utilizatorul nu a dat ca parametru fisierul
if [ -z "$1" ]; then
    echo "Utilizare: $0 <cale_fisier>"
    exit 1
fi

CALE_FISIER=$1

if ! [ -e "$CALE_FISIER" ]; then
    echo "Fisierul nu a fost gasit!"
    exit 2
fi


# Parsing fisier + ignora comentariile + regex

# Doua matrice asociative:
declare -A value # prima pentru valoari - atribute ale configurarii
declare -A line_no # a doua pentru linia pe care se afla valoarea


nr=0 # Luam fiecare linie pe care e scris ceva|contor ptr linie
# Dupa parsig numarul de linii trebuie sa fie egal cu numarul de 

# IFS = Internal Field Separator (Separator de Camp Intern)
while IFS= read -r line; do
    ((nr++))
    line=$(echo "$line" | sed 's/#.*//' | xargs)
    [ -z "$line" ] && continue

    if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
        key="${BASH_REMATCH[1]}" 
        val="${BASH_REMATCH[2]}"
        value[$key]="$val"
        line_no[$key]="$nr"
    fi
done < "$CALE_FISIER" #"$CONFIG"

# - permisiunile fisierului:
# - optiuni critice de securitate:

# #2 Afisare:
# - problemele detectate:
# - configuratii conforme:

# Exit standard
echo "Program functional" #Pentru testare,  sterge la final
exit 0