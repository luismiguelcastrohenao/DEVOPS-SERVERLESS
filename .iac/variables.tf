# variable "table_name" {
#   description = "Nombre de la tabla DynamoDB"
#   type        = string
#   default     = "messages-table"
# }

# variable "app_name" {
#   description = "Prefijo de nombres para todos los recursos"
#   type        = string
#   default     = "messagesApp"
# }

variable "myregion" {
  default = "us-east-2"
}

variable "accountId" {
  description = "AWS account ID"
}
