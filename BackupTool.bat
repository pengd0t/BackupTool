::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: NOTE: This script cannot be executed using "Run as Admin."  This causes it to try to backup a profile for the admin user.
::
:: This script does the following for the signed in user: 
:: Exports Outlook signatures
:: Exports Outlook PST files found in standard locations for XP, Win7, or Win10
:: Exports Chrome bookmarks
:: Exports mapped drives
:: Saves a list of printers and notes the default printer
:: Exports the PC Description
:: Records the hostname
:: Records all installed programs with version number.
:: Filters programs list to something shorter and more relevant.
:: The script only copies files, it does not delete or move anything, and only modifies the log files it creates.
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: To Do
:: Add logging by swapping from XCOPY to ROBOCOPY and using its logging function.
:: Show folder size before copying potentially large files.
:: Provide option to zip likely large folders before copying
:: Create more automatic version requiring less or no input, with automated zipping before sending once folders are above 500MB.
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
color 70

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:MENU

echo.
Set /P q=(B)acking up? Or (R)estoring from a remote server?
if /I "%q%" EQU "b" goto :BACKUP
if /I "%q%" EQU "r" goto :RESTORE
goto :Menu

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:BACKUP
CLS

:BackupDestinationChoice
echo.
Set /P q=Backup to (S)erver or (O)neDrive?
if /I "%q%" EQU "s" goto :BackupPathServer
if /I "%q%" EQU "o" goto :OneDriveBackupStart
goto :BackupDestinationChoice

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:BackupPathServer
:: Set destination server.
echo.
SET /p backup_path=Enter the name of the destination server including backslashes (e.g. \\FL999APPSVR).:
goto :ServerBackupStart

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Check for directory and create it if not found.  Avoids some potential errors.
if not exist "%backup_path%\apps\backup\" mkdir "%backup_path%\apps\backup\"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:ServerBackupStart

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:DescriptionBackup
:: This exports the PC Description from the registry.
echo.
echo Exporting Computer Description
REG Export HKLM\System\CurrentControlSet\services\LanmanServer\Parameters\srvcomment %backup_path%\apps\backup\%username%\PC_Description.reg /y >nul

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:BackupUserProfile
echo.
echo Backing Up User Profile.

xcopy "%userprofile%\Contacts" "%backup_path%\apps\backup\%USERNAME%\Contacts" /i /e /c /y
echo.
xcopy "%userprofile%\Favorites" "%backup_path%\apps\backup\%USERNAME%\Favorites" /i /e /c /y
echo.
xcopy "%userprofile%\Links" "%backup_path%\apps\backup\%USERNAME%\Links" /i /e /c /y
echo.
xcopy "%userprofile%\Music" "%backup_path%\apps\backup\%USERNAME%\Music" /i /e /c /y
echo.
xcopy "%userprofile%\Pictures" "%backup_path%\apps\backup\%USERNAME%\Pictures" /i /e /c /y
echo.
xcopy "%userprofile%\My Pictures" "%backup_path%\apps\backup\%USERNAME%\Pictures" /i /e /c /y
echo.
xcopy "%userprofile%\Videos" "%backup_path%\apps\backup\%USERNAME%\Videos" /i /e /c /y

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:DownloadsChoice
echo.
Set /P c=Copy Downloads folder [Y/N]?
if /I "%c%" EQU "Y" goto :DownloadsChoiceY
if /I "%c%" EQU "N" goto :DesktopChoice
goto :DownloadsChoice

:DownloadsChoiceY
xcopy %userprofile%\Downloads "%backup_path%\apps\backup\%USERNAME%\Downloads" /i /e /c /y

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:DesktopChoice
echo.
Set /P c=Copy Desktop folder [Y/N]?
if /I "%c%" EQU "Y" goto :DesktopChoiceY
if /I "%c%" EQU "N" goto :DocumentsChoice
goto :DesktopChoice

:DesktopChoiceY
xcopy "%userprofile%\Desktop" "%backup_path%\apps\backup\%USERNAME%\Desktop" /i /e /c /y

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:DocumentsChoice
echo.
Set /P c=Copy Documents folder [Y/N]?
if /I "%c%" EQU "Y" goto :DocumentsChoiceY
if /I "%c%" EQU "N" goto :BackupOutlookSignature
goto :DocumentsChoice

