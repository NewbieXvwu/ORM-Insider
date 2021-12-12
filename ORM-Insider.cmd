@echo off
set "scriptver=2.9.1"
title ORM-Insider %scriptver%
mode con:cols=90 lines=28
chcp 866 >nul
goto :LOCALE

:CHECK_BUILD
color a
if %build:~0,5% LSS %defbuild% (
echo.
echo.%agrl%
echo.%agre%
echo.%chbuild%
echo.%agre%
echo.                          %os% %build%
echo.%agrs%
echo.%agre%
echo.%pte%
echo.%agrs%
pause >nul
goto :EOF ) 

net session >nul 2>&1
if %ERRORLEVEL% equ 0 goto :AGREEMENT
echo.
echo.%agrl%
echo.%agre%
echo.%chadmin%
echo.%agrs%
echo.%agre%
echo.%pte%
echo.%agrs%
pause >nul
goto :EOF 

:START_SCRIPT
set "FlightSigningEnabled=0"
bcdedit /enum {current} | findstr /I /R /C:"^flightsigning *Yes$" >nul 2>&1
if %ERRORLEVEL% equ 0 set "FlightSigningEnabled=1"

:CHOICE_MENU
cls
color 2
set "WSH=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost"
set "cver=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion"
set "wdat=HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows"
echo.%agrl%
echo.%agre%
echo.^|                      ORM-Insider v%scriptver% by nondetect aka aleks242007                   ^|
echo.^|                            Special thank's abbodi1406 ^& AveYo                          ^|
echo.%agre%
echo.%agrd%
echo.%agre%
echo.%me%1] - %m1% Dev Channel
echo.%agre%
echo.%me%2] - %m1% Beta Channel
echo.%agre%
echo.%me%3] - %m1% Release Preview Channel
echo.%agre%
echo.%agrd%
echo.%agre%
echo.%m2%
echo.%agre%
echo.%m3%
echo.%agre%
echo.%agrd%
echo.%agre%
echo.%m4%
echo.%agre%
echo.%m5%
echo.%agrs%
echo.%agre%
choice /C:1234567 /N /M "%mch% [1,2,3,4,5,6,7] : "
if errorlevel 7 exit
if errorlevel 6 goto:STOP_INSIDER
if errorlevel 5 goto:EX_REMOVE_SKIP_CHECK
if errorlevel 4 goto:EX_SKIP_CHECK
if errorlevel 3 goto:ENROLL_RP
if errorlevel 2 goto:ENROLL_BETA
if errorlevel 1 goto:ENROLL_DEV

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
goto :CHECK_CHOICE

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
goto :CHECK_CHOICE

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
goto :CHECK_CHOICE

:CHECK_CHOICE
echo.%agrs%
echo.%agre%
echo.%m6%
echo.%agrs%
echo.%agre%
echo.%me%%m7%
echo.%agre%
echo.%me%%m8%
echo.%agrs%
echo.%agre%
choice /C:12 /N /M "%mch% [1,2] : "
if errorlevel 2 goto:ENROLL
if errorlevel 1 goto:ENROLL_SKIP_CHECK

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
reg delete "%cdat%\DataCollection" /f /v AllowTelemetry
reg delete "%cdat%\WindowsUpdate" /f /v BranchReadinessLevel
goto :EOF

