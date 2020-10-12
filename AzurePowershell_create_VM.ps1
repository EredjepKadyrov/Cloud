#######Connect with APowershell to Azure#######
Connect-AzAccount
#Import-Module Az.Resources
#Get-AzResourceGroup | Format-List

#######Create Resources Group#######
New-AzResourceGroup -Name TutorialResources -Location eastus

#######creadential for new VM#######
$cred = Get-Credential -Message "Enter a username and password for the virtual machine."

#######Create new VM1#######
$vmParams = @{
  ResourceGroupName = 'TutorialResources'
  Name = 'TutorialVM1'
  Location = 'eastus'
  ImageName = 'Win2016Datacenter'
  PublicIpAddressName = 'tutorialPublicIp'
  Credential = $cred
  OpenPorts = 3389
}
$newVM1 = New-AzVM @vmParams

#######Check VM name and user name #######
$newVM1.OSProfile | Select-Object ComputerName,AdminUserName

#######Check VM IP Address #######
$newVM1 | Get-AzNetworkInterface |
 Select-Object -ExpandProperty IpConfigurations |
    Select-Object Name,PrivateIpAddress

#######Check VM public IP Address for RDP #######
$publicIp = Get-AzPublicIpAddress -Name tutorialPublicIp -ResourceGroupName TutorialResources
$publicIp | Select-Object Name,IpAddress,@{label='FQDN';expression={$_.DnsSettings.Fqdn}}

#######With RDP connect to VM#######
mstsc.exe /v IP address

#######Create new VM2#######
$vm2Params = @{
  ResourceGroupName = 'TutorialResources'
  Name = 'TutorialVM2'
  ImageName = 'Win2016Datacenter'
  VirtualNetworkName = 'TutorialVM1'
  SubnetName = 'TutorialVM1'
  PublicIpAddressName = 'tutorialPublicIp2'
  Credential = $cred
  OpenPorts = 3389
}
$newVM2 = New-AzVM @vm2Params

$newVM2

#######With RDP connect to VM#######
mstsc.exe /v $newVM2.FullyQualifiedDomainName

#######Remove VM#######
$job = Remove-AzResourceGroup -Name TutorialResources -Force -AsJob
$job

#######Waiting remove VM#######
Wait-Job -Id $job.Id
