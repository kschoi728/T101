variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type        = string
}

variable "instance_type" {
  description = "the type of ec2 instance to run"
  type = string
}

variable "min_size" {
  description = "the minimum number of ec2 instance in the ASG"
  type = number
}

variable "max_size" {
  description = "the maximum number of ec2 instance in the ASG"
  type = number
}

variable "custom_tags" {
  description = "Custom tags to set on the Instances in the ASG"
  type        = map(string)
  default     = {}
}

variable "enable_autoscaling" {
  description = "If set to true, enable auto scaling"
  type        = bool
}

variable "enable_new_user_data" {
  description = "If set to true, use the new User Data script"
  type        = bool
}