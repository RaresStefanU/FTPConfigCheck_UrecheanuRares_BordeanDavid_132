#!/bin/bash

# #1 Verifica:
# - existenta fisierului:
CALE_FISIER=$1

if [ ! -r "$CALE_FISIER" ]; then
    echo "\e[31mEroare: fisierul nu poate fi citit\e[0m"
    exit 1
fi

# Daca utilizatorul nu a dat ca parametru fisierul
if [ -z "$1" ]; then
    echo "Utilizare: $0 <cale_fisier>"
    exit 1
fi

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
            echo -e "\e[33m[NESIGUR] $key=${value[$key]} (linia ${line_no[$key]}), ar trebui ${value_optim[$key]}\e[33m"
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
echo -e "\e[34m------------------------------------------------\e[0m"



# Exit standard
#Pentru testare,  sterge la final


exit 0