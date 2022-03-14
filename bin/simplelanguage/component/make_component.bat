@echo off
setlocal enabledelayedexpansion

@rem #########################################################################
@rem ## Environment setup

set _BASENAME=%~n0

set _EXITCODE=0

for %%f in ("%~dp0.") do set "_ROOT_DIR=%%~dpf\"

set "_LANGUAGE_DIR=%_ROOT_DIR%language"
set "_LAUNCHER_DIR=%_ROOT_DIR%launcher"
set "_NATIVE_DIR=%_ROOT_DIR%native"

set _GRAALVM_VERSION=21.2.0

set "_COMPONENT_DIR=%~dp0"

set _ARG_JAVA_VERSION=%~1
if "%_ARG_JAVA_VERSION:~0,3%"=="1.8" (
    set _JRE_DIR=jre\
    set _JAVA_VERSION=8
) else if "%_ARG_JAVA_VERSION:~0,2%"=="11" (
    set _JRE_DIR=
    set _JAVA_VERSION=11
) else (
    echo Unknown Java version: %_ARG_JAVA_VERSION%
    set _EXITCODE=1
    goto end
)
set "_TARGET_DIR=%_COMPONENT_DIR%target"
set "_TEMP_DIR=%_COMPONENT_DIR%temp"
set "_META_INF_DIR=%_TEMP_DIR%\META-INF"
set "_LANGUAGE_PATH=%_TEMP_DIR%\%_JRE_DIR%languages\sl"

set _INCLUDE_SLNATIVE=
if exist "%_NATIVE_DIR%\slnative.exe" (
    set _INCLUDE_SLNATIVE=1
)

if defined JAVA_HOME (
    set "_JAR_CMD=%JAVA_HOME%\bin\jar.exe"
) else if exist "c:\opt\graalvm-ce-%_GRAALVM_VERSION%\" (
    set "_JAR_CMD=c:\opt\graalvm-ce-%_GRAALVM_VERSION%\bin\jar.exe"
) else (
    set _JAR_CMD=jar.exe
)
if not exist "%_JAR_CMD%" (
    echo Error: jar executable not found ^("%_JAR_CMD%"^) 1>&2
    set _EXITCODE=1
    goto end
)

@rem #########################################################################
@rem ## Main

call :rmdir "%_TEMP_DIR%"
if not %_EXITCODE%==0 goto end

call :mkdir "%_LANGUAGE_PATH%"
if not %_EXITCODE%==0 goto end
call :copy_file "%_LANGUAGE_DIR%\target\simplelanguage.jar" "%_LANGUAGE_PATH%\"
if not %_EXITCODE%==0 goto end

call :mkdir "%_LANGUAGE_PATH%\launcher"
if not %_EXITCODE%==0 goto end
call :copy_file "%_LAUNCHER_DIR%\target\sl-launcher.jar" "%_LANGUAGE_PATH%\launcher\"
if not %_EXITCODE%==0 goto end

call :mkdir "%_LANGUAGE_PATH%\bin"
if not %_EXITCODE%==0 goto end
call :copy_file "%_ROOT_DIR%sl.bat" "%_LANGUAGE_PATH%\bin\"
if not %_EXITCODE%==0 goto end

if defined _INCLUDE_SLNATIVE (
    call :copy_file "%_NATIVE_DIR%\slnative.exe" "%_LANGUAGE_PATH%\bin\"
    if not !_EXITCODE!==0 goto end
)

call :mkdir "%_TARGET_DIR%"
if not %_EXITCODE%==0 goto end

call :touch_file "%_LANGUAGE_PATH%\native-image.properties"
if not %_EXITCODE%==0 goto end

call :mkdir "%_META_INF_DIR%"
if not %_EXITCODE%==0 goto end
(
    echo Bundle-Name: Simple Language
    echo Bundle-Symbolic-Name: com.oracle.truffle.sl
    echo Bundle-Version: %_GRAALVM_VERSION%
    echo Bundle-RequireCapability: org.graalvm; filter:="(&(graalvm_version=%_GRAALVM_VERSION%)(os_arch=amd64)(java_version=%_JAVA_VERSION%)"
    echo x-GraalVM-Polyglot-Part: True
) > "%_META_INF_DIR%\MANIFEST.MF"

pushd "%_TEMP_DIR%"
call "%_JAR_CMD%" cfm "%_TARGET_DIR%\sl-component.jar" "%_META_INF_DIR%\MANIFEST.MF" .
if not %ERRORLEVEL%==0 (
    popd
    set _EXITCODE=1
    goto end
)
echo bin\sl.bat = ..\%_JRE_DIR%languages\sl\bin\sl.bat> "%_META_INF_DIR%\symlinks"
if defined _INCLUDE_SLNATIVE (
    echo bin\slnative.exe = ..\%_JRE_DIR%languages\sl\bin\slnative.exe>> "%_META_INF_DIR%\symlinks"
)
call "%_JAR_CMD%" uf "%_TARGET_DIR%\sl-component.jar" "%_META_INF_DIR%\symlinks"
if not %ERRORLEVEL%==0 (
    popd
    set _EXITCODE=1
    goto end
)
(
    echo %_JRE_DIR%languages\sl\bin\sl = rwsrwxr-x
    echo %_JRE_DIR%languages\sl\bin\slnative.exe = rwsrwxr-x
) > "%_META_INF_DIR%\permissions"
call "%_JAR_CMD%" uf "%_TARGET_DIR%\sl-component.jar" "%_META_INF_DIR%\permissions"
if not %ERRORLEVEL%==0 (
    popd
    set _EXITCODE=1
    goto end
)
popd

call :rmdir "%_TEMP_DIR%"
if not %_EXITCODE%==0 goto end

goto end

@rem #########################################################################
@rem ## Subroutines

@rem input parameter: 1=directory path
:mkdir
set "__DIR=%~1"
if exist "%__DIR%" rmdir /s /q "%__DIR%"
mkdir "%__DIR%"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

@rem input parameter: 1=directory path
:rmdir
set "__DIR=%~1"
if not exist "%__DIR%" goto :eof
rmdir /s /q "%__DIR%"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

:copy_file
set "__FILE=%~1"
set "__TARGET_DIR=%~2"
copy /y "%__FILE%" "%__TARGET_DIR%"
if not %ERRORLEVEL%==0 (
    echo Failed to copy file "!__FILE:%_ROOT_DIR%=!" to directory "%__TARGET_DIR%" 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:touch_file
set "__FILE=%~1"
copy /y nul "%__FILE%" 1>NUL
if not %ERRORLEVEL%==0 (
    echo Failed to create file "!__FILE:%_ROOT_DIR%=!" 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

@rem #########################################################################
@rem ## Cleanups

:end
exit /b %_EXITCODE%
endlocal
