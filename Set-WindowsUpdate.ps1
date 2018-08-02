[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')] 
Param(
	[Parameter(Mandatory=$false,ValueFromPipeLine=$true,ValueFromPipeLineByPropertyName=$true,Position=0)]
	[ValidateNotNullorEmpty()]
	[String[]]$Computer = "$env:COMPUTERNAME",

	[Parameter(Mandatory=$false,Position=1)]
	[ValidateSet("NoCheck","CheckOnly","DownloadOnly","Install")]
	[String[]]$Options = "NoCheck"
	)

switch ($Options) { 
	"NoCheck"		{ $AuOptions = 1; $Op = "Never check for updates" }
	"CheckOnly"		{ $AuOptions = 2; $Op = "Check for updates but let me choose wether to download and install them" }
	"DownloadOnly"	{ $AuOptions = 3; $Op = "Download updates but let me choose whether to install them" }
	"Install"		{ $AuOptions = 4; $Op = "Install updates automatically" }
}
$Key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" 

try {
	Invoke-Command -ScriptBlock {
		Set-ItemProperty -Path $Key -Name "AUOptions" -Value $AuOptions -Force -Confirm:$false
		Set-ItemProperty -Path $Key -Name "CachedAUOptions" -Value $AuOptions -Force -Confirm:$false
	}
} catch {
	Write-Warning "Failed to set Windows Automatic Updates on computer '$Computer'"
}

try { 
    Install-WindowsFeature DNS -IncludeManagementTools 
} catch {
    Write-Warning "Failed to install WindowsFeature DNS"
} 
