#!/bin/bash

# Stop execution on error
set -e

# Variables
USER=$(whoami)
PROJECT_DIR="/home/$USER/traction-docker-compose"
DIGICRED_DIR="$PROJECT_DIR/digicred"
ENV_FILE="$DIGICRED_DIR/.env"
ENV_EXAMPLE="$DIGICRED_DIR/.env.example"

# Variables to find and replace in traction .env file
PUBLIC_DOMAIN=$(curl ifconfig.me)

# Update system packages
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Docker Installation (Check if Docker is installed, if not install it)
if [ command -v docker > /dev/null 2>&1 ]; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo apt install docker-compose-plugin -y
fi

# Install Caddy
if [ ! -x /var/lib/caddy]; then
    echo "Installing Caddy..."
    sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https

    # Overwrite existing keyring file without prompting
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --yes --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg

    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
    sudo apt update && sudo apt install caddy -y

    # Enable and start Caddy
    echo "Enabling and starting Caddy..."
    sudo systemctl enable caddy
    sudo systemctl restart caddy
fi

# Clone the repository if not already cloned
if [ ! -d $PROJECT_DIR ]; then
    echo "Cloning the Traction repository..."
    git clone https://github.com/DigiCred-Holdings/traction-docker-compose "$PROJECT_DIR"
fi

if [ ! -s $ENV_FILE ]; then
    echo "Configuring .env file"
    cp $ENV_EXAMPLE $ENV_FILE

    sed -i "s|<public-domain>|$PUBLIC_DOMAIN|g"  $ENV_FILE
fi

# Docker Compose (Navigate to the project folder and run docker compose)
echo "Setting up Docker containers..."
cd $DIGICRED_DIR || exit
sudo docker compose up -d

# Show Docker container status
sudo docker ps

echo "Setup complete!"
