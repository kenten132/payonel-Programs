SET target_prefix=D:\gitrepos\OCEmu\extras\cmd
SET CP=C:\Windows\System32\xcopy.exe

FOR /F "tokens=*" %%a in (%target_prefix%\instances.txt) do (
  %CP% /s /v /y /EXCLUDE:xcopy-excludes.txt OpenOS %target_prefix%\%%a
  %CP% /s /v /y payo-bash %target_prefix%\%%a
  %CP% /s /v /y payo-lib %target_prefix%\%%a
  %CP% /s /v /y payo-persistent-links %target_prefix%\%%a
  %CP% /s /v /y payo-tests %target_prefix%\%%a
  %CP% /s /v /y popm %target_prefix%\%%a
  %CP% /s /v /y psh %target_prefix%\%%a
)
