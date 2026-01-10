#!/bin/bash

# (optional) Banner


# Contoare pentru raport final
warnings=0

# #1 Verifica:
# - existenta fisierului:

# Daca utilizatorul nu a dat ca parametru fisierul
if [ -z "$1" ]; then
    echo "[EROARE] Lipseste fisierul de configurare!"
    echo "Utilizare: $0 <cale_fisier>"
    echo "Exemplu: $0 /etc/vsftpd/vsftpd.conf"
    exit 1
fi

CALE_FISIER=$1

echo "[INFO] Verificare existenta fisier:"
if ! [ -e "$CALE_FISIER" ]; then
    # Daca fisierul nu exista
    echo "[EROARE] Fisierul nu a fost gasit!"
    exit 1
elif ! [ -f "$CALE_FISIER" ]; then 
    # Daca calea nu duce catre un fisier (ex. duce catre un director)
    echo "[EROARE] Calea specificata nu este un fisier valid!"
    exit 1
else
    echo "[OK] Fisierul exista."
    echo ""
fi


# Parsing fisier + ignora comentariile + ?regex (am pus totul intr-o functie)
ParseIgnoreRegex() {

    echo "[INFO] Parsing in desfasurare:"
    # Doua matrice asociative:
    declare -A value # prima pentru valoari - atribute ale configurarii
    declare -A line_no # a doua pentru linia pe care se afla valoarea


    local nr=0 # contor pentru liniile fisierului

    # IFS = Internal Field Separator (Separator de Camp Intern)
    while IFS= read -r line; do
        ((nr++))
        # Ignoram liniile goale si comentariile
        line=$(echo "$line" | sed 's/#.*//' | xargs)
        [ -z "$line" ] && continue

        # Verifica daca se poate sparge linia in CHEIE = VALOARE
        if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then # Regex propriu zis  
            key="${BASH_REMATCH[1]}" # Partea dinainte de = devine CHEIE
            val="${BASH_REMATCH[2]}" # Partea dupa = devine VALOARE
            value[$key]="$val"
            line_no[$key]="$nr"
        else
            ((warnings++))
            echo "[CRITIC] Eroare la folosirea expresiilor regulare pe linia $nr !"
        fi
    done < "$CALE_FISIER" #"$CONFIG"
    echo "[INFO] Parsing complet."
    echo ""
}
ParseIgnoreRegex

# - permisiunile fisierului:



# - optiuni critice de securitate:

# #2 Afisare:
# - problemele detectate:
# - configuratii conforme:

# Exit standard
echo "[OK] Program functional" #Pentru testare,  sterge la final
exit 0