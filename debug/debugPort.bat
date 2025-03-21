@echo off
setlocal

:: Définit le fichier de sortie dans le même dossier que le script
set "output_file=%~dp0resultat.txt"

:: Vide le fichier avant d'écrire dedans
echo Liste des processus utilisant le port 5432 > "%output_file%"
echo. >> "%output_file%"

:: Parcourt les PIDs des connexions sur le port 5432 et enregistre les résultats
for /f "tokens=5" %%a in ('netstat -ano ^| find "5432"') do (
    echo PID: %%a >> "%output_file%"
    tasklist /fi "pid eq %%a" >> "%output_file%"
    echo. >> "%output_file%"
)

echo Résultats enregistrés dans "%output_file%"
endlocal
