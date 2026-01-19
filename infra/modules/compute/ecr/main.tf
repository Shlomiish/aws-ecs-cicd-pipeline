# ------ ECR REPOSITORIES (PER SERVICE) ------

resource "aws_ecr_repository" "this" {
  for_each = toset(var.repositories) # Creates one ECR repo per element from the array - ecr_repositories

  name                 = "${var.name}/${each.value}"
  image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"

# ------ IMAGE SCANNING ------

  image_scanning_configuration {
    scan_on_push = var.scan_on_push # Enables vulnerability scanning (like CVE = a international repo with vulnerability id) and check if my image in the list
  }

# ------ TAG MUTABILITY EXCEPTIONS ------

  # tags matching this filter stay MUTABLE (can be overwritten)
  image_tag_mutability_exclusion_filter {
    filter_type = "WILDCARD"
    filter      = "latest"
  }
}
