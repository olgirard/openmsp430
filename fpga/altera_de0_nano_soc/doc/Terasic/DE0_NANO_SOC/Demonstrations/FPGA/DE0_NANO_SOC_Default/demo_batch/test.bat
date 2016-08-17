@echo off
 @ REM ######################################
 @ REM # Variable to ignore <CR> in DOS
 @ REM # line endings
 @ set SHELLOPTS=igncr
 
@ REM ######################################
 @ REM # Variable to ignore mixed paths
 @ REM # i.e. G:/$SOPC_KIT_NIOS2/bin
 @ set CYGWIN=nodosfilewarning
 

@set QUARTUS_BIN=%QUARTUS_ROOTDIR%\\bin
 @if exist %QUARTUS_BIN%\\quartus_pgm.exe (goto DownLoad)
 
@set QUARTUS_BIN=%QUARTUS_ROOTDIR%\\bin64
 @if exist %QUARTUS_BIN%\\quartus_pgm.exe (goto DownLoad)
 
:: Prepare for future use (if exes are in bin32)
 @set QUARTUS_BIN=%QUARTUS_ROOTDIR%\\bin32
 
:DownLoad
 set project.sof=DE0_NANO_SOC_Default.sof
 set project.jic=DE0_NANO_SOC_Default.jic
 set device_sfl.sof=sfl_enhanced_01_02d010dd.sof
 goto main
 
:main
 echo **********************************
 echo Makesure MSEL[4:0] is set to "10010" 
echo Plesase choose your operation
 echo "1" for programming .sof to FPGA.
 echo "2" for converting .sof to .jic 
echo "3" for programming .jic to EPCS.
 echo "4" for erasing .jic from EPCS.
 echo **********************************
 choice /C 1234 /M "Please enter your choise:" 
if errorlevel 4 goto d 
if errorlevel 3 goto c  
 if errorlevel 2 goto b  
 if errorlevel 1 goto a 


:a
 echo ===========================================================
 echo "Progrming .sof to FPGA"
 echo ===========================================================
 %QUARTUS_BIN%\\quartus_pgm.exe -m jtag -c 1 -o "p;%project.sof%@2"
 @ set SOPC_BUILDER_PATH=%SOPC_KIT_NIOS2%+%SOPC_BUILDER_PATH%
 goto end
 

:b 
echo ===========================================================
 echo "Convert .sof to .jic"
 echo ===========================================================
 %QUARTUS_BIN%\\quartus_cpf -c -d epcs128 -s 5csema4 %project.sof% %project.jic%
 goto end
 
:c
 echo ===========================================================
 echo "Programming EPCS with .jic"
 echo ===========================================================
 %QUARTUS_BIN%\\quartus_pgm.exe -m jtag -c 1 -o "p;%device_sfl.sof%@2"
 %QUARTUS_BIN%\\quartus_pgm.exe -m jtag -c 1 -o "p;%project.jic%@2"
 goto end
 
:d
 echo ===========================================================
 echo "Erasing EPCS with .jic"
 echo ===========================================================
 %QUARTUS_BIN%\\quartus_pgm.exe -m jtag -c 1 -o "p;%device_sfl.sof%@2"
 %QUARTUS_BIN%\\quartus_pgm.exe -m jtag -c 1 -o "r;%project.jic%@2"
 goto end
 
:end
 echo Job Done!!
 goto main
