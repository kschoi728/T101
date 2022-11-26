variable "user_names" {
  description = "Create IAM users with these names"
  type        = list(string)
  default     = ["apeach", "chunsik", "ryan"]
}

variable "give_chunsik_cloudwatch_full_access" {
  description = "If true, neo gets full access to CloudWatch"
  type        = bool
}
