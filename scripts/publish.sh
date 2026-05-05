#!/bin/bash

# Game configuration
GAME_NAME=${GAME_NAME:-'godot-topdown-base'}

# Itch.io configuration
ITCH_USER=${ITCH_USER:-'chorage'}
ITCH_GAME=${ITCH_GAME:-$GAME_NAME}

# Check if RELEASE_VERSION is set
if [ -z "$RELEASE_VERSION" ]; then
    echo "Error: RELEASE_VERSION environment variable is not set"
    echo "Usage: RELEASE_VERSION=vX.Y.Z $0"
    exit 1
fi

# Windows
butler push dist/$GAME_NAME-windows-$RELEASE_VERSION.zip $ITCH_USER/$ITCH_GAME:windows --userversion $RELEASE_VERSION

# Linux  
butler push dist/$GAME_NAME-linux-$RELEASE_VERSION.zip $ITCH_USER/$ITCH_GAME:linux --userversion $RELEASE_VERSION
