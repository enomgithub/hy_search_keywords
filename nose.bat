@ECHO OFF
SETLOCAL

ECHO Activate venv...
CALL %USERPROFILE%\venv_hy\Scripts\activate.bat

SET THISDIR=%~dp0
SET PYTHONPATH=%THISDIR%\modules;%THISDIR%;%PYTHONPATH%

ECHO PUSHD test
PUSHD test

ECHO python -m nose .
python -m nose .
SET STATE=%ERRORLEVEL%

ECHO POPD
POPD

ECHO Deactivate venv...
CALL %USERPROFILE%\venv_hy\Scripts\deactivate.bat

IF NOT %STATE%==0 (
    ECHO �G���[���������܂����B
    EXIT /b 1
) ELSE (
    ECHO ����I�����܂����B
    EXIT /b 0
)

