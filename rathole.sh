#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Function to install unzip if not already installed
install_unzip() {
    if ! command -v unzip &> /dev/null; then
        echo "unzip is not installed. Installing..."
        if [[ $(uname) == "Darwin" ]]; then
            brew install unzip
        else
            sudo apt-get update
            sudo apt-get install -y unzip
        fi
    else
        echo "unzip is already installed."
    fi
}

# Install unzip
install_unzip

# Function to install jq if not already installed
install_jq() {
    if ! command -v jq &> /dev/null; then
        echo "jq is not installed. Installing..."
        if [[ $(uname) == "Darwin" ]]; then
            brew install jq
        else
            sudo apt-get update
            sudo apt-get install -y jq
        fi
    else
        echo "jq is already installed."
    fi
}

# Install jq
install_jq

# Get server IP
SERVER_IP=$(hostname -I | awk '{print $1}')

# Fetch server country using ip-api.com
SERVER_COUNTRY=$(curl -sS "http://ip-api.com/json/$SERVER_IP" | jq -r '.country')

# Fetch server isp using ip-api.com 
SERVER_ISP=$(curl -sS "http://ip-api.com/json/$SERVER_IP" | jq -r '.isp')

# Function to display ASCII logo
display_logo() {
    echo -e "${BLUE}"
    cat << "EOF"
 ____      _  _____ _   _  ___  _     _____ 
|  _ \    / \|_   _| | | |/ _ \| |   | ____|
| |_) |  / _ \ | | | |_| | | | | |   |  _|  
|  _ <  / ___ \| | |  _  | |_| | |___| |___ 
|_| \_\/_/   \_\_| |_| |_|\___/|_____|_____|  
                  By github.com/Musixal v1.0                       
EOF
    echo -e "${NC}"
}

# Function to display server location and IP
display_server_info() {
    echo -e "${GREEN}Server Country:${NC} $SERVER_COUNTRY"
    echo -e "${GREEN}Server IP:${NC} $SERVER_IP"
    echo -e "${GREEN}Server ISP:${NC} $SERVER_ISP"
    echo "-------------------------------"
}

# Function to display Rathole Core installation status
display_rathole_core_status() {
    if [[ -f "/root/rathole-core/rathole" ]]; then
        echo -e "${GREEN}Rathole Core installed.${NC}"
    else
        echo -e "${RED}Rathole Core not installed.${NC}"
    fi
    echo "-------------------------------"
}

# Function to display menu
display_menu() {
    clear
    display_logo
    display_server_info
    display_rathole_core_status
    echo -e "${GREEN}Welcome to Rathole Tunnel Menu${NC}"
    echo "-------------------------------"
    echo -e "${GREEN}1. Configure tunnel${NC}"
    echo -e "${RED}2. Destroy tunnel${NC}"
    echo -e "${BLUE}3. Check tunnel status${NC}"
    echo -e "4. Install Rathole Core"
    echo -e "${YELLOW}5. Restart services${NC}"
    echo -e "6. Add & remove cron-job reset timer"
    echo -e "7. Exit"
    echo "-------------------------------"
}

# Function to read user input
read_option() {
    read -p "Enter your choice: " choice
    case $choice in
        1) configure_tunnel ;;
        2) destroy_tunnel ;;
        3) check_tunnel_status ;;
        4) download_and_extract_rathole ;;
        5) restart_services ;;
        6) cronjob_main ;;
        7) exit 0 ;;
        *) echo -e "${RED}Invalid option!${NC}" && sleep 1 ;;
    esac
}

# Function for configuring tunnel
configure_tunnel() {
    echo -e "${YELLOW}Configuring tunnel...${NC}"
    echo -e "1. Configurating Iran Server"
    echo -e "2. Configurating Kharej Server"
    read -p "Enter your choice: " configure_choice
    case $configure_choice in
        1) iran_server_configuration ;;
        2) kharej_server_configuration ;;
        *) echo -e "${RED}Invalid option!${NC}" && sleep 1 ;;
    esac
    read -p "Press Enter to continue..."
}


