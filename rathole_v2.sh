#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   sleep 1
   exit 1
fi

# just press key to continue
press_key(){
 read -p "Press any key to continue..."
}

# Define a function to colorize text
colorize() {
    local color="$1"
    local text="$2"
    local style="${3:-normal}"
    
    # Define ANSI color codes
    local black="\033[30m"
    local red="\033[31m"
    local green="\033[32m"
    local yellow="\033[33m"
    local blue="\033[34m"
    local magenta="\033[35m"
    local cyan="\033[36m"
    local white="\033[37m"
    local reset="\033[0m"
    
    # Define ANSI style codes
    local normal="\033[0m"
    local bold="\033[1m"
    local underline="\033[4m"
    # Select color code
    local color_code
    case $color in
        black) color_code=$black ;;
        red) color_code=$red ;;
        green) color_code=$green ;;
        yellow) color_code=$yellow ;;
        blue) color_code=$blue ;;
        magenta) color_code=$magenta ;;
        cyan) color_code=$cyan ;;
        white) color_code=$white ;;
        *) color_code=$reset ;;  # Default case, no color
    esac
    # Select style code
    local style_code
    case $style in
        bold) style_code=$bold ;;
        underline) style_code=$underline ;;
        normal | *) style_code=$normal ;;  # Default case, normal text
    esac

    # Print the colored and styled text
    echo -e "${style_code}${color_code}${text}${reset}"
}

# Function to install unzip if not already installed
install_unzip() {
    if ! command -v unzip &> /dev/null; then
        # Check if the system is using apt package manager
        if command -v apt-get &> /dev/null; then
            echo -e "${RED}unzip is not installed. Installing...${NC}"
            sleep 1
            sudo apt-get update
            sudo apt-get install -y unzip
        else
            echo -e "${RED}Error: Unsupported package manager. Please install unzip manually.${NC}\n"
            press_key
            exit 1
        fi
    fi
}
# Install unzip
install_unzip

#Function to install cron if not already installed
install_cron() {
    if ! command -v cron &> /dev/null; then
        # Check if the system is using apt package manager
        if command -v apt-get &> /dev/null; then
            echo -e "${RED}cron is not installed. Installing...${NC}"
            sleep 1
            sudo apt-get update
            sudo apt-get install -y cron
        else
            echo -e "${RED}Error: Unsupported package manager. Please install cron manually.${NC}\n"
            press_key
            exit 1
        fi
    fi
}

# Install cron
install_cron

# Function to install jq if not already installed
install_jq() {
    if ! command -v jq &> /dev/null; then
        # Check if the system is using apt package manager
        if command -v apt-get &> /dev/null; then
            echo -e "${RED}jq is not installed. Installing...${NC}"
            sleep 1
            sudo apt-get update
            sudo apt-get install -y jq
        else
            echo -e "${RED}Error: Unsupported package manager. Please install jq manually.${NC}\n"
            press_key
            exit 1
        fi
    fi
}

# Install jq
install_jq

config_dir="/root/rathole-core"
# Function to download and extract Rathole Core
download_and_extract_rathole() {
    # check if core installed already
    if [[ -f "${config_dir}/rathole" ]]; then
        if [[ "$1" == "sleep" ]]; then
        	echo 
            colorize green "Rathole Core is already installed." bold
        	sleep 1
       	fi 
        return 1
    fi

    # Define the entry to check/add
     ENTRY="185.199.108.133 raw.githubusercontent.com"
    # Check if the github entry exists in /etc/hosts
    if ! grep -q "$ENTRY" /etc/hosts; then
	echo "Github Entry not found. Adding to /etc/hosts..."
        echo "$ENTRY" >> /etc/hosts
    else
    echo "Github entry already exists in /etc/hosts."
    fi

    # Check operating system
    if [[ $(uname) == "Linux" ]]; then
        ARCH=$(uname -m)
        DOWNLOAD_URL=$(curl -sSL https://api.github.com/repos/rapiz1/rathole/releases/latest | grep -o "https://.*$ARCH.*linux.*zip" | head -n 1)
    else
        echo -e "${RED}Unsupported operating system.${NC}"
        sleep 1
        exit 1
    fi
    if [[ "$ARCH" == "x86_64" ]]; then
    	DOWNLOAD_URL='https://github.com/Musixal/rathole-tunnel/raw/main/core/rathole.zip'
    fi

    if [ -z "$DOWNLOAD_URL" ]; then
        echo -e "${RED}Failed to retrieve download URL.${NC}"
        sleep 1
        exit 1
    fi

    DOWNLOAD_DIR=$(mktemp -d)
    echo -e "Downloading Rathole from $DOWNLOAD_URL...\n"
    sleep 1
    curl -sSL -o "$DOWNLOAD_DIR/rathole.zip" "$DOWNLOAD_URL"
    echo -e "Extracting Rathole...\n"
    sleep 1
    unzip -q "$DOWNLOAD_DIR/rathole.zip" -d "$config_dir"
    echo -e "${GREEN}Rathole installation completed.${NC}\n"
    chmod u+x ${config_dir}/rathole
    rm -rf "$DOWNLOAD_DIR"
}

#Download and extract the Rathole core
download_and_extract_rathole

# Get server IP
#SERVER_IP=$(hostname -I | awk '{print $1}')

# Fetch server country
SERVER_COUNTRY=$(curl -sS "http://ipwhois.app/json/$SERVER_IP" | jq -r '.country')

# Fetch server isp 
SERVER_ISP=$(curl -sS "http://ipwhois.app/json/$SERVER_IP" | jq -r '.isp')

# Function to display ASCII logo
# Function to display ASCII logo
display_logo() {   
    echo -e "${CYAN}"
    cat << "EOF"
               __  .__           .__          
____________ _/  |_|  |__   ____ |  |   ____  
\_  __ \__  \\   __|  |  \ /  _ \|  | _/ __ \ 
 |  | \// __ \|  | |   Y  (  <_> |  |_\  ___/ 
 |__|  (____  |__| |___|  /\____/|____/\___  >
            \/          \/                 \/ 	
EOF
    echo -e "${NC}${GREEN}"
    echo -e "Version: ${YELLOW}v2.0${GREEN}"
    echo -e "Github: ${YELLOW}github.com/Musixal/Rathole-Tunnel${GREEN}"
    echo -e "Telegram Channel: ${YELLOW}@Gozar_Xray${NC}"
}

# Function to display server location and IP
display_server_info() {
    echo -e "\e[93m═════════════════════════════════════════════\e[0m"  
 	#	Hidden for security issues   
    #echo -e "${CYAN}IP Address:${NC} $SERVER_IP"
    echo -e "${CYAN}Location:${NC} $SERVER_COUNTRY "
    echo -e "${CYAN}Datacenter:${NC} $SERVER_ISP"
}

# Function to display Rathole Core installation status
display_rathole_core_status() {
    if [[ -f "${config_dir}/rathole" ]]; then
        echo -e "${CYAN}Rathole Core:${NC} ${GREEN}Installed${NC}"
    else
        echo -e "${CYAN}Rathole Core:${NC} ${RED}Not installed${NC}"
    fi
    echo -e "\e[93m═════════════════════════════════════════════\e[0m"  
}

# Function to check if a given string is a valid IPv6 address
check_ipv6() {
    local ip=$1
    # Define the IPv6 regex pattern
    ipv6_pattern="^([0-9a-fA-F]{1,4}:){7}([0-9a-fA-F]{1,4}|:)$|^(([0-9a-fA-F]{1,4}:){1,7}|:):((:[0-9a-fA-F]{1,4}){1,7}|:)$"
    # Remove brackets if present
    ip="${ip#[}"
    ip="${ip%]}"

    if [[ $ip =~ $ipv6_pattern ]]; then
        return 0  # Valid IPv6 address
    else
        return 1  # Invalid IPv6 address
    fi
}

check_port() {
    local PORT=$1
	local TRANSPORT=$2
	
    if [ -z "$PORT" ]; then
        echo "Usage: check_port <port> <transport>"
        return 1
    fi
    
	if [[ "$TRANSPORT" == "tcp" ]]; then
		if ss -tlnp "sport = :$PORT" | grep "$PORT" > /dev/null; then
			return 0
		else
			return 1
		fi
	elif [[ "$TRANSPORT" == "udp" ]]; then
		if ss -ulnp "sport = :$PORT" | grep "$PORT" > /dev/null; then
			return 0
		else
			return 1
		fi
	else
		return 1
   	fi
   	
}

# Function for configuring tunnel
configure_tunnel() {

# check if the rathole-core installed or not
if [[ ! -d "$config_dir" ]]; then
    echo -e "\n${RED}Rathole-core directory not found. Install it first through 'Install Rathole core' option.${NC}\n"
    read -p "Press Enter to continue..."
    return 1
fi

    clear
    colorize green "Essential tips:" bold
    colorize yellow "   Enable TCP_NODELAY to improve the latency but decrease the bandwidth.
   For the high number of connections, I recommend turning off the Heartbeat option" 
    echo
    colorize green "1) Configure for IRAN server" bold
    colorize magenta "2) Configure for KHAREJ server" bold
    echo
    read -p "Enter your choice: " configure_choice
    case "$configure_choice" in
        1) iran_server_configuration ;;
        2) kharej_server_configuration ;;
        *) echo -e "${RED}Invalid option!${NC}" && sleep 1 ;;
    esac
    echo
    read -p "Press Enter to continue..."
}


