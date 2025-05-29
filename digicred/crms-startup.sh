#!/bin/bash

# Stop execution on error
set -e

# Variables
USER=$(whoami)
PROJECT_DIR="/home/$USER/traction-docker-compose"
DIGICRED_DIR="$PROJECT_DIR/digicred"
ENV_FILE="$DIGICRED_DIR/.env"
ENV_EXAMPLE="$DIGICRED_DIR/.env.example"
CADDYFILE_EXAMPLE="$DIGICRED_DIR/Caddyfile.example"

# Variables to find and replace in traction .env file
PUBLIC_DOMAIN=$(curl ifconfig.me)

# Update system packages
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Docker Installation (Check if Docker is installed, if not install it)
echo "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo apt install docker-compose-plugin -y

# Install Caddy
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

# Clone the repository if not already cloned
if [ ! -d $PROJECT_DIR ]; then
    echo "Cloning the Traction repository..."
    git clone https://github.com/DigiCred-Holdings/traction-docker-compose "$PROJECT_DIR"
fi


# Prompt user input for variables
read -p "Enter the public domain for your CrMS (default - this machine's public IP):" INPUT_DOMAIN
if [ -n "$INPUT_DOMAIN" ]; then
    PUBLIC_DOMAIN="$INPUT_DOMAIN"
fi

read -p "Enter the email you would like to use for the proxy:" INPUT_EMAIL


# .env file setup
echo "Configuring .env file"
cp -f $ENV_EXAMPLE $ENV_FILE

echo "Public domain in .env set to: $PUBLIC_DOMAIN"

sed -i "s|<public-domain>|$PUBLIC_DOMAIN|g"  $ENV_FILE

# Caddyfile setup
echo "Configuring Caddyfile"
sudo touch /etc/caddy/Caddyfile
sudo cp $CADDYFILE_EXAMPLE /etc/caddy/Caddyfile

sudo sed -i "s|<public-domain>|$PUBLIC_DOMAIN|g" /etc/caddy/Caddyfile
sudo sed -i "s|<email>|$INPUT_EMAIL|g" /etc/caddy/Caddyfile

echo "Setup complete!"
