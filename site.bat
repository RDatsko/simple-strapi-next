#!/bin/zsh
@echo off & GOTO Windows
clear

# =====================================
# Files/folders for backups
# =====================================
# Minimal backup
minimal_backup_items=(
  "./backend/src"
  "./backend/package.json"
  "./frontend/src"
  "./frontend/package.json"
)

# Full backup (minimal + extras)
full_backup_items=(
  "${minimal_backup_items[@]}"
)

# Complete backup (full + extras)
complete_backup_items=(
  "./backend"
  "./frontend"
)

NEXTJS_NODE_BIN="/node/mac/20.19.5/bin/"
STRAPI_NODE_BIN="/node/mac/18.20.8/bin/"

# =====================================
# Menu Configuration
# =====================================
main_menu_items=(
  "Backup:Minimal"
  "Backup:Full"
  "Backup:Complete"
  "Restore:Select a restore file"
  "Site Operations:Development"
  "Site Operations:Build"
  "Site Operations:Run"
  "Scripts:Create New Site"
  "Scripts:Install node_modules"
  "Scripts:Exit Script"
)

# =====================================
# Colors (hex)
# =====================================
arrow_hex="#33CCFF"       # sky blue arrow
selected_hex="#FFFFFF"    # white text for selected item
gray_hex="#999999"        # dim gray text for non-selected
title_bg_hex="#999999"    # light aqua background for section title
title_fg_hex="#000000"    # black text for section title

reset_format="\033[0m"

