# Preparação após a instalação de Ubuntu Server 20/22/24 .04 64 bit

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
export HISTTIMEFORMAT='%F %T ' && echo "export HISTTIMEFORMAT='%F %T '" >> /etc/bash.bashrc
```

Alterar o vm.swappiness para iniciar o uso de swap somente quando tiver menos de 10% de RAM livre
```bash
sysctl -w vm.swappiness=10 && echo vm.swappiness=10 >> /etc/sysctl.conf
```

 ### Acertar fuso horário no ubuntu
```bash
dpkg-reconfigure tzdata
```
 Verificar o horário do sistema e do syslog
```bash
date && tail /var/log/syslog
```
Caso o horário do syslog não tenha sido ajustado pro fuso correto
```bash
systemctl restart rsyslog
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


## Configurar o compartilhamento de arquivos

Criar estrutura de diretórios em
O exemplo abaixo é para configurar a partir do /

Definir a variável com o caminho raiz da pasta sky
```bash
SKYROOTDIR=/sky
```

```bash
mkdir $SKYROOTDIR && \
cd $SKYROOTDIR && \
mkdir -m 775 dados && \
mkdir -m 777 executaveis && \
mkdir -m 777 lixeira && \
mkdir logs skyremotebackup livros_digitalizados scripts backup executaveis/install/ && \
mkdir $SKYROOTDIR/backup/diario $SKYROOTDIR/backup/incremental $SKYROOTDIR/backup/completo
```

Instalar samba
```bash
apt install samba -y
```

Fazer uma cópia do arquivo original do samba
```bash
cp /etc/samba/smb.conf /etc/samba/smb_original.bkp
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


# Instalar e configurar o HQBIRD

Para realizar uma nova instalação ou atualizar o hq, pare os serviços do firebird e hqbird e confirme se não há nenhum processo rodando.
```bash
ps axu |grep firebird
```
Para atualizar (fb25 para fb25 ou fb40 para fb40), instale por cima e siga os passos do instalador.
Para trocar de firebird (fb25 para fb40) desinstale o hqbird.


Instalar as dependencias para instalação do HQbird com o comando abaixo
```bash
apt install -y openjdk-8-jre-headless libtommath1 libncurses5
```
> se for ubuntu 24, não instalar libncurses5, agora está na versão 6 e já vem instalado. Atenção para instalar corretamente as outras dependências.

#### Caso seja DEBIAN
ALGUMAS VERSÕES DO DEBIAN NÃO FUNCIONAM COM A VERSÃO DO HQ 2020
O debian 10, 11 e 12 não tem mais o java 8 nativamente no repositório, para poder instalar o JAVA 8 no debian, siga os passos abaixo.
##### Debian 10 e 11
```bash
apt-get install software-properties-common && \
apt-add-repository 'deb http://security.debian.org/debian-security stretch/updates main' && \
apt-get update && \
apt-get install openjdk-8-jdk
```
##### Debian 12
```bash
wget http://www.mirbsd.org/~tg/Debs/sources.txt/wtf-bookworm.sources && \
mv wtf-bookworm.sources /etc/apt/sources.list.d/ && \
apt update && apt-get install openjdk-8-jdk
```
##### Se não for debian, ignorar os comandos acima


# Firebird 2.5
Entrar no diretório de download HQbird comando abaixo
```bash
mkdir $SKYROOTDIR/executaveis/install/HQbird && \
cd $SKYROOTDIR/executaveis/install/HQbird
```
```bash
wget https://cc.ib-aid.com/download/distr/install.sh
```

> caso tenha problemas com o instalador há versões antigas em https://arch.skyinformatica.com.br/downloads/utilitarios/bancodados/ com o nome: `install_hqbird<Last update>.sh`. Para baixar direto no linux: ```wget --http-user=sky --ask-password <LINK>``` 

> endereço antigo apenas com fb25: https://ib-aid.com/download/hqbird/install_fb25_hqbird2024.sh

> Caso seja ubuntu 24, trocar a dependencia para libncurses6 em vez de 5. Criar um link para libncurses.so.5
```bash
sed -i 's/'libncurses\.so\.5/'libncurses\.so\.6/' install.sh
```
```bash
ln -s /usr/lib/x86_64-linux-gnu/libncurses.so.6.4 /usr/lib/x86_64-linux-gnu/libncurses.so.5
```



Dar a permissao completa ao arquivo instalador e instalar o HQbird
```bash
chmod +x install.sh && ./install.sh --fb25
```

Efetuar troca do método do firebird para superclassic
```bash
yes 'thread' | /opt/firebird/bin/changeMultiConnectMode.sh
```

- thread: **super classic** #recomendado
-- super classic aparece um processo unico fb_smp_server
- process: **classic**
-- classic usa multi processo fb_inet (um processo para cada conexão)

```bash
systemctl stop firebird.service && \
systemctl start firebird.service
 ```

Analisar e confirmar o nome correto da pasta de instalação firebird em /opt

```bash
ls -lh /opt
```
Definir uma variável com a pasta de instalação firebird em /opt

```bash
FBROOTDIR=/opt/firebird
```


- OBS¹: Se alterar para o classic e o sistema não rodar o firebird é necessário verificar se não ter o xinet na pasta /etc/init.d, é necessário instalar o xinet, para isso
- OBS²: Quando aplicado o modo classic mudar as paradas e inicializações nos scripts que normalmente passam a ser /etc/init.d/xinetd stop ou shutdown, /etc/init.d/xinetd start. E encerrar os processos abertos pelo usuário firebird (encerra também o dash do hqbird): **killall -u firebird**
```bash
apt install xinetd
```

Se necessário redefinir a senha do firebird no servidor
```bash
$FBROOTDIR/bin/gsec
```
```bash
modify sysdba -pw #8_CHAR
```
```bash
quit
```
Verificar configurações do conf do firebird
```bash
vi $FBROOTDIR/firebird.conf
```
DefaultDbCachePages = 384 #entre 384 a 1024

```bash
RemoteAuxPort = 3051
```

---

# Firebird 4.0
Pode-se manter o superserver que é o padrão da instalação.
O modo do server agora é configurado através do conf, mas dentro da pasta bin há um script `changeServerMode.sh` para realizar a função completa da troca do ServerMode.

Definir a variável com o caminho raiz da pasta sky
```bash
SKYROOTDIR=/sky
```

CASO SEJA UBUNTU 24, apenas rode o comando abaixo e pule para Pós Instalação
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/TI-SKY/Linux-Migracao_e_Configs/main/fb_hqbird_ub24-40.sh)
```

