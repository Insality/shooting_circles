import sys

def main():
	collection_name = sys.argv[1]
	print("Replace bootstrap.main_collection in game.project with: ", collection_name)

	# Replace first symbol dot in full file path
	collection_name = collection_name.replace(".", "", 1)

	# Add "c" symbol at the end as "compiled" resource name
	collection_name = collection_name + "c"

	# ./game.project file is ini file, replace bootstrap.main_collection value with new value
	# Find and replace a line starts main_collection = with new value and save file
	with open("./game.project", "r") as f:
		lines = f.readlines()

	with open("./game.project", "w") as f:
		for line in lines:
			if line.startswith("main_collection ="):
				f.write(f"main_collection = {collection_name}\n")
			else:
				f.write(line)

	print("Done with replacing bootstrap.main_collection in game.project")

main()
