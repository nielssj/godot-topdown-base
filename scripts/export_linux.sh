#!/bin/bash

# Use GODOT_PATH environment variable if set, otherwise use default path
GODOT_EXECUTABLE=${GODOT_PATH:-'godot'}

if [ -z "$RELEASE_VERSION" ]; then
    echo "Warning: RELEASE_VERSION environment variable is not set, using 'dev'"
    RELEASE_VERSION="dev"
fi

# Create export directory if it doesn't exist
mkdir -p dist/linux

# Inject RELEASE_VERSION into project.godot (replaces whatever version is currently set)
sed -i "s/config\/version=\"[^\"]*\"/config\/version=\"$RELEASE_VERSION\"/" project.godot

echo "Set project.godot config/version to: $RELEASE_VERSION"

echo "Exporting Linux build..."

# Run Godot export with the correct path
"$GODOT_EXECUTABLE" --headless --export-release "Linux"

# Store the export exit code
EXPORT_EXIT_CODE=$?

if [ $EXPORT_EXIT_CODE -eq 0 ]; then
    echo "Export successful, creating zip file..."
    
    # Create zip file in dist folder
    cd dist/linux
    zip -r "../godot-topdown-base-linux.zip" .
    cd ../..
    
    # Clean up individual files
    rm -rf dist/linux
    
    echo "Linux build packaged as godot-topdown-base-linux.zip"
else
    echo "Export failed with exit code: $EXPORT_EXIT_CODE"
fi

exit $EXPORT_EXIT_CODE
