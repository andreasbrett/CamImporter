@echo off

Setlocal EnableDelayedExpansion

set dirRoot=%~f1\
set dirRawCopies=%dirRoot%raw_copies\
set dirPreview=%dirRoot%culling\
set dirImport=%dirRoot%import\

echo ******************************************************************
echo *** Moving files to proper folder
echo ******************************************************************
pushd "%dirPreview%"

	REM ----------------------------------------------------------------------------------------
	REM iterate over all JPG files
	REM  - "RAW+JPG"...
	REM      - JPG ignored
	REM      - RAW moved to %dirImport%
	REM  - "JPG only" moved to %dirImport%
	REM ----------------------------------------------------------------------------------------
	for /f %%f in ('dir *.jpg /b 2^> nul') do (
			
			SET ignore=0
			
			REM any co-existing cr2 files from RAW+JPG are moved to %dirImport%
			if exist "%dirRawCopies%%%~nf.cr2" (
				move "%dirRawCopies%%%~nf.cr2" "%dirImport%" > nul
				SET ignore=1
			)
			
			REM any co-existing raf files from RAW+JPG are moved to %dirImport%
			if exist "%dirRawCopies%%%~nf.raf" (
				move "%dirRawCopies%%%~nf.raf" "%dirImport%" > nul
				move "%dirRawCopies%%%~nf.xmp" "%dirImport%" > nul
				SET ignore=1
			)
			
			REM any co-existing nef files from RAW+JPG are moved to %dirImport%
			if exist "%dirRawCopies%%%~nf.nef" (
				move "%dirRawCopies%%%~nf.nef" "%dirImport%" > nul
				SET ignore=1
			)
			
			REM this is a "JPG only" file, move it to %dirImport%
			if "!ignore!" == "0" (
				move "%%f" "%dirImport%" > nul
			)
	)

	REM ----------------------------------------------------------------------------------------
	REM move remaining RAW files to %dirImport%
	REM ----------------------------------------------------------------------------------------
	for /f %%f in ('dir *.cr2 *.raf *.nef *.xmp /b 2^> nul') do (
		move "%%f" "%dirImport%" > nul
	)

popd

echo.
echo.
echo.
echo ******************************************************************
echo *** Done. Please press "Enter" to start Lightroom
echo ******************************************************************
pause

REM ----------------------------------------------------------------------------------------
REM run Lightroom import dialog
REM ----------------------------------------------------------------------------------------
start "Window Title" "%ProgramFiles%\Adobe\Adobe Lightroom\lightroom.exe" "%dirImport%"