# Convert hex to ANSI truecolor
hex_to_ansi_fg() {
  local hex="$1"
  hex="${hex#"#"}"
  local r=$((16#${hex:0:2}))
  local g=$((16#${hex:2:2}))
  local b=$((16#${hex:4:2}))
  echo "\033[38;2;${r};${g};${b}m"
}

hex_to_ansi_bg() {
  local hex="$1"
  hex="${hex#"#"}"
  local r=$((16#${hex:0:2}))
  local g=$((16#${hex:2:2}))
  local b=$((16#${hex:4:2}))
  echo "\033[48;2;${r};${g};${b}m"
}

# Convert our hex colors
arrow_color=$(hex_to_ansi_fg "$arrow_hex")
selected_color=$(hex_to_ansi_fg "$selected_hex")
gray_color=$(hex_to_ansi_fg "$gray_hex")
title_bg_color=$(hex_to_ansi_bg "$title_bg_hex")
title_fg_color=$(hex_to_ansi_fg "$title_fg_hex")

# =====================================
# Terminal formatting
# =====================================
cursor_hide="\033[?25l"
cursor_show="\033[?25h"

# =====================================
# Draw a fancy section header
# =====================================
draw_section_header() {
  local title1="$1"
  local title2="$2"
  local padded_title1=$(printf " %-24s" "$title1")
  local padded_title2=$(printf " %-24s" "$title2")
  local title1_line="${title_bg_color}${title_fg_color}${padded_title1}${reset_format}"
  local title2_line="${title_bg_color}${title_fg_color}${padded_title2}${reset_format}"
  echo
  echo "$title1_line        $title2_line"
}

draw_section_items() {
  local title1="$1"
  local title2="$3"
  local padded_title1=$(printf " %-22s" "$title1")
  local padded_title2=$(printf " %-22s" "$title2")
  local title1_line="  ${gray_color}$padded_title1${reset_format}"
  local title2_line="  ${gray_color}$padded_title2${reset_format}"
  if (( $2 == selected )); then
    title1_line="${arrow_color}>${reset_format} ${selected_color}$padded_title1${reset_format}"
  else
    title1_line="  ${gray_color}$padded_title1${reset_format}"
  fi
  if (( $4 == selected )); then
    title2_line="${arrow_color}>${reset_format} ${selected_color}$padded_title2${reset_format}"
  else
    title2_line="  ${gray_color}$padded_title2${reset_format}"
  fi
  echo "$title1_line        $title2_line"
}

# =====================================
# Draw the main menu
# =====================================
selected=1

draw_menu() {
  clear
  echo "${selected_color}Please select an operation${reset_format}"
  echo 
  echo -e "${selected_color}Minimal${reset_format} : ${gray_color}backs up only bare minimal 'package.json' and 'src/' folder${reset_format}"
  echo -e "${selected_color}Full${reset_format}    : ${gray_color}backs up the entire folder except for the node_modules${reset_format}"
  echo -e "${selected_color}Complete${reset_format}: ${gray_color}backs up everything in the folders (Long backup: 1+ hr)${reset_format}"
  echo

  draw_section_header "Backup"                    "Site Operations"
  draw_section_items  "Minimal"  "1"              "Development"          "5"
  draw_section_items  "Full"     "2"              "Build for Production" "6"
  draw_section_items  "Complete" "3"              "Run"                  "7"
  draw_section_header "Restore"                   "Scripts"
  draw_section_items  "Select a Restore File" "4" "Create New Site"      "8"
  draw_section_items  ""                      "0" "Install mode_modules" "9"
  draw_section_items  ""                      "0" "Exit Script"          "10"

  echo
  echo
}

# =====================================
# Read key input
# =====================================
read_key() {
  local key rest
  stty -echo -icanon min 1 time 0
  key=$(LC_ALL=C dd bs=1 count=1 2>/dev/null)
  if [[ $key == $'\x1b' ]]; then
    rest=$(LC_ALL=C dd bs=1 count=2 2>/dev/null)
    case "$rest" in
      "[A") echo "up" ;;
      "[B") echo "down" ;;
      "[C") echo "right" ;;
      "[D") echo "left" ;;
      *) echo "" ;;
    esac
  elif [[ $key == "" ]]; then
    echo "enter"
  elif [[ $key == $'\x7f' ]]; then
    echo "backspace"
  fi
  stty sane
}

# =====================================
# Restore menu
# =====================================
restore_menu() {
  local backup_files=(./backups/*.zip)
  if (( ${#backup_files[@]} == 0 )); then
      echo "No backup files found in ./backups/"
      sleep 1
      return
  fi

  local restore_selected=1
  local done=false
  local selected_file=""

  draw_restore_menu() {
    clear
    # draw_section_header "Restore"
    local title="$1"
    local padded_title=$(printf " %-49s" "Restore")
    local title_line="${title_bg_color}${title_fg_color}${padded_title}${reset_format}"
    echo
    echo "$title_line"

    for (( i=1; i<=${#backup_files[@]}; i++ )); do
      local file="${backup_files[i]}"
      local file_name=$(basename "$file")
      if (( i == restore_selected )); then
        echo "${arrow_color}>${reset_format} ${selected_color}$file_name${reset_format}"
      else
        echo "  ${gray_color}$file_name${reset_format}"
      fi
    done
  }

  printf "$cursor_hide"
  while [[ "$done" = false ]]; do
    draw_restore_menu
    key=$(read_key)
    case "$key" in
      up)
        ((restore_selected--))
        ((restore_selected < 1)) && restore_selected=${#backup_files[@]}
        ;;
      down)
        ((restore_selected++))
        ((restore_selected > ${#backup_files[@]})) && restore_selected=1
        ;;
      enter)
        selected_file="${backup_files[restore_selected]}"
        done=true
        ;;
      backspace)
        # Back to main menu
        done=true
        selected_file=""
        ;;
    esac
  done
  printf "$cursor_show"
  clear

  if [[ -n "$selected_file" ]]; then
    echo "${arrow_color}You selected backup:${reset_format} ${selected_color}$selected_file${reset_format}"
    echo
    read -q "confirm?This will delete existing minimal backup files and restore them. Proceed? (y/N) "
    echo
    echo
    if [[ "$confirm" == [Yy] ]]; then
      echo
      echo "Cleaning up existing files..."
      echo
      if [[ "$selected_file" == *"minimal"* ]]; then
        for item in "${minimal_backup_items[@]}"; do
            [[ -e "$item" ]] && rm -rf "$item"
        done
      elif [[ "$selected_file" == *"full"* ]]; then
        for dir in ./backend ./frontend; do
            if [[ -d "$dir" ]]; then
                # Remove all files and directories except node_modules and public
                find "$dir" -mindepth 1 \
                    ! -path "*/node_modules*" \
                    ! -path "*/public*" \
                    -exec rm -rf {} +
            fi
        done
      elif [[ "$selected_file" == *"complete"* ]]; then
          for dir in ./backend ./frontend; do
            if [[ -d "$dir" ]]; then
              find "$dir" -mindepth 1 -print0 | xargs -0 rm -rf
            fi
          done
      else
        backup_type="Unknown"
      fi

      echo "Restoring files from backup..."
      echo
      # Get all files in the zip
      files=()
      while IFS= read -r line; do
          files+=("$line")
      done < <(unzip -Z1 "$selected_file")

      total=${#files[@]}
      count=0
      bar_length=50

      # Extract each file individually with progress bar
      for f in "${files[@]}"; do
          unzip -oq "$selected_file" "$f" >/dev/null 2>&1
          ((count++))
          percent=$((count * 100 / total))
          filled=$((percent * bar_length / 100))
          bar=$(printf "%${filled}s" | tr ' ' '█')
          empty=$(printf "%$((bar_length - filled))s" | tr ' ' '░')
          printf "\r%3d%%  %s%s" "$percent" "$bar" "$empty"
      done
      echo
      echo
      echo "✅ Restore complete."
    else
      echo "Restore canceled."
    fi
    echo
    sleep 2
  fi
}

# =====================================
# Main menu loop
# =====================================
# Find the Restore menu index
restore_index=1
for ((i=1; i<=${#main_menu_items[@]}; i++)); do
    if [[ "${main_menu_items[i]}" == "Restore:Select a restore file" ]]; then
        restore_index=$i
        break
    fi
done

selected=1
while true; do
    printf "$cursor_hide"
    draw_menu
    key=$(read_key)
    case "$key" in
        up)
            ((selected--))
            ((selected < 1)) && selected=${#main_menu_items[@]}
            ;;
        down)
            ((selected++))
            ((selected > ${#main_menu_items[@]})) && selected=1
            ;;
        left)
            case $selected in
              1) selected=5 ;;
              2) selected=6 ;;
              3) selected=7 ;;
              4) selected=8 ;;
              5) selected=1 ;;
              6) selected=2 ;;
              7) selected=3 ;;
              8) selected=4 ;;
              9) selected=4 ;;
              10) selected=4 ;;
              *) selected=$selected ;;  # default, no change
            esac
            ;;
        right)
            case $selected in
              1) selected=5 ;;
              2) selected=6 ;;
              3) selected=7 ;;
              4) selected=8 ;;
              5) selected=1 ;;
              6) selected=2 ;;
              7) selected=3 ;;
              8) selected=4 ;;
              9) selected=4 ;;
              10) selected=4 ;;
              *) selected=$selected ;;
            esac
            ;;
        enter)
            choice="${main_menu_items[selected]}"
            section="${choice%%:*}"
            label="${choice#*:}"

            if [[ "$section:$label" == "Restore:Select a restore file" ]]; then
                restore_menu
                # After returning, reset main menu selector to Restore
                selected=$restore_index
            elif [[ "$section:$label" == "Scripts:Create New Site" ]]; then
                echo "Creating a new site."
                ".${STRAPI_NODE_BIN}npx" create-strapi-app@latest backend --no-run --quickstart
                ".${STRAPI_NODE_BIN}npx" create-next-app@latest frontend --yes
                sleep 5
            elif [[ "$section:$label" == "Scripts:Install node_modules" ]]; then
                echo "Installing / Updating NodeJS node_modules"
                cd ./backend && "..$STRAPI_NODE_BIN/npm" install
                cd ..
                cd ./frontend && "..$NEXTJS_NODE_BIN/npm" install
                cd ..
                sleep 5
            elif [[ "$section:$label" == "Scripts:Exit Script" ]]; then
                clear
                printf "$cursor_show"
                echo "Exiting..."
                exit 0
            else
                echo "${arrow_color}You selected:${reset_format} ${selected_color}$section → $label${reset_format}"
                case "$section:$label" in
                  "Backup:Minimal")
                    backup_file="backups/backup__$(date +%Y-%m-%d__%H-%M)__minimal.zip"
                    mkdir -p ./backups

                    # Collect files
                    files=("${minimal_backup_items[@]}")
                    total=${#files[@]}
                    if (( total == 0 )); then
                        echo "No files found to back up!"
                        sleep 2
                        break
                    fi

                    count=0
                    bar_length=50

                    echo
                    echo "Creating Minimal backup..."
                    echo
                    zip -q "$backup_file" >/dev/null 2>&1

                    for f in "${files[@]}"; do
                      zip -q "$backup_file" "$f" >/dev/null 2>&1
                      ((count++))
                      percent=$((count * 100 / total))
                      filled=$((percent * bar_length / 100))
                      bar=$(printf "%${filled}s" | tr ' ' '█')
                      empty=$(printf "%$((bar_length - filled))s" | tr ' ' '░')
                      printf "\r%3d%%  %s%s" "$percent" "$bar" "$empty"
                    done

                    echo
                    echo
                    echo "✅ Minimal backup complete: $backup_file"
                    sleep 2
                    ;;
                  "Backup:Full")
                    backup_file="backups/backup__$(date +%Y-%m-%d__%H-%M)__full.zip"
                    mkdir -p ./backups

                    # Collect files (excluding node_modules and public)
                    files=()
                    for item in "${full_backup_items[@]}"; do
                        while IFS= read -r f; do
                            files+=("$f")
                        done < <(find "$item" -type f ! -path "*/node_modules/*" ! -path "*/public/*")
                    done

                    total=${#files[@]}
                    if (( total == 0 )); then
                        echo "No files found to back up!"
                        sleep 2
                        break
                    fi

                    count=0
                    bar_length=50

                    echo
                    echo "Creating Full backup..."
                    echo
                    zip -q "$backup_file" >/dev/null 2>&1

                    for f in "${files[@]}"; do
                      zip -q "$backup_file" "$f" >/dev/null 2>&1
                      ((count++))
                      percent=$((count * 100 / total))
                      filled=$((percent * bar_length / 100))
                      bar=$(printf "%${filled}s" | tr ' ' '█')
                      empty=$(printf "%$((bar_length - filled))s" | tr ' ' '░')
                      printf "\r%3d%%  %s%s" "$percent" "$bar" "$empty"
                    done

                    echo
                    echo
                    echo "✅ Full backup complete: $backup_file"
                    sleep 2
                    ;;
                  "Backup:Complete")
                    backup_file="backups/backup__$(date +%Y-%m-%d__%H-%M)__complete-mac.zip"
                    mkdir -p backups

                    # Collect all files (excluding node_modules and .cache)
                    files=( $(find ./backend ./frontend -type f ! -path "*/node_modules/*" ! -path "*/.cache/*") )
                    total=${#files[@]}

                    if (( total == 0 )); then
                      echo "No files found to back up!"
                      exit 1
                    fi

                    count=0
                    bar_length=50  # Number of bar segments

                    echo
                    echo "Creating backup..."
                    echo
                    # Prepare empty zip (suppress all messages)
                    zip -q "$backup_file" >/dev/null 2>&1

                    for f in "${files[@]}"; do
                      # Add file quietly, suppress all output
                      zip -q "$backup_file" "$f" >/dev/null 2>&1

                      # Update progress
                      ((count++))
                      percent=$((count * 100 / total))
                      filled=$((percent * bar_length / 100))

                      bar=$(printf "%${filled}s" | tr ' ' '█')
                      empty=$(printf "%$((bar_length - filled))s" | tr ' ' '░')

                      printf "\r%3d%%  %s%s" "$percent" "$bar" "$empty"
                    done

                    echo
                    echo
                    echo "✅ Backup complete: $backup_file"
                    sleep 5
                    ;;
                  "Site Operations:Development")
                    echo "Running NextJS and Strapi in development mode..."
                    echo

                    # Run NextJS dev
                    echo "Starting NextJS dev server..."
                    (cd ./frontend && "..$NEXTJS_NODE_BIN/node" node_modules/.bin/next dev) &

                    # Run Strapi dev
                    echo "Starting Strapi dev server..."
                    (cd ./backend && "..$STRAPI_NODE_BIN/node" node_modules/.bin/strapi develop) &

                    echo
                    echo "Both development servers started. Use Ctrl+C to stop."
                    wait
                    ;;
                  "Site Operations:Build")
                    echo "Building NextJS and Strapi for production..."
                    echo

                    # Build NextJS
                    echo "Building NextJS..."
                    (cd ./frontend && "..$NEXTJS_NODE_BIN/node" node_modules/.bin/next build)

                    # Build Strapi
                    echo "Building Strapi..."
                    (cd ./backend && "..$STRAPI_NODE_BIN/node" node_modules/.bin/strapi build)

                    echo
                    echo "Builds completed."
                    ;;
                  "Site Operations:Run")
                    echo "Running NextJS and Strapi in development mode..."
                    echo

                    # Running NextJS Server
                    echo "Starting NextJS server..."
                    (cd ./frontend && "..$NEXTJS_NODE_BIN/node" node_modules/.bin/next start)

                    # Running Strapi Server
                    echo "Starting Strapi server..."
                    (cd ./backend && "..$STRAPI_NODE_BIN/node" node_modules/.bin/strapi start)

                    echo
                    echo "Builds completed."
                    ;;
                esac
                echo
                sleep 1
            fi
            ;;
    esac
