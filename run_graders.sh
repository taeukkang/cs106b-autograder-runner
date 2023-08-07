#!/bin/bash

# Define color codes
red_color="\033[1;31m"
reset_color="\033[0m"

# Find the latest Qt version
qt_version=$(find ~/Qt -maxdepth 1 -type d | grep -Eo 'Qt_[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -n 1 | awk -F '_' '{print $2}')

# Initialize the flag for the -q option
quit_apps=false

# Parse command line options
while getopts ":q" opt; do
  case $opt in
    q)
      # Set the flag to quit apps
      quit_apps=true
      ;;
    \?)
      echo -e "${red_color}Invalid option: -$OPTARG${reset_color}" >&2
      exit 1
      ;;
  esac
done

# Quit all apps with the name "Autograder" if the -q option is specified
if $quit_apps; then
  pkill -f "Autograder"
  exit 0
fi

# Define the current folder as the base directory
base_dir=$(pwd)

# Initialize arrays to store sunetids with errors
sunetids_with_make_error=()
sunetids_with_app_error=()

echo "Using Qt version: $qt_version"

# Iterate through subfolders
for sunetid_dir in "$base_dir"/*; do
    if [ -d "$sunetid_dir" ]; then
        # Extract the sunetid from the folder name
        sunetid=$(basename "$sunetid_dir")

        # Find the .pro file within the sunetid folder
        pro_files=("$sunetid_dir"/*.pro)

        # Check if at least one .pro file exists
        if [ ${#pro_files[@]} -gt 0 ]; then
            pro_file="${pro_files[0]}"

            # Define the build directory path
            build_dir="$sunetid_dir/build"

            # Create the build folder if it doesn't exist
            mkdir -p "$build_dir"

            # Run the qmake command within the build directory
            (
                cd "$build_dir" || exit
                qmake_command="~/Qt/$qt_version/macos/bin/qmake \"$pro_file\" -spec macx-clang CONFIG+=debug CONFIG+=qml_debug"
                eval "$qmake_command"
            )

            # Run make for qmake_all
            make_qmake_all_command="/usr/bin/make -f \"$build_dir/Makefile\" qmake_all"
            eval "$make_qmake_all_command"

            # Run make with -j8
            make_j8_command="/usr/bin/make -j8 -C \"$build_dir\""
            eval "$make_j8_command"

            # Capture make command exit status
            make_exit_status=$?

            if [ $make_exit_status -ne 0 ]; then
                echo -e "${red_color}Error running make for sunetid $sunetid${reset_color}"
                sunetids_with_make_error+=("$sunetid")
            fi

            # Find and run the .app file if it exists
            app_files=("$sunetid_dir"/*.app)
            if [ ${#app_files[@]} -gt 0 ]; then
                for app_file in "${app_files[@]}"; do
                    echo "Running app for sunetid $sunetid: $app_file"
                    open "$app_file"
                    if [ $? -ne 0 ]; then
                        echo -e "${red_color}Error running app for sunetid $sunetid${reset_color}"
                        sunetids_with_app_error+=("$sunetid")
                    fi
                done
            else
                echo "No .app files found for sunetid $sunetid in build directory: $build_dir"
            fi

            echo "Commands executed for sunetid $sunetid"
        else
            echo "No .pro files found for sunetid $sunetid"
        fi
    fi
done

# Print the list of sunetids with make errors
if [ ${#sunetids_with_make_error[@]} -gt 0 ]; then
    echo -e "\n${red_color}List of sunetids with make errors:${reset_color}"
    for sunetid_with_make_error in "${sunetids_with_make_error[@]}"; do
        echo "$sunetid_with_make_error"
    done
else
    echo -e "\nNo sunetids with make errors found."
fi

# Print the list of sunetids with app errors
if [ ${#sunetids_with_app_error[@]} -gt 0 ]; then
    echo -e "\n${red_color}List of sunetids with app errors:${reset_color}"
    for sunetid_with_app_error in "${sunetids_with_app_error[@]}"; do
        echo "$sunetid_with_app_error"
    done
else
    echo -e "\nNo sunetids with app errors found."
fi
