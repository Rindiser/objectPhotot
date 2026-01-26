# Object Photo Workflow

A specialized automation tool for streamlining the digitization of natural history museum specimens. This program automates the renaming, organization, and metadata logging of specimen images captured during a tethered shooting workflow.

## Features

- **Automated File Detection**: Monitors a working directory for new images from your tethering software.
- **Robust Move & Rename**: renaming based on metadata (MUSIT number, UUID, Suffix) and moves files to a structured destination.
- **Metadata Logging**: Logs every processed image to `TaxonName_Object_list.txt` with relevant details.
- **Barcode Support**: optimized for barcode scanner input for UUIDs.
- **Progress Tracking**: Built-in "Motivation" meter tracking daily and total image counts.
- **Safe Handling**: Ensures files are fully saved and not locked by camera software before processing.

## Installation

1.  **Install AutoHotkey**: This script requires AutoHotkey v1.1+. Download it from [autohotkey.com](https://www.autohotkey.com/).
2.  **Download Program Files**: Download the following files to a single folder on your computer:
    *   `Object_photo_17.ahk` (The main program script)
    *   `go.jpg` (Status image)
    *   `vent.jpg` (Status image)
    *   `LICENSE` (Optional but recommended)
    *   *(Note: `settings.ini` and `Motivation_dag.txt` will be created automatically when you run the program)*
3.  **Directory Setup**: Ensure you have:
    *   A **Working Folder** where your camera software saves incoming images.
    *   A **Destination Folder** where processed images will be stored.

## Usage

1.  Run the script `Object_photo_17.ahk`.
2.  **First Run Configuration**:
    *   Go to the **Settings** tab.
    *   Select your **Working Folder** and **Destination Folder**.
    *   Set your Station Number and other preferences.
    *   Click **Save Settings**.
3.  **Daily Workflow**:
    *   Switch to the **Program** tab.
    *   Take a photo using your tethering software.
    *   Click **Hent bilde / Nytt objekt** (or waiting detection loop).
    *   **Scan/Enter Metadata**:
        *   **Filnavn (MUSIT nr)**: Enter the catalog number.
        *   **QR-kode (UUID)**: Scan the specimen UUID barcode.
    *   **Process**:
        *   Press **Enter** (or click Rename) to move and rename the file.
        *   The file is moved to the destination, and data is logged.

## Troubleshooting

- **"No image found"**: Ensure your camera software is saving to the folder specified in Settings > Working Folder.
- **Locked Files**: The program waits for files to be fully saved. If it hangs "Waiting...", check if your tethering software is holding the file open.
- **Settings Lost**: Settings are stored in `settings.ini` in the script directory. Ensure the script has write permissions to its own folder.
