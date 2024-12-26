variable "backend_size" {
  description = "Number of servers for backend"
  type        = number
}

variable "frontend_size" {
  description = "Number of servers for backend"
  type        = number
}

variable "backend_name" {
  type        = string
  description = "A name of a cluster backend to create"
  #default     = "cluster"
}

variable "frontend_name" {
  type        = string
  description = "A name of a cluster backend to create"
  #default     = "cluster"
}

variable "system_user" {
  type        = string
  description = "User to connect to VMs"
}

variable "iqn_base" {
  type = string
}
variable "vg_name" {
  type = string

}
variable "lv_name" {
  type = string
}
variable "fs_name" {
  type = string
}