:ADD_INSIDER_CONFIG
reg add "%cver%\WindowsUpdate\Orchestrator" /f /t REG_DWORD /v EnableUUPScan /d 1
reg add "%cver%\WindowsUpdate\SLS\Programs\Ring%Ring%" /f /t REG_DWORD /v Enabled /d 1
reg add "%cver%\WindowsUpdate\SLS\Programs\WUMUDCat" /f /t REG_DWORD /v WUMUDCATEnabled /d 1
reg add "%cver%\Policies\DataCollection" /f /t REG_DWORD /v AllowTelemetry /d 3
if defined BRL reg add "%cdat%\WindowsUpdate" /f /t REG_DWORD /v BranchReadinessLevel /d %BRL%
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
reg add "%WSH%\UI\Visibility" /f /t REG_DWORD /v UIDisabledElements_Rejuv /d 65517
reg add "%WSH%\UI\Visibility" /f /t REG_DWORD /v UIHiddenElements_Rejuv /d 65508
reg add "%WSH%\UI\Visibility" /f /t REG_DWORD /v UIErrorMessageVisibility /d 192
reg add "%WSH%\Cache" /f /t REG_SZ /v "ConfigurationOptionList" /d "{\"ConfigurationOptionList\":[{\"Name\":\"Dev\",\"Alias\":\"Dev Channel\",\"Description\":\"%cdevdesc%\",\"ContentType\":\"Mainline\",\"Branch\":\"Dev\",\"Ring\":\"External\",\"IsRecommended\":false,\"RecommendedOnly\":false,\"IsValid\":%actived%,\"Title\":\"Dev\",\"Warning\":\"%cdevwar%\"},{\"Name\":\"Beta\",\"Alias\":\"Beta Channel (Recommended)\",\"Description\":\"%cbetadesc%\",\"ContentType\":\"Mainline\",\"Branch\":\"Beta\",\"Ring\":\"External\",\"IsRecommended\":true,\"RecommendedOnly\":false,\"IsValid\":%activeb%,\"Title\":\"Beta\",\"Warning\":\"\"},{\"Name\":\"ReleasePreview\",\"Alias\":\"Release Preview Channel\",\"Description\":\"%crpdesk%\",\"ContentType\":\"Mainline\",\"Branch\":\"ReleasePreview\",\"Ring\":\"External\",\"IsRecommended\":false,\"RecommendedOnly\":false,\"IsValid\":%activerp%,\"Title\":\"Release Preview\",\"Warning\":\"\"}]}"
reg add "%WSH%\UI\Strings" /f /t REG_SZ /v "AccountText" /d "{\"Description\":\"%acdesc%\",\"Title\":\"%actitle%\",\"ButtonTitle\":\"%acbutton%\"}"
reg add "%WSH%\UI\Strings" /f /t REG_SZ /v "DeviceStatusBarText" /d "{\"Subtitle\":\"%dsdesk%\",\"LinkTitle\":\"%dsltitle%\",\"LinkUrl\":\"https://aka.ms/%Channel%Latest\",\"ButtonUrl\":\"ms-settings:about\",\"Status\":1,\"Title\":\"%dstitle%\",\"ButtonTitle\":\"%dsbutton%\"}"
reg add "%WSH%\UI\Strings" /f /t REG_SZ /v "ConfigurationExpanderText_Rejuv" /d "{\"Title\":\"%conftitle%\",\"RelatedLinkText\":\"%confrlink%\",\"RelatedLinkUrl\":\"https://github.com/nondetect/ORM-Insider/releases\"}"
reg add "%WSH%\UI\Strings" /f /t REG_SZ /v "UnenrollText_Rejuv" /d "{\"Status\":\"\",\"ToggleTitle\":\"%unrtogtitle%\",\"ToggleDescription\":\"%unrtogdesk%\",\"LinkTitle\":\"%unrlinktitle%\",\"LinkDescription\":\"%unrlinkdesk%\",\"LinkUrl\":\"https://go.microsoft.com/fwlink/?linkid=2136438\",\"Title\":\"%unrtitle%\",\"RelatedLinkText\":\"%unrreltext%\",\"RelatedLinkUrl\":\"https://insider.windows.com/leave-program\"}"
reg add "%WSH%\UI\Strings" /f /t REG_SZ /v StickyXaml /d "<StackPanel xmlns="^""http://schemas.microsoft.com/winfx/2006/xaml/presentation"^""><TextBlock Margin="^""0,10,0,0"^"" Style="^""{StaticResource BodyTextBlockStyle}"^"">%mdesc% v%scriptver%. %confrlink%. <Hyperlink NavigateUri="^""https://github.com/nondetect/ORM-Insider/releases"^"" TextDecorations="^""None"^"">%lm%</Hyperlink></TextBlock><TextBlock Margin="^""0,10,0,5"^"" Style="^""{StaticResource SubtitleTextBlockStyle}"^""><Run FontFamily="^""Segoe MDL2 Assets"^"">&#xECA7;</Run> <Span FontWeight="^""SemiBold"^"">%aco%</Span></TextBlock><TextBlock Style="^""{StaticResource BodyTextBlockStyle }"^""><Span FontWeight="^""SemiBold"^"">%Fancy%</Span></TextBlock><TextBlock Text="^""Channel: %Channel%"^"" Style="^""{StaticResource BodyTextBlockStyle }"^"" /><TextBlock Text="^""Content: %Content%"^"" Style="^""{StaticResource BodyTextBlockStyle }"^"" /><TextBlock Margin="^""0,10,0,0"^"" Style="^""{StaticResource SubtitleTextBlockStyle}"^""><Run FontFamily="^""Segoe MDL2 Assets"^"">&#xE9D9;</Run> <Span FontWeight="^""SemiBold"^"">%mnottitle%</Span></TextBlock><TextBlock Style="^""{StaticResource BodyTextBlockStyle }"^"">%mnotdesk1% <Span FontWeight="^""SemiBold"^"">%mnotdesk2%</Span>%mnotdesk3% <Span FontWeight="^""SemiBold"^"">%mnotdesk4%</Span>.</TextBlock><Button Command="^""{StaticResource ActivateUriCommand}"^"" CommandParameter="^""ms-settings:privacy-feedback"^"" Margin="^""0,10,0,20"^""><TextBlock Margin="^""5,0,5,0"^"">%mnotdesk4%</TextBlock></Button></StackPanel>"
chcp 1251 >nul
(
echo Windows Registry Editor Version 5.00
echo.
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\UI\Strings]
echo "StickyMessage"="{\"Message\":\"%mtitle%\",\"LinkTitle\":\"%lm%\",\"LinkUrl\":\"https://github.com/nondetect/ORM-Insider/blob/master/readme.md\",\"DynamicXaml\":\"^<StackPanel xmlns=\\\"http://schemas.microsoft.com/winfx/2006/xaml/presentation\\\"^>^<TextBlock Margin=\\\"0,-25,0,10\\\" Style=\\\"{StaticResource BodyTextBlockStyle }\\\"^>%mdesc% v%scriptver%.^</TextBlock^>^<TextBlock Style=\\\"{StaticResource SubtitleTextBlockStyle }\\\" ^>^<Run FontFamily=\\\"Segoe Fluent Icons\\\"^>^&#xE9D9;^</Run^> ^<Span FontWeight=\\\"SemiBold\\\"^>%mnottitle%^</Span^>^</TextBlock^>^<TextBlock Style=\\\"{StaticResource BodyTextBlockStyle }\\\"^>%mnotdesk1% ^<Span FontWeight=\\\"SemiBold\\\"^>%mnotdesk2%^</Span^>%mnotdesk3% ^<Span FontWeight=\\\"SemiBold\\\"^>%mnotdesk4%^</Span^>.^</TextBlock^>^<Button Command=\\\"{StaticResource ActivateUriCommand}\\\" CommandParameter=\\\"ms-settings:privacy-feedback\\\" Margin=\\\"0,10,0,0\\\"^>^<TextBlock Margin=\\\"5,0,5,0\\\"^>%mnotdesk4%^</TextBlock^>^</Button^>^</StackPanel^>\",\"Severity\":0}"
echo.
)>"%Temp%\oie.reg"
regedit /s "%Temp%\oie.reg"
del /f /q "%Temp%\oie.reg"
goto :EOF

