reg delete HKEY_CURRENT_USER\SOFTWARE\SkyInformatica\Financeiro\BancoDados\Database /v "TemporaryDir" /f
reg delete HKEY_CURRENT_USER\Software\Notar\BancoDadosD7\Database /v "TemporaryDir" /f
reg delete HKEY_CURRENT_USER\Software\SkyInformatica\Civil\BancoDados\Database /v "TemporaryDir" /f
reg delete HKEY_CURRENT_USER\SOFTWARE\SkyInformatica\TED\BancoDados\Database /v "TemporaryDir" /f
reg delete HKEY_CURRENT_USER\SOFTWARE\Imoveis\BancoDados\Database /v "TemporaryDir" /f
reg delete HKEY_CURRENT_USER\SOFTWARE\SkyInformatica\Protesto\BancoDados\Database\Database /v "TemporaryDir" /f
reg delete HKEY_CURRENT_USER\SOFTWARE\SkyInformatica\SkyLivros\BancoDados\Database /v "TemporaryDir" /f
reg delete HKEY_CURRENT_USER\SOFTWARE\SkyInformatica\SkySigner\BancoDados\Database /v "TemporaryDir" /f
reg delete HKEY_CURRENT_USER\Software\SkyInformatica\SeloDigital\BancoDados\Database /v "TemporaryDir" /f
reg delete HKEY_CURRENT_USER\Software\SkyInformatica\SkyMonitor\BancoDados\Database /v "TemporaryDir" /f
reg delete HKEY_CURRENT_USER\Software\SkyBiometrics\BancoDadosD10\Database /v "TemporaryDir" /f

reg export HKEY_CURRENT_USER\SOFTWARE\SkyInformatica\Financeiro\BancoDados\Database c:\financeiro.reg
reg export HKEY_CURRENT_USER\Software\Notar\BancoDadosD7\Database c:\notar.reg
reg export HKEY_CURRENT_USER\Software\SkyInformatica\Civil\BancoDados\Database c:\civil.reg
reg export HKEY_CURRENT_USER\SOFTWARE\SkyInformatica\TED\BancoDados\Database c:\ted.reg
reg export HKEY_CURRENT_USER\SOFTWARE\Imoveis\BancoDados\Database c:\imoveis.reg
reg export HKEY_CURRENT_USER\SOFTWARE\SkyInformatica\Protesto\BancoDados\Database\Database c:\protesto.reg
reg export HKEY_CURRENT_USER\SOFTWARE\SkyInformatica\SkyLivros\BancoDados\Database c:\skylivros.reg
reg export HKEY_CURRENT_USER\SOFTWARE\SkyInformatica\SkySigner\BancoDados\Database c:\skysigner.reg
reg export HKEY_CURRENT_USER\Software\SkyInformatica\SeloDigital\BancoDados\Database c:\selo.reg
reg export HKEY_CURRENT_USER\Software\SkyInformatica\SkyMonitor\BancoDados\Database c:\skywebmonitor.reg
reg export HKEY_CURRENT_USER\Software\SkyBiometrics\BancoDadosD10\Database c:\skybiometrics.reg

cd\
copy financeiro.reg+imoveis.reg+protesto.reg+skylivros.reg+skysigner.reg+ted.reg+notar.reg+civil.reg+selo.reg+skywebmonitor.reg+skybiometrics.reg sistemas.reg

exit



