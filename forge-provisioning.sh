#!/bin/bash

# Navigate to the persistent workspace directory
cd /workspace

# 1. Download the archive (e.g., a pre-packaged webui or custom nodes)
# Replace the URL and filename with your actual target
wget -O setup_files.tar.gz "https://files.catbox.moe/qrrqgt.zip"

# 2. Extract the archive
# -x: extract, -z: decompress gzip, -f: file
tar -xzf setup_files.tar.gz

# Optional: Clean up the downloaded archive to save disk space
rm setup_files.tar.gz

# 3. Create the target directory for the model if it does not exist
mkdir -p /workspace/sdwebui/models/Stable-diffusion

# 4. Download the model using wget
# The -O flag is critical here to ensure the file is named correctly, 
# especially when downloading from APIs like Civitai or HuggingFace.
wget -O /workspace/sdwebui/models/Stable-diffusion/waiNSFWIllustrious_v150.safetensors "https://huggingface.co/IbarakiDouji/WAI-NSFW-illustrious-SDXL/resolve/main/waiNSFWIllustrious_v150.safetensors?download=true"

# Optional: Set permissions if your instance runs as a non-root user (like Jupyter)
chown -R root:root /workspace/sdwebui