done

exit 0

















































:Windows
cd /D "%~dp0"
cls

setlocal enabledelayedexpansion
chcp 65001 >nul
title Website Backup Utility (Color Edition)

:: =====================================
:: Enable ANSI (truecolor)
:: =====================================
for /f "tokens=2 delims==" %%A in ('"reg query HKCU\Console /v VirtualTerminalLevel 2>nul"') do set vt=%%A
if not defined vt reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul

:: =====================================
:: Convert hex to RGB ANSI
:: =====================================
set "ESC="
set "reset=%ESC%[0m"

call :hex_to_rgb_fg 33CCFF arrow_color
call :hex_to_rgb_fg FFFFFF selected_color
call :hex_to_rgb_fg 999999 gray_color
call :hex_to_rgb_bg CCCCCC title_bg_color
call :hex_to_rgb_fg 000000 title_fg_color
call :hex_to_rgb_fg 33FF33 success_color
call :hex_to_rgb_fg FF3333 error_color
goto :menu_start

:hex_to_rgb_fg
setlocal
set "hex=%~1"
set "r=0x%hex:~0,2%"
set "g=0x%hex:~2,2%"
set "b=0x%hex:~4,2%"
for /f %%r in ('powershell -NoProfile -Command "[int]%r%"') do set r=%%r
for /f %%g in ('powershell -NoProfile -Command "[int]%g%"') do set g=%%g
for /f %%b in ('powershell -NoProfile -Command "[int]%b%"') do set b=%%b
endlocal & set "%~2=%ESC%[38;2;%r%;%g%;%b%m"
exit /b

