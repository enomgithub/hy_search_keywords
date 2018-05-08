@ECHO OFF
SETLOCAL

ECHO Activate venv...
CALL %USERPROFILE%\venv_hy\Scripts\activate.bat

SET THISDIR=%~dp0
SET PYTHONPATH=%THISDIR%\modules;%PYTHONPATH%

hy search_keywords.hy %*
IF NOT %ERRORLEVEL%==0 (
    ECHO �G���[���������܂����B
) ELSE (
    ECHO ����I�����܂����B
)

ECHO Deactivate venv...
CALL %USERPROFILE%\venv_hy\Scripts\deactivate.bat