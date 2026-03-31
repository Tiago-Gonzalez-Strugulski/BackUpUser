#/bin/bash

# script para auxiliar a restauracao dos arquivos da maquina farmaceuticoxxx
ip=`/sbin/ifconfig | grep 'inet' | cut -d: -f2 | grep -o "10.[0-9]*\.[0-9]*\." | grep -v "127.0.0"`
filial=$(hostname -s | tr -cd '[:digit:]' |cut -c1-3)

echo -e " ${ip} ${filial}"
scp -r /backup/farmaceutico${filial}/sistemas/ ${ip}50:/home/sistemas/Backup/