:SKIP_CHECK
cls
echo.
echo:$_Paste_in_Powershell = { $Code = @'
echo: $Nfo = 'Skip TPM Check on Dynamic Update v7, AveYo 2021'
echo: $Arg = (([environment]::get_CommandLine()-split'-[-]%% ')[1]-split'.exe[\p{P}]? ')[1]
echo: foreach ($x in 'Product','DynamicUpdate','Telemetry') {$Arg = $Arg -replace $('\p{P}?/'+ $x +'\p{P}? \p{P}?[A-Z]+\p{P}? '),' '}
echo: $Cli = ' /DynamicUpdate Disable /Telemetry Disable ' + $Arg; $Srv = ' /Product Server' + $Cli
echo: $Dir = join-path $([Environment]::SystemDirectory[0..2]-join'') '$WINDOWS.~BT\Sources\'
echo: $Cfg = join-path $Dir 'EI.cfg'; $EI = '[Channel]' +[char]13+[char]10+ '_Default' +[char]13+[char]10
echo: $Exe = join-path $Dir 'SetupHost.exe'; $Inf = get-item -force -lit $Exe; [int]$Ver = $Inf.VersionInfo.FileBuildPart
echo: if ($Ver -ge 22000) {$Run = $Exe + $Srv} else {$Run = $Exe + $Cli}
echo: if ($Ver -ge 22000 -and !(test-path $Cfg)) {[io.file]::WriteAllText($Cfg, $EI)}
echo: $D=@(); $T=@(); $A=@(); $M=[AppDomain]::CurrentDomain.DefineDynamicAssembly(1,1).DefineDynamicModule(1) 
echo: foreach ($x in 0..2) {$D+=$M.DefineType('AveYo_'+$x,1179913,[ValueType])}; foreach ($x in 1..2) {$D+=$D[$x].MakeByRefType()}
echo: $S=[string]; $I=[int32]; $U=[uintptr]; $y=0; $z=0;  foreach ($x in $U,$U,$I,$I) {$9=$D[2].DefineField('f'+$y++,$x,6)}
echo: foreach ($x in $I,$S,$S,$S,$I,$I,$I,$I,$I,$I,$I,$I,[int16],[int16],$U,$U,$U,$U) {$9=$D[1].DefineField('f'+$z++,$x,6)}
echo: $9=$D[0].DefinePInvokeMethod('CreateProcess','kernel32',8214,1,[void],($S,$S,$I,$I,[bool],$I,$I,$S,$D[3],$D[4]),1,4)
echo: $9=$D[0].DefinePInvokeMethod('DebugActiveProcessStop','kernel32',8214,1,[void],($I),1,4)
echo: foreach ($x in 0..2) {$T+=$D[$x].CreateType()}; foreach ($x in 1..2) {$A+=[Activator]::CreateInstance($T[$x])}
echo: $R=$null, $Run, $null, $null, $false, 0x02000011, $null, $null, $A[0], $A[1] 
echo: $T[0].GetMethod('CreateProcess').invoke(0, $R); $T[0].GetMethod('DebugActiveProcessStop').invoke(0, $R[9].f2)
echo: $W=get-process -pid $R[9].f2 -ea 0; for (;;) {sleep 1; if (0-eq $R[9].f2 -or $null-eq $W -or $W.HasExited) {return} }
echo:'@ -replace '\r?\n^|\r', '; ' 
echo: $IFEO = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SetupHost.exe'
echo: $Prog = join-path $([Environment]::SystemDirectory[0..2] -join '') '$WINDOWS.~BT\Sources\SetupHost.exe'
echo: $Skip = ^"powershell -win 1 -nop -c iex (get-itemproperty '$IFEO\0' 'Code' -ea 0).Code; write-host --%%^"
echo: if (test-path ^"$IFEO\0^") {
echo:    write-host -fore 0xf -back 0x4 ^"`n Skip TPM Check on Dynamic Update v7 already [INSTALLED]^"  
echo: } else {                              
echo:   new-item ^"$IFEO\0^" -force -ea 0 ^>'' 
echo:   set-itemproperty ^"$IFEO\0^" 'Debugger' $Skip -force -ea 0; set-itemproperty ^"$IFEO\0^" 'Code' $Code -force -ea 0
echo:   set-itemproperty ^"$IFEO\0^" 'FilterFullPath' $Prog -force -ea 0; set-itemproperty $IFEO 'UseFilter' 1 -type dword -force -ea 0
echo:   write-host -fore 0xf -back 0x2 ^"`n Skip TPM Check on Dynamic Update v7 [INSTALLED]^" } 
echo: remove-item $($IFEO -replace 'SetupHost', 'vdsldr') -rec -force -ea 0 ^>''; rmdir (split-path $Prog) -rec -force -ea 0 ^>''
echo: $N = 'Skip TPM Check on Dynamic Update'
echo: $U = 'root\subscription'; $C = gwmi -Class CommandLineEventConsumer -Namespace $U -Filter ^"Name='$N'^" -ea 0 
echo: $B = gwmi -Class __FilterToConsumerBinding -Namespace $U -Filter ^"Filter = ^"^"__eventfilter.name='$N'^"^"^" -ea 0
echo: $F = gwmi -Class __EventFilter -NameSpace $U -Filter ^"Name='$N'^" -ea 0; $B,$C,$F ^|%% {$_^|rwmi -ea 0}; timeout /t 2
echo:} ; start -verb runas powershell -args ^"-nop -c ^& {`n`n$($_Paste_in_Powershell-replace'^"','\^"')}^"
goto :EOF

