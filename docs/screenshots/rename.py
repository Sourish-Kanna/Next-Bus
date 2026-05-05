import os
import sys
import json

script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)

BACKUP_FILE = "rename_backup.json"

def get_files():
    return [f for f in os.listdir() if os.path.isfile(f) and not f.endswith('.py') and f != BACKUP_FILE]

def preview_renames(given_name):
    files = get_files()
    preview = {}
    for i, filename in enumerate(files, start=1):
        new_name = f"{given_name} - {i}.jpg"
        preview[filename] = new_name
    return preview

def rename_files(preview_map):
    backup = {}
    for old, new in preview_map.items():
        os.rename(old, new)
        backup[new] = old
        print(f"Renamed: {old} → {new}")
    with open(BACKUP_FILE, 'w') as f:
        json.dump(backup, f)

def undo_rename():
    if not os.path.exists(BACKUP_FILE):
        print("No backup found. Cannot undo.")
        return
    with open(BACKUP_FILE, 'r') as f:
        backup = json.load(f)
    for new, old in backup.items():
        if os.path.exists(new):
            os.rename(new, old)
            print(f"Reverted: {new} → {old}")
    os.remove(BACKUP_FILE)

# Main flow
print("Choose an option:")
print("1. Rename files")
print("2. Undo last rename")
choice = input("Enter 1 or 2: ")

if choice == "1":
    name = "NextBus - " + input("Enter the version: ")
    preview = preview_renames(name)
    print("\nPreview:")
    for old, new in preview.items():
        print(f"{old} → {new}")
    confirm = input("\nProceed with renaming? (y/n): ")
    if confirm.lower() == 'y':
        rename_files(preview)
    else:
        print("Renaming cancelled.")
elif choice == "2":
    undo_rename()
else:
    print("Invalid choice.")

input("Enter to exit....")
