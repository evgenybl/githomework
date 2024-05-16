#!/bin/bash

# Define log file path
LOG_FILE="/home/itai/DevOpsCourseINT2024/Submission/ItaiLouk/final_linux_project/script_logs
/system_file_setup.log"
FIXED_PATH="/home/itai/DevOpsCourseINT2024/Submission/ItaiLouk/final_linux_project/personal_folder"

# Function to log messages
log_message() {
    local message="$1"
    echo "$(date +"%Y-%m-%d %H:%M") - $message" >> "$LOG_FILE"
}

# Function to print user-friendly messages
print_message() {
    local message="$1"
    echo "$message"
}

# Function to add a new item
add_item() {
    log_message "User chose to add a new item"
    print_message "Adding a new item..."

    read -p "Enter the category (1=Education, 2=Development, 3=Personal): " category

    # Choose category based on user input
    case $category in
        1) category_name="Education" ;;
        2) category_name="Development" ;;
        3) category_name="Personal" ;;
        *) log_message "Invalid category." && print_message "Invalid category." && return ;;
    esac

    log_message "User chose category: $category_name"
    print_message "Category chosen: $category_name"

    # Check if the directory already exists
    if [[ ! -d "$FIXED_PATH/$category_name" ]]; then
        mkdir -p "$FIXED_PATH/$category_name"  # Create directory if it doesn't exist
        if [ $? -eq 0 ]; then
            log_message "Directory created successfully."
            print_message "Directory created successfully."
        else
            log_message "Failed to create directory."
            print_message "Failed to create directory."
            return
        fi
    else
        log_message "Directory already exists."
        print_message "Directory already exists."
    fi

    # Prompt user to choose file or directory
    read -p "Do you want to create a file or directory? (file/dir): " item_type
    log_message "User chose item type: $item_type"

    # Based on category and item type, perform corresponding actions
    case $item_type in
        file)
            # Prompt user for filename
            read -p "Enter the file name (with or without extension): " filename
            log_message "User entered filename: $filename"

            # Extract extension if provided in filename
            base_name="${filename%.*}"
            extension="${filename##*.}"
            if [[ "$base_name" == "$extension" ]]; then
                # No extension provided in filename
                base_name="$filename"
                extension=""
            fi

            case $category in
                1)
                    # For Education category, ensure the extension is txt, md, or sh
                    while [[ -z "$extension" || ( "$extension" != "txt" && "$extension" != "md" && "$extension" != "sh" ) ]]; do
                        read -p "Enter the file extension (txt, md, sh): " extension
                        log_message "User entered extension: $extension"
                        if [[ "$extension" != "txt" && "$extension" != "md" && "$extension" != "sh" ]]; then
                            log_message "Invalid extension. Only txt, md, and sh extensions are allowed for education files."
                            print_message "Invalid extension. Only txt, md, and sh extensions are allowed for education files."
                            read -p "Try again? (y/n): " try_again
                            log_message "User entered try_again: $try_again"
                            if [[ "$try_again" != "y" && "$try_again" != "Y" ]]; then
                                return
                            fi
                        fi
                    done
                    ;;
                2)
                    # For Development category, any extension is allowed
                    if [[ -z "$extension" ]]; then
                        read -p "Enter the file extension: " extension
                        log_message "User entered extension: $extension"
                    fi
                    ;;
                3)
                    # For Personal category, ensure the extension is mp3 or mp4
                    while [[ -z "$extension" || ( "$extension" != "mp3" && "$extension" != "mp4" ) ]]; do
                        read -p "Enter the file extension (mp3, mp4): " extension
                        log_message "User entered extension: $extension"
                        if [[ "$extension" != "mp3" && "$extension" != "mp4" ]]; then
                            log_message "Invalid extension. Only mp3 and mp4 extensions are allowed for personal files."
                            print_message "Invalid extension. Only mp3 and mp4 extensions are allowed for personal files."
                            read -p "Try again? (y/n): " try_again
                            log_message "User entered try_again: $try_again"
                            if [[ "$try_again" != "y" && "$try_again" != "Y" ]]; then
                                return
                            fi
                        fi
                    done
                    ;;
            esac

            # Create the file with the specified filename and extension
            touch "$FIXED_PATH/$category_name/$base_name.$extension"
            if [ $? -eq 0 ]; then
                log_message "File created successfully."
                print_message "File created successfully."
            else
                log_message "Failed to create file."
                print_message "Failed to create file."
            fi
            ;;
        dir)
            # For directory creation, prompt user for directory name
            read -p "Enter the directory name: " dirname
            log_message "User entered directory name: $dirname"
            # Create the directory
            mkdir "$FIXED_PATH/$category_name/$dirname"
            if [ $? -eq 0 ]; then
                log_message "Directory created successfully."
                print_message "Directory created successfully."
            else
                log_message "Failed to create directory."
                print_message "Failed to create directory."
            fi
            ;;
        *)
            log_message "Invalid option. Please enter 'file' or 'dir'."
            print_message "Invalid option. Please enter 'file' or 'dir'."
            ;;
    esac
}