:hex_to_rgb_bg
setlocal
set "hex=%~1"
set "r=0x%hex:~0,2%"
set "g=0x%hex:~2,2%"
set "b=0x%hex:~4,2%"
for /f %%r in ('powershell -NoProfile -Command "[int]%r%"') do set r=%%r
for /f %%g in ('powershell -NoProfile -Command "[int]%g%"') do set g=%%g
for /f %%b in ('powershell -NoProfile -Command "[int]%b%"') do set b=%%b
endlocal & set "%~2=%ESC%[48;2;%r%;%g%;%b%m"
exit /b

:: =====================================
:: Menu Start
:: =====================================
:menu_start
@REM cls
echo %selected_color%Please select an operation%reset%
echo.
echo %selected_color%Minimal%reset% : %gray_color%backs up only bare minimal 'package.json' and 'src/' folder%reset%
echo %selected_color%Full%reset%    : %gray_color%backs up the entire folder except for the node_modules%reset%
echo %selected_color%Complete%reset%: %gray_color%backs up everything in the folders%reset%
echo.
echo.
echo !title_bg_color!!title_fg_color! Backup             !reset!
echo !arrow_color!  1.!reset! !gray_color!Minimal!reset!
echo !arrow_color!  2.!reset! !gray_color!Full!reset!
echo !arrow_color!  3.!reset! !gray_color!Complete!reset!
echo.
echo !title_bg_color!!title_fg_color! Restore            !reset!
echo !arrow_color!  4.!reset! !gray_color!Minimal!reset!
echo.
echo !title_bg_color!!title_fg_color! Site Operations    !reset!
echo !arrow_color!  5.!reset! !gray_color!Development!reset!
echo !arrow_color!  6.!reset! !gray_color!Build!reset!
echo !arrow_color!  7.!reset! !gray_color!Run!reset!
echo.
echo !title_bg_color!!title_fg_color! Scripts            !reset!
echo !arrow_color!  8.!reset! !gray_color!Install node_modules!reset!
echo !arrow_color!  9.!reset! !gray_color!Exit Script!reset!
echo.
echo.
set /p choice="!selected_color!Select option number:!reset! "

