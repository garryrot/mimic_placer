param(
	[ValidateSet("mimic", "trap", "all")]
	[string]$Project = "all",

	[string]$Version = "0.1.0"
)

$PackageDir = "package"
$TempRoot = "temp"
$SevenZipExe = "C:\Program Files\7-Zip\7z.exe"

function New-ModArchive {
	param(
		[string]$DeploySubPath,
		[string]$ProjectName,
		[string]$ArchiveName
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
	"mimic" { New-ModArchive -DeploySubPath "mimic" -ProjectName "mimic" -ArchiveName "OMNOM" }
	"trap"  { New-ModArchive -DeploySubPath "trap" -ProjectName "trap" -ArchiveName "Trap Defeat" }
	"all" {
		New-ModArchive -DeploySubPath "mimic" -ProjectName "mimic" -ArchiveName "OMNOM"
		New-ModArchive -DeploySubPath "trap" -ProjectName "trap" -ArchiveName "Trap Defeat"
	}
}