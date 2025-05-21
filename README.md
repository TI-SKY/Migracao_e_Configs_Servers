# Checklist para verificação de requisitos (Servidor)
1. Servidor dedicado exclusivamente ao processamento e armazenamento de dados (não utilizado como estação de trabalho).
2. Presença de nobreak: 
3. Armazenamento redundante configurado: RAID 1 ou RAID 10 (RAID 5 não recomendado).
4. Sistema operacional de servidor com IP fixo instalado e atualizado (Windows Server ou Linux recomendado).
5. Utilização de discos SSD ou SAS Enterprise (não utilizar discos de desktop).
6. Configuração de memória RAM e processador: 
- Até 10 estações: Processador 4 Cores, 8GB RAM.
- De 11 a 30 estações: Processador 6-8 Cores, 16GB RAM.
- Mais de 30 estações: Processador 16-48 Cores, 32-128GB RAM.
7. Presença de virtualização: 
8. Monitoramento ativo de hardware e serviços para garantia de funcionamento:

# 

O arquivo [Migracao_UBUNTU_ou_DEBIAN.md](https://github.com/TI-SKY/Linux-Migracao_e_Configs/blob/main/Migracao_UBUNTU_ou_DEBIAN.md) contém o roteiro para configurar UBUNTU DO 20.04 AO 24.04, também pode ser utilizado com DEBIAN 10 ou 11.

> Ubuntu 22.04 liberado para uso a partir da versão do fb 2.5.9.27174, no HqBird 2024.

O arquivo [Migracao_CENTOS_ou_REDHAT.md](https://github.com/TI-SKY/Linux-Migracao_e_Configs/blob/main/Migracao_CENTOS_ou_REDHAT.md) contém o roteiro para configurar um Centos 7, também pode ser utilizado em outras distros Red Hat. DEPRECADO.

> Não recomendamos o uso de centos devido o encerramento do suporte gratuito.

O arquivo [script_config_sistemas.bat](https://github.com/TI-SKY/Linux-Migracao_e_Configs/blob/main/script_config_sistemas.bat) é um **script** que pode ser baixado em uma estação que já teve os sistemas configurados para gerar o .reg para configurar novas estações.

O arquivo [Configurar_Acesso_Samba_Por_Usuario.md](https://github.com/TI-SKY/Linux-Migracao_e_Configs/blob/main/Configurar_Acesso_Samba_Por_Usuario.md) contém exemplo para configurar uma pasta no samba com usuário e senha.
