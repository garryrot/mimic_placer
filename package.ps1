param(
	[ValidateSet("mimic", "trap", "all")]
	[string]$Project = "all"
)

$PackageDir = "package"
$TempRoot = "temp"
$SevenZipExe = "C:\Program Files\7-Zip\7z.exe"

$OmnomVersion = "1.3.0"
$TrapVersion = "1.2.1"

function New-ModArchive {
	param(
		[string]$DeploySubPath,
		[string]$ProjectName,
		[string]$ArchiveName,
		[string]$Version
	)

	$stageDir = Join-Path $TempRoot $ProjectName
	if (Test-Path $stageDir) {
		Remove-Item -Path $stageDir -Recurse -Force
	}

	New-Item -ItemType Directory -Path $stageDir -Force | Out-Null
	Copy-Item -Path ".\deploy\$DeploySubPath\*" -Destination $stageDir -Recurse -Force

	Get-ChildItem -Path $stageDir -Filter "skyrimse.ppj" -Recurse | Remove-Item -Force

	$archivePath = Join-Path $PackageDir "$ArchiveName v$Version.7z"
	if (Test-Path $archivePath) {
		Remove-Item -Path $archivePath -Force
	}

	$archivePath = [System.IO.Path]::GetFullPath($archivePath)

	Push-Location $stageDir
	try {
		& $SevenZipExe a $archivePath ".\*"
	}
	finally {
		Pop-Location
	}
}

New-Item -ItemType Directory -Path $PackageDir -Force | Out-Null

switch ($Project) {
	"mimic" { New-ModArchive -DeploySubPath "mimic" -ProjectName "mimic" -ArchiveName "OMNOM" -Version $OmnomVersion }
	"trap"  { New-ModArchive -DeploySubPath "trap" -ProjectName "trap" -ArchiveName "Extra Evil Traps" -Version $TrapVersion }
	"all" {
		New-ModArchive -DeploySubPath "mimic" -ProjectName "mimic" -ArchiveName "OMNOM" -Version $OmnomVersion
		New-ModArchive -DeploySubPath "trap" -ProjectName "trap" -ArchiveName "Extra Evil Traps" -Version $TrapVersion 
	}
}
