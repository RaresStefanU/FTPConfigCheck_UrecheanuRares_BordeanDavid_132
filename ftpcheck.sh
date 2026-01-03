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


# - permisiunile fisierului:


# - optiuni critice de securitate:




#Analiza fisierului





# Afisare:

# - problemele detectate:




# - configuratii conforme:

