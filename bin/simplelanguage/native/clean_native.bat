@echo off

@rem #########################################################################
@rem ## Environment setup

set _EXITCODE=0

call :env
if not %_EXITCODE%==0 goto end

@rem #########################################################################
@rem ## Main

if exist "%_TARGET_DIR%\" ( rmdir /s /q "%_TARGET_DIR%"
) else ( echo Directory %_TARGET_DIR% not found.
)

goto end

@rem #########################################################################
@rem ## Subroutines

:env
set _BASENAME=%~n0
set "_ROOT_DIR=%~dp0"

set "_TARGET_DIR=%_ROOT_DIR%target"
goto :eof

@rem #########################################################################
@rem ## Cleanups

:end
exit /b %_EXITCODE%
