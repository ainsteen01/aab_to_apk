@echo off
title AAB to APK Converter by bundletool

:: === CONFIGURATION ===
set AAB_PATH=my_app.aab
set OUTPUT_APKS=my_app.apks
set BUNDLETOOL_JAR=bundletool.jar
set KEYSTORE_PATH=debug.jks
set KEY_ALIAS=debugKey
set KEYSTORE_PASSWORD=123456
set KEY_PASSWORD=123456

:: === CHECK AAB FILE ===
if not exist %AAB_PATH% (
    echo [ERROR] AAB file not found: %AAB_PATH%
    echo Please rename your AAB to "my_app.aab" and place it in this folder.
    pause
    exit /b
)

:: === CHECK bundletool.jar ===
if not exist %BUNDLETOOL_JAR% (
    echo [ERROR] Missing bundletool.jar!
    echo Download it from: https://github.com/google/bundletool/releases
    echo Rename it to "bundletool.jar" and place it in this folder.
    pause
    exit /b
)

:: === CHECK OR CREATE KEYSTORE ===
if exist %KEYSTORE_PATH% (
    echo [INFO] Keystore already exists. Using it.
) else (
    echo [INFO] Generating debug keystore...
    keytool -genkeypair -v -keystore %KEYSTORE_PATH% -alias %KEY_ALIAS% -keyalg RSA -keysize 2048 -validity 10000 -storepass %KEYSTORE_PASSWORD% -keypass %KEY_PASSWORD% -dname "CN=Debug, OU=Dev, O=Company, L=City, S=State, C=US"
)

:: === BUILD UNIVERSAL APK ===
echo [INFO] Building APK using bundletool...
java -jar %BUNDLETOOL_JAR% build-apks ^
  --bundle=%AAB_PATH% ^
  --output=%OUTPUT_APKS% ^
  --mode=universal ^
  --ks=%KEYSTORE_PATH% ^
  --ks-key-alias=%KEY_ALIAS% ^
  --ks-pass=pass:%KEYSTORE_PASSWORD% ^
  --key-pass=pass:%KEY_PASSWORD% ^
  --overwrite 2>bundletool_errors.log

:: === CHECK IF .apks FILE WAS CREATED ===
if not exist %OUTPUT_APKS% (
    echo [ERROR] Failed to generate APKs.
    echo Check bundletool_errors.log for details.
    pause
    exit /b
)

:: === EXTRACT APK ===
echo [INFO] Extracting APK from .apks...
mkdir extracted_apks >nul 2>&1
tar -xf %OUTPUT_APKS% -C extracted_apks

:: === DELETE TEMP .apks FILE ===
echo [INFO] Cleaning up temporary .apks file...
del /f /q %OUTPUT_APKS%

:: === FINAL SUCCESS CHECK ===
if exist extracted_apks\universal\universal.apk (
    echo.
    echo [✅ SUCCESS] universal.apk was created!
    echo Path: extracted_apks\universal\universal.apk
) else (
    echo [⚠️ WARNING] APK may not have been created correctly.
    echo Check bundletool_errors.log for details.
)

pause
