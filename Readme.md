New Branch of Jenkins

<#
<powershell>
mkdir c:\jenkins

& NetSh Advfirewall set allprofiles state off 
$curlurl = 'https://dl.uxnr.de/build/curl/curl_winssl_msys2_mingw32_stc/curl-7.53.1/curl-7.53.1.zip'
(New-Object -TypeName System.Net.WebClient).DownloadFile($curlurl,"C:\curl.zip")
#Extracting Curl
Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::ExtractToDirectory("C:\curl.zip","C:\curl\")
#Downloading & Installing JRE
$jreurl = 'http://javadl.oracle.com/webapps/download/AutoDL?BundleId=225353_090f390dda5b47b9b721c7dfaa008135'
$env:Path = $env:Path + ';' + "C:\curl\src"
$curlargs = "--location --verbose --url ""$jreurl"" --output ""C:\jre2.exe"""
& C:\Windows\System32\cmd.exe /c "curl $curlargs"

& C:\jre2.exe /s
while(get-process | ?{$_.Name -match 'jre'}){
	"Running jre"
	start-sleep -seconds 10
}
(get-childitem -path 'C:\Program Files (x86)' -Recurse -Filter 'java.exe').Directory.FullName
$java_home = Split-path -path (get-childitem -path 'C:\Program Files (x86)' -Recurse -Filter 'java.exe').Directory.FullName -Parent

setx /m java_home "$java_home"
setx /m path "$env:path;$java_home\bin"
$env:path += ';' + "$java_home\bin"

Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private
Enable-PSRemoting -SkipNetworkProfileCheck -Force
winrm quickconfig -quiet
winrm e winrm/config/listener
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'

winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/client '@{AllowUnencrypted="true"}'
winrm set winrm/config/client '@{TrustedHosts="*"}'
winrm set winrm/config/service '@{EnableCompatibilityHttpListener="true"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="1024"}'

Write-host "Config Completed"

#Creating Local UserAccount
$Computername = $env:COMPUTERNAME
$ADSIComp = [adsi]"WinNT://$Computername"

$Username = 'jk_user'
$NewUser = $ADSIComp.Create('User',$Username)

#Create password 

$Password = ConvertTo-SecureString -String 'P@ssw0rd123' -AsPlainText -Force

$BSTR = [system.runtime.interopservices.marshal]::SecureStringToBSTR($Password)

$_password = [system.runtime.interopservices.marshal]::PtrToStringAuto($BSTR)

#Set password on account 
$NewUser.SetPassword(($_password))
$NewUser.SetInfo()

#Adding created local user into local Administrators group
$Group = 'Administrators'
$de = [ADSI]"WinNT://$env:computername/$Group,group" 
$de.psbase.Invoke("Add",([ADSI]"WinNT://$env:computername/$username").path)

#Cleanup 
[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR) 
Remove-Variable Password,BSTR,_password

</powershell>
#>