source "vmware-vmx" "win10-sysprep" {
  source_path = "${var.source_path}"
  vm_name     = "${var.os_name}-sysprep"

  # WinRM connection information
  communicator     = "winrm"
  winrm_password   = "${var.winrm_password}"
  winrm_timeout    = "${var.winrm_timeout}"
  winrm_username   = "${var.winrm_username}"
  headless         = "${var.headless}"
  shutdown_command = "C:/windows/packer/Shutdown-Packer.bat" # Disable winrm for sysprep to work
  shutdown_timeout = "1h"
  # Allow vnc for debugging
  # NOTE Used for remote deployments
  vmx_data = {
    "RemoteDisplay.vnc.enabled" = "false"
    "RemoteDisplay.vnc.port"    = "5900"
  }
  vnc_port_max = 5980
  vnc_port_min = 5900
}

build {
  sources = ["sources.vmware-vmx.win10-sysprep"]

  # Setup shutdown command
  provisioner "file" {
    source      = "Scripts/Shutdown-Packer.bat"
    destination = "C:/windows/packer/Shutdown-Packer.bat"
  }

  # Allow winRM through firewall on boot
  provisioner "file" {
    source      = "Scripts/Setup-Complete.bat"
    destination = "C:/Windows/setup/Scripts/Setup-Complete.bat"
  }

  # Defrag and Sysprep
  provisioner "powershell" {
    inline = [
      "Write-Host 'INFO: Optimizing Volume...'",
      "Optimize-Volume -DriveLetter c -Verbose"
    #   "Write-Host 'INFO: Generalizing image...'",
    #   "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /quiet /generalize /oobe /quit",
    #   "while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }"
    ]
  }
}

variables {
  source_path    = ""
  os_name        = ""
  headless       = "true"
  winrm_password = "1qaz2wsx!QAZ@WSX"
  winrm_timeout  = "3h"
  winrm_username = "sap_admin"
}