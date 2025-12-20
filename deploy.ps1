$ModDeployPath = "" 

# Base Mod
Copy-Item -v "Scripts\*.pex" "$ModDeployPath\Scripts\" -Force
Copy-Item -v "Source\Scripts\*.psc" "$ModDeployPath\Source\Scripts\" -Force
