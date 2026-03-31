#!/bin/bash

# Script em Shell para realizar backup dos arquivos do usuario /home/sistemas/ para o servidor da loja em /backup/"hostname da maquina"/sistemas, executado a 00:00
# O backup esta situado em /backup/$maquinalocal/sistemas na maquina local.
# 
# Scritp deve ser colocado no /usr/dimedbin/BackupUser.sh
# Permissoes: chown root:root /usr/dimedbin/BackupUser.sh ; chmod 755 /usr/dimedbin/BackupUser.sh
# Crontab: 
# @reboot /usr/dimedbin/BackupUser.sh
# 00 00 * * * /usr/dimedbin/BackupUser.sh
# 
# 23/11/2022 - V1 - Tiago Shaolin - Infra

#Variaveis
maquinalocal=$(hostname -s)                     # Obtem o nome da maquina local 
setfil=$(hostname -i | cut -d "." -f 2,3)       # seta o num da filial no ip do server 10.x.xx.40
servidor="10.$setfil.40"                        # Monta o ip de Destino
userfiles=$(du -sh /home/sistemas/)             # Obtem o tamanho antes de realizar o filtro de backup

# Informaçoes de date time para log
DATALOG=`date "+%d%m%Y"`                        # Data do log Dia/Mes/Ano
tempo=`date "+%H:%M:%S"`                        # time do log hora:minuto:segundo
log="/var/log/BackupUser$DATALOG.log"

echo -e "- ${tempo} - Realizando Backup do Diretorio ${maquinalocal}/home/sistemas/ com ${userfiles} para Diretorio local /backup/${maquinalocal}/sistemas" >> ${log}
#echo -e "Servidor backup: $servidor"
#echo -e "Tamanho atual: $userfiles"

#Cria Subdiretorio na maquina local
mkdir -p /backup/${maquinalocal}/sistemas

# Aguarda 1 segundo
sleep 1

# Exclui Arquivos de sistema e imagens para a pasta local
rsync -auv --exclude={'.*','*.deb','*.sh','bin','*.rpm','*.js','GNUstep','oradiag_sistemas','backup*','*.log','*.desktop','*.jpeg','*.jpg','*.png','*.gif','*.tif','*.zip','*.bin','public_html','Modelos','Imagens'} --no-links /home/sistemas/ /backup/${maquinalocal}/sistemas/  >> $log

# Aguarda 1 segundo
sleep 1

# Verifica o Tamanho do Backup da pasta SISTEMAS apos o Filtro no RSYNC
backupfiles=$(du -sh /backup/$maquinalocal/sistemas)

#echo -e "Tamanho do Backup: $backupfiles"       # exibe o tamanho do backup na pasta local

# Aguarda 1 segundo
sleep 1

# Envia para o Servidor da Filial no Diretorio /backup/"hostname da maquina"/ que esta executando.
rsync -av /backup/$maquinalocal/ -e "ssh -o StrictHostKeyChecking=no" $servidor:/backup/$maquinalocal/ >> $log

echo -e "- ${tempo} - Tamanho apos filtro ${backupfiles} Enviado para o Server ${servidor} Diretorio /backup/${maquinalocal}/sistemas \n " >> ${log}