Entrar no diretório de download HQbird comando abaixo
```bash
mkdir -p $SKYROOTDIR/executaveis/install/HQbird && \
cd $SKYROOTDIR/executaveis/install/HQbird
```
```bash
wget https://cc.ib-aid.com/download/distr/install.sh
```
endereço antigo apenas com fb40: https://ib-aid.com/download/hqbird/install_fb40_hqbird2022.sh
Dar a permissao completa ao arquivo instalador e instalar o HQbird
```bash
chmod +x install.sh && ./install.sh --fb40
```
Analisar e confirmar o nome correto da pasta de instalação firebird em /opt

```bash
ls -lh /opt
```
Definir uma variável com a pasta de instalação firebird em /opt

```bash
FBROOTDIR=/opt/fb40
```

Se necessário redefinir a senha do firebird no servidor

`O gsec nessa versão está obsoleto, o ideal é alterar através dos comandos de SQL. Lembre-se que há mais de um método de autenticação, por isso há vários usuários SYSDBA, então é interessante alterar a senha de todos os SYSDBA.`

```bash
$FBROOTDIR/bin/isql -user sysdba -password masterkey security.db
```
O banco para ser conectado é $FBROOTDIR/security4.fdb, mas há um alias criado para ele com o nome de security.db

```bash
alter user SYSDBA password 'NOVASENHA' using plugin Srp;
```
O comando abaixo altera a senha do usuário sysdba no modo legacy, é esperado retornar um erro no firebird 4 já que o módulo não esta carregado por padrão.
> NÃO HÁ A NECESSIDADE DE RODAR O COMANDO ABAIXO SE NÃO FOR UTILIZAR O MODO LEGACY.
```bash
alter user SYSDBA password 'NOVASENHA' using plugin Legacy_UserManager;
```
```bash
exit;
```
```bash
vi $FBROOTDIR/firebird.conf
```
```bash
WireCrypt = Disabled
DataTypeCompatibility = 2.5
RemoteAuxPort = 3051
```
E caso necessário
```bash
AuthServer = Legacy_Auth, Srp, Win_Sspi
AuthClient = Srp256, Srp, Legacy_Auth
```
Confirme o nome do serviço
```bash
systemctl list-units --type service
```
Manipule o serviço com systemctl
```bash
systemctl stop firebird.opt_firebird40.service
```
```bash
systemctl start firebird.opt_firebird40.service
```

---

# Pós instalação

Caso não tenha criado, crie a variável com o caminho da pasta de instalação do firebird e sky.

Ex: FBROOTDIR=/opt/firebird ou FBROOTDIR=/opt/fb40, SKYROOTDIR=/sky

Criar os atalhos gbak, gstat e gfix
```bash
ln -s $FBROOTDIR/bin/gbak /bin/gbak && \
ln -s $FBROOTDIR/bin/gstat /bin/gstat && \
ln -s $FBROOTDIR/bin/gfix /bin/gfix && \
ln -s $FBROOTDIR/bin/nbackup /bin/nbackup && \
ln -s $FBROOTDIR/bin/gsec /bin/gsec && \
ln -s $FBROOTDIR/bin/isql /bin/isql
```