# Function to configure Iran server
# Function to configure Iran server
iran_server_configuration() {
    local config_dir="/root/rathole-core"
    local config_file="${config_dir}/server.toml"
    local service_name="rathole-server-iran.service"
    local service_file="/etc/systemd/system/${service_name}"
    
    echo -e "${YELLOW}Configuring Iran server...${NC}"
    
    # Read the tunnel port
    read -p "Enter the tunnel port: " tunnel_port
    while ! [[ "$tunnel_port" =~ ^[0-9]+$ ]]; do
        echo "Please enter a valid port number."
        read -p "Enter the tunnel port: " tunnel_port
    done
    
    # Read the number of config ports and read each port
    read -p "Enter the number of config ports: " num_ports
    while ! [[ "$num_ports" =~ ^[0-9]+$ ]]; do
        echo "Please enter a valid number."
        read -p "Enter the number of config ports: " num_ports
    done
    
    config_ports=()
    for ((i=1; i<=$num_ports; i++)); do
        read -p "Enter Config Port $i: " port
        while ! [[ "$port" =~ ^[0-9]+$ ]]; do
            echo "Please enter a valid port number."
            read -p "Enter Config Port $i: " port
        done
        config_ports+=("$port")
    done

    # Generate server configuration file
    cat << EOF > "$config_file"
[server]
bind_addr = "0.0.0.0:${tunnel_port}"
default_token = "musixal_tunnel"
heartbeat_interval = 30

[server.transport]  # Same as the client
type = "tcp"

[server.transport.tcp] # Same as the client
nodelay = true
keepalive_secs = 20
keepalive_interval = 8
EOF

    # Add each config port to the configuration file
    for port in "${config_ports[@]}"; do
        cat << EOF >> "$config_file"
[server.services.${port}]
bind_addr = "0.0.0.0:${port}"
nodelay = true
EOF
    done

    echo "Iran server configuration completed."
    echo "Starting Rathole server as a service..."

    # Create the systemd service unit file
    cat << EOF > "$service_file"
[Unit]
Description=Rathole Server (Iran)
After=network.target

[Service]
Type=simple
ExecStart=${config_dir}/rathole ${config_file}
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd to read the new unit file
    if systemctl daemon-reload; then
        echo "Systemd daemon reloaded."
    else
        echo "Failed to reload systemd daemon. Please check your system configuration."
        return 1
    fi

    # Enable the service to start on boot
    if systemctl enable "$service_name"; then
        echo "Service '$service_name' enabled to start on boot."
    else
        echo "Failed to enable service '$service_name'. Please check your system configuration."
        return 1
    fi

    # Start the service
    if systemctl start "$service_name"; then
        echo "Service '$service_name' started."
    else
        echo "Failed to start service '$service_name'. Please check your system configuration."
        return 1
    fi

    echo "Rathole server service started."
}

# Function for configuring Kharej server
kharej_server_configuration() {
    local config_dir="/root/rathole-core"
    local config_file="${config_dir}/client.toml"
    local service_name="rathole-client-kharej.service"
    local service_file="/etc/systemd/system/${service_name}"
    
    echo -e "${YELLOW}Configuring kharej server...${NC}"
    
    # Read the server address
    read -p "Enter the Iran server address: " SERVER_ADDR

    # Read the tunnel port
    read -p "Enter the tunnel port: " tunnel_port
    while ! [[ "$tunnel_port" =~ ^[0-9]+$ ]]; do
        echo "Please enter a valid port number."
        read -p "Enter the tunnel port: " tunnel_port
    done
    
    # Read the number of config ports and read each port
    read -p "Enter the number of config ports: " num_ports
    while ! [[ "$num_ports" =~ ^[0-9]+$ ]]; do
        echo "Please enter a valid number."
        read -p "Enter the number of config ports: " num_ports
    done
    
    config_ports=()
    for ((i=1; i<=$num_ports; i++)); do
        read -p "Enter Config Port $i: " port
        while ! [[ "$port" =~ ^[0-9]+$ ]]; do
            echo "Please enter a valid port number."
            read -p "Enter Config Port $i: " port
        done
        config_ports+=("$port")
    done

    # Generate server configuration file
    cat << EOF > "$config_file"
[client]
remote_addr = "${SERVER_ADDR}:${tunnel_port}"
default_token = "musixal_tunnel"
heartbeat_timeout = 40
retry_interval = 1

[client.transport]
type = "tcp"

[client.transport.tcp]
nodelay = true
keepalive_secs = 20
keepalive_interval = 8

EOF

    # Add each config port to the configuration file
    for port in "${config_ports[@]}"; do
        cat << EOF >> "$config_file"
[client.services.${port}]
type = "tcp"
local_addr = "0.0.0.0:${port}"
nodelay = true
retry_interval = 1 
EOF
    done

    echo "Kharej server configuration completed."
    echo "Starting Rathole server as a service..."

    # Create the systemd service unit file
    cat << EOF > "$service_file"
[Unit]
Description=Rathole Server (Kharej)
After=network.target

[Service]
Type=simple
ExecStart=${config_dir}/rathole ${config_file}
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd to read the new unit file
    if systemctl daemon-reload; then
        echo "Systemd daemon reloaded."
    else
        echo "Failed to reload systemd daemon. Please check your system configuration."
        return 1
    fi

    # Enable the service to start on boot
    if systemctl enable "$service_name"; then
        echo "Service '$service_name' enabled to start on boot."
    else
        echo "Failed to enable service '$service_name'. Please check your system configuration."
        return 1
    fi

    # Start the service
    if systemctl start "$service_name"; then
        echo "Service '$service_name' started."
    else
        echo "Failed to start service '$service_name'. Please check your system configuration."
        return 1
    fi

    echo "Rathole client service started."
}

