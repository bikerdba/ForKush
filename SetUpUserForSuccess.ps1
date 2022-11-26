[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
function WriteLog {
    Param ([string]$LogString)
    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $LogMessage = "$Stamp : $LogString"
    Write-Host $LogMessage -ForegroundColor DarkGray
}
WriteLog "reading configs"
$config = Get-Content .\ScriptConfig.json | ConvertFrom-Json
WriteLog "will install / do the following"
WriteLog "------------------------------------------"
WriteLog "latest 64 bit version of git"
WriteLog "PythonVersion = $($config.PythonVersion)"
WriteLog "PythonInstallArgs = $($config.PythonInstallArgs)"
WriteLog "TestPlanOSSPath = $($config.TestPlanOSSPath)"
WriteLog "TestPlanPath = $($config.TestPlanPath)"
WriteLog "install pip"
WriteLog "upgrade pip to latest version"
WriteLog "install virtualenv"
WriteLog "create virtualenv (venv) at $($config.TestPlanPath) "
WriteLog "activate testplan-oss"
WriteLog "create directory testplan at the same path where testplan-oss is"
WriteLog "clone morganstanly testplan repo"
WriteLog "Install dependecies and setup"
WriteLog "------------------------------------------"
<#
.\Scripts\activate

git clone https://github.com/morganstanley/testplan.git
cd testplan
#>
WriteLog "installing git ..."
# get latest download url for git-for-windows 64-bit exe
$git_url = "https://api.github.com/repos/git-for-windows/git/releases/latest"
$asset = Invoke-RestMethod -Method Get -Uri $git_url | ForEach-Object assets | Where-Object name -like "*64-bit.exe"
# download installer
$installer = "$env:temp\$($asset.name)"
if (!(Test-Path $installer)) {
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $installer
}
# run installer
$git_install_inf = "gitInstall.inf"
$install_args = "/SP- /SILENT /SUPPRESSMSGBOXES /NOCANCEL /NORESTART /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /LOADINF=""$git_install_inf"""
Start-Process -FilePath $installer -ArgumentList $install_args -Wait
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

WriteLog "installing python ..."
# https://docs.python.org/3.6/using/windows.html#installing-without-ui
# url for all python versions https://www.python.org/ftp/python

$python_ver = $($config.PythonVersion)
$python_url = "https://www.python.org/ftp/python/$python_ver/python-$($python_ver).exe"
# download installer
$installer = "$env:temp\python-$($python_ver).exe"
if (!(Test-Path $installer)) {
    Invoke-WebRequest -Uri $python_url -OutFile $installer
}
# run installer
$install_args = $($config.PythonInstallArgs)
Start-Process -FilePath $installer -ArgumentList $install_args -Wait
$pyVersion = (Get-Command python).Version
$exeFilePath = (Get-Command python).Source
WriteLog "sucessfully installed python version $pyVersion at $exeFilePath"
WriteLog "setting up and upgrading pip ...."
Start-Process -FilePath $exeFilePath -ArgumentList "get-pip.py" -Wait
Invoke-Command -ScriptBlock { python -m pip install --upgrade pip } -Verbose
WriteLog "installing vistualenv ...."
Invoke-Command -ScriptBlock { python -m pip install --user virtualenv } -Verbose
WriteLog "setting up TestPlanOSSPath = $($config.TestPlanOSSPath) ... "
Invoke-Command -ScriptBlock { python virtualenv -p $($config.TestPlanOSSPath) }
WriteLog "setting up TestPlanPath .... "
if (!(Test-Path $($config.TestPlanPath))) {
    New-Item $($config.TestPlanPath) -ItemType Directory
}
WriteLog "cloning git repo from https://github.com/morganstanley/testplan.git"
Invoke-Command -ScriptBlock {Set-Location $($config.TestPlanPath)}
Invoke-Command -ScriptBlock {git clone https://github.com/morganstanley/testplan.git}

