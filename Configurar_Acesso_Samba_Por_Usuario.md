# SAMBA: Configurar acesso através de usuário com senha

Primeiro passo de segurança para compartilhar o backup em rede, é colocá-lo em somente leitura, assim, asseguramos que ninguém, que tenha simples acesso a rede, possa apagar os arquivos, ou que eles sejam alvo de criptografia. Isso, no entanto, não impede que qualquer um com acesso a rede possa copiar o backup.
Podemos então criar um usuário no servidor para ser utilizado no samba, configurar uma senha e forçar no compartilhamento da pasta de backup, esse usuário. Podemos também limitar o acesso a pasta em máquinas específicas.

## CONFIGURAÇÃO POR SENHA

Abaixo um exemplo para criar o usuário ‘skybackup’.
```bash
useradd skybackup -s /bin/false -c "usuario para copia de backup no samba" -M
```

- **-c** é pra criar um comentário no /etc/passwd
- **-M** é pra não criar o diretório no /home pro usuário
- **-s** é pra apontar o shell padrão do usuário, como não é um usuário que pretendemos usar para login no sistema: /bin/false ou /usr/sbin/nologin

Após criado o usuário no sistema, precisamos adicioná-lo ao samba, e criar uma senha para o samba.
Abaixo um exemplo em que o usuário ‘skybackup’ é adicionado ao samba, ao rodar o comando, será pedido a informação de senha, NÃO USE senhas simples como 1234, qwe123. Diversifique entre caracteres especiais, letras maiúsculas e minúsculas e números. Use informações da serventia para a criação de senha e registre nos locais adequados. Informe o responsável, que pode ser o oficial, funcionário da serventia ou o técnico.
```bash
smbpasswd -a skybackup
```
- **-a** para adicionar


Precisamos então, no .conf do samba, forçar o usuário criado no compartilhamento desejado. Em adição, podemos também usar a opção ‘browseable = no’ que não deixará a pasta visível, sendo necessário digitar o caminho completo do endereço para acessar a pasta.
```bash
vim /etc/samba/smb.conf
```

```bash
[backup]
comment = diretorio arquivos de backups de bancos de dados de sistemas sky
writeable = no
browseable = yes
path = /sky/backup/
guest ok = no
valid users = skybackup
read only = yes
```


```bash
systemctl reload smbd nmbd
```

PRONTO!
## MAS LEMBRE-SE: 
- O usuário criado precisará ter permissão na pasta compartilhada;
- O windows só permite um usuario pra conexão por servidor samba;
- Você pode salvar as credenciais no gerenciador de credenciais do windows.
