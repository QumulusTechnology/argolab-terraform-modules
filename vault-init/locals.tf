locals {

  #is_prod_or_dev = var.parent_domain == var.domain ? true : false
  is_prod_or_dev   = true
  domain_name_safe = replace(var.domain, ".", "-dot-")
}
