Import-Module WebAdministration 
New-WebAppPool -name "NewWebSiteAppPool"  -force

$appPool = Get-Item -name "NewWebSiteAppPool" 
$appPool.processModel.identityType = "NetworkService"
$appPool.enable32BitAppOnWin64 = 1
$appPool | Set-Item
md "c:\Web Sites\NewWebSite"

# All on one line
$site = $site = new-WebSite -name "NewWebSite" -PhysicalPath "c:\Web Sites\NewWebSite" -HostHeader "home2.west-wind.com" -ApplicationPool "NewWebSiteAppPool" -force