:REMOVE_SKIP_CHECK
cls
echo.
echo:$_Paste_in_Powershell = { $Code = @'
echo: $Nfo = 'Skip TPM Check on Dynamic Update v7, AveYo 2021'
echo:'@ -replace '\r?\n^|\r', '; ' 
echo: $IFEO = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SetupHost.exe'
echo: $Prog = join-path $([Environment]::SystemDirectory[0..2] -join '') '$WINDOWS.~BT\Sources\SetupHost.exe'
echo: $Skip = ^"powershell -win 1 -nop -c iex (get-itemproperty '$IFEO\0' 'Code' -ea 0).Code; write-host --%%^"
echo: if (test-path ^"$IFEO\0^") {
echo:   remove-item $IFEO -rec -force -ea 0 ^>''
echo:   write-host -fore 0xf -back 0xd ^"`n Skip TPM Check on Dynamic Update v7 [REMOVED]^" 
echo: } else {                              
echo:    write-host -fore 0xf -back 0x4 ^"`n Skip TPM Check on Dynamic Update v7 already [REMOVED]^"  } 
echo: remove-item $($IFEO -replace 'SetupHost', 'vdsldr') -rec -force -ea 0 ^>''; rmdir (split-path $Prog) -rec -force -ea 0 ^>''
echo: $N = 'Skip TPM Check on Dynamic Update'
echo: $U = 'root\subscription'; $C = gwmi -Class CommandLineEventConsumer -Namespace $U -Filter ^"Name='$N'^" -ea 0 
echo: $B = gwmi -Class __FilterToConsumerBinding -Namespace $U -Filter ^"Filter = ^"^"__eventfilter.name='$N'^"^"^" -ea 0
echo: $F = gwmi -Class __EventFilter -NameSpace $U -Filter ^"Name='$N'^" -ea 0; $B,$C,$F ^|%% {$_^|rwmi -ea 0}; timeout /t 2
echo:} ; start -verb runas powershell -args ^"-nop -c ^& {`n`n$($_Paste_in_Powershell-replace'^"','\^"')}^"
goto :EOF


