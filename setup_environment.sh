#!/bin/bash

# BadCLIP Environment Setup Script
# This script sets up the complete environment for running BadCLIP experiments

set -e  # Exit on error

echo "=========================================="
echo "BadCLIP Environment Setup"
echo "=========================================="
echo ""

# Step 1: Create conda environment
echo "[Step 1/6] Creating conda environment 'badclip' with Python 3.8..."
conda create -n badclip python=3.8 -y

echo ""
echo "[Step 2/6] Activating conda environment..."
eval "$(conda shell.bash hook)"
conda activate badclip

echo ""
echo "[Step 3/6] Installing PyTorch with CUDA 11.3..."
conda install pytorch==1.12.1 torchvision==0.13.1 torchaudio==0.12.1 cudatoolkit=11.3 -c pytorch -y

echo ""
echo "[Step 4/6] Installing requirements from requirements.txt..."
pip install ftfy regex tqdm

echo ""
echo "[Step 5/6] Installing dassl library..."
# Clone and install dassl
cd /tmp
if [ -d "Dassl.pytorch" ]; then
    echo "Removing existing Dassl.pytorch directory..."
    rm -rf Dassl.pytorch
fi
git clone https://github.com/KaiyangZhou/Dassl.pytorch.git
cd Dassl.pytorch
pip install -r requirements.txt
python setup.py develop
cd -

echo ""
echo "[Step 6/6] Installing additional dependencies..."
pip install numpy pillow matplotlib tensorboard

echo ""
echo "=========================================="
echo "Verifying Installation"
echo "=========================================="
echo ""

# Verify installation
python -c "import torch; print(f'PyTorch version: {torch.__version__}')"
python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"
python -c "import torch; print(f'CUDA version: {torch.version.cuda}')" || echo "CUDA not available"
python -c "import torchvision; print(f'Torchvision version: {torchvision.__version__}')"
python -c "from dassl.engine import TRAINER_REGISTRY; print('Dassl imported successfully')"
python -c "import clip; print('CLIP module available')" 2>/dev/null || echo "CLIP will be loaded from local implementation"

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "To activate the environment, run:"
echo "    conda activate badclip"
echo ""
echo "To verify CUDA is working, run:"
echo "    python -c 'import torch; print(torch.cuda.is_available())'"
echo ""