# Function for destroying tunnel
destroy_tunnel() {
    echo -e "${YELLOW}Destroying tunnel...${NC}"

    # Stop and disable the client service if it exists
    service_file="/etc/systemd/system/rathole-client-kharej.service"
    if [[ -f "$service_file" ]]; then
        if systemctl is-active rathole-client-kharej.service &>/dev/null; then
            systemctl stop rathole-client-kharej.service
            systemctl disable rathole-client-kharej.service
        fi
        rm -f "$service_file"
    fi


    # Stop and disable the Iran server service if it exists
    service_file="/etc/systemd/system/rathole-server-iran.service"
    if [[ -f "$service_file" ]]; then
        if systemctl is-active rathole-server-iran.service &>/dev/null; then
            systemctl stop rathole-server-iran.service
            systemctl disable rathole-server-iran.service
        fi
        rm -f "$service_file"
    fi

    echo "Tunnel destroyed successfully!"
    read -p "Press Enter to continue..."
}


# Function for checking tunnel status
check_tunnel_status() {
    echo -e "${YELLOW}Checking tunnel status...${NC}"
    echo "----------------------------------------------------"
    
    # Check if the rathole-client-kharej service is active
    if systemctl is-active --quiet rathole-client-kharej.service; then
        echo -e "${GREEN}Rathole client in Kharej server is running.${NC}"
    else
        echo -e "${RED}Rathole client in Kharej server is not running.${NC}"
    fi
    
    # Check if the rathole-server-iran service is active
    if systemctl is-active --quiet rathole-server-iran.service; then
        echo -e "${GREEN}Rathole server in Iran is running.${NC}"
    else
        echo -e "${RED}Rathole server in Iran is not running.${NC}"
    fi
    
    read -p "Press Enter to continue..."
}

#Function to restart services
restart_services() {
    # Check if rathole-client-kharej.service exists
    if systemctl list-units --type=service | grep -q 'rathole-client-kharej.service'; then
        systemctl restart rathole-client-kharej.service
        echo -e "${GREEN}Rathole Client Kharej service restarted.${NC}"
    fi

    # Check if rathole-server-iran.service exists
    if systemctl list-units --type=service | grep -q 'rathole-server-iran.service'; then
        systemctl restart rathole-server-iran.service
        echo -e "${GREEN}Rathole Server Iran service restarted.${NC}"
    fi

    # If neither service exists
    if ! systemctl list-units --type=service | grep -q 'rathole-client-kharej.service' && \
       ! systemctl list-units --type=service | grep -q 'rathole-server-iran.service'; then
        echo -e "${RED}Neither Rathole Client Kharej service nor Rathole Server Iran service exists.${NC}"
    fi
    
     read -p "Press Enter to continue..."
}

# Function to add cron-tab job
add_cron_job() {
    local service_name=$1
    local restart_time=$2

    # Save existing crontab to a temporary file
    crontab -l > /tmp/crontab.tmp

    # Append the new cron job to the temporary file
    echo "$restart_time systemctl restart $service_name # Added by rathole_script" >> /tmp/crontab.tmp

    # Install the modified crontab from the temporary file
    crontab /tmp/crontab.tmp

    # Remove the temporary file
    rm /tmp/crontab.tmp
}

