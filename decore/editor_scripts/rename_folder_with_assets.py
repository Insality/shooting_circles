import os
import shutil
import sys

def main():
	if len(sys.argv) < 3:
		print("Usage: python rename_folder_with_assets.py <folder_path> <target_folder_name>")
		sys.exit(1)

	folder_path = sys.argv[1]
	target_folder_name = sys.argv[2]

	print(f"Folder path: {folder_path}")
	print(f"Target folder name: {target_folder_name}")

	duplicate_folder_with_assets(folder_path, target_folder_name)


def duplicate_folder_with_assets(folder_path, target_folder_name):
	folder_name = os.path.basename(os.path.normpath(folder_path))
	parent_folder = os.path.abspath(os.path.join(folder_path, os.pardir))
	target_folder_path = os.path.join(parent_folder, target_folder_name)

	if not os.path.exists(target_folder_path):
		os.makedirs(target_folder_path)

	for item in os.listdir(folder_path):
		item_path = os.path.join(folder_path, item)
		target_item_path = os.path.join(target_folder_path, item)
		if os.path.isdir(item_path):
			shutil.copytree(item_path, target_item_path)
		else:
			shutil.copy2(item_path, target_item_path)

	for root, _, files in os.walk(target_folder_path):
		for file in files:
			file_path = os.path.join(root, file)
			replace_file_name_and_content(file_path, folder_name, target_folder_name)


def replace_file_name_and_content(file_path, folder_name, target_folder_name):
	new_file_path = file_path.replace(folder_name, target_folder_name)
	os.rename(file_path, new_file_path)
	print(f"Renamed file: {file_path} to: {new_file_path}")

	with open(new_file_path, 'r') as file:
		file_content = file.read()

	new_file_content = file_content.replace(folder_name, target_folder_name)
	with open(new_file_path, 'w') as file:
		file.write(new_file_content)
		print(f"Replaced content in file: {new_file_path}")


if __name__ == "__main__":
	main()
