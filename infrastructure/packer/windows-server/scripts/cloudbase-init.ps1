# Cloudbase-Init Configuration Script
# This script configures Cloudbase-Init for cloud-init compatibility on Proxmox

$ErrorActionPreference = "Stop"

Write-Host "Configuring Cloudbase-Init for Proxmox..." -ForegroundColor Green

$cloudbaseConfPath = "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf"
$cloudbaseConf = "$cloudbaseConfPath\cloudbase-init.conf"
$cloudbaseUnattendConf = "$cloudbaseConfPath\cloudbase-init-unattend.conf"

# Main configuration
$mainConfig = @"
[DEFAULT]
username=Administrator
groups=Administrators
inject_user_password=true
config_drive_raw_hhd=true
config_drive_cdrom=true
config_drive_vfat=true
bsdtar_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\bin\bsdtar.exe
mtools_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\bin\
verbose=true
debug=true
logdir=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\log\
logfile=cloudbase-init.log
default_log_levels=comtypes=INFO,suds=INFO,iso8601=WARN,requests=WARN
logging_serial_port_settings=
mtu_use_dhcp_config=true
ntp_use_dhcp_config=true
local_scripts_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\LocalScripts\
metadata_services=cloudbaseinit.metadata.services.configdrive.ConfigDriveService,cloudbaseinit.metadata.services.httpservice.HttpService
plugins=cloudbaseinit.plugins.common.mtu.MTUPlugin,cloudbaseinit.plugins.common.sethostname.SetHostNamePlugin,cloudbaseinit.plugins.windows.createuser.CreateUserPlugin,cloudbaseinit.plugins.common.setuserpassword.SetUserPasswordPlugin,cloudbaseinit.plugins.windows.extendvolumes.ExtendVolumesPlugin,cloudbaseinit.plugins.common.userdata.UserDataPlugin,cloudbaseinit.plugins.common.localscripts.LocalScriptsPlugin,cloudbaseinit.plugins.windows.winrmlistener.ConfigWinRMListenerPlugin,cloudbaseinit.plugins.windows.winrmcertificateauth.ConfigWinRMCertificateAuthPlugin
allow_reboot=false
stop_service_on_exit=false
check_latest_version=false
"@

# Unattend configuration for sysprep
$unattendConfig = @"
[DEFAULT]
username=Administrator
groups=Administrators
inject_user_password=true
config_drive_raw_hhd=true
config_drive_cdrom=true
config_drive_vfat=true
bsdtar_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\bin\bsdtar.exe
mtools_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\bin\
verbose=true
debug=true
logdir=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\log\
logfile=cloudbase-init-unattend.log
default_log_levels=comtypes=INFO,suds=INFO,iso8601=WARN,requests=WARN
logging_serial_port_settings=
mtu_use_dhcp_config=true
ntp_use_dhcp_config=true
local_scripts_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\LocalScripts\
metadata_services=cloudbaseinit.metadata.services.configdrive.ConfigDriveService
plugins=cloudbaseinit.plugins.common.mtu.MTUPlugin,cloudbaseinit.plugins.common.sethostname.SetHostNamePlugin
allow_reboot=false
stop_service_on_exit=false
check_latest_version=false
"@

Write-Host "Writing Cloudbase-Init configuration..." -ForegroundColor Yellow
Set-Content -Path $cloudbaseConf -Value $mainConfig -Force
Set-Content -Path $cloudbaseUnattendConf -Value $unattendConfig -Force

# Configure Cloudbase-Init service
Write-Host "Configuring Cloudbase-Init service..." -ForegroundColor Yellow
Set-Service -Name "cloudbase-init" -StartupType Automatic

Write-Host "Cloudbase-Init configuration complete!" -ForegroundColor Green