#Global Variables
service_dir="/etc/systemd/system"
  
# Function to configure Iran server
iran_server_configuration() {  
    clear
    colorize cyan "Configuring IRAN server" bold
    
    echo
    
    #Add IPv6 Support
	local_ip='0.0.0.0'
	read -p "[-] Listen for IPv6 address? (y/n): " answer
	if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
	    colorize yellow "IPv6 Enabled"
	    local_ip='[::]'
	elif [ "$answer" = "n" ]; then
	    colorize yellow "IPv4 Enabled"
	    local_ip='0.0.0.0'
	else
	    colorize yellow "Invalid choice. IPv4 enabled by default."
	    local_ip='0.0.0.0'
	fi

	echo 
	
	while true; do
	    echo -ne "[*] Tunnel port: "
	    read -r tunnel_port
	
	    if [[ "$tunnel_port" =~ ^[0-9]+$ ]] && [ "$tunnel_port" -gt 22 ] && [ "$tunnel_port" -le 65535 ]; then
	        if check_port "$tunnel_port" "tcp"; then
	            colorize red "Port $tunnel_port is in use."
	        else
	            break
	        fi
	    else
	        colorize red "Please enter a valid port number between 23 and 65535"
	    fi
	done
	
	echo
	
	# Initialize nodelay variable
	local nodelay=""
	# Keep prompting the user until a valid input is provided
	while [[ "$nodelay" != "true" && "$nodelay" != "false" ]]; do
	    echo -ne "[*] Enable TCP_NODELAY (true/false): " 
	    read -r nodelay
	    if [[ "$nodelay" != "true" && "$nodelay" != "false" ]]; then
	        colorize red "Invalid TCP_NODELAY value. Please enter 'true' or 'false'"
	    fi
	done
    
    echo
    
    # Initialize HEARTBEAT variable
	local HEARTBEAT=""
	# Keep prompting the user until a valid input is provided
	while [[ "$HEARTBEAT" != "true" && "$HEARTBEAT" != "false" ]]; do
	    echo -ne "[*] Enable HEARTBEAT (true/false): " 
	    read -r HEARTBEAT
	    if [[ "$HEARTBEAT" != "true" && "$HEARTBEAT" != "false" ]]; then
	        colorize red "Invalid HEARTBEAT value. Please enter 'true' or 'false'"
	    fi
	done
    
    if [[ "$HEARTBEAT" == "true" ]]; then
    	HEARTBEAT="30"
    else
    	HEARTBEAT="0"
    fi
    echo
    
    # Initialize transport variable
	local transport=""
	# Keep prompting the user until a valid input is provided
	while [[ "$transport" != "tcp" && "$transport" != "udp" ]]; do
	    # Prompt the user to input transport type
	    echo -ne "[*] Transport type(tcp/udp): " 
	    read -r transport
	
	    # Check if the input is either tcp or udp
	    if [[ "$transport" != "tcp" && "$transport" != "udp" ]]; then
	        colorize red "Invalid transport type. Please enter 'tcp' or 'udp'"
	    fi
	done
	
	echo 

	echo -ne "[-] Security Token (press enter to use default value): "
	read -r token
	if [[ -z "$token" ]]; then
		token="musixal"
	fi

	echo 
	
	# Prompt for Ports
	echo -ne "[*] Enter your ports separated by commas (e.g. 2070,2080): "
	read -r input_ports
	input_ports=$(echo "$input_ports" | tr -d ' ')
	# Convert the input into an array, splitting by comma
	IFS=',' read -r -a ports <<< "$input_ports"
	declare -a config_ports
	# Iterate through each port and perform an action
	for port in "${ports[@]}"; do
		if [[ "$port" =~ ^[0-9]+$ ]] && [ "$port" -gt 22 ] && [ "$port" -le 65535 ]; then
			if check_port "$port" "$transport"; then
			    colorize red "[ERROR] Port $port is in use."
			else
				colorize green "[INFO] Port $port added to your configs"
			    config_ports+=("$port")
			fi
		else
			colorize red "[ERROR] Port $port is Invalid. Please enter a valid port number between 23 and 65535"
		fi
	  
	done

	if [ ${#config_ports[@]} -eq 0 ]; then
		colorize red "No ports were entered. Exiting." bold
		sleep 2
		return 1
	fi
	
	
    # Generate server configuration file
    cat << EOF > "${config_dir}/iran${tunnel_port}.toml"
[server]
bind_addr = "${local_ip}:${tunnel_port}"
default_token = "$token"
heartbeat_interval = $HEARTBEAT

[server.transport]
type = "tcp"

[server.transport.tcp]
nodelay = $nodelay

EOF

    # Add each config port to the configuration file
    for port in "${config_ports[@]}"; do
        cat << EOF >> "${config_dir}/iran${tunnel_port}.toml"
[server.services.${port}]
type = "$transport"
bind_addr = "${local_ip}:${port}"

EOF
    done

    echo 

    # Create the systemd service unit file
    cat << EOF > "${service_dir}/rathole-iran${tunnel_port}.service"
[Unit]
Description=Rathole Iran Port $tunnel_port (Iran)
After=network.target

[Service]
Type=simple
ExecStart=${config_dir}/rathole ${config_dir}/iran${tunnel_port}.toml
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd to read the new unit file
    systemctl daemon-reload >/dev/null 2>&1

    # Enable and start the service to start on boot
    if systemctl enable --now "${service_dir}/rathole-iran${tunnel_port}.service" >/dev/null 2>&1; then
        colorize green "Iran service with port $tunnel_port enabled to start on boot and started."
    else
        colorize red "Failed to enable service with port $tunnel_port. Please check your system configuration."
        return 1
    fi
     
    echo
    colorize green "IRAN server configuration completed successfully."
}

#Function for configuring Kharej server
kharej_server_configuration() {
    clear
    colorize cyan "Configuring kharej server" bold 
    
    echo
 
	# Prompt for IRAN server IP address
	while true; do
	    echo -ne "[*] IRAN server IP address [IPv4/IPv6]: " 
	    read -r SERVER_ADDR
	    if [[ -n "$SERVER_ADDR" ]]; then
	        break
	    else
	        colorize red "Server address cannot be empty. Please enter a valid address."
	        echo
	    fi
	done
	
    echo
    
    # Read the tunnel port
 	while true; do
	    echo -ne "[*] Tunnel port: "
	    read -r tunnel_port
	
	    if [[ "$tunnel_port" =~ ^[0-9]+$ ]] && [ "$tunnel_port" -gt 22 ] && [ "$tunnel_port" -le 65535 ]; then
	       	break
	    else
	        colorize red "Please enter a valid port number between 23 and 65535"
	    fi
	done
    
    echo
    
	# Initialize nodelay variable
	local nodelay=""
	# Keep prompting the user until a valid input is provided
	while [[ "$nodelay" != "true" && "$nodelay" != "false" ]]; do
	    echo -ne "[*] TCP_NODELAY (true/false): " 
	    read -r nodelay
	    if [[ "$nodelay" != "true" && "$nodelay" != "false" ]]; then
	        colorize red "Invalid nodelay input. Please enter 'true' or 'false'"
	    fi
	done

	echo
	
	# Initialize HEARTBEAT variable
	local HEARTBEAT=""
	# Keep prompting the user until a valid input is provided
	while [[ "$HEARTBEAT" != "true" && "$HEARTBEAT" != "false" ]]; do
	    echo -ne "[*] Enable HEARTBEAT (true/false): " 
	    read -r HEARTBEAT
	    if [[ "$HEARTBEAT" != "true" && "$HEARTBEAT" != "false" ]]; then
	        colorize red "Invalid HEARTBEAT value. Please enter 'true' or 'false'"
	    fi
	done
    
    if [[ "$HEARTBEAT" == "true" ]]; then
    	HEARTBEAT="40"
    else
    	HEARTBEAT="0"
    fi
    
    echo

    # Initialize transport variable
    local transport=""

	# Keep prompting the user until a valid input is provided
	while [[ "$transport" != "tcp" && "$transport" != "udp" ]]; do
	    # Prompt the user to input transport type
	    echo -ne "[*] Transport type (tcp/udp): " 
	    read -r transport
	
	    # Check if the input is either tcp or udp
	    if [[ "$transport" != "tcp" && "$transport" != "udp" ]]; then
	        colorize red "Invalid transport type. Please enter 'tcp' or 'udp'"
	    fi
	done

	echo

	echo -ne "[-] Security Token (press enter to use default value): "
	read -r token
	if [[ -z "$token" ]]; then
		token="musixal"
	fi

	echo
	
		
	# Prompt for Ports
	echo -ne "[*] Enter your ports separated by commas (e.g. 2070,2080): "
	read -r input_ports
	input_ports=$(echo "$input_ports" | tr -d ' ')
	declare -a config_ports
	# Convert the input into an array, splitting by comma
	IFS=',' read -r -a ports <<< "$input_ports"
	# Iterate through each port and perform an action
	for port in "${ports[@]}"; do
		if [[ "$port" =~ ^[0-9]+$ ]] && [ "$port" -gt 22 ] && [ "$port" -le 65535 ]; then
			if ! check_port "$port" "$transport" ; then
			    colorize yellow "[INFO] Port $port is not in LISTENING state."
			fi
			colorize green "[INFO] Port $port added to your configs"
		    config_ports+=("$port")
		else
			colorize red "[ERROR] Port $port is Invalid. Please enter a valid port number between 23 and 65535"
		fi
	  
	done
	

	if [ ${#config_ports[@]} -eq 0 ]; then
		colorize red "No ports were entered. Exiting." bold
		sleep 2
		return 1
	fi
	
	
	#Add IPv6 Support
	local_ip='0.0.0.0'
	if check_ipv6 "$SERVER_ADDR"; then
	    local_ip='[::]'
	    # Remove brackets if present
	    SERVER_ADDR="${SERVER_ADDR#[}"
	    SERVER_ADDR="${SERVER_ADDR%]}"
	fi

    # Generate server configuration file
    cat << EOF > "${config_dir}/kharej${tunnel_port}.toml"
[client]
remote_addr = "${SERVER_ADDR}:${tunnel_port}"
default_token = "$token"
heartbeat_timeout = $HEARTBEAT
retry_interval = 1

[client.transport]
type = "tcp"

[client.transport.tcp]
nodelay = $nodelay

EOF

    # Add each config port to the configuration file
    for port in "${config_ports[@]}"; do
        cat << EOF >> "${config_dir}/kharej${tunnel_port}.toml"
[client.services.${port}]
type = "$transport"
local_addr = "${local_ip}:${port}"

EOF
    done
    
    echo

    # Create the systemd service unit file
    cat << EOF > "${service_dir}/rathole-kharej${tunnel_port}.service"
[Unit]
Description=Rathole Kharej Port $tunnel_port 
After=network.target

[Service]
Type=simple
ExecStart=${config_dir}/rathole ${config_dir}/kharej${tunnel_port}.toml
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd to read the new unit file
    systemctl daemon-reload >/dev/null 2>&1

    # Enable and start the service to start on boot
    if systemctl enable --now "${service_dir}/rathole-kharej${tunnel_port}.service" >/dev/null 2>&1; then
        colorize green "Kharej service with port $tunnel_port enabled to start on boot and started."
    else
        colorize red "Failed to enable service with port $tunnel_port. Please check your system configuration."
        return 1
    fi

    echo
    colorize green "Kharej server configuration completed successfully."
}


# Function for checking tunnel status
check_tunnel_status() {
    echo
    
	# Check for .toml files
	if ! ls "$config_dir"/*.toml 1> /dev/null 2>&1; then
	    colorize red "No config files found in the rathole directory." bold
	    echo 
	    press_key
	    return 1
	fi

	clear
    colorize yellow "Checking all services status..." bold
    sleep 1
    echo
    for config_path in "$config_dir"/iran*.toml; do
        if [ -f "$config_path" ]; then
            # Extract config_name without directory path and change it to service name
			config_name=$(basename "$config_path")
			config_name="${config_name%.toml}"
			service_name="rathole-${config_name}.service"
            config_port="${config_name#iran}"
            
			# Check if the rathole-client-kharej service is active
			if systemctl is-active --quiet "$service_name"; then
				colorize green "Iran service with tunnel port $config_port is running"
			else
				colorize red "Iran service with tunnel port $config_port is not running"
			fi
   		fi
    done
    
    for config_path in "$config_dir"/kharej*.toml; do
        if [ -f "$config_path" ]; then
            # Extract config_name without directory path and change it to service name
			config_name=$(basename "$config_path")
			config_name="${config_name%.toml}"
			service_name="rathole-${config_name}.service"
            config_port="${config_name#kharej}"
            
			# Check if the rathole-client-kharej service is active
			if systemctl is-active --quiet "$service_name"; then
				colorize green "Kharej service with tunnel port $config_port is running"
			else
				colorize red "Kharej service with tunnel port $config_port is not running"
			fi
   		fi
    done
    
    
    echo
    press_key
}


# Function for destroying tunnel
tunnel_management() {
	echo
	# Check for .toml files
	if ! ls "$config_dir"/*.toml 1> /dev/null 2>&1; then
	    colorize red "No config files found in the rathole directory." bold
	    echo 
	    press_key
	    return 1
	fi
	
	clear
	colorize cyan "List of existing services to manage:" bold
	echo 
	
	#Variables
    local index=1
    declare -a configs

    for config_path in "$config_dir"/iran*.toml; do
        if [ -f "$config_path" ]; then
            # Extract config_name without directory path
            config_name=$(basename "$config_path")
            
            # Remove "iran" prefix and ".toml" suffix
            config_port="${config_name#iran}"
            config_port="${config_port%.toml}"
            
            configs+=("$config_path")
            echo -e "${MAGENTA}${index}${NC}) ${GREEN}Iran${NC} service, Tunnel port: ${YELLOW}$config_port${NC}"
            ((index++))
        fi
    done
    

    
    for config_path in "$config_dir"/kharej*.toml; do
        if [ -f "$config_path" ]; then
            # Extract config_name without directory path
            config_name=$(basename "$config_path")
            
            # Remove "kharej" prefix and ".toml" suffix
            config_port="${config_name#kharej}"
            config_port="${config_port%.toml}"
            
            configs+=("$config_path")
            echo -e "${MAGENTA}${index}${NC}) ${GREEN}Kharej${NC} service, Tunnel port: ${YELLOW}$config_port${NC}"
            ((index++))
        fi
    done
    
    echo
	echo -ne "Enter your choice (0 to return): "
    read choice 
	
	# Check if the user chose to return
	if (( choice == 0 )); then
	    return
	fi
	#  validation
	while ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 0 || choice > ${#configs[@]} )); do
	    colorize red "Invalid choice. Please enter a number between 1 and ${#configs[@]}." bold
	    echo
	    echo -ne "Enter your choice (0 to return): "
	    read choice
		if (( choice == 0 )); then
			return
		fi
	done
	
	selected_config="${configs[$((choice - 1))]}"
	config_name=$(basename "${selected_config%.toml}")
	service_name="rathole-${config_name}.service"
	  
	clear
	colorize cyan "List of available commands for $config_name:" bold
	echo 
	colorize red "1) Remove this tunnel"
	colorize yellow "2) Restart this tunnel"
	colorize green "3) Add a new config for this tunnel"
	colorize reset "4) Add a cronjob for this tunnel"
	colorize reset "5) Remove existing cronjob for this tunnel"
	colorize reset "6) View service logs"
    colorize reset "7) View service status"
	echo 
	read -p "Enter your choice (0 to return): " choice
	
    case $choice in
        1) destroy_tunnel "$selected_config" ;;
        2) restart_service "$service_name" ;;
        3) add_new_config "$selected_config" ;;
        4) add_cron_job_menu "$service_name";;
        5) delete_cron_job "$service_name";;
        6) view_service_logs "$service_name" ;;
        7) view_service_status "$service_name" ;;
        0) return 1 ;;
        *) echo -e "${RED}Invalid option!${NC}" && sleep 1 && return 1;;
    esac
	
}

remove_core(){
	echo
	# If user try to remove core and still a service is running, we should prohibit this.	
	# Check if any .toml file exists
	if find "$config_dir" -type f -name "*.toml" | grep -q .; then
	    colorize red "You should delete all services first and then delete the rathole-core."
	    sleep 3
	    return 1
	else
	    colorize cyan "No .toml file found in the directory."
	fi

	echo
	
	# Prompt to confirm before removing Rathole-core directory
	colorize yellow "Do you want to remove rathole-core? (y/n)"
    read -r confirm
	echo     
	if [[ $confirm == [yY] ]]; then
	    if [[ -d "$config_dir" ]]; then
	        rm -rf "$config_dir" >/dev/null 2>&1
	        colorize green "Rathole-core directory removed." bold
	    else
	        colorize red "Rathole-core directory not found." bold
	    fi
	else
	    colorize yellow "Rathole core removal canceled."
	fi
	
	echo
	press_key
}

destroy_tunnel(){
	echo
	#Vaiables
	config_path="$1"
	config_name=$(basename "${config_path%.toml}")
    service_name="rathole-${config_name}.service"
    service_path="$service_dir/$service_name"
    
	# Check if config exists and delete it
	if [ -f "$config_path" ]; then
	  rm -f "$config_path" >/dev/null 2>&1
	fi

    delete_cron_job $service_name
    
    # Stop and disable the client service if it exists
    if [[ -f "$service_path" ]]; then
        if systemctl is-active "$service_name" &>/dev/null; then
            systemctl disable --now "$service_name" >/dev/null 2>&1
        fi
        rm -f "$service_path" >/dev/null 2>&1
    fi
    
        
    echo
    # Reload systemd to read the new unit file
    if systemctl daemon-reload >/dev/null 2>&1 ; then
        echo -e "Systemd daemon reloaded.\n"
    else
        echo -e "${RED}Failed to reload systemd daemon. Please check your system configuration.${NC}"
    fi
    
    echo -e "${GREEN}Tunnel destroyed successfully! ${NC}"
    echo
    sleep 1

}


#Function to restart services
restart_service() {
    echo
    service_name="$1"
    colorize yellow "Restarting $service_name" bold
    echo
    
    # Check if service exists
    if systemctl list-units --type=service | grep -q "$service_name"; then
        systemctl restart "$service_name"
        colorize green "Service restarted successfully"

    else
        colorize red "Cannot restart the service" 
    fi
    echo
    press_key
}


# Function to add cron-tab job
add_cron_job() {
    local restart_time="$1"
    local reset_path="$2"
    local service_name="$3"

    # Save existing crontab to a temporary file
    crontab -l > /tmp/crontab.tmp

    # Append the new cron job to the temporary file
    echo "$restart_time $reset_path #$service_name" >> /tmp/crontab.tmp

    # Install the modified crontab from the temporary file
    crontab /tmp/crontab.tmp

    # Remove the temporary file
    rm /tmp/crontab.tmp
}
delete_cron_job() {
    echo
    local service_name="$1"
    
    crontab -l | grep -v "#$service_name" | crontab -
    rm -f "$config_dir/${service_name%.service}.sh" >/dev/null 2>&1
    
    colorize green "Cron job for $service_name deleted successfully." bold
    sleep 2
}

add_new_config(){
    echo
    
    local config_path="$1"
    
    #Add IPv6 Support
	local_ip='0.0.0.0'
	read -p "[-] Listen for IPv6 address? (y/n): " answer
	if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
	    colorize yellow "IPv6 Enabled"
	    local_ip='[::]'
	elif [ "$answer" = "n" ]; then
	    colorize yellow "IPv4 Enabled"
	    local_ip='0.0.0.0'
	else
	    colorize yellow "Invalid choice. IPv4 enabled by default."
	    local_ip='0.0.0.0'
	fi
	
	echo 
	
    # Initialize transport variable
	local transport=""
	# Keep prompting the user until a valid input is provided
	while [[ "$transport" != "tcp" && "$transport" != "udp" ]]; do
	    # Prompt the user to input transport type
	    echo -ne "[*] Transport type(tcp/udp): " 
	    read -r transport
	
	    # Check if the input is either tcp or udp
	    if [[ "$transport" != "tcp" && "$transport" != "udp" ]]; then
	        colorize red "Invalid transport type. Please enter 'tcp' or 'udp'"
	    fi
	done
	
	echo
	
    # Prompt for Ports
	echo -ne "[*] Enter your ports separated by commas (e.g. 2070,2080): "
	read -r input_ports
	input_ports=$(echo "$input_ports" | tr -d ' ')
	# Convert the input into an array, splitting by comma
	IFS=',' read -r -a ports <<< "$input_ports"
	declare -a config_ports
	# Iterate through each port and perform an action
	for port in "${ports[@]}"; do
		if [[ "$port" =~ ^[0-9]+$ ]] && [ "$port" -gt 22 ] && [ "$port" -le 65535 ]; then
			    config_ports+=("$port")
		else
			colorize red "[ERROR] Port $port is Invalid. Please enter a valid port number between 23 and 65535"
		fi
	  
	done

	if [ ${#config_ports[@]} -eq 0 ]; then
		colorize red "No ports were entered. Exiting." bold
		sleep 2
		return 1
	fi
	
	echo
	
	if grep -q "iran" <<< "$config_path"; then
	# Add each config port to the configuration file
    for port in "${config_ports[@]}"; do
        cat << EOF >> "$config_path"
[server.services.${port}]
type = "$transport"
bind_addr = "${local_ip}:${port}"

EOF
    done
    
    else   
    # Add each config port to the configuration file
    for port in "${config_ports[@]}"; do
        cat << EOF >> "$config_path"
[client.services.${port}]
type = "$transport"
local_addr = "${local_ip}:${port}"

EOF
    done
    
    fi
        
    colorize green "All ports added to your config successfully" done
    sleep 1
    
    config_name=$(basename "${config_path%.toml}")
	service_name="rathole-${config_name}.service"
	restart_service "$service_name" 
	
}

add_cron_job_menu() {
    echo
    service_name="$1"
    
    # Prompt user to choose a restart time interval
    colorize cyan "Select the restart time interval:" bold
    echo
    echo "1. Every 30th minute"
    echo "2. Every 1 hour"
    echo "3. Every 2 hours"
    echo "4. Every 4 hours"
    echo "5. Every 6 hours"
    echo "6. Every 12 hours"
    echo "7. Every 24 hours"
    echo
    read -p "Enter your choice: " time_choice
    # Validate user input for restart time interval
    case $time_choice in
        1)
            restart_time="*/30 * * * *"
            ;;
        2)
            restart_time="0 * * * *"
            ;;
        3)
            restart_time="0 */2 * * *"
            ;;
        4)
            restart_time="0 */4 * * *"
            ;;
        5)
            restart_time="0 */6 * * *"
            ;;
        6)
            restart_time="0 */12 * * *"
            ;;
        7)
            restart_time="0 0 * * *"
            ;;
        *)
            echo -e "${RED}Invalid choice. Please enter a number between 1 and 7.${NC}\n"
            return 1
            ;;
    esac


    # remove cronjob created by this script
    delete_cron_job $service_name  > /dev/null 2>&1
    
    # Path ro reset file
    reset_path="$config_dir/${service_name%.service}.sh"
    
    #add cron job to kill the running rathole processes
    cat << EOF > "$reset_path"