# Function to modify an item
modify_item() {
    log_message "User chose to modify an item"
    print_message "Modifying an item..."

    read -p "Enter the category (1=Education, 2=Development, 3=Personal): " category

    # Choose category based on user input
    case $category in
        1) category_name="Education" ;;
        2) category_name="Development" ;;
        3) category_name="Personal" ;;
        *) log_message "Invalid category." && print_message "Invalid category." && return ;;
    esac

    log_message "User chose category: $category_name"
    print_message "Category chosen: $category_name"

    read -p "Enter the name of the item you want to modify: " item_name
    log_message "User entered item name: $item_name"

    if [[ -e "$FIXED_PATH/$category_name/$item_name" ]]; then
        read -p "Are you sure you want to modify $item_name? (y/n): " confirm
        log_message "User entered confirmation: $confirm"
        if [[ $confirm == "y" || $confirm == "Y" ]]; then
            read -p "Enter the new name for the item: " new_name
            log_message "User entered new item name: $new_name"
            mv "$FIXED_PATH/$category_name/$item_name" "$FIXED_PATH/$category_name/$new_name"
            if [ $? -eq 0 ]; then
                log_message "Item modified successfully."
                print_message "Item modified successfully."
            else
                log_message "Failed to modify item."
                print_message "Failed to modify item."
            fi
        else
            log_message "Modification canceled."
            print_message "Modification canceled."
        fi
    else
        log_message "Item not found."
        print_message "Item not found."
    fi
}

# Function to delete an item
delete_item() {
    log_message "User chose to delete an item"
    print_message "Deleting an item..."

    read -p "Enter the category (1=Education, 2=Development, 3=Personal): " category

    # Choose category based on user input
    case $category in
        1) category_name="Education" ;;
        2) category_name="Development" ;;
        3) category_name="Personal" ;;
        *) log_message "Invalid category." && print_message "Invalid category." && return ;;
    esac

    log_message "User chose category: $category_name"
    print_message "Category chosen: $category_name"

    read -p "Enter the name of the item you want to delete: " item_name
    log_message "User entered item name: $item_name"

    if [[ -e "$FIXED_PATH/$category_name/$item_name" ]]; then
        read -p "Are you sure you want to delete $item_name? (y/n): " confirm
        log_message "User entered confirmation: $confirm"
        if [[ $confirm == "y" || $confirm == "Y" ]]; then
            rm -rf "$FIXED_PATH/$category_name/$item_name"
            if [ $? -eq 0 ]; then
                log_message "Item deleted successfully."
                print_message "Item deleted successfully."
            else
                log_message "Failed to delete item."
                print_message "Failed to delete item."
            fi
        else
            log_message "Deletion canceled."
            print_message "Deletion canceled."
        fi
    else
        log_message "Item not found."
        print_message "Item not found."
    fi
}

# Main menu
while true; do
    log_message "Displaying main menu"
    echo "Choose an option:"
    echo "1. Add new item"
    echo "2. Modify item name"
    echo "3. Delete item"
    echo "4. Exit"

    read -p "Enter your choice: " choice

    # Perform actions based on user choice
    case $choice in
        1) add_item ;;
        2) modify_item ;;
        3) delete_item ;;
        4) exit ;;
        *) log_message "Invalid choice. Please enter a number between 1 and 4." ;;
    esac
done
