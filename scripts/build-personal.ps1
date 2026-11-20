param([switch]$PolicyTestOnly, [switch]$TestSuiteOnly)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
Push-Location $root
try {
    $vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
    $vs = & $vswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    if (-not $vs) { throw 'Microsoft C++ Build Tools with x64 compiler are required.' }
    $devcmd = Join-Path $vs 'Common7\Tools\VsDevCmd.bat'
    $environment = & $env:ComSpec /d /c "call `"$devcmd`" -no_logo -arch=x64 -host_arch=x64 >nul && set"
    if ($LASTEXITCODE) { throw 'Could not initialize Microsoft C++ environment.' }
    foreach ($line in $environment) {
        if ($line -match '^([^=]+)=(.*)$') { [Environment]::SetEnvironmentVariable($matches[1], $matches[2], 'Process') }
    }
    New-Item -ItemType Directory -Force build/personal | Out-Null
    $common = @('/nologo', '/std:c++17', '/EHsc', '/utf-8', '/MT', '/O1', '/Gy', '/Zc:inline', '/DNOMINMAX', '/DUNICODE', '/D_UNICODE', '/D_WIN32_WINNT=0x0A00', '/DWINVER=0x0A00', '/DWB_PERSONAL_BUILD=1')
    & "$PSScriptRoot/generate-version.ps1" -Version '1.1.0' -Channel stable
    $policyFailed = $false
    foreach ($test in 'personal_version_test', 'personal_report_test', 'personal_helper_test', 'personal_updater_test') {
        $support = @(if ($test -eq 'personal_report_test') { 'src/hid.cpp'; 'src/i18n.cpp' } elseif ($test -eq 'personal_helper_test') { 'src/hid.cpp' } elseif ($test -eq 'personal_updater_test') { 'src/update_core.cpp'; 'src/update_signature.cpp'; 'src/i18n.cpp' })
        & cl.exe @common "tests/$test.cpp" @support /Fobuild/personal/ "/Febuild/personal/$test.exe" /link /OPT:REF user32.lib winhttp.lib gdi32.lib advapi32.lib comctl32.lib setupapi.lib hid.lib shell32.lib bcrypt.lib version.lib ole32.lib
        if ($LASTEXITCODE) { throw "Policy test compilation failed: $test" }
        & "./build/personal/$test.exe"
        if ($LASTEXITCODE) { $policyFailed = $true }
    }
    if ($policyFailed) { throw 'Personal policy regression tests failed.' }
    if ($PolicyTestOnly) { return }
    if ($TestSuiteOnly) {
        $cases = @(
            @{ Name='device_aliases'; Sources=@('tests/device_aliases_test.cpp') },
            @{ Name='alerts'; Sources=@('tests/alert_rules_test.cpp') },
            @{ Name='history'; Sources=@('tests/history_model_test.cpp') },
            @{ Name='runtime_estimate'; Sources=@('tests/runtime_estimate_test.cpp') },
            @{ Name='json_output'; Sources=@('tests/json_output_test.cpp') },
            @{ Name='labels'; Sources=@('tests/labels_test.cpp','src/labels.cpp') },
            @{ Name='brands'; Sources=@('tests/brands_test.cpp','src/brands.cpp') },
            @{ Name='update_core'; Sources=@('tests/update_core_test.cpp','src/update_core.cpp') },
            @{ Name='update_signature'; Sources=@('tests/update_signature_test.cpp','src/update_signature.cpp') },
            @{ Name='hyperx_haste'; Sources=@('tests/hyperx_haste_driver_test.cpp','src/drivers/hyperx.cpp') },
            @{ Name='hyperx_flight_s'; Sources=@('tests/hyperx_cloud_flight_s_driver_test.cpp','src/drivers/hyperx.cpp') },
            @{ Name='hyperx_stinger'; Sources=@('tests/hyperx_stinger_driver_test.cpp','src/drivers/hyperx.cpp') }
        )
        foreach ($case in $cases) {
            $directory = "build/personal/tests/$($case.Name)"
            New-Item -ItemType Directory -Force $directory | Out-Null
            $testSources = $case.Sources
            & cl.exe @common @testSources "/Fo$directory/" "/Fe$directory/test.exe" /link bcrypt.lib
            if ($LASTEXITCODE) { throw "Test compilation failed: $($case.Name)" }
            & "./$directory/test.exe"
            if ($LASTEXITCODE) { throw "Test failed: $($case.Name)" }
            Write-Output "PASS: $($case.Name)"
        }
        foreach ($argument in '--report', '--apply-update') {
            $process = Start-Process -FilePath (Join-Path $root 'build/personal/BatteryHub.exe') -ArgumentList $argument -WindowStyle Hidden -PassThru
            if (-not $process.WaitForExit(5000)) {
                $process.Kill()
                throw "Disabled command hung: $argument"
            }
            if ($process.ExitCode -ne 2) { throw "Disabled command did not return code 2: $argument" }
            Write-Output "PASS: $argument exits promptly with code 2"
        }
        return
    }
    & "$PSScriptRoot/generate-version.ps1" -Version '1.1.0' -Channel dev
    # Microsoft's resource compiler requires the generated header to end with a newline.
    [IO.File]::AppendAllText((Join-Path $root 'build/version.h'), "`r`n")
    $languages = foreach ($file in Get-ChildItem lang/*.txt | Sort-Object Name) {
        "@file $($file.BaseName)"
        [IO.File]::ReadAllText($file.FullName)
        ''
    }
    [IO.File]::WriteAllText((Join-Path $root 'build/languages.txt'), ($languages -join "`n"), [Text.UTF8Encoding]::new($false))
    & rc.exe /nologo /I res /I build /fo build/personal/app.res res/app.rc
    if ($LASTEXITCODE) { throw 'Resource compilation failed.' }
    $sources = @(Get-ChildItem src/*.cpp, src/drivers/*.cpp | ForEach-Object { $_.FullName })
    $libs = @('hid.lib', 'setupapi.lib', 'cfgmgr32.lib', 'ole32.lib', 'oleaut32.lib', 'comctl32.lib', 'gdi32.lib', 'runtimeobject.lib', 'ws2_32.lib', 'winhttp.lib', 'bcrypt.lib', 'version.lib', 'bthprops.lib', 'bluetoothapis.lib', 'user32.lib', 'advapi32.lib', 'shell32.lib')
    & cl.exe @common @sources /Fobuild/personal/ /Febuild/personal/BatteryHub.exe /link /SUBSYSTEM:WINDOWS /OPT:REF /OPT:ICF build/personal/app.res @libs
    if ($LASTEXITCODE) { throw 'Application compilation failed.' }
    Get-FileHash build/personal/BatteryHub.exe -Algorithm SHA256
} finally { Pop-Location }