if "%choice%"=="1" call :backup minimal
if "%choice%"=="2" call :backup full
if "%choice%"=="3" call :backup complete-win
if "%choice%"=="4" call :restore
if "%choice%"=="5" call :development
if "%choice%"=="6" call :build
if "%choice%"=="7" call :run
if "%choice%"=="8" call :update
if "%choice%"=="9" exit /b
set "choice="
cls
goto :menu_start

:backup minimal
echo.
echo.
set "type=%~1"
set "BACKUP_DIR=backups"
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"
set "timestamp=%date:~10,4%-%date:~4,2%-%date:~7,2%__%time:~0,2%-%time:~3,2%"
set "timestamp=%timestamp: =0%"
set "backup_file=%BACKUP_DIR%\backup__%timestamp%__%type%.zip"

echo %arrow_color%Running %type% backup...%reset%
@REM if "%type%"=="minimal" powershell -Command "Compress-Archive -Path 'backend\src','backend\package.json','frontend\src','frontend\package.json' -DestinationPath '%backup_file%' -Force"
if "%type%"=="minimal" powershell -NoProfile -Command ^
  "$Zip='%backup_file%'; Add-Type -AssemblyName System.IO.Compression.FileSystem; " ^
  "if (Test-Path $Zip) { Remove-Item $Zip }; " ^
  "$zipObj=[System.IO.Compression.ZipFile]::Open($Zip,'Create'); " ^
  "[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zipObj,'backend\package.json','backend/package.json'); " ^
  "[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zipObj,'frontend\package.json','frontend/package.json'); " ^
  "$backendSrc=(Get-ChildItem -Recurse 'backend\src'); " ^
  "foreach($f in $backendSrc){if(-not $f.PSIsContainer){$rel=$f.FullName.Substring((Resolve-Path 'backend').Path.Length+1); [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zipObj,$f.FullName,'backend/'+$rel)}}; " ^
  "$frontendSrc=(Get-ChildItem -Recurse 'frontend\src'); " ^
  "foreach($f in $frontendSrc){if(-not $f.PSIsContainer){$rel=$f.FullName.Substring((Resolve-Path 'frontend').Path.Length+1); [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zipObj,$f.FullName,'frontend/'+$rel)}}; " ^
  "$zipObj.Dispose()"
