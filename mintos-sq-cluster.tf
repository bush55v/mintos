terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.12.1"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "mintos" {
  metadata {
    name = "mintos"
  }
}

resource "kubernetes_persistent_volume_claim" "db-pvc" {
  metadata {
    name = "mintos-db-pvc"
    namespace = kubernetes_namespace.mintos.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "8Gi"
      }
    }
  }
}

resource "helm_release" "postgresql" {
  namespace  = kubernetes_namespace.mintos.metadata[0].name
  name       = "mintos-postgresql"
  repository = "oci://registry-1.docker.io/bitnamicharts/"
  chart      = "postgresql"
  # chart      = "postgresql:16.1.0-debian-11-r18"
  # version    = "13.2.27"

  # set {
  #   name  = "SONARQUBE_JDBC_USERNAME"
  #   value = "mintos"
  # }
  # set {
  #   name = "serviceAccount.create"
  #   value = "true"
  # }
  # set {
  #   name  = "auth.postgresUser"
  #   value = "mintos"
  # }
  set {
    name  = "global.postgresql.auth.postgresPassword"
    value = "secretMintos"
  }
  # set {
  #   name = "primary.persistence.enabled"
  #   value = "true"
  # }
  # set {
  #   name = "primary.persistence.existingClaim"
  #   value = kubernetes_persistent_volume_claim.db-pvc.metadata[0].name
  # }
  set {
    name = "global.postgresql.auth.database"
    value = "mintosDB"
  }
  # set {
  #   name = "primary.service.port"
  #   value = "5432"
  # }
  # set {
  #   name = "primary.service.type"
  #   value = "ClusterIP"
  # }
  # set {
  #   name = "backup.enabled"
  #   value = "true"
  # }
  # set {
  #   name = "backup.cronjob.schedule"
  #   value = "@daily"
  # }
}

resource "helm_release" "sonarqube" {
  namespace  = kubernetes_namespace.mintos.metadata[0].name
  name       = "mintos-sonarqube"
  repository = "https://oteemo.github.io/charts"
  chart      = "sonarqube"
  # version    = "9.6.3"

  set {
    name = "postgresql.enabled"
    value = "false"
  }
  set {
    name = "postgresql.postgresqlServer"
    value = helm_release.postgresql.metadata[0].name
  }
    set {
    name = "postgresql.postgresqlUsername"
    value = "postgres"
  }
  set {
    name = "postgresql.postgresqlPassword"
    value = "secretMintos"
  }
  set {
    name = "postgresql.postgresqlDatabase"
    value = "mintosDB"
    # value = helm_release.postgresql.set[5].value
  }
}

resource "helm_release" "nginx_ingress" {
  namespace  = kubernetes_namespace.mintos.metadata[0].name
  name       = "mintos-ingress-controller"
  repository = "oci://registry-1.docker.io/bitnamicharts/"
  chart      = "nginx-ingress-controller"
  # version    = "5.3.2"

  set {
    name = "service.externalTrafficPolicy"
    value = "Local"
  }
  set {
    name = "service.ports"
    value = "{HTTP = 80}"
    # type = "set"
  }
  set {
    name = "service.targetPorts"
    value = "9000"
  }
  set {
    name = "hostAliases"
    value = "mintos.com"
  }

}
