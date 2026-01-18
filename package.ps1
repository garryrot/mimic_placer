$Version = "0.1.0"
$ProjectName = "OMNOM"

mkdir package

Remove-Item -v "temp" -Recurse
Copy-Item -v .\deploy "temp" -Recurse
Remove-Item "temp\deploy\00_Default\skyrimse.ppj"

Remove-Item "package\$ProjectName v$Version.7z"
C:\"Program Files"\7-Zip\7z.exe a "package\$ProjectName v$Version.7z" .\temp\*