if "%type%"=="full" powershell -NoProfile -Command ^
  "$Zip='%backup_file%'; Add-Type -AssemblyName System.IO.Compression.FileSystem; " ^
  "if (Test-Path $Zip) { Remove-Item $Zip }; " ^
  "$zipObj=[System.IO.Compression.ZipFile]::Open($Zip,'Create'); " ^
  "foreach($root in @('backend','frontend')) { " ^
  "  $items = Get-ChildItem -Recurse -Force $root | Where-Object { $_.FullName -notmatch '\\node_modules(\\|$)' }; " ^
  "  foreach($item in $items) { " ^
  "    $rel = $item.FullName.Substring((Resolve-Path $root).Path.Length+1); " ^
  "    if ($item.PSIsContainer) { " ^
  "      $null = $zipObj.CreateEntry($root + '/' + $rel.TrimEnd('\') + '/'); " ^
  "    } else { " ^
  "      [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zipObj, $item.FullName, $root + '/' + $rel) " ^
  "    } " ^
  "  } " ^
  "} " ^
  "$zipObj.Dispose()"
if "%type%"=="complete" powershell -Command "Compress-Archive -Path 'backend','frontend' -DestinationPath '%backup_file%' -Force"
echo %success_color%Backup complete:%reset% %backup_file%
timeout /t 3 >nul
exit /b