:EX_SKIP_CHECK
echo.%agrs%
echo.%agre%
echo.%apc%
call :SKIP_CHECK >%temp%\oie.ps1 
powershell -command " & { Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force; %temp%\oie.ps1 }"
del /f /q "%temp%\oie.ps1"
echo.%agre%
echo.%apd%
if %FlightSigningEnabled% neq 1 goto :ASK_FOR_REBOOT
echo.%agrs%
echo.%agre%
echo.%pte%
echo.%agrs%
pause > nul
goto :EOF

:EX_REMOVE_SKIP_CHECK
echo.%agrs%
echo.%agre%
echo.%apc%
call :REMOVE_SKIP_CHECK >%temp%\oie.ps1
powershell -command " & { Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force; %temp%\oie.ps1 }"
del /f /q "%temp%\oie.ps1"
if %FlightSigningEnabled% neq 0 goto :ASK_FOR_REBOOT
echo.%agre%
echo.%apd%
echo.%agrs%
echo.%agre%
echo.%pte%
echo.%agrs%
pause > nul
goto :EOF

:ENROLL
echo.%agrs%
echo.%agre%
echo.%apc%
call :RESET_INSIDER_CONFIG 1>NUL 2>NUL
call :ADD_INSIDER_CONFIG 1>NUL 2>NUL
bcdedit /set {current} flightsigning yes >nul 2>&1
echo.%agre%
echo.%apd%
if %FlightSigningEnabled% neq 1 goto :ASK_FOR_REBOOT
echo.%agrs%
echo.%agre%
echo.%pte%
echo.%agrs%
pause >nul
exit

