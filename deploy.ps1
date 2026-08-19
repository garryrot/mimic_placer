param(
	[string]$ModDeployPath = ""
)

$ProjectSourcePaths = @(
	".\deploy\mimic\00_Default",
	".\deploy\mimic\02_Option_PatchedScripts",
	".\deploy\trap\00_Default",
	".\deploy\trap\03_Option_PatchedScripts"
)

foreach ($ProjectSourcePath in $ProjectSourcePaths) {
	if (-not (Test-Path $ProjectSourcePath)) {
		throw "Deploy source path does not exist: $ProjectSourcePath"
	}
}

New-Item -ItemType Directory -Path "$ModDeployPath\Scripts" -Force | Out-Null
New-Item -ItemType Directory -Path "$ModDeployPath\SKSE" -Force | Out-Null

Remove-Item -Path "$ModDeployPath\Scripts\*.pex" -Force -ErrorAction SilentlyContinue

foreach ($ProjectSourcePath in $ProjectSourcePaths) {
	if (Test-Path "$ProjectSourcePath\Scripts") {
		Copy-Item -Path "$ProjectSourcePath\Scripts\*" -Destination "$ModDeployPath\Scripts\" -Recurse -Force
	}
	if (Test-Path "$ProjectSourcePath\SKSE") {
		Copy-Item -Path "$ProjectSourcePath\SKSE\*" -Destination "$ModDeployPath\SKSE\" -Recurse -Force
	}
}

Remove-Item -Path "$ModDeployPath\skyrimse.ppj" -Force -ErrorAction SilentlyContinue