#! /bin/bash
pids=\$(pgrep rathole)
sudo kill -9 \$pids
sudo systemctl daemon-reload
sudo systemctl restart $service_name
EOF

    # make it +x !
    chmod +x "$reset_path"
    
    # Add cron job to restart the specified service at the chosen time
    add_cron_job  "$restart_time" "$reset_path" "$service_name"
    echo
    colorize green "Cron-job added successfully to restart the service '$service_name'." bold
    sleep 2
}

view_service_logs (){
	clear
	journalctl -eu "$1"

}

view_service_status (){
	clear
	systemctl status "$1"

}

update_script(){
# Define the destination path
DEST_DIR="/usr/bin/"
RATHOLE_SCRIPT="rathole"
SCRIPT_URL="https://github.com/Musixal/rathole-tunnel/raw/main/rathole_v2.sh"

echo
# Check if rathole.sh exists in /bin/bash
if [ -f "$DEST_DIR/$RATHOLE_SCRIPT" ]; then
    # Remove the existing rathole
    rm "$DEST_DIR/$RATHOLE_SCRIPT"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Existing $RATHOLE_SCRIPT has been successfully removed from $DEST_DIR.${NC}"
    else
        echo -e "${RED}Failed to remove existing $RATHOLE_SCRIPT from $DEST_DIR.${NC}"
        sleep 1
        return 1
    fi
else
    echo -e "${YELLOW}$RATHOLE_SCRIPT does not exist in $DEST_DIR. No need to remove.${NC}"
fi
# Download the new rathole.sh from the GitHub URL
#echo -e "${CYAN}Downloading the new $RATHOLE_SCRIPT from $SCRIPT_URL...${NC}"

curl -s -L -o "$DEST_DIR/$RATHOLE_SCRIPT" "$SCRIPT_URL"

echo
if [ $? -eq 0 ]; then
    #echo -e "${GREEN}New $RATHOLE_SCRIPT has been successfully downloaded to $DEST_DIR.${NC}\n"
    chmod +x "$DEST_DIR/$RATHOLE_SCRIPT"
    colorize yellow "Type 'rathole' to run the script.\n" bold
    colorize yellow "For removing script type: 'rm -rf /usr/bin/rathole\n" bold
    press_key
    exit 0
else
    echo -e "${RED}Failed to download $RATHOLE_SCRIPT from $SCRIPT_URL.${NC}"
    sleep 1
    return 1
fi

}