:restore
cls
echo !title_bg_color!!title_fg_color! Available backups  !reset!
setlocal enabledelayedexpansion
set i=0
for %%f in ("backups\*.zip") do (
    set /a i+=1
    set "File[!i!]=%%~nxf"
    set FileName=%%~nxf
    if !i! LSS 10 (set "num= !i!") else (set "num=!i!")
    echo !arrow_color! !num!. !reset! !gray_color!!FileName!!reset!
)

:: If no backups found
if !i! EQU 0 (
    echo %error_color%No backups found.%reset%
    timeout /t 2 >nul
    endlocal
    exit /b
)

echo.
set /p choice="!selected_color!Select backup number:!reset! "

:: Call restore routine with selected file
call :restore_file "!File[%choice%]!"

endlocal
cls
goto :menu_start

:: =====================================
:restore_file
:: %~1 = filename passed (without path)
echo.
echo.
set "target=%~1"
if not defined target exit /b

echo %arrow_color%Restoring from:%reset% %selected_color%%target%%reset%
powershell -Command "Expand-Archive -Path 'backups\%target%' -DestinationPath '.' -Force"
echo %success_color%Restore complete.%reset%
timeout /t 5 >nul
cls
exit /b

:development
cls
:: kill all running node tasks in case they weren't closed properly
taskkill /f /im node.exe >nul 2>&1

echo Running NextJS and Strapi in development mode in the same window...
echo.

:: Paths
set "FRONTEND_DIR=%~dp0frontend"
set "BACKEND_DIR=%~dp0backend"
set "NEXTJS_CMD=%FRONTEND_DIR%\node_modules\.bin\next.cmd"
set "STRAPI_CMD=%BACKEND_DIR%\node_modules\.bin\strapi.cmd"

:: Run both in background within the same window
start /b cmd /c "cd /d "%FRONTEND_DIR%" && call "%NEXTJS_CMD%" dev"
start /b cmd /c "cd /d "%BACKEND_DIR%" && call "%STRAPI_CMD%" develop"

echo Both servers are starting in the background...
echo Press any key to return to the menu.
echo.
echo.
pause >nul

:: Kill all Node.js processes
echo.
echo.
echo Stopping servers...
taskkill /f /im node.exe >nul 2>&1

echo Servers stopped.
timeout /t 5 >nul
exit /b

:build
echo "bild"
exit /b

:update
echo "npm install"
exit /b

:run
echo "run"
exit /b
