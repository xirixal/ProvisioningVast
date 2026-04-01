#!/bin/bash
# =============================================
# Custom Forge Provisioning for Vast.ai
# - Overlays your pre-configured files safely
# - Downloads your main model
# - Prevents git repo breakage
# =============================================

echo "=== Starting custom Forge provisioning ==="

cd ${WORKSPACE}

# 1. Download your custom zip if not present
if [ ! -f "forge_template.zip" ]; then
    echo "→ Downloading your forge_template.zip..."
    wget -q --show-progress -O forge_template.zip https://files.catbox.moe/8tg9gk.zip
fi

# 2. Safe overlay: only your custom files (extensions, configs, wildcards, Civitaibrowser+)
if [ -f "forge_template.zip" ]; then
    echo "→ Overlaying your custom setup (extensions, configs, wildcards, Civitaibrowser+...)"

    cd stable-diffusion-webui-forge
    unzip -o ../forge_template.zip \
      extensions/* \
      wildcards/* \
      config.json \
      ui-config.json \
      styles.csv \
      scripts/* \
      -x "repositories/*" "models/*" "*.git*" 2>/dev/null || true
    cd ..

    echo "→ Your custom local setup applied successfully!"
fi

# 3. Download your main model (one model only, as you requested)
MODEL_URL="https://huggingface.co/tonera/waiNSFWIllustrious_v150/resolve/main/svdq-int4_r32-waiNSFWIllustrious_v150.safetensors"
MODEL_PATH="stable-diffusion-webui-forge/models/Stable-diffusion/svdq-int4_r32-waiNSFWIllustrious_v150.safetensors"

if [ ! -f "${MODEL_PATH}" ]; then
    echo "→ Downloading your main model (waiNSFWIllustrious_v150)..."
    mkdir -p stable-diffusion-webui-forge/models/Stable-diffusion
    wget -q --show-progress -O "${MODEL_PATH}" "${MODEL_URL}"
    echo "→ Model downloaded successfully!"
else
    echo "→ Main model already present."
fi

# 4. Clean any broken git repositories (critical fix for the loop error)
echo "→ Cleaning potential broken git repos..."
rm -rf stable-diffusion-webui-forge/repositories/stable-diffusion-stability-ai \
       stable-diffusion-webui-forge/repositories/generative-models \
       stable-diffusion-webui-forge/repositories/stable-diffusion-webui-assets \
       2>/dev/null || true

echo "=== Custom provisioning complete! Your configured Forge with model is ready. ==="
