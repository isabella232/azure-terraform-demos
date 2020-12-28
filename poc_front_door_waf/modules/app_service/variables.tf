variable "name" {
  description = "Specifies the name of the App Service component. Changing this forces a new resource to be created."
}

variable "resource_group_name" {
  description = "Name of the parent resource group"
}

variable "location" {
  description = "Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}

variable "app_service_plan_id" {
  description = "The ID of the App Service Plan within which to create this App Service."
}

variable "linux_fx_version" {
  description = "Linux App Framework and version for the App Service. Possible options are a Docker container (DOCKER|<user/image:tag>), a base-64 encoded Docker Compose file or a base-64 encoded Kubernetes Manifest."
}