#!/bin/bash
# This script does not use associative arrays or optimizations like GNU parallel to ensure compatibility with default macOS environments.

# Privacy info file path
PRIVACY_INFO_PATH="./Application/Supporting Files/PrivacyInfo.xcprivacy"

# Required reason API categories and keywords
# refs: https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api
categories=("NSPrivacyAccessedAPICategoryFileTimestamp" \
"NSPrivacyAccessedAPICategorySystemBootTime" \
"NSPrivacyAccessedAPICategoryDiskSpace" \
"NSPrivacyAccessedAPICategoryActiveKeyboards" \
"NSPrivacyAccessedAPICategoryUserDefaults"\
)
keywords=("creationDate|\.modificationDate|\.fileModificationDate|\.contentModificationDateKey|getattrlist\( |getattrlistbulk\( |fgetattrlist\( |stat.st_|fstat\( |fstatat\( |lstat\( |getattrlistat\(" \
"systemUptime|mach_absolute_time\(\)" \
"volumeAvailableCapacityKey|volumeAvailableCapacityForImportantUsageKey|volumeAvailableCapacityForOpportunisticUsageKey|volumeTotalCapacityKey|systemFreeSize|systemSize|statfs\( |statvfs\( |fstatfs\( |getattrlist\( |fgetattrlist\( |getattrlistat\(" \
"activeInputModes" \
"UserDefaults")

all_keywords=$(IFS='|'; echo "${keywords[*]}")

defined_categories=()
while IFS= read -r line; do
    if [[ "$line" =~ \<string\>(NSPrivacyAccessedAPICategory[a-zA-Z]+)\<\/string\> ]]; then
        defined_categories+=("${BASH_REMATCH[1]}")
    fi
done < "$PRIVACY_INFO_PATH"

is_category_defined() {
    local category="$1"
    for defined_category in "${defined_categories[@]}"; do
        if [ "$category" == "$defined_category" ]; then
            return 0
        fi
    done
    return 1
}

is_excluded() {
    local path="$1"
    for exclude_pattern in "${EXCLUDE_PATHS[@]}"; do
        if [[ "$path" == $exclude_pattern ]]; then
            return 0
        fi
    done
    return 1
}

error_found=0

search_and_log() {
    local folder="$1"

    if is_excluded "$folder"; then
        echo "Skipping excluded folder: $folder"
        return
    fi

    for item in "$folder"/*; do
        if [ -d "$item" ]; then
            search_and_log "$item"
        elif [ -f "$item" ] && [[ "$item" == *.swift ]]; then
            local hits=$(grep -nEo "$all_keywords" "$item")
            if [ -n "$hits" ]; then
                for i in "${!categories[@]}"; do
                    local category="${categories[i]}"
                    local keyword_group="${keywords[i]}"
                    if echo "$hits" | grep -Eo "$keyword_group" > /dev/null; then
                        if ! is_category_defined "$category"; then
                            echo "Error: '$category' not defined in $PRIVACY_INFO_PATH but used in $item"
                            error_found=1
                        fi
                    fi
                done
            fi
        fi
    done
}

# Checking if any directories were passed as arguments
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <directory-path-1> <directory-path-2> ..."
    exit 1
fi

# Process each directory path provided as argument
for directory in "$@"; do
    echo "Starting the search for API usage in Swift files at $directory..."
    search_and_log "$directory"
done

if [ "$error_found" -ne 0 ]; then
    echo "Errors found during the check across all directories. Please review the log."
    exit 1
else
    echo "No errors found across all directories. All API categories are properly defined."
    exit 0
fi