# _________________________ HAWSHEMI SCRIPT OPT FOR UBUNTU _________________________
# Declare Paths & Settings.
SYS_PATH="/etc/sysctl.conf"
PROF_PATH="/etc/profile"

# Ask Reboot
ask_reboot() {
    echo -ne "${YELLOW}Reboot now? (Recommended) (y/n): ${NC}"
    while true; do
        read choice
        echo 
        if [[ "$choice" == 'y' || "$choice" == 'Y' ]]; then
            sleep 0.5
            reboot
            exit 0
        fi
        if [[ "$choice" == 'n' || "$choice" == 'N' ]]; then
            break
        fi
    done
}
# SYSCTL Optimization
sysctl_optimizations() {
    ## Make a backup of the original sysctl.conf file
    cp $SYS_PATH /etc/sysctl.conf.bak

    echo 
    echo -e "${YELLOW}Default sysctl.conf file Saved. Directory: /etc/sysctl.conf.bak${NC}"
    echo 
    sleep 1

    echo 
    echo -e  "${YELLOW}Optimizing the Network...${NC}"
    echo 
    sleep 0.5

    sed -i -e '/fs.file-max/d' \
        -e '/net.core.default_qdisc/d' \
        -e '/net.core.netdev_max_backlog/d' \
        -e '/net.core.optmem_max/d' \
        -e '/net.core.somaxconn/d' \
        -e '/net.core.rmem_max/d' \
        -e '/net.core.wmem_max/d' \
        -e '/net.core.rmem_default/d' \
        -e '/net.core.wmem_default/d' \
        -e '/net.ipv4.tcp_rmem/d' \
        -e '/net.ipv4.tcp_wmem/d' \
        -e '/net.ipv4.tcp_congestion_control/d' \
        -e '/net.ipv4.tcp_fastopen/d' \
        -e '/net.ipv4.tcp_fin_timeout/d' \
        -e '/net.ipv4.tcp_keepalive_time/d' \
        -e '/net.ipv4.tcp_keepalive_probes/d' \
        -e '/net.ipv4.tcp_keepalive_intvl/d' \
        -e '/net.ipv4.tcp_max_orphans/d' \
        -e '/net.ipv4.tcp_max_syn_backlog/d' \
        -e '/net.ipv4.tcp_max_tw_buckets/d' \
        -e '/net.ipv4.tcp_mem/d' \
        -e '/net.ipv4.tcp_mtu_probing/d' \
        -e '/net.ipv4.tcp_notsent_lowat/d' \
        -e '/net.ipv4.tcp_retries2/d' \
        -e '/net.ipv4.tcp_sack/d' \
        -e '/net.ipv4.tcp_dsack/d' \
        -e '/net.ipv4.tcp_slow_start_after_idle/d' \
        -e '/net.ipv4.tcp_window_scaling/d' \
        -e '/net.ipv4.tcp_adv_win_scale/d' \
        -e '/net.ipv4.tcp_ecn/d' \
        -e '/net.ipv4.tcp_ecn_fallback/d' \
        -e '/net.ipv4.tcp_syncookies/d' \
        -e '/net.ipv4.udp_mem/d' \
        -e '/net.ipv6.conf.all.disable_ipv6/d' \
        -e '/net.ipv6.conf.default.disable_ipv6/d' \
        -e '/net.ipv6.conf.lo.disable_ipv6/d' \
        -e '/net.unix.max_dgram_qlen/d' \
        -e '/vm.min_free_kbytes/d' \
        -e '/vm.swappiness/d' \
        -e '/vm.vfs_cache_pressure/d' \
        -e '/net.ipv4.conf.default.rp_filter/d' \
        -e '/net.ipv4.conf.all.rp_filter/d' \
        -e '/net.ipv4.conf.all.accept_source_route/d' \
        -e '/net.ipv4.conf.default.accept_source_route/d' \
        -e '/net.ipv4.neigh.default.gc_thresh1/d' \
        -e '/net.ipv4.neigh.default.gc_thresh2/d' \
        -e '/net.ipv4.neigh.default.gc_thresh3/d' \
        -e '/net.ipv4.neigh.default.gc_stale_time/d' \
        -e '/net.ipv4.conf.default.arp_announce/d' \
        -e '/net.ipv4.conf.lo.arp_announce/d' \
        -e '/net.ipv4.conf.all.arp_announce/d' \
        -e '/kernel.panic/d' \
        -e '/vm.dirty_ratio/d' \
        -e '/^#/d' \
        -e '/^$/d' \
        "$SYS_PATH"


    ## Add new parameteres.

cat <<EOF >> "$SYS_PATH"


################################################################
################################################################


# /etc/sysctl.conf
# These parameters in this file will be added/updated to the sysctl.conf file.
# Read More: https://github.com/hawshemi/Linux-Optimizer/blob/main/files/sysctl.conf


## File system settings
## ----------------------------------------------------------------

# Set the maximum number of open file descriptors
fs.file-max = 67108864


## Network core settings
## ----------------------------------------------------------------

# Specify default queuing discipline for network devices
net.core.default_qdisc = fq_codel

# Configure maximum network device backlog
net.core.netdev_max_backlog = 32768

# Set maximum socket receive buffer
net.core.optmem_max = 262144

# Define maximum backlog of pending connections
net.core.somaxconn = 65536

# Configure maximum TCP receive buffer size
net.core.rmem_max = 33554432

# Set default TCP receive buffer size
net.core.rmem_default = 1048576

# Configure maximum TCP send buffer size
net.core.wmem_max = 33554432

# Set default TCP send buffer size
net.core.wmem_default = 1048576


## TCP settings
## ----------------------------------------------------------------

# Define socket receive buffer sizes
net.ipv4.tcp_rmem = 16384 1048576 33554432

# Specify socket send buffer sizes
net.ipv4.tcp_wmem = 16384 1048576 33554432

# Set TCP congestion control algorithm to BBR
net.ipv4.tcp_congestion_control = bbr

# Configure TCP FIN timeout period
net.ipv4.tcp_fin_timeout = 25

# Set keepalive time (seconds)
net.ipv4.tcp_keepalive_time = 1200

# Configure keepalive probes count and interval
net.ipv4.tcp_keepalive_probes = 7
net.ipv4.tcp_keepalive_intvl = 30

# Define maximum orphaned TCP sockets
net.ipv4.tcp_max_orphans = 819200

# Set maximum TCP SYN backlog
net.ipv4.tcp_max_syn_backlog = 20480

# Configure maximum TCP Time Wait buckets
net.ipv4.tcp_max_tw_buckets = 1440000

# Define TCP memory limits
net.ipv4.tcp_mem = 65536 1048576 33554432

# Enable TCP MTU probing
net.ipv4.tcp_mtu_probing = 1

# Define minimum amount of data in the send buffer before TCP starts sending
net.ipv4.tcp_notsent_lowat = 32768

# Specify retries for TCP socket to establish connection
net.ipv4.tcp_retries2 = 8

# Enable TCP SACK and DSACK
net.ipv4.tcp_sack = 1
net.ipv4.tcp_dsack = 1

# Disable TCP slow start after idle
net.ipv4.tcp_slow_start_after_idle = 0

# Enable TCP window scaling
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_adv_win_scale = -2

# Enable TCP ECN
net.ipv4.tcp_ecn = 1
net.ipv4.tcp_ecn_fallback = 1

# Enable the use of TCP SYN cookies to help protect against SYN flood attacks
net.ipv4.tcp_syncookies = 1


## UDP settings
## ----------------------------------------------------------------

# Define UDP memory limits
net.ipv4.udp_mem = 65536 1048576 33554432


## IPv6 settings
## ----------------------------------------------------------------

# Enable IPv6
net.ipv6.conf.all.disable_ipv6 = 0

# Enable IPv6 by default
net.ipv6.conf.default.disable_ipv6 = 0

# Enable IPv6 on the loopback interface (lo)
net.ipv6.conf.lo.disable_ipv6 = 0


## UNIX domain sockets
## ----------------------------------------------------------------

# Set maximum queue length of UNIX domain sockets
net.unix.max_dgram_qlen = 256


## Virtual memory (VM) settings
## ----------------------------------------------------------------

# Specify minimum free Kbytes at which VM pressure happens
vm.min_free_kbytes = 65536

# Define how aggressively swap memory pages are used
vm.swappiness = 10

# Set the tendency of the kernel to reclaim memory used for caching of directory and inode objects
vm.vfs_cache_pressure = 250


## Network Configuration
## ----------------------------------------------------------------

# Configure reverse path filtering
net.ipv4.conf.default.rp_filter = 2
net.ipv4.conf.all.rp_filter = 2

# Disable source route acceptance
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

# Neighbor table settings
net.ipv4.neigh.default.gc_thresh1 = 512
net.ipv4.neigh.default.gc_thresh2 = 2048
net.ipv4.neigh.default.gc_thresh3 = 16384
net.ipv4.neigh.default.gc_stale_time = 60

# ARP settings
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.all.arp_announce = 2

# Kernel panic timeout
kernel.panic = 1

# Set dirty page ratio for virtual memory
vm.dirty_ratio = 20


################################################################
################################################################


EOF

    sudo sysctl -p
    
    echo 
    echo -e "${GREEN}Network is Optimized.${NC}"
    echo 
    sleep 0.5
}