:DocumentsChoiceY
xcopy "%userprofile%\Documents" "%backup_path%\apps\backup\%USERNAME%\Documents" /i /e /c /y
xcopy "%userprofile%\My Documents" "%backup_path%\apps\backup\%USERNAME%\Documents" /i /e /c /y

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:BackupOutlookSignature
echo.
echo Backing up Outlook Signatures.
xcopy "c:\Users\%USERNAME%\AppData\Roaming\Microsoft\Signatures\*.*" "%backup_path%\apps\backup\%USERNAME%\Signatures\" /i /e /c /y

:BackupOutlookPST
:: This exports any Outlook PST file if found in default installation locations.
::XP Location
echo.
echo Searching for old Outlook PST files
xcopy "C:\Documents and Settings\%USERNAME%\Local Settings\Application Data\Microsoft\Outlook\*.pst" "%backup_path%\apps\backup\%USERNAME%\" /i /e /c /y
::Win7 Location
xcopy "C:\Users\%USERNAME%\AppData\Local\MicrosoftOutlook\*.pst" "%backup_path%\apps\backup\%USERNAME%\" /i /e /c /y
::Win10 Location
xcopy "C:\Users\%USERNAME%\AppData\Local\Microsoft\Outlook\*.pst" "%backup_path%\apps\backup\%USERNAME%\" /i /e /c /y

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:BackupChromeFavorites
echo.
echo Backing up Chrome Favorites.
		SET userbookmarkspath=%backup_path%\apps\backup\%USERNAME%\ChromeBookmarks\Local\Google\Chrome\User Data\Default
		SET bookmark_chrome=%USERPROFILE%\AppData\Local\Google\Chrome\User Data\Default
		SET userbookmarkspathcomputer=%userbookmarkspath%\%computername%
		IF NOT EXIST "%userbookmarkspath%" (
			mkdir "%userbookmarkspath%"
	)
	ROBOCOPY "%bookmark_chrome%" "%userbookmarkspath%" Bookmarks /COPY:DAT /DCOPY:T /R:5 /W:10 /NP >nul
	ROBOCOPY "%bookmark_chrome%" "%userbookmarkspath%" Bookmarks.bak /COPY:DAT /DCOPY:T /R:5 /W:10 /NP >nul
	
	:: This also backs up saved logins and passwords
	ROBOCOPY "%bookmark_chrome%" "%userbookmarkspath%" "Login Data" /COPY:DAT /DCOPY:T /R:5 /W:10 /NP /LOG >nul
	ROBOCOPY "%bookmark_chrome%" "%userbookmarkspath%" "Login Data-journal" /COPY:DAT /DCOPY:T /R:5 /W:10 /NP >nul
	
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

echo.
ECHO Backing up Adobe DC signature file.
ROBOCOPY "C:\users\%username%\AppData\Roaming\Adobe\Acrobat\DC\Security" "%backup_path%\apps\backup\%USERNAME%\AdobeSignature" *.* /COPY:DAT /DCOPY:T /R:5 /W:10 /NP >nul

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:BackupPrintersList
echo.
Echo Exporting printers.
:: List all printers to Printers.txt
wmic printer get name /value > "%backup_path%\apps\backup\%username%\Printers.txt"
:: Saves name of default printer to text file.
wmic printer get name,default | findstr TRUE > "%backup_path%\apps\backup\%username%\PrintersDefault.txt"

:: This exports printers registry key.  Cannot import the REG file, but can view in Notepad to see them all.
::	reg export HKCU\Printers\Connections %backup_path%\apps\backup\%username%\printers.reg /y

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:MappedDrivesExport
echo.
Echo Exporting mapped drives.
:: Exports registry key for mapped drives.  These can be installed by running the REG file, but explorer.exe may need to be restarted to see them.
:: Importing this appears to cause a problem when the user does not have rights to kill the Explorer.exe process.  No long restoring automatically.  Just a reference for manual restoral if necessary.
Reg Export HKEY_CURRENT_USER\Network "%backup_path%\apps\backup\%username%\Mapped_Drives.reg" /y >NUL

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:ExportESM
echo.
echo Checking for MarchNetworks ESM config data
:: Back up March Networks ESM Server for easier installation on replacement PC.
:: REG Export "HKCU\Software\MarchNetworks\Live Monitoring Console\Manager2\alarmdvr\(Default).reg" %backup_path%\apps\backup\%username%\alarmdvr\March_ESM.reg /y
REG EXPORT "HKCU\Software\MarchNetworks\Live Monitoring Console\Prefs\esmConnection" "%backup_path%\apps\backup\%username%\March_ESM.reg" /y >nul

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:BackupProgramsList
:: Creates a textfile containing all installed programs.
echo.
echo Saving list of all installed programs.
wmic /output:"%backup_path%\apps\backup\%username%\ProgramsList.txt" product get Name, Version
echo.
echo Filtering programs list.
:: This filters default programs out of the list, leaving things that may manually need to be installed on the new computer.
type "%backup_path%\apps\backup\%username%\ProgramsList.txt" | findstr /v "Chrome TeamViewer DC McAfee FORCEPOINT Office Password Windows Intel OEM Visual Documentation Redistributables redistributables Redistributable MDOP MBAM Default HP Java MER Driveguard Local Appman Forefront Installer Plug-in Driver Configuration Phish UEV Helper Imaging Silverlight Deployment WebEx DameWare Policy WPTx64 Authentication Receiver(DV) Receiver(Aero) Flash Identity Inside Receiver(SSON)" > %backup_path%\apps\backup\%username%\ProgramsList2.txt

:: If this process takes too long, make it optional with this.
:: :ExportProgramListChoice
:: Set /P c=Export Programs List[Y/N]?
:: if /I "%c%" EQU "Y" goto :ProgramsListChoiceY
:: if /I "%c%" EQU "N" goto :ServerBackupEnd
:: goto :ExportProgramListChoice

:: :ProgramsListChoiceY
:: :: Creates a textfile containing all installed programs.
:: echo Saving list of all installed programs.
:: wmic "/output:%backup_path%\apps\backup\%username%\ProgramsList.txt" product get Name, Version

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:ServerBackupEnd
echo.
echo Process is complete.
echo.
goto :END

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:OneDriveBackupStart
:: Backup to OneDrive

SETLOCAL

:OneDriveVariables
SET SDesktopP=C:\Users\%username%\Desktop
SET SDocumentsP=C:\Users\%username%\Documents
SET SDownloadsP=C:\Users\%username%\Downloads
SET SPicturesP=C:\Users\%username%\Pictures
SET SFavoritesP=C:\users\%username%\Favorites
SET SFirefoxP=C:\Users\%username%\AppData\Roaming\Mozilla\Firefox\Profiles
SET SChromeP=C:\Users\%username%\AppData\Local\Google\Chrome\User Data\Default
SET SAdobeP=C:\users\%username%\AppData\Roaming\Adobe\Acrobat\DC\Security
SET DestinationPath=C:\Users\%username%\OneDrive - Ameris Bank\Profile Backup
SET LogFile="%DestinationPath%\Profile Backup\Logfile.txt"

:: If DestinationPath location doesn't exist, create it so there are no conflicts. 
IF NOT EXIST "%DestinationPath%" MD "%DestinationPath%"

:DescriptionBackup2
echo Exporting Computer Description
REG Export HKLM\System\CurrentControlSet\services\LanmanServer\Parameters\srvcomment "%DestinationPath%\PC_Description.reg" /y

:BackupOutlookSignature2
echo.
echo Backing up Outlook Signatures.
xcopy "c:\Users\%USERNAME%\AppData\Roaming\Microsoft\Signatures\*.*" "%DestinationPath%\Signatures\" /i /e /c /y

:BackupOutlookPST2
echo.
echo Searching for old Outlook PST files
xcopy "C:\Documents and Settings\%USERNAME%\Local Settings\Application Data\Microsoft\Outlook\*.pst" "%DestinationPath%\" /i /e /c /y
::Win7 Location
xcopy "C:\Users\%USERNAME%\AppData\Local\MicrosoftOutlook\*.pst" "%DestinationPath%\" /i /e /c /y
::Win10 Location
xcopy "C:\Users\%USERNAME%\AppData\Local\Microsoft\Outlook\*.pst" "%DestinationPath%\" /i /e /c /y

:BackupPrintersList2
echo.
Echo Exporting printers.
:: List all printers to Printers.txt
wmic printer get name /value > "%DestinationPath%\Printers.txt"
:: Saves name of default printer to text file.
wmic printer get name,default | findstr TRUE > "%DestinationPath%\PrintersDefault.txt"

:MappedDrivesExport2
echo.
Echo Exporting mapped drives.
:: Exports registry key for mapped drives.  These can be installed by running the REG file, but explorer.exe may need to be restarted to see them.
	Reg Export HKEY_CURRENT_USER\Network "%DestinationPath%\Mapped_Drives.reg" /y >NUL

:ExportESM2
echo.
echo Checking for MarchNetworks ESM config data
:: Back up March Networks ESM Server for easier installation on replacement PC.
:: REG Export "HKCU\Software\MarchNetworks\Live Monitoring Console\Manager2\alarmdvr\(Default).reg" %backup_path%\apps\backup\%username%\alarmdvr\March_ESM.reg /y
REG EXPORT "HKCU\Software\MarchNetworks\Live Monitoring Console\Prefs\esmConnection" "%DestinationPath%\March_ESM.reg" /y >nul

:BProgramsList2
:: Creates a textfile containing all installed programs.
echo.
echo Saving list of all installed programs.
wmic /output:"%DestinationPath%\ProgramsList.txt" product get Name, Version
echo.
echo Filtering programs list.
:: This filters default programs out of the list, leaving things that may manually need to be installed on the new computer.
type "%DestinationPath%\ProgramsList.txt" | findstr /v "Chrome TeamViewer DC McAfee FORCEPOINT Office Password Windows Intel OEM Visual Documentation Redistributables redistributables Redistributable MDOP MBAM Default HP Java MER Driveguard Local Appman Forefront Installer Plug-in Driver Configuration Phish UEV Helper Imaging Silverlight Deployment WebEx DameWare Policy WPTx64 Authentication Receiver(DV) Receiver(Aero) Flash Identity Inside Receiver(SSON)" > "%DestinationPath%\ProgramsList2.txt"

:ODProfileBackup
echo.
ECHO Backing up Desktop.
ROBOCOPY "%SDesktopP%" "%DestinationPath%\Desktop" *.* /COPY:DAT /DCOPY:T /R:5 /W:10 /NP

echo.
ECHO Backing up Documents. 
ROBOCOPY "%SDocumentsP%" "%DestinationPath%\Documents" *.* /COPY:DAT /DCOPY:T /R:5 /W:10 /NP

echo.
ECHO Backing up Downloads.
ROBOCOPY "%SDownloadsP%" "%DestinationPath%\Downloads" *.* /COPY:DAT /DCOPY:T /R:5 /W:10 /NP

echo.
ECHO Backing up Pictures.
ROBOCOPY "%SPicturesP%" "%DestinationPath%\Pictures" *.* /COPY:DAT /DCOPY:T /R:5 /W:10 /NP

echo.
ECHO Backing up Internet Explorer Favorites.
ROBOCOPY "%SFavoritesP%" "%DestinationPath%\Favorites" *.* /COPY:DAT /DCOPY:T /R:5 /W:10 /NP

echo.
ECHO Backing up Chrome Bookmarks and Login info.
ROBOCOPY "%SChromeP%" "%DestinationPath%\ChromeBookmarks\Local\Google\Chrome\User" *.* /COPY:DAT /DCOPY:T /R:5 /W:10 /NP

:: These 4 are what I really want instead of the whole folder above, but I'm running into errors with this version.
:: ROBOCOPY "%bookmark_chrome%" "%userbookmarkspath%" Bookmarks /COPY:DAT /DCOPY:T /R:5 /W:10 /NP
:: ROBOCOPY "%bookmark_chrome%" "%userbookmarkspath%" Bookmarks.bak /COPY:DAT /DCOPY:T /R:5 /W:10 /NP
:: ROBOCOPY "%bookmark_chrome%" "%userbookmarkspath%" "Login Data" /COPY:DAT /DCOPY:T /R:5 /W:10 /NP
:: ROBOCOPY "%bookmark_chrome%" "%userbookmarkspath%" "Login Data-journal" /COPY:DAT /DCOPY:T /R:5 /W:10 /NP

echo.
ECHO Backing up Adobe DC signature file.
ROBOCOPY "%SAdobeP%" "%DestinationPath%\AdobeSignature" *.* /COPY:DAT /DCOPY:T /R:5 /W:10 /NP

echo.
echo If this user has Acrobat Pro, they may have signatures to export.
echo In Acrobat X it is under Tools > Sign&Certify > More Sign&Certify > Export Security Settings
echo In Acrobat XI it is under Edit > Preferences > Security > Export
echo The file it creates can be imported into Acrobat on the new computer to restore their signature.

echo.
echo Process is complete.
echo.
goto :END

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:RESTORE
CLS
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Restore
:: 
:: This script does the following for the signed in user: 
:: Imports Outlook signatures
:: Imports Outlook PST files found in standard locations for XP, Win7, or Win10
:: Import Chrome bookmarks
:: Imports the PC Description
:: Displays a list of printers and notes the default printer
:: Filters program list to a shorter relevant list and displays them along with version number.
:: Records new computer serial to backup directory.
:: This script only copies files from the backup location.  It does not delete or move anything from the existing backup location, and only modifies the textfiles it creates.
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: To Do
:: Create alternate version requiring input only for backup server.
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:RestoreServerPath
::  Set backup path and establishes %backup_path% variable
SET /p backup_path=Enter the name of the server where backups are found, including backslashes.  (e.g. \\FL999APPSVR).:

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:RecordNewName
:: This saves a text file in the backup directory that shows the new computer's name.
echo %computername% > %backup_path%\apps\backup\%USERNAME%\New-%computername%.txt

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:RestoreDescription
:: This restores the PC description from the backed up registry key.
REG IMPORT "%backup_path%\apps\backup\%username%\PC_Description.reg" /y

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:RestoreESM
:: Import March Networks ESM Server registry key if it was found during the backup process.
REG IMPORT "%backup_path%\apps\backup\%username%\March_ESM.reg" /y

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:RestoreProfile
::  Copies from backup on remote server to local user profile directory.
echo.
echo Restoring User Profile.
xcopy %backup_path%\apps\backup\%USERNAME% C:\Users\%USERNAME% /i /e /c /y 

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:RestoreOutlookSig
echo.
echo Restoring Outlook Signature files.
xcopy %backup_path%\apps\backup\%USERNAME%\Signatures c:\Users\%USERNAME%\AppData\Roaming\Microsoft\Signatures /i /e /c /y

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:RestoreOutlookPST
echo.
echo Restoring Outlook PST files.
xcopy %backup_path%\apps\backup\%USERNAME%\*.pst C:\Users\%USERNAME%\AppData\Local\Microsoft\Outlook /i /e /c /y

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:RestoreChrome
echo.
echo Restoring Chrome favorites.
	SET userbookmarkspath=%backup_path%\apps\backup\%USERNAME%\ChromeBookmarks\Local\Google\Chrome\User Data\Default
	SET bookmark_chrome=%USERPROFILE%\AppData\Local\Google\Chrome\User Data\Default
	SET userbookmarkspathcomputer=%userbookmarkspath%\%computername%
	ROBOCOPY "%userbookmarkspath%" "%bookmark_chrome%" Bookmarks /COPY:DAT /DCOPY:T /R:5 /W:10 /NP
	ROBOCOPY "%userbookmarkspath%" "%bookmark_chrome%" Bookmarks.bak /COPY:DAT /DCOPY:T /R:5 /W:10 /NP
	:: This also restores saved logins and passwords
	ROBOCOPY "%userbookmarkspath%" "%bookmark_chrome%" "Login Data" /COPY:DAT /DCOPY:T /R:5 /W:10 /NP
	ROBOCOPY "%userbookmarkspath%" "%bookmark_chrome%" "Login Data-journal" /COPY:DAT /DCOPY:T /R:5 /W:10 /NP
