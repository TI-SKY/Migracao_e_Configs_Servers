#!/bin/bash
############################################################################################################################
# Script para Preparação de ambiente para HQBIRD
#      _            _        __                            _   _
#  ___| | ___   _  (_)_ __  / _| ___  _ __ _ __ ___   __ _| |_(_) ___ __ _ 
# / __| |/ / | | | | | '_ \| |_ / _ \| '__| '_ ` _ \ / _` | __| |/ __/ _` |
# \__ \   <| |_| | | | | | |  _| (_) | |  | | | | | | (_| | |_| | (_| (_| |
# |___/_|\_\\__, | |_|_| |_|_|  \___/|_|  |_| |_| |_|\__,_|\__|_|\___\__,_|
#           |___/
#
# Autor: Silvio Souza
# silvio.souza@skyinformatica.com.br
# Última modificação: 30/09/2022
############################################################################################################################
echo Verificar atualizações do sistema operacional
sleep 3
apt-get update -y
apt-get upgrade -y
clear

echo Habilitar Data e hora no histórico de comandos
sleep 3
export HISTTIMEFORMAT='%F %T '
echo '##############################################################################################################################'
echo Instalar unzip, samba no sistema
sleep 3
apt-get install -y unzip samba
echo '##############################################################################################################################'
echo Fazendo uma cópia do arquivo original do samba
sleep 3
cp /etc/samba/smb.conf /etc/samba/smb_original.conf
echo '##############################################################################################################################'
echo Configurando conf do Samba
sleep 3
cat >> /etc/samba/smb.conf << EOF
[sky]

comment = diretorio arquivos executaveis de sky
writeable = yes
browseable = yes
path = /sky/executaveis/
create mask = 0777
directory mask = 0777
force create mode = 0777
force directory mode = 0777
guest ok = yes
read only = no
veto files = /*.mp3/*.mp4/*.doc/*.docx
delete veto files = no
vfs objects = recycle
recycle:keeptree = true
recycle:repository = /sky/lixeira

[backup]

comment = diretorio arquivos de backups de bancos de dados de sistemas sky
writeable = yes
browseable = yes
path = /sky/backup/
guest ok = yes
read only = yes
EOF
echo '##############################################################################################################################'
echo Reiniciando Samba
sleep 3
systemctl restart smbd
echo '##############################################################################################################################'
echo Instalar pré requisitos para HQBIRD
sleep 3

echo Instalando Java
sleep 3
apt install -y openjdk-8-jre-headless
echo '##############################################################################################################################'
echo Instalando libtommath
sleep 3
apt install -y libtommath1
echo '##############################################################################################################################'
echo Instalando libncurses
sleep 3
apt install -y libncurses5
echo '##############################################################################################################################'
echo Download da versão do HQBird
sleep 3
wget https://ib-aid.com/download/hqbird/install_fb25_hqbird2022.sh
chmod +x install_fb25_hqbird2022.sh
echo '############################################################################################################################################################################################################################################################'
echo Instalando HQBIRD
sleep 3
./install_fb25_hqbird2022.sh
echo '##############################################################################################################################'
echo Criando os atalhos gbak, gfix, gstat
sleep 3
ln -s /opt/firebird/bin/gbak /bin/gbak && ln -s /opt/firebird/bin/gstat /bin/gstat && ln -s /opt/firebird/bin/gfix /bin/gfix && ln -s /opt/firebird/bin/nbackup /bin/nbackup && ln -s /opt/firebird/bin/gsec /bin/gsec
echo '##############################################################################################################################'
echo Parar e desativar serviços que vem com hq2022 e não utilizaremos
sleep 3
systemctl stop fbcclauncher.service fbcctracehorse.service fbccamv.service
systemctl disable fbcclauncher.service fbcctracehorse.service fbccamv.service
echo '##############################################################################################################################'
echo Alterando método firebird
sleep 3
/opt/firebird/bin/changeMultiConnectMode.sh
echo '##############################################################################################################################'
echo Instalação concluída
echo '##############################################################################################################################'
