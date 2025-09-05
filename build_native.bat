@echo off
echo Building C++ Corner Detector Library...

REM Create build directory
if not exist "build" mkdir build
cd build

REM Configure with CMake
cmake -G "Visual Studio 16 2019" -A x64 ..\native
if %ERRORLEVEL% neq 0 (
    echo CMake configuration failed!
    pause
    exit /b 1
)

REM Build the project
cmake --build . --config Release
if %ERRORLEVEL% neq 0 (
    echo Build failed!
    pause
    exit /b 1
)

REM Copy the library to the Flutter project
copy "Release\corner_detector.dll" "..\windows\runner\Release\"
copy "Release\corner_detector.dll" "..\windows\runner\Debug\"

echo Build completed successfully!
echo Library copied to Flutter project.
pause


