Unicode true
!include LogicLib.nsh
!include FileFunc.nsh
Name "SJ Downloader browser setup"
OutFile "${OUTPUT_FILE}"
RequestExecutionLevel admin
SilentInstall silent
!define EXTENSION_ID "dnolinbkicmedadaigcedkmndcpahmml"
!define UPDATE_URL "https://clients2.google.com/service/update2/crx"
!define OWNERS "Software\SJDownloader\BrowserSetupOwners"
Var owner

!macro registerBrowser ROOT
  ; Remove legacy third-party web store extension references to ensure SJ Downloader is used
  DeleteRegValue HKLM "${ROOT}\${EXTENSION_ID}" "update_url"
  DeleteRegValue HKLM "${ROOT}\${EXTENSION_ID}" "SJDownloaderOwned"
  DeleteRegKey /ifempty HKLM "${ROOT}\${EXTENSION_ID}"
  DeleteRegValue HKCU "${ROOT}\${EXTENSION_ID}" "update_url"
  DeleteRegValue HKCU "${ROOT}\${EXTENSION_ID}" "SJDownloaderOwned"
  DeleteRegKey /ifempty HKCU "${ROOT}\${EXTENSION_ID}"
!macroend

!macro unregisterBrowser ROOT
  DeleteRegValue HKLM "${ROOT}\${EXTENSION_ID}" "update_url"
  DeleteRegValue HKLM "${ROOT}\${EXTENSION_ID}" "SJDownloaderOwned"
  DeleteRegKey /ifempty HKLM "${ROOT}\${EXTENSION_ID}"
  DeleteRegValue HKCU "${ROOT}\${EXTENSION_ID}" "update_url"
  DeleteRegValue HKCU "${ROOT}\${EXTENSION_ID}" "SJDownloaderOwned"
  DeleteRegKey /ifempty HKCU "${ROOT}\${EXTENSION_ID}"
!macroend

Section
  SetRegView 32
  ${GetParameters} $0
  ClearErrors
  ${GetOptions} $0 "/owner=" $owner
  ${If} ${Errors}
  ${OrIf} $owner == ""
    SetErrorLevel 2
    Quit
  ${EndIf}
  ClearErrors
  ${GetOptions} $0 "/remove" $3
  ${IfNot} ${Errors}
    DeleteRegValue HKLM "${OWNERS}" "$owner"
    EnumRegValue $1 HKLM "${OWNERS}" 0
    ${If} $1 == ""
      !insertmacro unregisterBrowser "Software\Google\Chrome\Extensions"
      !insertmacro unregisterBrowser "Software\Microsoft\Edge\Extensions"
      DeleteRegKey /ifempty HKLM "${OWNERS}"
    ${EndIf}
  ${Else}
    ClearErrors
    WriteRegDWORD HKLM "${OWNERS}" "$owner" 1
    ${If} ${Errors}
      SetErrorLevel 1
      Quit
    ${EndIf}
    !insertmacro registerBrowser "Software\Google\Chrome\Extensions"
    !insertmacro registerBrowser "Software\Microsoft\Edge\Extensions"
  ${EndIf}
  SetErrorLevel 0
SectionEnd