:ENROLL_SKIP_CHECK
call :RESET_INSIDER_CONFIG 1>NUL 2>NUL
call :ADD_INSIDER_CONFIG 1>NUL 2>NUL
bcdedit /set {current} flightsigning yes >nul 2>&1
goto :EX_SKIP_CHECK


:STOP_INSIDER
call :RESET_INSIDER_CONFIG 1>nul 2>nul
bcdedit /deletevalue {current} flightsigning >nul 2>&1
goto :EX_REMOVE_SKIP_CHECK


:ASK_FOR_REBOOT
echo.%agrs%
echo.%agre%
echo.%rtitle%
echo.%rdesk%
echo.%agrs%
echo.%agre%
echo.%me%%m7%
echo.%agre%
echo.%me%%m8%
echo.%agrs%
echo.%agre%
choice /C:12 /N /M "%mch% [1,2] : "
if errorlevel 2 exit
if errorlevel 1 ( shutdown -r -t 0 )

:RU_LOCALE
set "chadmin=^|                      Необходимо запускать от имени Администратора                      ^|"
set "chbuild=^|       Для работы скрипта необходима версия Windows 10 v1809 сборка %defbuild% или выше      ^|"
set "m1=Перейти на"
set "m2=^|                    [4] - Отключить проверку совместимости                              ^|"
set "m3=^|                    [5] - Включить проверку совместимости                               ^|"
set "m4=^|                    [6] - Прекратить получение Инсайдерских сборок                      ^|"
set "m5=^|                    [7] - Выход без внесения изменений                                  ^|"
set "m6=^|                    Отключить проверку совместимости?                                   ^|"
set "m7=1] - Да                                                            ^|"
set "m8=2] - Нет                                                           ^|"
set "mch=| Введите свой выбор"
set "apc=^|                    Применение изменений...                                             ^|"
set "apd=^|                    Готово                                                              ^|"
set "pte=^| Нажмите любую кнопку для выхода                                                        ^|"
set "rtitle=^|                 Необходима перезагрузка чтобы изменения вступили в силу                ^|"
set "rdesk=^|                        Хотите перезагрузить компьютер сейчас?                          ^|"
set "actitle=Учетная запись участника программы предварительной оценки Windows"
set "acdesc=Нет привязанной учётной записи"
set "acbutton=Изменить"
set "cdevdesc=Идеально подходит для технически подкованных пользователей. Первыми получайте доступ к новейшим сборкам Windows 11 на самом раннем этапе цикла разработки с новейшим кодом. Вы заметите некоторые шероховатости и низкую стабильность."
set "cdevwar=Мы рекомендуем Dev Channel только в том случае, если вы активно выполняете резервное копирование данных и вам комфортно выполнять чистую установку Windows. Этот канал получает сборки, которые имеют некоторые шероховатости и могут быть нестабильными. После установки сборки из Dev Channel единственный способ перейти на другой канал или отменить регистрацию этого устройства - это выполнить чистую установку Windows. Вам нужно будет вручную создать резервную копию и восстановить все данные, которые вы хотите сохранить."
set "cbetadesc=Идеально подходит для ранних последователей. Эти сборки Windows 11 более надежны, чем сборки из канала Dev, благодаря обновлениям, проверяемым корпорацией Microsoft. Ваш отзыв оказывает значительное воздействие."
set "crpdesk=Идеально подходит, если вы хотите ознакомиться с исправлениями и некоторыми ключевыми функциями, а также получить возможность доступа к следующей версии Windows, прежде чем она станет общедоступной для всего мира. Этот канал также рекомендуется для коммерческих пользователей."
set "dstitle=На вашем устройстве установлена новейшая версия сборки"
set "dsdesk=Информация о текущей версии доступна в разделе Система - О системе"
set "dsltitle=Последние изменения в сборке"
set "dsbutton=О системе"
set "conftitle=Посмотреть текущие параметры программы предварительной оценки"
set "confrlink=Если хотите изменить настройки Windows Insider или прекратить участие, пожалуйста используйте скрипт"
set "lm=Узнать больше"
set "mtitle=Устройство зарегистрировано с помощью ORM-Insider"
set "mdesc=Это устройство было зарегистрировано в программе предварительной оценки Windows с помощью ORM-Insider"
set "aco=Выбранные настройки"
set "mnottitle=Уведомление о настройках телеметрии"
set "mnotdesk1=Программа предварительной оценки Windows требует, чтобы в настройках сбора диагностических данных была включена"
set "mnotdesk2=Отправка необязательных диагностических данных"
set "mnotdesk3=. Вы можете проверить или изменить свои текущие настройки в"
set "mnotdesk4=Диагностика и Отзывы"
set "unrtitle=Прекратить получение предварительных сборок"
set "unrtogtitle=Отменить регистрацию этого устройства после выхода следующей версии Windows"
set "unrtogdesk=Доступно для каналов бета-версии и предварительного выпуска. Включите этот параметр, чтобы прекратить получение предварительных сборок после запуска следующего общедоступного основного выпуска Windows. До этого момента ваше устройство будет получать сборки для предварительной оценки, чтобы поддерживать его безопасность. Все ваши приложения, драйверы и параметры будут сохранены даже после того, как вы перестанете получать предварительные сборки."
set "unrlinktitle=Быстрая отмена регистрации устройства"
set "unrlinkdesk=Чтобы прекратить получение сборок Insider Preview на устройстве, выполните чистую установку последней версии Windows. Примечание. При этом будут удалены все ваши данные и установлена свежая копия Windows."
set "unrreltext=Выход из программы предварительной оценки Windows"
set "agrt=                           Соглашение об использовании ORM Insider"                                 
set "agr1=^|               Применяя скрипт ORM Insider Вы понимаете все риски и любые               ^|"
set "agr2=^|       повреждения вашего компьютера из-за отсутствия совместимости не покрываются      ^|"
set "agr3=^|         гарантией производителя или авторами данного скрипта. Детали по ссылке:        ^|"
set "agr4=^|         Выбрав Принять, вы подтверждаете, что прочитали и поняли это соглашение.       ^|"
set "agr5=^|                [1] Принять                                                             ^|"
set "agr6=^|                [2] Отказаться                                                          ^|"
goto :CHECK_BUILD

