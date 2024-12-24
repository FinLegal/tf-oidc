variable "default_tags" {
  type        = map(string)
  description = "(Required) Default tags specified at the top level of the scalr environment"
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Additional tags to append to all resources"
  default     = {}
}