# System Limits Optimizations
limits_optimizations() {
    echo
    echo -e "${YELLOW}Optimizing System Limits...${NC}"
    echo 
    sleep 0.5

    ## Clear old ulimits
    sed -i '/ulimit -c/d' $PROF_PATH
    sed -i '/ulimit -d/d' $PROF_PATH
    sed -i '/ulimit -f/d' $PROF_PATH
    sed -i '/ulimit -i/d' $PROF_PATH
    sed -i '/ulimit -l/d' $PROF_PATH
    sed -i '/ulimit -m/d' $PROF_PATH
    sed -i '/ulimit -n/d' $PROF_PATH
    sed -i '/ulimit -q/d' $PROF_PATH
    sed -i '/ulimit -s/d' $PROF_PATH
    sed -i '/ulimit -t/d' $PROF_PATH
    sed -i '/ulimit -u/d' $PROF_PATH
    sed -i '/ulimit -v/d' $PROF_PATH
    sed -i '/ulimit -x/d' $PROF_PATH
    sed -i '/ulimit -s/d' $PROF_PATH


    ## Add new ulimits
    ## The maximum size of core files created.
    echo "ulimit -c unlimited" | tee -a $PROF_PATH

    ## The maximum size of a process's data segment
    echo "ulimit -d unlimited" | tee -a $PROF_PATH

    ## The maximum size of files created by the shell (default option)
    echo "ulimit -f unlimited" | tee -a $PROF_PATH

    ## The maximum number of pending signals
    echo "ulimit -i unlimited" | tee -a $PROF_PATH

    ## The maximum size that may be locked into memory
    echo "ulimit -l unlimited" | tee -a $PROF_PATH

    ## The maximum memory size
    echo "ulimit -m unlimited" | tee -a $PROF_PATH

    ## The maximum number of open file descriptors
    echo "ulimit -n 1048576" | tee -a $PROF_PATH

    ## The maximum POSIX message queue size
    echo "ulimit -q unlimited" | tee -a $PROF_PATH

    ## The maximum stack size
    echo "ulimit -s -H 65536" | tee -a $PROF_PATH
    echo "ulimit -s 32768" | tee -a $PROF_PATH

    ## The maximum number of seconds to be used by each process.
    echo "ulimit -t unlimited" | tee -a $PROF_PATH

    ## The maximum number of processes available to a single user
    echo "ulimit -u unlimited" | tee -a $PROF_PATH

    ## The maximum amount of virtual memory available to the process
    echo "ulimit -v unlimited" | tee -a $PROF_PATH

    ## The maximum number of file locks
    echo "ulimit -x unlimited" | tee -a $PROF_PATH


    echo 
    echo -e "${GREEN}System Limits are Optimized.${NC}"
    echo 
    sleep 0.5
}