delete_cron_job() {
    # Delete all cron jobs added by this script
    crontab -l | grep -v '# Added by rathole_script' | crontab -
    echo -e "${GREEN}Cron jobs added by this script have been deleted successfully.${NC}"
}


# Main function to add or delete cron job for restarting services
cronjob_main() {
    echo -e "${BLUE}Welcome to the Cron Job Scheduler for Service Restart${NC}"
    echo "----------------------------------------------------"

    # Prompt user for action
    echo -e "Select an option:"
    echo "1. Add a cron job to restart a service"
    echo "2. Delete cron jobs added by this script"
    read -p "Enter the number corresponding to the desired action: " action_choice

    # Validate user input
    case $action_choice in
        1)
            add_cron_job_menu
            ;;
        2)
            delete_cron_job
            ;;
        *)
            echo -e "${RED}Invalid choice. Please enter 1 or 2.${NC}"
            return 1
            ;;
    esac
    read -p "Press Enter to continue..."
}

add_cron_job_menu() {
    # Prompt user to choose a service
    echo "Select the service you want to restart:"
    echo "1. Rathole Client Kharej"
    echo "2. Rathole Server Iran"
    read -p "Enter the number corresponding to the service you want to restart: " service_choice

    # Validate user input
    case $service_choice in
        1)
            service_name="rathole-client-kharej"
            ;;
        2)
            service_name="rathole-server-iran"
            ;;
        *)
            echo -e "${RED}Invalid choice. Please enter 1 or 2.${NC}"
            return 1
            ;;
    esac

    # Prompt user to choose a restart time interval
    echo "Select the restart time interval:"
    echo "1. Every 1 hour"
    echo "2. Every 2 hours"
    echo "3. Every 4 hours"
    echo "4. Every 6 hours"
    echo "5. Every 12 hours"
    echo "6. Every 24 hours"
    read -p "Enter the number corresponding to the restart time interval: " time_choice

    # Validate user input for restart time interval
    case $time_choice in
        1)
            restart_time="0 * * * *"
            ;;
        2)
            restart_time="0 */2 * * *"
            ;;
        3)
            restart_time="0 */4 * * *"
            ;;
        4)
            restart_time="0 */6 * * *"
            ;;
        5)
            restart_time="0 */12 * * *"
            ;;
        6)
            restart_time="0 0 * * *"
            ;;
        *)
            echo -e "${RED}Invalid choice. Please enter a number between 1 and 6.${NC}"
            return 1
            ;;
    esac

    # Add cron job to restart the specified service at the chosen time
    add_cron_job "$service_name" "$restart_time"

    echo -e "${GREEN}Cron job added successfully to restart the service '$service_name'.${NC}"
}

# Function to download and extract Rathole Core
download_and_extract_rathole() {

    # check if core installed already
    if [[ -f "/root/rathole-core/rathole" ]]; then
        echo -e "${GREEN}Rathole Core is already installed.${NC}"
        read -p "Press Enter to continue..."
        return 1
    fi
    
    # Check operating system
    if [[ $(uname) == "Linux" ]]; then
        ARCH=$(uname -m)
        DOWNLOAD_URL=$(curl -sSL https://api.github.com/repos/rapiz1/rathole/releases/latest | grep -o "https://.*$ARCH.*linux.*zip" | head -n 1)
    elif [[ $(uname) == "Darwin" ]]; then
        DOWNLOAD_URL=$(curl -sSL https://api.github.com/repos/rapiz1/rathole/releases/latest | grep -o "https://.*darwin.*zip" | head -n 1)
    else
        echo "Unsupported operating system."
        exit 1
    fi

    if [ -z "$DOWNLOAD_URL" ]; then
        echo "Failed to retrieve download URL."
        exit 1
    fi

    DOWNLOAD_DIR=$(mktemp -d)
    echo "Downloading Rathole from $DOWNLOAD_URL..."
    curl -sSL -o "$DOWNLOAD_DIR/rathole.zip" "$DOWNLOAD_URL"
    echo "Extracting Rathole..."
    unzip -q "$DOWNLOAD_DIR/rathole.zip" -d /root/rathole-core
    echo "Rathole installation completed."
    rm -rf "$DOWNLOAD_DIR"
}

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Main script
while true
do
    display_menu
    read_option
done
