variable "zip_file" {
  type = string
}
variable "function_name" {
  type = string
}
variable "handler" {
  type = string
}
variable "dynamodb_table_name" {
  type = string
}
variable "policy" {
  type = map(any)
  # {
  #     "Effect" : "Allow",
  #     "Action" : var.allowed_actions,
  #     "Resource" : "${var.dynamodb_table_arn}"
  #     }
}
variable "logs_retention_in_days" {
  type    = number
  default = 1
}
