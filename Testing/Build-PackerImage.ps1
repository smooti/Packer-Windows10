param(
	[switch]$SkipAtlas,
	[Parameter(Mandatory = $true)]
	[ValidateSet('Win10', 'Win2016StdCore')]
	$OSName
)

switch ($OSName) {
	'Win10' {
		$osData = @{
			os_name       = 'win10'
			guest_os_type = 'windows9-64'
			full_os_name  = 'Windows10'
			iso_checksum  = 'sha256:2FD924BF87B94D2C4E9F94D39A57721AF9D986503F63D825E98CEE1F06C34F68'
			iso_url       = './Distros/Win10_21H2_x64_English.ISO'
		}
	}

	'Win2016StdCore' {
		$osData = @{
			os_name       = 'win2016stdcore'
			guest_os_type = 'Windows2012_64'
			full_os_name  = 'Windows2016StdCore'
			iso_checksum  = '3bb1c60417e9aeb3f4ce0eb02189c0c84a1c6691'
			iso_url       = 'http://care.dlservice.microsoft.com/dl/download/1/6/F/16FA20E6-4662-482A-920B-1A45CF5AAE3C/14393.0.160715-1616.RS1_RELEASE_SERVER_EVAL_X64FRE_EN-US.ISO'
		}
	}
}

$s1configFile = 'Testing/s1-setup.pkr.hcl'
$s2configFile = 'Testing/s2-update.pkr.hcl'
$s3configFile = 'Testing/s3-provision.pkr.hcl'
$s4configFile = 'Testing/s4-sysprep.pkr.hcl'

$source2Path = "output-$($osData.os_name)-base\$($osData.os_name)-base.vmx"
$source3Path = "output-$($osData.os_name)-updates\$($osData.os_name)-updates.vmx"
$source4Path = "output-$($osData.os_name)-updates\$($osData.os_name)-provisioned.vmx"

$s1args = @{
	FilePath     = 'packer.exe'
	ArgumentList = "build -var `"os_name=$($osData.os_name)`" -var `"iso_checksum=$($osData.iso_checksum)`" -var `"iso_url=$($osData.iso_url)`" -var `"guest_os_type=$($osData.guest_os_type)`" $($s1configFile)"
	wait         = $true
	NoNewWindow  = $true
}

$s2args = @{
	FilePath     = 'packer.exe'
	ArgumentList = "build -var `"os_name=$($osData.os_name)`" -var `"source_path=$($source2Path)`" $($s2configFile)"
	wait         = $true
	NoNewWindow  = $true
}

$s3args = @{
	FilePath     = 'packer.exe'
	ArgumentList = "build -var `"os_name=$($osData.os_name)`" -var `"source_path=$($source3Path)`" $($s3configFile)"
	wait         = $true
	NoNewWindow  = $true
}

$s4args = @{
	FilePath     = 'packer.exe'
	ArgumentList = "build -var `"os_name=$($osData.os_name)`" -var `"source_path=$($source4Path)`" $($s4configFile)"
	wait         = $true
	NoNewWindow  = $true
}

# # Unpack Image
# Start-Process @s1args

# Installs Windows Updates
Start-Process @s2args

# Provision
Start-Process @s3args

# Sysprep
Start-Process @s4args