import json
import os
import requests
import base64
from pathlib import Path
import time
from openai import OpenAI
import argparse

def setup_args():
    """Parse command line arguments"""
    parser = argparse.ArgumentParser(description="Generate card images using DALL-E 3")
    parser.add_argument("--input", "-i", type=str, required=True, help="Input JSON file with image prompts")
    parser.add_argument("--output", "-o", type=str, default="card_images", help="Output directory for images")
    parser.add_argument("--size", "-s", type=str, default="1024x1024", 
                        choices=["1024x1024", "1792x1024", "1024x1792"], 
                        help="Image size (square, landscape, or portrait)")
    parser.add_argument("--quality", "-q", type=str, default="standard", 
                        choices=["standard", "hd"], help="Image quality")
    parser.add_argument("--limit", "-l", type=int, default=None, 
                        help="Limit number of images to generate (for testing)")
    parser.add_argument("--overwrite", action="store_true", help="Overwrite existing images")
    return parser.parse_args()

def load_prompts(filename):
    """Load image prompts from JSON file"""
    try:
        with open(filename, 'r') as f:
            data = json.load(f)
        
        # Check if the JSON has the expected structure
        if "imagePrompts" not in data:
            print("Error: JSON file does not have 'imagePrompts' key")
            return []
            
        return data["imagePrompts"]
    except json.JSONDecodeError:
        print(f"Error: Could not parse {filename} as JSON")
        return []
    except FileNotFoundError:
        print(f"Error: File {filename} not found")
        return []

def create_output_directory(output_dir):
    """Create output directory if it doesn't exist"""
    os.makedirs(output_dir, exist_ok=True)
    print(f"Images will be saved to: {output_dir}")

def generate_image(client, prompt, card_id, output_dir, size="1024x1024", quality="standard", overwrite=False):
    """Generate an image using DALL-E 3 and save it"""
    output_path = os.path.join(output_dir, f"{card_id}.jpg")
    
    # Skip if file exists and we're not overwriting
    if os.path.exists(output_path) and not overwrite:
        print(f"Skipping {card_id} - image already exists")
        return False
    
    try:
        print(f"Generating image for {card_id}...")
        response = client.images.generate(
            model="dall-e-3",
            prompt=prompt,
            size=size,
            quality=quality,
            n=1,
            response_format="b64_json"
        )

        # Decode and save the image
        image_data = base64.b64decode(response.data[0].b64_json)
        with open(output_path, "wb") as f:
            f.write(image_data)
            
        print(f"Saved image: {output_path}")
        return True
        
    except Exception as e:
        print(f"Error generating image for {card_id}: {str(e)}")
        return False

def main():
    args = setup_args()
    
    # Initialize OpenAI client
    client = OpenAI()
    
    # Check if API key is set
    if not os.environ.get("OPENAI_API_KEY"):
        print("Error: OPENAI_API_KEY environment variable not set")
        print("Please set it with: export OPENAI_API_KEY='your-api-key'")
        return
    
    # Load prompts from JSON file
    prompts = load_prompts(args.input)
    if not prompts:
        return
    
    # Create output directory
    create_output_directory(args.output)
    
    # Apply limit if specified
    if args.limit is not None:
        prompts = prompts[:args.limit]
    
    # Track success/failure statistics
    total = len(prompts)
    successful = 0
    
    # Generate images
    for i, item in enumerate(prompts):
        card_id = item.get("cardID")
        prompt = item.get("prompt")
        
        if not card_id or not prompt:
            print(f"Skipping item {i+1} - missing cardID or prompt")
            continue
        
        # Generate the image
        if generate_image(client, prompt, card_id, args.output, args.size, args.quality, args.overwrite):
            successful += 1
            # Add a short delay to avoid rate limits
            time.sleep(1)
    
    # Print summary
    print(f"\nGeneration complete! Successfully generated {successful} out of {total} images.")
    print(f"Images saved to: {os.path.abspath(args.output)}")

if __name__ == "__main__":
    main()