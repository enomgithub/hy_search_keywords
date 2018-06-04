@ECHO OFF
SETLOCAL

ECHO Activate venv...
CALL %USERPROFILE%\venv_hy\Scripts\activate.bat

hy search_keywords.hy %*
SET STATE=%ERRORLEVEL%

ECHO Deactivate venv...
CALL %USERPROFILE%\venv_hy\Scripts\deactivate.bat

IF NOT %STATE%==0 (
    ECHO �G���[���������܂����B
    EXIT /b 1
) ELSE (
    ECHO ����I�����܂����B
    EXIT /b 0
)