:EN_LOCALE
set "chadmin=^|                   This script needs to be executed as an Administrator.                ^|"
set "chbuild=^|      This script is compatible only with Windows 10 v1809 build %defbuild% and later.       ^|"
set "m1=Enroll to"
set "m2=^|                    [4] - Disable compatibility check                                   ^|"
set "m3=^|                    [5] - Enable compatibility check                                    ^|"
set "m4=^|                    [6] - Stop receiving Insider Preview builds                         ^|"
set "m5=^|                    [7] - Quit without making any changes                               ^|"
set "m6=^|                    Disable compatibility check?                                        ^|"
set "m7=1] - Yes                                                           ^|"
set "m8=2] - No                                                            ^|"
set "mch=| Enter Your Choice"
set "apc=^|                    Applying changes...                                                 ^|"
set "apd=^|                    Done                                                                ^|"
set "pte=^| Press any key to exit.                                                                 ^|"
set "rtitle=^|                     A reboot is required to finish applying changes.                   ^|"
set "rdesk=^|                         Do you want restart your computer now?                         ^|"
set "actitle=Windows Insider account"
set "acdesc=No account linked"
set "acbutton=Edit"
set "cdevdesc=Ideal for highly technical users. Be the first to access the latest Windows 11 builds earliest in the development cycle with the newest code. There will be some rough edges and low stability."
set "cdevwar=We recommend the Dev Channel only if you actively back up your data and are comfortable clean installing Windows. This channel receives builds that may have rough edges or be unstable. Once you install a build from the Dev Channel, the only way to move to another channel or unenroll this device is to clean install Windows. You?ll need to manually back up and restore any data you want to keep."
set "cbetadesc=Ideal for early adopters. These Windows 11 builds will be more reliable than builds from our Dev Channel, with updates validated by Microsoft. Your feedback has the greatest impact here."
set "crpdesk=Ideal if you want to preview fixes and certain key features, plus get optional access to the next version of Windows before it's generally available to the world. This channel is also recommended for commercial users."
set "dstitle=You're on the latest build for your device"
set "dsdesk=Information about the current version is available in the section System - About"
set "dsltitle=Latest build notes"
set "dsbutton=About System"
set "conftitle=Your Insider settings"
set "confrlink=If you want to change settings of the enrollment or stop receiving Insider Preview builds, please use the script."
set "lm=Learn more"
set "mtitle=Device Enrolled using ORM-Insider"
set "mdesc=This device has been enrolled to the Windows Insider program using ORM-Insider"
set "aco=Applied configuration"
set "mnottitle=Telemetry settings notice"
set "mnotdesk1=Windows Insider Program requires diagnostic data collection to be enabled "
set "mnotdesk2=Send optional diagnostic data"
set "mnotdesk3=. You can verify or modify your current settings in "
set "mnotdesk4=Diagnostics and Feedback"
set "unrtitle=Stop getting preview builds"
set "unrtogtitle=Unenroll this device when the next version of Windows releases"
set "unrtogdesk=Available for Beta and Release Preview channels. Turn this on to stop getting preview builds when the next major release of Windows launches to the public. Until then, your device will continue to get Insider builds to keep it secure. You'll keep all your apps, drivers and settings even after you stop getting preview builds."
set "unrlinktitle=Unenroll this device immediately"
set "unrlinkdesk=To stop getting Insider Preview builds on this device, you'll need to clean install the latest release of Windows. Note: This option will erase all your data and install a fresh copy of Windows."
set "unrreltext=Leaving the Insider Program"
set "agrt=                               Agreement of using ORM-Insider"
set "agr1=^|               By using the ORM Insider script, you understand all the risks            ^|"
set "agr2=^|       and any damage to your computer due to lack of compatibility is not covered      ^|"
set "agr3=^|    by the manufacturer's warranty or the authors of this script. Details on the link:  ^|"
set "agr4=^|  By choosing to Accept, you confirm that you have read and understood this agreement.  ^|"
set "agr5=^|                [1] Accept                                                              ^|"
set "agr6=^|                [2] Decline                                                             ^|"
goto :CHECK_BUILD

:AGREEMENT
set "agru=^|              https://github.com/nondetect/ORM-Insider/blob/master/readme.md            ^|"
cls
color c
echo.%agrl%
echo.
echo.%agrt%
echo.
echo.                    %os% %build%
echo.%agrl%
echo.%agre%
echo.%agr1%
echo.%agre%
echo.%agr2%
echo.%agre%
echo.%agr3%
echo.%agre%
echo.%agru%
echo.%agre%
echo.%agrd%
echo.%agre%
echo.%agr4%
echo.%agre%
echo.%agrd%
echo.%agre%
echo.%agr5%
echo.%agre%
echo.%agr6%
echo.%agrs%
echo.%agre%
choice /C:12 /N /M "%mch% [1,2] : "
echo.%agrs%
if errorlevel 2 exit
if errorlevel 1 goto:START_SCRIPT

:LOCALE
set "agrl= ________________________________________________________________________________________"
set "agre=^|                                                                                        ^|"
set "agrs=^|________________________________________________________________________________________^|"
set "agrd=^|========================================================================================^|"
set "me=^|                    ["
set "defbuild=17763"
for /f "tokens=2-8 delims= " %%a in ('powershell -c "(Get-WmiObject -class Win32_OperatingSystem).Caption"') do set "os=%%a %%b %%c %%d %%e %%f"
for /f "tokens=4-5 delims=[]." %%a in ('ver') do set "build=%%a.%%b"
for /f "tokens=1 delims=-" %%l in ('powershell -c "(get-uiculture).name"') do set "lang=%%l"
if /I "%lang%"=="ru"  ( goto :RU_LOCALE ) else ( goto :EN_LOCALE )
