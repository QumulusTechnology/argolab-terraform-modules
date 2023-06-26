# ArgoLab Vault-Init Terraform Module

This module sets up vault after it has been initialised by ArgoLab

It is designed to be called by terraform-operator and a manifest deployed by ArgoLab.

It sets up the following sections of Vault

* **PKI** (needed for Cert-Manager)

* **Kubernetes Authentication**

* **Azure AD integration**

  * so that you sign on using AzureAD (this will be replaced by KeyCloak)
  * so that you can request temporary credentials that will give you access to Azure

* **Azure AD Groups and Users** - pulls groups and users from Azure and configures them in Vault and adds some policies for the groups

* **KV secret engine** - this is initially used by external-authentication kubernetes operator

* **Database secret engine -** initially to be used by harbor and keycloak



### PKI

The code is located [here](https://github.com/QumulusTechnology/argolab-terraform-modules/blob/main/vault-init/pki.tf)

The initial code sets up the root CA which only occurs on the dev and prod cluster/branch.

Then the code creates a sub-ordinate CA which occurs on every branch and this CA is a sub to the dev/prod deployment which means that you don't need to trust each deployment of vault

Finally the code over [here](https://github.com/QumulusTechnology/argolab-terraform-modules/blob/main/vault-init/cert-manager.tf) creates the PKI role, policy and kubernetes backend role needed for cert-manager to function



### Kubernetes Authentication

The code is located [here](https://github.com/QumulusTechnology/argolab-terraform-modules/blob/main/vault-init/kubernetes.tf)

The enables and configures Kubernetes Authentication



### Azure AD integration

Azure AD is used by vault in 3 ways

1. It's seal is stored in a key hosted by Azure KeyVault. Without this seal, vault will not start even if you use the recovery keys. It is possible to backup the Azure KeyVault key but it can only be restored to the same Azure Subscription. A dedicated service principal with minimal permission is created for vault to use to get access to this keyvault and this is handled by argolab as it needs to be implemented before vault can start.
2. To enable developers to authenticate to Azure - this code is over [here](https://github.com/QumulusTechnology/argolab-terraform-modules/blob/main/vault-init/azure-auth.tf) . A service principal has been created for this specific purpose. This service principal has complete permissions over AzureAD and our subscriptions - So is a "Global Administrator" for Azure AD and Owner of the subscriptions and these credentials need to be protected. Currently they are only stored in the terraform state and in vault. We need to look at better ways of protecting terraform state down the line
3. To enable single-sign-on via Azure AD. (to be replaced by KeyCloak). A 3rd service principal has been created for this and has been configured with relevant SAML configuration and is visible is our Azure App Gallery - this code is over [here](https://github.com/QumulusTechnology/argolab-terraform-modules/blob/main/vault-init/azure-auth.tf). Additonally the code uses additional modules to synchronise AD users and groups - These modules are available [here](https://github.com/QumulusTechnology/terraform-vault-azuread-users) and here [here](https://github.com/QumulusTechnology/terraform-vault-azuread-groups).



### KV secret engine

This is just a simple key value secret engine and the relevant role and policy to enable the external-secret operator to access it.

Additonally the external-secret operator will need the following manifests which are part of ArgoLab and managd by ArgoCD.

###### ClusterRoleBinding

*Allows external secrets to use delegated kubernetes authentication to access vault using a service account*

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: external-secrets-credentials-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: external-secrets-credentials
  namespace: external-secrets
```

###### ServiceAccount

*The service account used by external-secrets to authenticate to vault*

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: external-secrets-credentials`
```

###### ClusterSecretStore

*Defines the actual external-secrets store*

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: vault-secrets
spec:
  provider:
    vault:
      server: http://vault-internal.vault:8200
      path: secret
      version: v2
      auth:
        kubernetes:
          mountPath: kubernetes
          role: secrets-access
          serviceAccountRef:
            name: external-secrets-credentials
            namespace: external-secrets
```



### Database secret engine

This for secrets that define usernames and password for databases (initially just progres for now)

The secret will be a temporary password issued and rotated by vault according to policy and synchronised to a kubernetes secret by the external-secrets operator

The main code is available over [here](https://github.com/QumulusTechnology/argolab-terraform-modules/blob/main/vault-init/database.tf).

I will break it down because it took me a while to grasp how it all tied together and hopefull this will make it easier for anyone to add new databases as required.

The first step to adding a new database is to add an init job in the postgres helm values manifest over [here](https://github.com/QumulusTechnology/argolab/blob/dev/services/database/config/values.yaml).

Here is an example

```yaml
primary:
  initdb:
    scripts:
      keycloak-init.sh: |
        export PGPASSWORD=$POSTGRES_PASSWORD
        echo "Creating keycloak database and role, and adding keycloak-admin user"
        psql -U postgres <<EOF
        CREATE USER "keycloak" WITH LOGIN PASSWORD '$POSTGRES_PASSWORD';
        CREATE DATABASE keycloak OWNER keycloak;
        EOF
```

Then you need to create a vault database static role and relevant policy. This is currently handled by terraform in this module in the file above

Here is an example

```yaml
resource "vault_database_secret_backend_static_role" "keycloak" {
  name                = "keycloak"
  backend             = vault_database_secrets_mount.db.path
  db_name             = vault_database_secrets_mount.db.postgresql[0].name
  username            = "keycloak"
  rotation_period     = "3600"
  rotation_statements = ["ALTER USER \"{{username}}\" WITH PASSWORD '{{password}}';"]
}

resource "vault_policy" "keycloak_database_access" {
  name   = "keycloak-database-access"
  policy = <<EOT
path "database/static-creds/keycloak" {
  capabilities = [ "read" ]
}
EOT
}
```

You will also need to add the static role to the vault database secrets mount shown below under the allowed_roles option.

```yaml
resource "vault_database_secrets_mount" "db" {
  path = "database"
  postgresql {
    name           = "postgres"
    connection_url = "postgres://{{username}}:${data.kubernetes_secret.database_password.data["initialPassword"]}@postgres.database.svc:5432/postgres"
    username       = "postgres"
    password       = data.kubernetes_secret.database_password.data["initialPassword"]
    allowed_roles  = ["harbor", "keycloak"]
  }
}

```

Then you need to allow external secrets to access the static role via a kubernetes service account, this is done in a similar way to cert-manager for PKI

The vault kubernetes auth backend role which the service account will authenticate against is handled in this [file](https://github.com/QumulusTechnology/argolab-terraform-modules/blob/main/vault-init/external-secrets.tf).

Here is what is required for KeyCloak.

```yaml
resource "vault_kubernetes_auth_backend_role" "keycloak" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "keycloak-database-access"
  bound_service_account_names      = ["keycloak-database-credentials"]
  bound_service_account_namespaces = ["keycloak"]
  token_ttl                        = 3600
  token_policies                   = ["keycloak-database-access"]
}
```

Kubernetes will need to be configured to allow the service account to authenticate. This is done in argolab as a kubernetes manifest over [here](https://github.com/QumulusTechnology/argolab/blob/daniel/services/keycloak/manifests/instance/keycloak-database-credentials.yaml).

Here is what is required for KeyCloak. There is a service account and ClusterRoleBinding

```yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: keycloak-database-credentials
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: keycloak-database-credentials-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: keycloak-database-credentials
  namespace: keycloak
```

Finally, external-secrets needs to be configured to synchronise the password. This is done by creating a VaultDynamicSecret which allows external-secret to query any type of secret store and ExternalSecret which actually synchronises the secret

```yaml
apiVersion: generators.external-secrets.io/v1alpha1
kind: VaultDynamicSecret
metadata:
  name: keycloak-database-credentials
spec:
  path: database/static-creds/keycloak
  method: GET
  provider:
    server: http://vault-internal.vault:8200
    version: v1
    auth:
      kubernetes:
        mountPath: kubernetes
        role: keycloak-database-access
        serviceAccountRef:
          name: keycloak-database-credentials
          namespace: keycloak
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: keycloak-database-credentials
spec:
  refreshInterval: '15m'
  dataFrom:
    - sourceRef:
        generatorRef:
          apiVersion: generators.external-secrets.io/v1alpha1
          kind: VaultDynamicSecret
          name: 'keycloak-database-credentials'
```
