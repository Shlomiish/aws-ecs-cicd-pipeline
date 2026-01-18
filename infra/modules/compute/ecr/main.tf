# resource "aws_ecr_repository" "this" {
#   for_each = toset(var.repositories)

#   name                 = "${var.name}/${each.value}"
#   image_tag_mutability = var.image_tag_mutability

#   image_scanning_configuration {
#     scan_on_push = var.scan_on_push
#   }
# }


resource "aws_ecr_repository" "this" {
  for_each = toset(var.repositories)

  name                 = "${var.name}/${each.value}"
  image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  # tags matching this filter stay MUTABLE (can be overwritten)
  image_tag_mutability_exclusion_filter {
    filter_type = "WILDCARD"
    filter      = "latest"
  }
}
