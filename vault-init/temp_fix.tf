# ### Temporary override until we resolve external secrets recycling

# resource "random_password" "temporal_temp_password" {
#   length           = 24
#   special          = true
#   override_special = "!@#%^&*()_-+={}[]"
# }

# resource "postgresql_role" "temporal_temp_role" {
#   name             = "temporal-temp-user"
#   login            = true
#   create_role      = true
#   superuser        = true
#   connection_limit = 5
#   password         = random_password.temporal_temp_password.result
# }

# resource "kubernetes_secret" "temporal_temp_password" {
#   metadata {
#     name      = "temporal-temp-user"
#     namespace = "temporal"
#   }
#   data = {
#     "username" = postgresql_role.temporal_temp_role.name
#     "password" = random_password.temporal_temp_password.result
#   }
#   type = "Opaque"
# }

# resource "random_password" "harbor_temp_password" {
#   length           = 24
#   special          = true
#   override_special = "!@#%^&*()_-+={}[]"
# }

# resource "postgresql_role" "harbor_temp_role" {
#   name             = "harbor-temp-user"
#   login            = true
#   create_role      = true
#   superuser        = true
#   connection_limit = 5
#   password         = random_password.harbor_temp_password.result
# }

# resource "kubernetes_secret" "harbor_temp_password" {
#   metadata {
#     name      = "harbor-temp-user"
#     namespace = "harbor"
#   }
#   data = {
#     "username" = postgresql_role.harbor_temp_role.name
#     "password" = random_password.harbor_temp_password.result
#   }
#   type = "Opaque"
# }


# resource "random_password" "semaphore_temp_password" {
#   length           = 24
#   special          = true
#   override_special = "!@#%^&*()_-+={}[]"
# }

# resource "postgresql_role" "semaphore_temp_role" {
#   name             = "semaphore-temp-user"
#   login            = true
#   create_role      = true
#   superuser        = true
#   connection_limit = 5
#   password         = random_password.semaphore_temp_password.result
# }

# resource "kubernetes_secret" "semaphore_temp_password" {
#   metadata {
#     name      = "semaphore-temp-user"
#     namespace = "semaphore"
#   }
#   data = {
#     "username" = postgresql_role.semaphore_temp_role.name
#     "password" = random_password.semaphore_temp_password.result
#   }
#   type = "Opaque"
# }

# resource "random_password" "keycloak_temp_password" {
#   length           = 24
#   special          = true
#   override_special = "!@#%^&*()_-+={}[]"
# }

# resource "postgresql_role" "keycloak_temp_role" {
#   name             = "keycloak-temp-user"
#   login            = true
#   create_role      = true
#   superuser        = true
#   connection_limit = 5
#   password         = random_password.keycloak_temp_password.result
# }

# resource "kubernetes_secret" "keycloak_temp_password" {
#   metadata {
#     name      = "keycloak-temp-user"
#     namespace = "keycloak"
#   }
#   data = {
#     "username" = postgresql_role.keycloak_temp_role.name
#     "password" = random_password.keycloak_temp_password.result
#   }
#   type = "Opaque"
#   lifecycle {
#     ignore_changes = [
#       metadata["labels"]
#     ]

#   }
# }
