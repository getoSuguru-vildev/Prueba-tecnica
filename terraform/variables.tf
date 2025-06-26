variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "project_name" {
  type    = string
  default = "examen-demo"
}

variable "lambda1_package" {
  type        = string
  description = "Ruta al paquete zip de Lambda1"
}
