#!/bin/bash
# Modified default provisioning for SD Forge with custom overlay only

DISK_GB_REQUIRED=30

APT_PACKAGES=()

PIP_PACKAGES=(
    "onnxruntime-gpu"
)

EXTENSIONS=()

CHECKPOINT_MODELS=()

LORA_MODELS=()

VAE_MODELS=()

ESRGAN_MODELS=()

CONTROLNET_MODELS=()

function provisioning_start() {
    source /opt/ai-dock/etc/environment.sh
    source /opt/ai-dock/bin/venv-set.sh webui

    provisioning_print_header
    provisioning_get_apt_packages
    provisioning_get_pip_packages
    provisioning_get_extensions
    provisioning_get_models "${WORKSPACE}/storage/stable_diffusion/models/ckpt" "${CHECKPOINT_MODELS[@]}"
    provisioning_get_models "${WORKSPACE}/storage/stable_diffusion/models/lora" "${LORA_MODELS[@]}"
    provisioning_get_models "${WORKSPACE}/storage/stable_diffusion/models/controlnet" "${CONTROLNET_MODELS[@]}"
    provisioning_get_models "${WORKSPACE}/storage/stable_diffusion/models/vae" "${VAE_MODELS[@]}"
    provisioning_get_models "${WORKSPACE}/storage/stable_diffusion/models/esrgan" "${ESRGAN_MODELS[@]}"

    # Safe custom overlay
    echo "=== Applying custom overlay ==="
    cd ${WORKSPACE}
    if [ -f "forge_custom_only.zip" ]; then
        cd stable-diffusion-webui-forge
        unzip -o ../forge_custom_only.zip -x "repositories/*" "models/*" "*.git*" 2>/dev/null || true
        cd ..
        echo "→ Custom extensions and configs applied"
    fi

    # Download your model
    MODEL_URL="https://huggingface.co/tonera/waiNSFWIllustrious_v150/resolve/main/svdq-int4_r32-waiNSFWIllustrious_v150.safetensors"
    MODEL_PATH="stable-diffusion-webui-forge/models/Stable-diffusion/svdq-int4_r32-waiNSFWIllustrious_v150.safetensors"
    if [ ! -f "$MODEL_PATH" ]; then
        mkdir -p stable-diffusion-webui-forge/models/Stable-diffusion
        wget -q --show-progress -O "$MODEL_PATH" "$MODEL_URL"
        echo "→ Model downloaded"
    fi

    provisioning_print_end
}

function pip_install() {
    "$FORGE_VENV_PIP" install --no-cache-dir "$@"
}

function provisioning_get_apt_packages() {
    if [[ -n $APT_PACKAGES ]]; then
        sudo $APT_INSTALL ${APT_PACKAGES[@]}
    fi
}

function provisioning_get_pip_packages() {
    if [[ -n $PIP_PACKAGES ]]; then
        pip_install ${PIP_PACKAGES[@]}
    fi
}

function provisioning_get_extensions() {
    for repo in "${EXTENSIONS[@]}"; do
        dir="${repo##*/}"
        path="/opt/stable-diffusion-webui-forge/extensions/${dir}"
        if [[ -d $path ]]; then
            if [[ ${AUTO_UPDATE,,} == "true" ]]; then
                ( cd "$path" && git pull )
            fi
        else
            git clone "${repo}" "${path}" --recursive
        fi
    done
}

function provisioning_get_models() {
    if [[ -z $2 ]]; then return 1; fi
    dir="$1"
    mkdir -p "$dir"
    shift
    for url in "$@"; do
        provisioning_download "${url}" "${dir}"
    done
}

function provisioning_print_header() {
    printf "\n##############################################\n#          Provisioning container            #\n##############################################\n\n"
}

function provisioning_print_end() {
    printf "\nProvisioning complete\n\n"
}

function provisioning_download() {
    wget -qnc --content-disposition --show-progress -e dotbytes="${3:-4M}" -P "$2" "$1"
}

provisioning_start
