# Preparação após a instalação de Ubuntu Server 20.04 64 bit

Lista o service tag e serial do equipamento
```bash
dmidecode -t 1
```

Verificar a distro
```bash
hostnamectl
```

Verificar espaço em disco
```bash
df -h
```

Configurar o hostname
```bash
vim /etc/hostname
```

Atualizar índice de pacotes 
```bash
apt-get update
```

Atualizar o sistema
```bash
apt-get upgrade -y
```

Habilitar Data e hora no histórico de comandos (history)
```bash
export HISTTIMEFORMAT='%F %T '
```

 Acertar fuso de horas no ubuntu
```bash
dpkg-reconfigure tzdata
```

Caso queira colocar a hora em formato 24hrs
```bash
localectl set-locale LC_TIME="C.UTF-8"
```

Instalar unzip no sistema
```bash
apt-get install unzip
```

## Configurar a rede

### Exemplo quando configurado 2 placas de rede com sistema bond: (placas funcionam com redundândia de conexão e somam as taxas)
-- VERIFICAR OS ENDEREÇOS

Abrir o arquivo de configuraçao de rede

```bash
vim /etc/netplan/*.yaml
```

```bash
bonds:
        bond0:
            addresses:
            - 10.10.1.4/24
            dhcp4: false
            gateway4: 10.10.1.254
            interfaces:
            - eno1
            - eno2
            nameservers:
                addresses:
                - 10.10.1.254
                - 8.8.8.8
                search:
                - 8.8.8.8
            parameters:
                mode: balance-rr
    ethernets:
        eno1:
            addresses: []
            dhcp4: false
            dhcp6: false
        eno2:
            addresses: []
            dhcp4: false
            dhcp6: false
    version: 2
```

Testar os link das placas de rede com o comando.  (nome dado a sua interface bond)
```bash
ethtool bond0
```

### Exemplo quando configurado uma unica placa de rede: 
-- VERIFICAR OS ENDEREÇOS

```bash
network:
    ethernets:
        eno1:
            addresses:
            - 10.10.1.254/24
            gateway4: 10.10.1.254
            nameservers:
                addresses:
                - 8.8.8.8
                - 8.8.4.4
    version: 2

```

Após qualquer alteração em arquivo de configuração de rede aplique o comando:
```bash
netplan try
```

Caso tenha ficado OK
```bash
netplan apply
```

Desabilitar verificação de rede (a start job is running for wait for network to be configured)
Evitar que outro serviço force sua inicialização
```bash
systemctl disable systemd-networkd-wait-online.service
systemctl mask systemd-networkd-wait-online.service
```

Criar estrutura de diretórios em
O exemplo abaixo é para configurar a partir do /

```bash
mkdir /sky && cd /sky && mkdir -m 775 dados && mkdir -m 777 executaveis && mkdir logs skyremotebackup livros_digitalizados scripts backup executaveis/install/ && mkdir /sky/backup/diario /sky/backup/incremental /sky/backup/completo
```

## Configurar o compartilhamento de arquivos

Instalar samba
```bash
apt install samba -y
```

Fazer uma cópia do arquivo original do samba
```bash
cp /etc/samba/smb.conf /etc/samba/smb_original.conf
```

```bash
vim /etc/samba/smb.conf
```

/etc/samba/smb.conf
```bash
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
```
```bash
[backup]

comment = diretorio arquivos de backups de bancos de dados de sistemas sky
writeable = yes
browseable = yes
path = /sky/backup/
guest ok = yes
read only = yes
```

```bash
[livros digitalizados]

comment = diretorio arquivos de livros digitalizados do acervo do cartorio
writeable = yes
browseable = yes
path = /sky/livros_digitalizados/
guest ok = yes
read only = yes
vfs objects = recycle
recycle:keeptree = true
recycle:repository = /sky/lixeira
```

Reiniciar o serviço do samba
```bash
systemctl restart smbd
```

## Instalar e configurar o HQBIRD

Instalar as dependencias para instalação do HQbird com o comando abaixo
```bash
apt install -y openjdk-8-jre-headless libtommath1 libncurses5
```

### Caso seja DEBIAN
ALGUMAS VERSÕES DO DEBIAN NÃO FUNCIONAM COM A VERSÃO DO HQ 2020
O debian 10 e 11 não tem mais o java 8 nativamente no repositório, para poder instalar o JAVA 8 no debian, siga os passos abaixo.

```bash
apt-get install software-properties-common && apt-add-repository 'deb http://security.debian.org/debian-security stretch/updates main' && apt-get update && apt-get install openjdk-8-jdk
```

Entrar no diretório de download HQbird comando abaixo
```bash
cd /sky/executaveis/install/HQbird
```
```bash
wget https://ib-aid.com/download/hqbird/install_fb25_hqbird2022.sh
```

Descompactar, dar a permissao completa ao arquivo instalador e instalar o HQbird
```bash
unzip /sky/executaveis/HQbird/hqbirdlinux.zip
```
```bash
rm /sky/executaveis/HQbird/hqbirdlinux.zip
```
```bash
chmod +x /sky/executaveis/HQbird/install_fb25_hqbird2022.sh
```
```bash
./install_fb25_hqbird2022.sh
```
