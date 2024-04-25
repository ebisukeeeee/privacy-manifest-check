# Privacy Manifest Checker

## Overview

The Privacy Manifest Checker is a bash script designed to validate the usage of required reason APIs in Swift code against the categories defined in the Privacy Manifest file (`PrivacyInfo.xcprivacy`). This script helps ensure that all APIs used in the code are properly categorized in the Privacy Manifest file as required by Apple's guidelines.

## Prerequisites

- This script is intended for use on macOS environments.
  - It is designed to be integrated as a script step in CI services like Bitrise for quick checks.
- Ensure that the Privacy Manifest file (`PrivacyInfo.xcprivacy`) is located at `./Application/Supporting Files/PrivacyInfo.xcprivacy` relative to the script's location.
  - Please modify the script's path as necessary according to your project's structure.

## Usage

1. Clone or download this repository to your local machine.
2. Ensure that the Swift code directories you want to check are accessible.
3. Open a terminal window and navigate to the directory where the script is located.
4. Run the script with the following command:
   ```
   ./check_privacy_manifest.sh <directory-path-1> <directory-path-2> ...
   ```
   Replace `<directory-path-1>`, `<directory-path-2>`, etc. with the paths to the Swift code directories you want to check. You can specify multiple directory paths separated by spaces.

## Output

- The script will search for Swift files recursively within the specified directories.
- If any required reason API usage is found in the Swift code, the script will verify whether the corresponding category is defined in the Privacy Manifest file.
- If a category is used in the code but not defined in the Privacy Manifest file, an error message will be displayed.
- Upon completion, the script will indicate whether any errors were found during the check.
- If errors are found, the script will exit with a non-zero status code, allowing for easy integration into automated workflows.

## Example

```bash
./check_privacy_manifest.sh ./Project/Source ./Project/Test
```

## Important Links

- [Apple Developer Documentation: Describing Use of Required Reason API](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api)

---

Feel free to customize this README further to suit your project's specific needs or documentation standards.
