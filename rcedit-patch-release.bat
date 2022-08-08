::https://github.com/electron/rcedit
@echo off
set file-version=0.1.0.0
set product-version=0.1.0.0
echo %file-version%
echo %product-version%
rcedit-x64.exe "bin\Main.exe" --set-icon "assets\icon_chibi_kiana_kaslana.ico" --set-file-version "%file-version%" --set-product-version "0.1.0.0" --set-product-version "%product-version%" --set-version-string "LegalCopyright" "Devyatyi9" --set-version-string "FileDescription" "Honkai Impact video usm patcher" --set-version-string "ProductName" "Honkai Impact usm patcher"
::raname Main.exe
::replace
::pause