# _________________________ END OF HAWSHEMI SCRIPT OPT FOR UBUNTU _________________________

hawshemi_script(){
clear

echo -e "${MAGENTA}Special thanks to Hawshemi, the author of optimizer script...${NC}"
sleep 2
# Get the operating system name
os_name=$(lsb_release -is)

echo -e 
# Check if the operating system is Ubuntu
if [ "$os_name" == "Ubuntu" ]; then
  echo -e "${GREEN}The operating system is Ubuntu.${NC}"
  sleep 1
else
  echo -e "${RED} The operating system is not Ubuntu.${NC}"
  sleep 2
  return
fi


sysctl_optimizations
limits_optimizations
ask_reboot
read -p "Press Enter to continue..."
}


install_modified_core(){
	echo
	DOWNLOAD_URL='https://github.com/Musixal/rathole-tunnel/raw/main/core/rathole_modified.zip'
	
	if [ -z "$DOWNLOAD_URL" ]; then
        echo -e "${RED}Failed to retrieve download URL.${NC}"
        sleep 1
        return 1
    fi
    
    DOWNLOAD_DIR=$(mktemp -d)
    echo -e "Downloading modifed rathole-core from $DOWNLOAD_URL...\n"
    sleep 1
    curl -sSL -o "$DOWNLOAD_DIR/rathole_modified.zip" "$DOWNLOAD_URL"
    echo -e "Extracting Rathole...\n"
    sleep 1
    unzip -q "$DOWNLOAD_DIR/rathole_modified.zip" -d "$config_dir"
    mv -f ${config_dir}/rathole_modified ${config_dir}/rathole
    echo -e "${GREEN}Rathole installation completed.${NC}"
    chmod u+x ${config_dir}/rathole
    rm -rf "$DOWNLOAD_DIR"
    echo
}

