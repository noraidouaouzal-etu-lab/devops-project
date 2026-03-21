# DÉFINITION DES VARIABLES


variable "location" {
  description = "La région Azure pour le déploiement"
  type        = string
  default     = "norwayeast"
}

variable "resource_group_name" {
  description = "Le nom du groupe de ressources"
  type        = string
  default     = "DevOps-Project-RG"
}

variable "vm_size" {
  description = "La taille de la machine virtuelle"
  type        = string
  default     = "Standard_B2ats_v2"
}