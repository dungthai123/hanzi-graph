import json

# Load the JSON file
with open('public/data/simplified/definitions.json', 'r', encoding='utf-8') as file:
    data = json.load(file)

# Count the number of keys
key_count = len(data)
print(f'Total number of keys: {key_count}')
