locals {
  common_tags = merge(
    {
      Product       = var.tag_product
      Environment   = var.tag_environment
    },
    var.extra_tags,
  )
}
