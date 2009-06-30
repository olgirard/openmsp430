:: generate_exec.bat
:: 
:: Generate the windows executables of the TCL scripts

del               ..\bin\openmsp430-loader.exe
freewrapTCLSH.exe ..\bin\openmsp430-loader.tcl
move              openmsp430-loader.exe ..\bin\

del               ..\bin\openmsp430-minidebug.exe
freewrap.exe      ..\bin\openmsp430-minidebug.tcl
move              openmsp430-minidebug.exe ..\bin\

del               ..\bin\openmsp430-gdbproxy.exe
freewrap.exe      ..\bin\openmsp430-gdbproxy.tcl
move              openmsp430-gdbproxy.exe ..\bin\
