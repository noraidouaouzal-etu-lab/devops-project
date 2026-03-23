# =============================================================================
# PROJET FINAL : INFRASTRUCTURE DEVOPS - MASTER DSBD & IA
# CONFIGURATION TERRAFORM POUR AZURE
# =============================================================================

# 1. Configuration du fournisseur Azure (Azure Resource Manager)
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false 
    }
  }
}

# 2. Création du Groupe de Ressources (Conteneur logique pour le projet)
resource "azurerm_resource_group" "rg" {
  name     = "DevOps-Project-RG"
  location = "norwayeast" # Région recommandée pour la performance
}

# 3. Configuration du Réseau Virtuel (Infrastructure réseau privée)
resource "azurerm_virtual_network" "vnet" {
  name                = "k8s-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Création d'un sous-réseau (Subnet) pour isoler les instances
resource "azurerm_subnet" "subnet" {
  name                 = "k8s-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# 4. Groupe de Sécurité Réseau (Pare-feu pour contrôler le trafic entrant)
resource "azurerm_network_security_group" "nsg" {
  name                = "k8s-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Autorisation du trafic SSH (Port 22) pour l'accès à distance
  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Autorisation du port API Kubernetes (Port 6443)
  security_rule {
    name                       = "Allow-K8s-API"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# =============================================================================
# CONFIGURATION DU NODE MASTER
# =============================================================================

# IP Publique statique pour le Node Master
resource "azurerm_public_ip" "pip_master" {
  name                = "master-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Interface réseau pour le Node Master
resource "azurerm_network_interface" "nic_master" {
  name                = "master-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip_master.id
  }
}

# Machine Virtuelle pour le Node Master (Ubuntu 22.04 LTS)
resource "azurerm_linux_virtual_machine" "master" {
  name                = "k8s-master"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2ats_v2" # Instance économique (1 vCPU, 1GB RAM)
  admin_username      = "azureuser"
  network_interface_ids = [azurerm_network_interface.nic_master.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub") # Authentification par clé SSH
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# =============================================================================
# CONFIGURATION DU NODE WORKER
# =============================================================================

# IP Publique statique pour le Node Worker
resource "azurerm_public_ip" "pip_worker" {
  name                = "worker-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Interface réseau pour le Node Worker
resource "azurerm_network_interface" "nic_worker" {
  name                = "worker-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip_worker.id
  }
}

# Machine Virtuelle pour le Node Worker (Ubuntu 22.04 LTS)
resource "azurerm_linux_virtual_machine" "worker" {
  name                = "k8s-worker"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2ats_v2"
  admin_username      = "azureuser"
  network_interface_ids = [azurerm_network_interface.nic_worker.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}