Dê permissão para a pasta dados (onde ficarão os bancos)
```bash
chown -R firebird.firebird $SKYROOTDIR/dados && chmod 664 $SKYROOTDIR/dados/*?db
```

Parar e desativar serviços que vem com hq2022 e não usamos
```bash
systemctl stop fbcclauncher.service fbcctracehorse.service fbccamv.service && \
systemctl disable fbcclauncher.service fbcctracehorse.service fbccamv.service
```

Após definir o conf personalizado como ativo definir os bancos para que passem a usar as configurções personalizadas do conf personalizado, no diretório dados aplicar o comando.
```bash
for i in *.?db; do gfix -buffers 0 $i;done
```
OBS: Após esse procedimento para que entre em vigor é necessário parar e iniciar o firebird.

Definir os bancos de imagens antigos para somente leitura
```bash
for i in skyimagens*.?db; do gfix -mode read_only $i;done
for i in tedimagens*.?db; do gfix -mode read_only $i;done
for i in imgprotesto*.?db; do gfix -mode read_only $i;done
for i in imagens*.?db; do gfix -mode read_only $i;done
```
Mas o último banco de imagens deve ficar como leitura e gravação, para isso aplique o comando abaixo no último banco de imagens
```bash
gfix -mode read_write #ultimo-banco-de-imagens
```


Teoricamente está configurado e pronto para receber a sincronização dos dados que devem ficar organizados conforme os padrões.

Ficando então em /sky

backup
backup/completo
backup/diario
backup/incremental
dados
executaveis
executaveis/install
livros_digitalizados
logs
scripts
skyremotebackup


Dentro do diretório /sky/scripts crie os scripts necessários e conforme modelos abaixo:
(scripts no github)
sincroniza-srb.sh (linux para a estação srb)
sincroniza_executaveis_para_srb.sh (linux para estação srb)
skybackup.sh
skybackup-img.sh
inicia-backup-diario.sh

## SOUNDEX imoveis

Se tiver sistema de imoveis, colocar a skysoundex.dll em: /opt/firebird/UDF/

[SKySoundex.dll](https://drive.google.com/file/d/14T9GZy0SVe73d4qf59GsMVbK0PDhI3ph/view)


## Crontab
Realiza os backups diários de Segundas a Sextas no servidor local.
```bash
00 12 * * 1-5 root  /sky/scripts/inicia-backup-diario.sh
```

Realiza as sincronizações de Segundas a Sextas para estação do backup remoto.
```bash
00 21 * * 1-5 root  /sky/scripts/sincroniza_executaveis_para_srb.sh
30 21 * * 1-5 root  /sky/scripts/sincroniza-srb.sh
```

Realiza a reinicialização do servidor todas as Segundas Feiras à 01:00.
```bash
00 01 * * 1   root  shutdown -r now
```

Realiza sincronização da hora  todas as Segundas Feiras pela internet.
```bash
10 07 * * 1   root  ntpdate br.pool.ntp.org br.pool.ntp.org br.pool.ntp.org
```


## Lowercase no nome dos bancos

### Método 1

Usar a linha de comando (atenção as CRASES e APÓSTROFOS)
```bash
for i in $( ls | grep [A-Z] ); do mv -i $i `echo $i | tr 'A-Z' 'a-z'`; done
```

### Método 2

Instalar o serviço rename
```bash
apt-get install rename
```

De maiúscula para minúscula entre no diretório dados e aplique o comando
```bash
rename 'y/A-Z/a-z/' *
```

De minúscula para maiúsculas entre no diretório dados e aplique o comando
```bash
rename 'y/a-z/A-Z/' *
```

Renomear tudo de .gdb para .fdb entre no diretório dados e aplique o comando
```bash
rename -v 's/.gdb/.fdb/' *.gdb
```

Renomear tudo de .fdb para .gdb entre no diretório dados e aplique o comando:
```bash
rename -v 's/.fdb/.gdb/' *.fdb
```

## Bancos de imagens nos sistemas

### IMOVEIS

1º Navegue nos menus Utilitários>>Painel de controle>>Conexão com banco de dados.
2º Tecle ctrl+D no menu Digitalização>>Configurações


### NOTAR
Verifique se no banco NOTAR há apontamentos para os bancos SKYIMAGENS em vez de skyimagens.
```bash
SELECT DBNOMEARQUIVO FROM IMAGENSIDX i WHERE i.DBNOMEARQUIVO = 'SKYIMAGENS'
```
E caso for necessário, faça update para colcoar em minúsculo. 
```bash
UPDATE imagensidx i SET i.DBNOMEARQUIVO = 'skyimagens' where i.DBNOMEARQUIVO = 'SKYIMAGENS'
```
