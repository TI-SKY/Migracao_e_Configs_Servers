# Preparação após a instalação de CENTOS 7 64 bit

Verificar a distro
```bash
hostnamectl
```

Verificar espaço em disco
```bash
df -h
```

Atualizar o sistema
```bash
yum update -y
```

Habilitar Data e hora no histórico de comandos (history)
```bash
export HISTTIMEFORMAT='%F %T '
```

Verificar o fusohorário
```bash
timedatectl
```

 Acertar fuso da hora, caso necessário
```bash
timedatectl list-timezones | grep America
```
```bash
timedatectl set-timezone America/Sao_Paulo
```

Para definir o horário do hardware para o mesmo horário local, use
```bash
timedatectl set-local-rtc 1
```
Importante reiniciar o serviço cron
```bash
systemctl restart crond
```

Instalar unzip e vim no sistema
```bash
yum -y install unzip vim
```

Configurar o hostname
```bash
vim /etc/hostname
```

## Configurar o compartilhamento de arquivos

Criar estrutura de diretórios em
O exemplo abaixo é para configurar a partir do /

```bash
mkdir /sky && cd /sky && mkdir -m 775 dados && mkdir -m 777 executaveis && mkdir logs skyremotebackup livros_digitalizados scripts backup executaveis/install/ && mkdir /sky/backup/diario /sky/backup/incremental /sky/backup/completo
```

Instalar samba
```bash
yum install samba -y
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
[global] 
workgroup = <domínio ou grupo do windows> 
server string = <descrição do servidor> 
netbios name = <nome do servidor linux> 
security = user
map to guest = bad user 
dns proxy = no
```
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
public = yes
veto files = /*.bat/*.mp3/*.mp4/*.doc/*.docx
delete veto files = no
vfs objects = recycle
recycle:keeptree = true
recycle:repository = /sky/lixeira
```
```bash
[backup]

comment = Backups Sky
writeable = yes
browseable = yes
path = /sky/backup/
create mask = 0777
directory mask = 0777
guest ok = yes
read only = yes
public = yes
vfs objects = recycle
recycle:keeptree = true
recycle:repository = /sky/lixeira
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

Em seguida, é necessário ativar e reiniciar os serviços do samba:
```bash
systemctl enable smb.service && systemctl enable nmb.service && systemctl restart smb.service && systemctl restart nmb.service
```

RELOAD SAMBA (Relê as configurações do smb.conf sem para o serviço do samba)
```bash
systemctl reload smb
```

Após ativar e reiniciar os serviços, deve ser permitido o serviço do samba no firewall do CentOS. Use os seguintes comandos:
```bash
firewall-cmd --permanent --zone=public --add-service=samba && firewall-cmd --reload
```

Permitir também selinux na configuração do samba com o comando:
```bash
chcon -t samba_share_t /sky/executaveis/ -R && chcon -t samba_share_t /sky/backup/ -R
```

## Instalar e configurar o HQBIRD

Instalar as dependencias para instalação do HQbird com o comando abaixo
```bash
yum -y install libncurses.so.5 libtommath java-1.8.0-openjdk-headless.x86_64 xinetd
```

Entrar no diretório de download HQbird comando abaixo
```bash
mkdir /sky/executaveis/install/HQbird && cd /sky/executaveis/install/HQbird
```
```bash
wget https://ib-aid.com/download/hqbird/install_fb25_hqbird2022.sh
```

Descompactar, dar a permissao completa ao arquivo instalador e instalar o HQbird
```bash
unzip /sky/executaveis/install/HQbird/hqbirdlinux.zip
```
```bash
rm /sky/executaveis/install/HQbird/hqbirdlinux.zip
```
```bash
chmod +x /sky/executaveis/install/HQbird/install_fb25_hqbird2022.sh
```
```bash
./install_fb25_hqbird2022.sh
```

Efetuar troca do método do firebird para superclassic
```bash
/opt/firebird/bin/changeMultiConnectMode.sh
```
- thread: **super classic** #recomendado
-- super classic aparece um processo unico fb_smp_server
- process: **classic**
-- classic usa multi processo fb_inet (um processo para cada conexão)

Criar os atalhos gbak, gstat e gfix
```bash
ln -s /opt/firebird/bin/gbak /bin/gbak && ln -s /opt/firebird/bin/gstat /bin/gstat && ln -s /opt/firebird/bin/gfix /bin/gfix && ln -s /opt/firebird/bin/nbackup /bin/nbackup && ln -s /opt/firebird/bin/gsec /bin/gsec
```

Se necessário redefinir a senha do firebird no servidor
```bash
/opt/firebird/bin/gsec
```
```bash
modify sysdba -pw #8_CHAR
```
```bash
quit
```

Dê permissão para a pasta dados (onde ficarão os bancos)
```bash
chown -R firebird.firebird /sky/dados && chmod 664 /sky/dados/*?db
```

Verificar configurações do conf do firebird
```bash
vi /opt/firebird/firebird.conf
```
DefaultDbCachePages = 384 #entre 384 a 1024

```bash
RemoteAuxPort = 3051
```

Parar e desativar serviços que vem com hq2022 e não usamos
```bash
systemctl stop fbcclauncher.service fbcctracehorse.service fbccamv.service

systemctl disable fbcclauncher.service fbcctracehorse.service fbccamv.service
```

### Liberar FBDataguard no Firewall
Para liberar o acesso do utilitário do FBDataguard, é necessário liberar a porta 8082. Seguir os seguintes passos:

Liberar FBDataguard e Firebird no firewall
```bash
firewall-cmd --permanent --zone=public --add-port=8082/tcp && firewall-cmd --permanent --zone=public --add-port=3051/tcp && firewall-cmd --permanent --zone=public --add-port=3050/tcp
```

Caso tenha DMZ
```bash
firewall-cmd --permanent --zone=dmz --add-port=3050/tcp && firewall-cmd --permanent --zone=dmz --add-port=3051/tcp && firewall-cmd --permanent --zone=dmz --add-port=8082/tcp
```

Recarregar o firewall para aplicar as alterações:
```bash
firewall-cmd --reload
```

### IRQBalance - Otimizando uso dos núcleos do CPU pelo Firebird
```bash
yum install -y irqbalance && chkconfig irqbalance on && service irqbalance start
```
[Mais informações da ferramenta](https://linux.die.net/man/1/irqbalance)

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

```bash
```

```bash
```
