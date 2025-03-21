import json
import os

# Define the SF symbols and colors for each fighting style
style_metadata = {
    "Blood Magic": {
        "sfSymbol": "heart.fill",
        "color": {"red": 0.8, "green": 0.0, "blue": 0.0}  # Blood red
    },
    "Earth Magic": {
        "sfSymbol": "mountain.2.fill",
        "color": {"red": 0.5, "green": 0.3, "blue": 0.0}  # Earth brown
    },
    "Fire Magic": {
        "sfSymbol": "flame.fill",
        "color": {"red": 0.9, "green": 0.3, "blue": 0.1}  # Fire red
    },
    "Frost Magic": {
        "sfSymbol": "snow",
        "color": {"red": 0.7, "green": 0.9, "blue": 1.0}  # Ice blue
    },
    "Lightning Magic": {
        "sfSymbol": "bolt.fill",
        "color": {"red": 1.0, "green": 0.8, "blue": 0.0}  # Electric yellow
    },
    "Shadow Magic": {
        "sfSymbol": "moon.stars.fill",
        "color": {"red": 0.3, "green": 0.0, "blue": 0.5}  # Dark purple
    },
    "Water Magic": {
        "sfSymbol": "drop.fill",
        "color": {"red": 0.0, "green": 0.5, "blue": 0.8}  # Azure blue
    },
    "Longsword": {
        "sfSymbol": "bolt.horizontal.fill",
        "color": {"red": 0.0, "green": 0.0, "blue": 0.8}  # Blue
    },
    "Battle Axe": {
        "sfSymbol": "hammer.fill",
        "color": {"red": 0.6, "green": 0.4, "blue": 0.2}  # Brown
    },
    "Bow": {
        "sfSymbol": "arrow.up.and.down.and.arrow.left.and.right",
        "color": {"red": 0.2, "green": 0.5, "blue": 0.3}  # Forest green
    },
    "Rapier & Dagger": {
        "sfSymbol": "checkmark.seal.fill",
        "color": {"red": 0.5, "green": 0.0, "blue": 0.5}  # Purple
    },
    "Spear": {
        "sfSymbol": "arrow.up.to.line.compact",
        "color": {"red": 0.7, "green": 0.7, "blue": 0.2}  # Olive
    },
    "Thrown Weapons": {
        "sfSymbol": "arrowtriangle.forward.fill",
        "color": {"red": 0.6, "green": 0.3, "blue": 0.1}  # Rust
    }
}

def update_fighting_styles_json(input_file_path, output_file_path=None):
    """
    Update the FightingStyleCards.json file to include SF Symbols and colors for each fighting style.
    
    Args:
        input_file_path (str): Path to the input JSON file
        output_file_path (str, optional): Path to save the updated JSON file. 
                                         If None, overwrites the input file.
    """
    # If no output path is specified, overwrite the input file
    if output_file_path is None:
        output_file_path = input_file_path
    
    # Read the input JSON file
    with open(input_file_path, 'r') as file:
        data = json.load(file)
    
    # Update each fighting style with SF Symbol and color
    for style_name, style_data in data.items():
        if style_name in style_metadata:
            # Add the SF Symbol and color
            style_data["sfSymbol"] = style_metadata[style_name]["sfSymbol"]
            style_data["color"] = style_metadata[style_name]["color"]
        else:
            print(f"Warning: No metadata defined for style '{style_name}'")
    
    # Write the updated JSON back to the file
    with open(output_file_path, 'w') as file:
        json.dump(data, file, indent=2)
    
    print(f"Updated JSON saved to {output_file_path}")

# Usage example
if __name__ == "__main__":
    # Path to your FightingStyleCards.json file
    input_path = "FightingStyleCards.json"
    
    # Optional: Path to save the updated file (if you want to keep the original)
    output_path = "FightingStyleCards_updated.json"
    
    # Update the JSON file
    update_fighting_styles_json(input_path, output_path)