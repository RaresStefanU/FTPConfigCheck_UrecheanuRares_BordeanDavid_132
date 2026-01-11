#!/bin/bash

# #1 Verifica:
# - existenta fisierului:
CALE_FISIER=$1

# Daca utilizatorul nu a dat ca parametru fisierul
if [ -z "$1" ]; then
    echo "[EROARE] Lipseste fisierul de configurare!"
    echo "Utilizare: $0 <cale_fisier>"
    echo "Exemplu: $0 /etc/vsftpd/vsftpd.conf"
    exit 1
fi

if ! [ -e "$CALE_FISIER" ]; then
    echo -e "\e[31mEroare: Fisierul nu a fost gasit!\e[0m"
    exit 1
elif ! [ -f "$CALE_FISIER" ]; then 
    # Daca calea nu duce catre un fisier (ex. duce catre un director)
    echo -e "\e[31mEroare: Calea specificata nu este un fisier valid!\e[0m"
    exit 1
fi

if [ ! -r "$CALE_FISIER" ]; then
    echo -e "\e[31mEroare: fisierul nu poate fi citit\e[0m"
    exit 1
fi

# Parsing fisier + ignora comentariile + ?regex (am pus totul intr-o functie)
ParseIgnoreRegex() {

    # Doua matrice asociative:
    declare -gA value # prima pentru valoari - atribute ale configurarii
    declare -gA line_no # a doua pentru linia pe care se afla valoarea

    # Doua matrici pentru directive duplicate:
    declare -gA count       # numar aparitii directive
    declare -gA all_lines   # toate liniile unde apare directiva


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
            ((count[$key]++))
            if [[ -n "${all_lines[$key]}" ]]; then
                all_lines[$key]="${all_lines[$key]}, $nr"
            else
                all_lines[$key]="$nr"
            fi
            value[$key]="$val"      # valoarea finala activa
            line_no[$key]="$nr"     # ultima linie
        else
            ((warnings++))
            echo "[CRITIC] Eroare la folosirea expresiilor regulare pe linia $nr !"
        fi
    done < "$CALE_FISIER"
}
ParseIgnoreRegex

# - optiuni critice de securitate:

# - setari duplicate:


# - optiuni de securitate:
# - declaram un array asociativ cu setarile optime la care ne raportam:

declare -A value_optim=(
    [anonymous_enable]="NO"
    [ssl_enable]="YES"
    [force_local_logins_ssl]="YES"
    [force_local_data_ssl]="YES"
    [ssl_sslv2]="NO"
    [ssl_sslv3]="NO"
    [ssl_tlsv1]="YES"
    [userlist_enable]="YES"
    [userlist_deny]="NO"
    [userlist_file]="/etc/vsftpd/user_list"
    [write_enable]="YES"
    [allow_writeable_chroot]="YES"
    [chroot_local_user]="YES"
    [userlist_enable]="YES"
    [userlist_deny]="NO"
    [tcp_wrappers]="YES"
    [pasv_enable]="YES"
    [pasv_min_port]="40000"
    [pasv_max_port]="40100"
    [secure_chroot_dir]="/var/run/vsftpd/empty"
)

# #2 Afisare:
# - problemele detectate:
# - configuratii conforme:
setari_ok=0
setari_nesigure=0
setari_critice=0

for key in "${!value_optim[@]}"; do
    if [[ -z "${value[$key]+x}" ]]; then
        echo -e "\e[31m[CRITIC] $key lipseste din configuratie\e[0m"
        ((setari_critice++))
    else
        if [[ "${value[$key]}" != "${value_optim[$key]}" ]]; then
            echo -e "\e[33m[NESIGUR] $key=${value[$key]} (linia ${line_no[$key]}), ar trebui ${value_optim[$key]}\e[0m"
            ((setari_nesigure++))
        else
            echo -e "\e[32m[OK] $key=${value[$key]} (linie ${line_no[$key]})\e[0m"
            ((setari_ok++))
        fi
    fi
done

# Rezumat:

echo -e "\e[34m------------------------------------------------\e[0m"
echo "Rezumat:"
if (($setari_critice == 1)); then
    echo -e "\e[31m- 1 setare critica\e[0m"
else
    echo -e "\e[31m- $setari_critice setari critice\e[0m"
fi
if (($setari_nesigure == 1)); then
    echo -e "\e[33m- 1 setare nesigure\e[0m"
else
    echo -e "\e[33m- $setari_nesigure setari nesigure\e[0m"
fi
if (($setari_ok == 1)); then
    echo -e "\e[32m- 1 setare ok\e[0m"
else
    echo -e "\e[32m- $setari_ok setari ok\e[m"
fi
echo ""

# Directive duplicate:
echo "Directive duplicate:"
for key in "${!count[@]}"; do
    if (( count[$key] > 1 )); then
        echo -e "\e[33m-$key apare de ${count[$key]} ori (linii:${all_lines[$key]})\e[0m"
        echo -e "\e[33m          Valoare finala activa: ${value[$key]}\e[0m"
    fi
done
echo ""
# Permisiuni
# - permisiunile fisierului:
echo "Permisiuni:"

crit_set=0
ok_set=0

perms=$(stat -c "%a" "$CALE_FISIER" 2>/dev/null)
owner=$(stat -c "%U" "$CALE_FISIER" 2>/dev/null)
echo "[INFO] Permisiuni curente: $perms"
echo "[INFO] Proprietar: $owner"

if [ $((perms & 002)) -ne 0 ]; then
    echo -e "\e[31m[CRITIC] Fisierul este modificabil de oricine (world-writable)!\e[0m"
    ((crit_set++))
else
    echo -e "\e[32m[OK] Fisierul nu este world-writable\e[0m"
    ((ok_set++))
fi

if [ $((perms & 020)) -ne 0 ]; then
    echo -e "\e[33m[WARNING] Fisierul este modificabil de grup\e[0m"
    echo -e "\e[33m         Recomandare: chmod 644 sau 600\e[0m"
fi


#recomandare (muta la fin)
if [ "$perms" != "600" ] && [ "$perms" != "644" ]; then
    echo -e "\e[33m[WARNING] Permisiuni recomandate: 600 (root only) sau 644\e[0m"
    echo -e "\e[33m         Permisiuni curente: $perms\e[0m"
fi


echo -e "\e[34m------------------------------------------------\e[0m"



# Exit standard
#Pentru testare,  sterge la final


exit 0