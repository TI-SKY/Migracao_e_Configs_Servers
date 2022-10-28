## Instalar e configurar o HQBIRD

Instalar as dependencias para instalação do HQbird com o comando abaixo
```bash
apt install -y openjdk-8-jre-headless libtommath1 libncurses5
```

Na instalação da versão 3, o hqbird busca pela libtommath0, podemos criar um link usando a libtommath1.
```bash
ln -s /usr/lib/x86_64-linux-gnu/libtommath.so.1.2.0 /usr/lib/x86_64-linux-gnu/libtommath.so.0
```

Entrar no diretório de download HQbird comando abaixo
```bash
mkdir /sky/executaveis/install/HQbird && cd /sky/executaveis/install/HQbird
```
```bash
wget https://ib-aid.com/download/hqbird/install_fb30_hqbird2022.sh
```
```bash
chmod +x /sky/executaveis/install/HQbird/install_fb30_hqbird2022.sh
```
```bash
./install_fb30_hqbird2022.sh
```

Por padrão é instalado o SuperServer.
 
- OBS¹: lembre que o cache do SupersServer é compartilhado e não depende do número de conexões
- OBS²: o executável é /opt/firebird/bin/firebird e o serviço é **firebird-superserver.service**

Verificar configurações do conf do firebird
```bash
vi /opt/firebird/firebird.conf
```
DefaultDbCachePages = 50k #entre 3k até ...
AuthServer = Srp, Legacy_Auth
UserManager = Srp, Legacy_UserManager
WireCrypt = Disabled

[Para calcular DefaultDbCachePages, TempCacheLimit, etc...](cc.ib-aid.com/)

```bash
RemoteAuxPort = 3051
```

Criar os atalhos gbak, gstat e gfix
```bash
ln -s /opt/firebird/bin/gbak /bin/gbak && ln -s /opt/firebird/bin/gstat /bin/gstat && ln -s /opt/firebird/bin/gfix /bin/gfix && ln -s /opt/firebird/bin/nbackup /bin/nbackup && ln -s /opt/firebird/bin/gsec /bin/gsec
```

Use o gsec para alterar a senha do sysdba no modo legacy
```bash
/opt/firebird/bin/gsec
```
```bash
modify sysdba -pw 'senha_de_8char'
```
```bash
quit
```
Altere também a senha do sysdba do método de autenticação mais recente (nosso sistema ainda usa o legacy)
Embora o novo método de autenticação aceite senhas maiores e mais complexas, o modo legacy continua com as mesmas limitações.
```bash
/opt/firebird/bin/isql
```
```bash
connect localhost:employee user sysdba password masterkey;
```
```bash
alter user sysdba set password 'senha_de_8char';
```

Dê permissão para a pasta dados (onde ficarão os bancos)
```bash
chown -R firebird.firebird /sky/dados && chmod 664 /sky/dados/*?db
```



Parar e desativar serviços que vem com hq2022 e não usamos
```bash
systemctl stop fbcclauncher.service fbcctracehorse.service fbccamv.service

systemctl disable fbcclauncher.service fbcctracehorse.service fbccamv.service
```

