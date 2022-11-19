variable "names" {
  description = "A list of names"
  type        = list(string)
  default     = ["apeach", "chun-sik", "ryan"]
}

output "upper_roles" {
  value = [for name in var.names : upper(name)]
}

output "short_upper_names" {
  value = [for name in var.names : upper(name) if length(name) < 5]
}

variable "Kakao_Friends" {
  description = "map"
  type        = map(string)

  default = {
    apeach   = "bad boy peach"
    chun-sik = "stray cat"
    ryan     = "the escaped prince"
  }
}

output "bios" {
  value = [for name, role in var.Kakao_Friends : "${name} is the ${role}"]
}

output "upper_roles_2" {
  value = {for name, role in var.Kakao_Friends : upper(name) => upper(role)}
}