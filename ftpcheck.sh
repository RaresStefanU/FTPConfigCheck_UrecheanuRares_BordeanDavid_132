#!/bin/bash


# Verifica:


# - existenta fisierului:
CONFIG="$1"

if [ -z "$CONFIG" ]; then
    echo "Usage: $0 <config_file>"
    exit 1
fi

if [ ! -f "$CONFIG" ]; then
    echo "Error: file does not exist"
    exit 1
fi

if [ ! -r "$CONFIG" ]; then
    echo "Error: file is not readable"
    exit 1
fi

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

# - permisiunile fisierului:


# - optiuni critice de securitate:




#Analiza fisierului





# Afisare:

# - problemele detectate:




# - configuratii conforme:

