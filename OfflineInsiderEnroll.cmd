@echo off
set "scriptver=2.7.4"
chcp 866
for /f "tokens=3" %%b in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "BuildBranch"') do set br=%%b 
set "locale=ru"
for /f "tokens=3 delims=;:- " %%l in ('systeminfo ^| findstr /b /c:"System Locale:"') do set lang=%%l 
for /f "tokens=3 delims=;:- " %%l in ('systeminfo ^| findstr /b /c:"��� ��⥬�:"') do set lang=%%l
if /I %lang%==%locale%  ( goto :RU_LOCALE ) else ( goto :EN_LOCALE )

:CHECK_BUILD
for /f "tokens=4 delims=[] " %%i in ('ver') do set build=%%i
if %build:~5,5% LSS 17763 (
    echo =============================================================
    echo  %chbuild1% %build:~5%. %chbuild2%
    echo =============================================================
    echo.
    pause
    goto :EOF )

reg query HKU\S-1-5-19 1>nul 2>nul
if %ERRORLEVEL% equ 0 goto :START_SCRIPT
echo =====================================================
echo %chadmin%
echo =====================================================
echo.
pause
goto :EOF

:START_SCRIPT
set "FlightSigningEnabled=0"
bcdedit /enum {current} | findstr /I /R /C:"^flightsigning *Yes$" >nul 2>&1
if %ERRORLEVEL% equ 0 set "FlightSigningEnabled=1"

:CHOICE_MENU
cls
set "WSH=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost"
set "cver=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion"
set "wdat=HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows"
set "choice="
echo OfflineInsiderEnroll v%scriptver%
echo.
echo 1 - %m1% Dev Channel
echo 2 - %m1% Beta Channel
echo 3 - %m1% Release Preview Channel
echo.
echo 4 - %m2%
echo 5 - %m3%
echo.
choice /C:12345 /N /M "%mch% [1,2,3,4,5] : "
if errorlevel 5 goto:EOF
if errorlevel 4 goto:STOP_INSIDER
if errorlevel 3 goto:ENROLL_RP
if errorlevel 2 goto:ENROLL_BETA
if errorlevel 1 goto:ENROLL_DEV

:ENROLL_RP
set "Channel=ReleasePreview"
set "Fancy=Release Preview Channel"
set "BRL=8"
set "Content=Mainline"
set "Ring=External"
set "RID=11"
set "actived=false"
set "activeb=false"
set "activerp=true"
goto :ENROLL

:ENROLL_BETA
set "Channel=Beta"
set "Fancy=Beta Channel"
set "BRL=4"
set "Content=Mainline"
set "Ring=External"
set "RID=11"
set "actived=false"
set "activeb=true"
set "activerp=false"
goto :ENROLL

:ENROLL_DEV
set "Channel=Dev"
set "Fancy=Dev Channel"
set "BRL=2"
set "Content=Mainline"
set "Ring=External"
set "RID=11"
set "actived=true"
set "activeb=false"
set "activerp=false"
goto :ENROLL

:RESET_INSIDER_CONFIG
reg delete "%WSH%\Account" /f
reg delete "%WSH%\Applicability" /f
reg delete "%WSH%\Cache" /f
reg delete "%WSH%\UI" /f
reg delete "%cver%\WindowsUpdate\SLS\Programs\WUMUDCat" /f
reg delete "%cver%\WindowsUpdate\SLS\Programs\Ring%Ring%" /f
reg delete "%cver%\WindowsUpdate\SLS\Programs\RingExternal" /f
reg delete "%cver%\WindowsUpdate\SLS\Programs\RingPreview" /f
reg delete "%cver%\WindowsUpdate\SLS\Programs\RingInsiderSlow" /f
reg delete "%cver%\WindowsUpdate\SLS\Programs\RingInsiderFast" /f
reg delete "%cver%\Policies\DataCollection" /f /v AllowTelemetry
reg delete "%cver%\DataCollection" /f /v AllowTelemetry
reg delete "%cver%\WindowsUpdate" /f /v BranchReadinessLevel
goto :EOF

:ADD_INSIDER_CONFIG
reg add "%cver%\WindowsUpdate\Orchestrator" /f /t REG_DWORD /v EnableUUPScan /d 1
reg add "%cver%\WindowsUpdate\SLS\Programs\Ring%Ring%" /f /t REG_DWORD /v Enabled /d 1
reg add "%cver%\WindowsUpdate\SLS\Programs\WUMUDCat" /f /t REG_DWORD /v WUMUDCATEnabled /d 1
reg add "%cver%\Policies\DataCollection" /f /t REG_DWORD /v AllowTelemetry /d 3
if defined BRL reg add "%cver%\WindowsUpdate" /f /t REG_DWORD /v BranchReadinessLevel /d %BRL%
reg add "%WSH%\Applicability" /f /t REG_DWORD /v EnablePreviewBuilds /d 2
reg add "%WSH%\Applicability" /f /t REG_DWORD /v IsBuildFlightingEnabled /d 1
reg add "%WSH%\Applicability" /f /t REG_DWORD /v IsConfigSettingsFlightingEnabled /d 1
reg add "%WSH%\Applicability" /f /t REG_DWORD /v IsConfigExpFlightingEnabled /d 0
reg add "%WSH%\Applicability" /f /t REG_DWORD /v TestFlags /d 32
reg add "%WSH%\Applicability" /f /t REG_DWORD /v RingId /d %RID%
reg add "%WSH%\Applicability" /f /t REG_SZ /v Ring /d "%Ring%"
reg add "%WSH%\Applicability" /f /t REG_SZ /v ContentType /d "%Content%"
reg add "%WSH%\Applicability" /f /t REG_SZ /v BranchName /d "%Channel%"
reg add "%WSH%\UI\Selection" /f /t REG_SZ /v UIRing /d "%Ring%"
reg add "%WSH%\UI\Selection" /f /t REG_SZ /v UIContentType /d "%Content%"
reg add "%WSH%\UI\Selection" /f /t REG_SZ /v UIBranch /d "%Channel%"
reg add "%WSH%\UI\Visibility" /f /t REG_DWORD /v UIHiddenElements_Rejuv /d 65508
reg add "%WSH%\UI\Visibility" /f /t REG_DWORD /v UIDisabledElements_Rejuv /d 65517
reg add "%WSH%\Cache" /f /t REG_SZ /v "ConfigurationOptionList" /d "{\"ConfigurationOptionList\":[{\"Name\":\"Dev\",\"Alias\":\"Dev Channel\",\"Description\":\"%cdevdesc%\",\"ContentType\":\"Mainline\",\"Branch\":\"Dev\",\"Ring\":\"External\",\"IsRecommended\":false,\"RecommendedOnly\":false,\"IsValid\":%actived%,\"Title\":\"Dev\",\"Warning\":\"%cdevwar%\"},{\"Name\":\"Beta\",\"Alias\":\"Beta Channel (Recommended)\",\"Description\":\"%cbetadesc%\",\"ContentType\":\"Mainline\",\"Branch\":\"Beta\",\"Ring\":\"External\",\"IsRecommended\":true,\"RecommendedOnly\":false,\"IsValid\":%activeb%,\"Title\":\"Beta\",\"Warning\":\"\"},{\"Name\":\"ReleasePreview\",\"Alias\":\"Release Preview Channel\",\"Description\":\"%crpdesk%\",\"ContentType\":\"Mainline\",\"Branch\":\"ReleasePreview\",\"Ring\":\"External\",\"IsRecommended\":false,\"RecommendedOnly\":false,\"IsValid\":%activerp%,\"Title\":\"Release Preview\",\"Warning\":\"\"}]}"
reg add "%WSH%\UI\Strings" /f /t REG_SZ /v "AccountText" /d "{\"Description\":\"%acdesc%\",\"Title\":\"%actitle%\",\"ButtonTitle\":\"%acbutton%\"}"
reg add "%WSH%\UI\Strings" /f /t REG_SZ /v "DeviceStatusBarText" /d "{\"Subtitle\":\"%dsdesk% %build:~5% %br% \",\"LinkTitle\":\"%dsltitle%\",\"LinkUrl\":\"https://aka.ms/%Channel%Latest\",\"ButtonUrl\":\"feedback-hub://\",\"Status\":1,\"Title\":\"%dstitle%\",\"ButtonTitle\":\"%dsbutton%\"}"
reg add "%WSH%\UI\Strings" /f /t REG_SZ /v "ConfigurationExpanderText_Rejuv" /d "{\"Title\":\"%conftitle%\",\"RelatedLinkText\":\"%confrlink%\",\"RelatedLinkUrl\":\"https://github.com/nondetect/offlineinsiderenroll/releases\"}"
reg add "%WSH%\UI\Strings" /f /t REG_SZ /v "UnenrollText_Rejuv" /d "{\"Status\":\"\",\"ToggleTitle\":\"%unrtogtitle%\",\"ToggleDescription\":\"%unrtogdesk%\",\"LinkTitle\":\"%unrlinktitle%\",\"LinkDescription\":\"%unrlinkdesk%\",\"LinkUrl\":\"https://go.microsoft.com/fwlink/?linkid=2136438\",\"Title\":\"%unrtitle%\",\"RelatedLinkText\":\"%unrreltext%\",\"RelatedLinkUrl\":\"https://insider.windows.com/leave-program\"}"
if %build:~5,5% LSS 21990 reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\UI\Strings" /f /t REG_SZ /v StickyXaml /d "<StackPanel xmlns="^""http://schemas.microsoft.com/winfx/2006/xaml/presentation"^""><TextBlock Margin="^""0,-25,0,0"^"" Style="^""{StaticResource BodyTextBlockStyle}"^"">%mdesc% v%scriptver%.</TextBlock><TextBlock Style="^""{StaticResource SubtitleTextBlockStyle}"^""><Run FontFamily="^""Segoe Fluent Icons"^"">&#xE9D9;</Run> <Span FontWeight="^""SemiBold"^"">%mnottitle%</Span></TextBlock><TextBlock Style="^""{StaticResource BodyTextBlockStyle }"^"">%mnotdesk1% <Span FontWeight="^""SemiBold"^"">%mnotdesk2%</Span>%mnotdesk3% <Span FontWeight="^""SemiBold"^"">%mnotdesk4%</Span>.</TextBlock><Button Command="^""{StaticResource ActivateUriCommand}"^"" CommandParameter="^""ms-settings:privacy-feedback"^"" Margin="^""0,10,0,0"^""><TextBlock Margin="^""5,0,5,0"^"">%mnotbutton%</TextBlock></Button></StackPanel>"
chcp 1251 >nul
if %build:~5,5% LSS 21990 goto :EOF
(
echo Windows Registry Editor Version 5.00
echo.
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\UI\Strings]
echo "StickyMessage"="{\"Message\":\"%mtitle%\",\"LinkTitle\":\"\",\"LinkUrl\":\"\",\"DynamicXaml\":\"^<StackPanel xmlns=\\\"http://schemas.microsoft.com/winfx/2006/xaml/presentation\\\"^>^<TextBlock Margin=\\\"0,-25,0,10\\\" Style=\\\"{StaticResource BodyTextBlockStyle }\\\"^>%mdesc% v%scriptver%.^</TextBlock^>^<TextBlock Style=\\\"{StaticResource SubtitleTextBlockStyle }\\\" ^>^<Run FontFamily=\\\"Segoe Fluent Icons\\\"^>^&#xE9D9;^</Run^> ^<Span FontWeight=\\\"SemiBold\\\"^>%mnottitle%^</Span^>^</TextBlock^>^<TextBlock Style=\\\"{StaticResource BodyTextBlockStyle }\\\"^>%mnotdesk1% ^<Span FontWeight=\\\"SemiBold\\\"^>%mnotdesk2%^</Span^>%mnotdesk3% ^<Span FontWeight=\\\"SemiBold\\\"^>%mnotdesk4%^</Span^>.^</TextBlock^>^<Button Command=\\\"{StaticResource ActivateUriCommand}\\\" CommandParameter=\\\"ms-settings:privacy-feedback\\\" Margin=\\\"0,10,0,0\\\"^>^<TextBlock Margin=\\\"5,0,5,0\\\"^>%mnotbutton%^</TextBlock^>^</Button^>^</StackPanel^>\",\"Severity\":0}"
echo.
)>"%Temp%\oie.reg"
regedit /s "%Temp%\oie.reg"
del /f /q "%Temp%\oie.reg"
goto :EOF

:ENROLL
echo %apc%
call :RESET_INSIDER_CONFIG 1>NUL 2>NUL
call :ADD_INSIDER_CONFIG 1>NUL 2>NUL
bcdedit /set {current} flightsigning yes >nul 2>&1
echo %apd%
echo.
if %FlightSigningEnabled% neq 1 goto :ASK_FOR_REBOOT
echo %pte%
pause >nul
goto :EOF

:STOP_INSIDER
echo %apc%
call :RESET_INSIDER_CONFIG 1>nul 2>nul
bcdedit /deletevalue {current} flightsigning >nul 2>&1
echo %apd%
echo.
if %FlightSigningEnabled% neq 0 goto :ASK_FOR_REBOOT
echo %pte%
pause >nul
goto :EOF

:ASK_FOR_REBOOT
set "choice="
echo %rtitle%
set /p choice="%rdesk% "
if /I "%choice%"=="y" shutdown -r -t 0
goto :EOF

:RU_LOCALE
echo %lang% in ru
set "chadmin=����室��� ����᪠�� �� ����� �����������"
set "chbuild1=��� ⥪��� ᡮઠ"
set "chbuild2=��� ࠡ��� �ਯ� ����室��� ���� Windows 10 v1809 ᡮઠ 17763 ��� ���"
set "m1=��३� ��"
set "m2=�४���� ����祭�� ��ᠩ���᪨� ᡮப"
set "m3=��室 ��� ���ᥭ�� ���������"
set "mch=������ ᢮� �롮�"
set "apc=�ਬ������ ���������..."
set "apd=��⮢�"
set "pte=������ ���� ������ ��� ��室�"
set "rtitle=����室��� ��१���㧪� �⮡� ��������� ���㯨�� � ᨫ�"
set "rdesk=���� ��१���㧨�� ��������"
set "actitle=��⭠� ������ ���⭨�� �ணࠬ�� �।���⥫쭮� �業�� Windows"
set "acdesc=��� �ਢ易���� ���⭮� �����"
set "acbutton=��������"
set "cdevdesc=�����쭮 ���室�� ��� �孨�᪨ ����������� ���짮��⥫��. ���묨 ����砩� ����� � �����訬 ᡮઠ� Windows 11 �� ᠬ�� ࠭��� �⠯� 横�� ࠧࠡ�⪨ � �����訬 �����. �� ������ ������� ��客���� � ������ �⠡��쭮���."
set "cdevwar=�� ४�����㥬 Dev Channel ⮫쪮 � ⮬ ��砥, �᫨ �� ��⨢�� �믮���� १�ࢭ�� ����஢���� ������ � ��� �����⭮ �믮����� ����� ��⠭���� Windows. ��� ����� ����砥� ᡮન, ����� ����� ������� ��客���� � ����� ���� ���⠡���묨. ��᫥ ��⠭���� ᡮન �� Dev Channel �����⢥��� ᯮᮡ ��३� �� ��㣮� ����� ��� �⬥���� ॣ������ �⮣� ���ன�⢠ - �� �믮����� ����� ��⠭���� Windows. ��� �㦭� �㤥� ������ ᮧ���� १�ࢭ�� ����� � ����⠭����� �� �����, ����� �� ��� ��࠭���."
set "cbetadesc=�����쭮 ���室�� ��� ࠭��� ��᫥����⥫��. �� ᡮન Windows 11 ����� �������, 祬 ᡮન �� ������ Dev, ��������� ����������, �஢��塞� ��௮�樥� ��������. ��� ��� ����뢠�� ����⥫쭮� �������⢨�."
set "crpdesk=�����쭮 ���室��, �᫨ �� ��� ������������ � ��ࠢ����ﬨ � ������묨 ���祢묨 �㭪�ﬨ, � ⠪�� ������� ����������� ����㯠 � ᫥���饩 ���ᨨ Windows 10, �०�� 祬 ��� �⠭�� ��饤���㯭�� ��� �ᥣ� ���. ��� ����� ⠪�� ४��������� ��� �������᪨� ���짮��⥫��."
set "dstitle=�� ��襬 ���ன�⢥ ��⠭������ ������� ����� ᡮન"
set "dsdesk=��⠭������ ᡮઠ:"
set "dsltitle=��᫥���� ��������� � ᡮથ"
set "dsbutton=��⠢��� ���"
set "conftitle=��ᬮ���� ⥪�騥 ��ࠬ���� �ணࠬ�� �।���⥫쭮� �業��"
set "confrlink=�᫨ ��� �������� ����ன�� Windows Insider ��� �४���� ���⨥, �������� �ᯮ���� �ਯ�"
set "mtitle=���ன�⢮ ��ॣ����஢��� � ������ OfflineInsiderEnroll"
set "mdesc=�� ���ன�⢮ �뫮 ��ॣ����஢��� � �ணࠬ�� �।���⥫쭮� �業�� Windows � ������� OfflineInsiderEnroll"
set "mnottitle=����������� � ����ன��� ⥫����ਨ"
set "mnotdesk1=�ணࠬ�� �।���⥫쭮� �業�� Windows �ॡ��, �⮡� � ����ன��� ᡮ� ���������᪨� ������ �뫠 ����祭�"
set "mnotdesk2=��ࠢ�� ����易⥫��� ���������᪨� ������."
set "mnotdesk3=�� ����� �஢���� ��� �������� ᢮� ⥪�騥 ����ன�� �"
set "mnotdesk4=�������⨪� � ����"
set "mnotbutton=������ �������⨪� � ����"
set "unrtitle=�४���� ����祭�� �।���⥫��� ᡮப"
set "unrtogtitle=�⬥���� ॣ������ �⮣� ���ன�⢠ ��᫥ ��室� ᫥���饩 ���ᨨ Windows"
set "unrtogdesk=����㯭� ��� ������� ���-���ᨨ � �।���⥫쭮�� ���᪠. ������ ��� ��ࠬ���, �⮡� �४���� ����祭�� �।���⥫��� ᡮப ��᫥ ����᪠ ᫥���饣� ��饤���㯭��� �᭮����� ���᪠ Windows. �� �⮣� ������ ��� ���ன�⢮ �㤥� ������� ᡮન ��� �।���⥫쭮� �業��, �⮡� �����ন���� ��� ������᭮���. �� ��� �ਫ������, �ࠩ���� � ��ࠬ���� ���� ��࠭��� ���� ��᫥ ⮣�, ��� �� ����⠭�� ������� �।���⥫�� ᡮન."
set "unrlinktitle=������ �⬥�� ॣ����樨 ���ன�⢠"
set "unrlinkdesk=�⮡� �४���� ����祭�� ᡮப Insider Preview �� ���ன�⢥, �믮���� ����� ��⠭���� ��᫥���� ���ᨨ Windows 10. �ਬ�砭��. �� �⮬ ���� 㤠���� �� ��� ����� � ��⠭������ ᢥ��� ����� Windows 10."
set "unrreltext=��室 �� �ணࠬ�� �।���⥫쭮� �業�� Windows"
goto :CHECK_BUILD

:EN_LOCALE
echo %lang% in en
set "chadmin=This script needs to be executed as an administrator."
set "chbuild1=Your build is"
set "chbuild2=This script is compatible only with Windows 10 RS5 17763 and later."
set "m1=Enroll to"
set "m2=Stop receiving Insider Preview builds"
set "m3=Quit without making any changes"
set "mch=Enter Your Choice"
set "apc=Applying changes..."
set "apd=Done"
set "pte=Press any key to exit."
set "rtitle=A reboot is required to finish applying changes."
set "rdesk=Would you like to reboot your PC?"
set "actitle=Windows Insider account"
set "acdesc=No account linked"
set "acbutton=Edit"
set "cdevdesc=Ideal for highly technical users. Be the first to access the latest Windows 11 builds earliest in the development cycle with the newest code. There will be some rough edges and low stability."
set "cdevwar=We recommend the Dev Channel only if you actively back up your data and are comfortable clean installing Windows. This channel receives builds that may have rough edges or be unstable. Once you install a build from the Dev Channel, the only way to move to another channel or unenroll this device is to clean install Windows. You?ll need to manually back up and restore any data you want to keep."
set "cbetadesc=Ideal for early adopters. These Windows 11 builds will be more reliable than builds from our Dev Channel, with updates validated by Microsoft. Your feedback has the greatest impact here."
set "crpdesk=Ideal if you want to preview fixes and certain key features, plus get optional access to the next version of Windows 10 before it's generally available to the world. This channel is also recommended for commercial users."
set "dstitle=You're on the latest build for your device"
set "dsdesk=Installed build:"
set "dsltitle=Latest build notes"
set "dsbutton=Give feedback"
set "conftitle=Your Insider settings"
set "confrlink=If you want to change settings of the enrollment or stop receiving Insider Preview builds, please use the script."
set "mtitle=Device Enrolled using OfflineInsiderEnroll"
set "mdesc=This device has been enrolled to the Windows Insider program using OfflineInsiderEnroll"
set "mnottitle=Telemetry settings notice"
set "mnotdesk1=Windows Insider Program requires diagnostic data collection to be enabled "
set "mnotdesk2=Send optional diagnostic data"
set "mnotdesk3=. You can verify or modify your current settings in "
set "mnotdesk4=Diagnostics and feedback"
set "mnotbutton=Open Diagnostics and feedback"
set "unrtitle=Stop getting preview builds"
set "unrtogtitle=Unenroll this device when the next version of Windows releases"
set "unrtogdesk=Available for Beta and Release Preview channels. Turn this on to stop getting preview builds when the next major release of Windows launches to the public. Until then, your device will continue to get Insider builds to keep it secure. You?ll keep all your apps, drivers and settings even after you stop getting preview builds."
set "unrlinktitle=Unenroll this device immediately"
set "unrlinkdesk=To stop getting Insider Preview builds on this device, you?ll need to clean install the latest release of Windows 10. Note: This option will erase all your data and install a fresh copy of Windows 10."
set "unrreltext=Leaving the Insider Program"
goto :CHECK_BUILD