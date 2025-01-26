#!/bin/bash

# Silk Apps Updater Script
# This script updates the Silk Apps to the latest version.

# Function to check if Git is installed
check_git_installed() {
    if ! command -v git &> /dev/null; then
        echo "Error: Git is not installed. Please install Git and try again."
        exit 1
    fi
}

# Function to check if the script is run as root
check_root_user() {
    if [ "$EUID" -eq 0 ]; then
        echo "Error: Do not run this script as root. Use a regular user account."
        exit 1
    fi
}

# Function to handle errors
handle_error() {
    echo "Error: $1"
    echo "Aborting update..."
    exit 1
}

# Start message
clear
echo "Welcome to the Silk Apps Updater!"
echo "This script will update Silk Apps to the latest version."
echo "Ensure you have an active internet connection."
echo

# Confirm before proceeding
while true; do
    read -p "Do you want to proceed with the update? (y/n) " yn
    case $yn in
        [yY] ) echo "Proceeding..."; break ;;
        [nN] ) echo "Update cancelled."; exit ;;
        * ) echo "Invalid input. Please enter 'y' or 'n'." ;;
    esac
done

# Check prerequisites
check_git_installed
check_root_user

# Variables
APP_DIR="$HOME/Silk-Apps"
USERDATA_DIR="$HOME/silkapps-userdata"
REPO_URL="https://github.com/CommandCrafterx/Silk-Apps.git"

# Create temporary directory for user data backup
echo "Creating backup directory..."
mkdir -p "$USERDATA_DIR" || handle_error "Failed to create backup directory."

# Backup user data
if [ -f "$APP_DIR/Apps/to-do/ list/to-do.txt" ]; then
    echo "Backing up user data..."
    cp "$APP_DIR/Apps/to-do.txt" "$USERDATA_DIR/todo.txt" || handle_error "Failed to back up user data."
else
    echo "No user data found to back up."
fi

# Remove old Silk Apps directory
echo "Removing old Silk Apps directory..."
rm -rf "$APP_DIR" || handle_error "Failed to remove old directory."

# Clone the latest version of Silk Apps
echo "Cloning the latest version of Silk Apps..."
git clone "$REPO_URL" "$APP_DIR" || handle_error "Failed to clone the repository."

# Restore user data
if [ -f "$USERDATA_DIR/todo.txt" ]; then
    echo "Restoring user data..."
    cp "$USERDATA_DIR/todo.txt" "$APP_DIR/Apps/to-do/ list/todo.txt" || handle_error "Failed to restore user data."
else
    echo "No user data to restore."
fi

# Cleanup
echo "Cleaning up temporary files..."
rm -rf "$USERDATA_DIR" || handle_error "Failed to clean up temporary files."

# Success message
echo "Silk Apps have been successfully updated!"
