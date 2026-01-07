#!/bin/bash


# Verifica:


# - existenta fisierului:

#daca utilizatorul nu a dat ca parametru fisierul
if [ -z "$1" ] then
    echo "Utilizare: $0 <cale_fisier>"
    exit $1
fi

CALE_FISIER=$1

if ! [ -e "$CALE_FISIER" ]; then
    echo "Fisierul nu a fost gasit!"
    exit $2
fi


# Parsing fisier + ignora comentariile
# SCI = Separator de Camp Intern
while SCI= read -r line; do
    line=$(echo "$line" | sed 's/#.*//')
    [ -z "$line" ] && continue
done < "$CONFIG"


# - permisiunile fisierului:


# - optiuni critice de securitate:




#Analiza fisierului





# Afisare:

# - problemele detectate:




# - configuratii conforme:

