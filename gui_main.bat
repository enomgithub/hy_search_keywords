@ECHO OFF
SETLOCAL

ECHO Activate venv...
CALL %USERPROFILE%\venv_hy_qt\Scripts\activate.bat

hy gui_main.hy %*
SET STATE=%ERRORLEVEL%

ECHO Deactivate venv...
CALL %USERPROFILE%\venv_hy_qt\Scripts\deactivate.bat

IF NOT %STATE%==0 (
    ECHO �G���[���������܂����B
    EXIT /b 1
) ELSE (
    ECHO ����I�����܂����B
    EXIT /b 0
)