change_core(){
	echo
	ARCH=$(uname -m)
	if ! [[ "$ARCH" == "x86_64" ]]; then
    	colorize red "Only x86_64 arch. is supported right now!" bold
    	sleep 2
    	return 1
    fi
	 	
	colorize cyan "Select your rathole-core:" bold
	echo
	colorize green "1) Default Core"
	colorize yellow "2) Modified Core (Lower connections, maybe higher latency)"
	colorize reset "3) return "
	echo
	read -p "Enter your choice [1-3]: " choice

	case $choice in
        1) rm -f "${config_dir}/rathole" &> /dev/null 
        download_and_extract_rathole ;;
        2) rm -f "${config_dir}/rathole" &> /dev/null 
        install_modified_core;;
        3) return 1 ;;
        *) echo -e "${RED} Invalid option!${NC}" && sleep 1 && return 1 ;;
    esac
	
	colorize red "IMPORTANT!" bold
	colorize yellow "To load the new core, restart all services." bold
	echo
	press_key

}

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\e[36m'
MAGENTA="\e[95m"
NC='\033[0m' # No Color

# Function to display menu
display_menu() {
    clear
    display_logo
    display_server_info
    display_rathole_core_status
    echo
    colorize green " 1. Configure a new tunnel [IPv4/IPv6]" bold
    colorize red " 2. Tunnel management menu" bold
    colorize cyan " 3. Check tunnels status" bold
 	echo -e " 4. Optimize network & system limits"
 	echo -e " 5. Install rathole core"
 	echo -e " 6. Update & install script"
 	echo -e " 7. Change core [experimental]"
 	echo -e " 8. Remove rathole core"
    echo -e " 0. Exit"
    echo
    echo "-------------------------------"
}

# Function to read user input
read_option() {
    read -p "Enter your choice [0-8]: " choice
    case $choice in
        1) configure_tunnel ;;
        2) tunnel_management ;;
        3) check_tunnel_status ;;
        4) hawshemi_script ;;
        5) download_and_extract_rathole "sleep";;
        6) update_script ;;
        7) change_core ;;
        8) remove_core ;;
        0) exit 0 ;;
        *) echo -e "${RED} Invalid option!${NC}" && sleep 1 ;;
    esac
}

# Main script
while true
do
    display_menu
    read_option
done