ping -n 3 127.0.0.1 > nul
::  Start Chrome to load bookmarks and create the rest of its directories.  
echo.
echo Launching Chrome to load bookmarks bar.
start "Chrome" "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
echo Proceed after Chrome has fully loaded.
timeout /t 60
:: echo Closing Chrome.
:: taskkill /f /IM chrome.exe >NUL

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: This seems to cause an issue when the user doesn't have sufficient permission to kill the Explorer process.  
:: Exported key can instead be used as reference to manually restore mapped drives.
:: 
:: :MappedChoice
:: ::  Import mapped drives from backed up registry key.  Drives do not show until explorer.exe is restarted.
:: echo.
:: Set /P c=Kill Explorer process and proceed with importing mapped drives[Y/N]?
:: if /I "%c%" EQU "Y" goto :MappedChoiceY
:: if /I "%c%" EQU "N" goto :MappedChoiceN
:: goto :MappedChoice
:: 
:: :MappedChoiceY
:: taskkill /f /IM explorer.exe >NUL
:: ping -n 2 127.0.0.1 > nul
:: REG IMPORT "\\%backup_path%\apps\backup\%username%\Mapped_Drives.reg" /y
:: ping -n 2 127.0.0.1 > nul
:: Start "Explorer" explorer.exe >NUL
:: 
:: :MappedChoiceN
:: echo.
:: echo Importing without killing Explorer process.
:: echo The mapped drives may not show up until Explorer is relaunched.
:: REG IMPORT \\%backup_path%\apps\backup\%username%\Mapped_Drives.reg /y
:: 
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:OutlookStart
:: Launches Outlook
echo.
echo Opening Outlook.
echo Select user's default signatures.
Start "Outlook" "C:\Program Files (x86)\Microsoft Office\root\Office16\OUTLOOK.EXE"
timeout /t 30

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:SkypeStart
:: Launches Skype
echo.
echo Starting Skype 
echo Make sure user gets signed in.
start "Skype" "C:\Program Files (x86)\Microsoft Office\root\Office16\lync.exe"
timeout /t 30

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:WMPstart
:: Launches Windows Media Player
echo.echo Starting Windows Media Player to clear configuration screen.
start "MediaPlayer" "C:\Program Files (x86)\Windows Media Player\wmplayer.exe" /acceptEula
timeout /t 10

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:IEstart
:: Launches Internet Explorer
echo.
echo Starting IE to set toolbars.
start "InternetExplorer" "C:\Program Files\internet explorer\iexplore.exe"
timeout /t 30

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:PrintersRestore
:: Searches Printers.txt for network printer names.
cls
echo.
echo Reconnect these printers.
echo.
type %backup_path%\apps\backup\%username%\Printers.txt | findstr Name=\\ 
:: Open local server to start connecting printers
start %backup_path%
echo.
echo The printer below is the DEFAULT PRINTER.
type %backup_path%\apps\backup\%username%\PrintersDefault.txt
echo.
echo ======================================================================================

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:RProgramsList
echo.
echo These programs need to be installed:
echo.
type %backup_path%\apps\backup\%username%\ProgramsList2.txt
echo. 
echo ======================================================================================
:: Waits up to 10 min for user to reference.
:: echo Batch file is exiting after 10 minute pause...
:: ping -n 600 127.0.0.1 > nul

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:RestoreMappedDrivesManually
echo.
echo If the user had extra mapped drives that would not be set by logon script, 
echo reference Mapped_Drives.reg and manually restore mapped drive connections. 
echo This file can be opened in Notepad.
echo.
echo ======================================================================================
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:END
pause 

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: XCOPY switches used
:: /i if destination does not exist, assume it is a folder
:: /e copies supfolders, even empty
:: /c continue copy even if errors occur
:: /y overwrite existing files without prompts
:: /EXCLUDE Does not include any directories or file types listed in the referenced text file

:: ROBOCOPY switches used
:: /COPY:DAT copies the data only
:: /DCOPY:T  copies timestamp
:: /R:[#]      Number of retry attempts to make
:: /W:[time]     Wait 30 seconds to retry
:: /NP       No progress displayed

:: REG EXPORT switches used
:: /y Ignore errors from overwriting files.  Used for testing script.

:: IF switches used
:: /I Case insensitive