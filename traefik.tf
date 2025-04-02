# Install Traefik using Helm
resource "helm_release" "traefik" {
  name             = "traefik"
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  namespace        = "traefik"
  create_namespace = true

  # API Gateway settings - only applied when enable_api_gateway or enable_api_management is true
  dynamic "set" {
    for_each = var.enable_api_gateway || var.enable_api_management ? [1] : []
    content {
      name  = "hub.token"
      value = "traefik-hub-license"
    }
  }

  dynamic "set" {
    for_each = var.enable_api_gateway || var.enable_api_management ? [1] : []
    content {
      name  = "image.registry"
      value = "ghcr.io"
    }
  }

  dynamic "set" {
    for_each = var.enable_api_gateway || var.enable_api_management ? [1] : []
    content {
      name  = "image.repository"
      value = "traefik/traefik-hub"
    }
  }

  dynamic "set" {
    for_each = var.enable_api_gateway || var.enable_api_management ? [1] : []
    content {
    name  = "image.tag"
    value = "v3.15.0"
    }
  }

  # API Management settings - only applied when enable_api_management is true
  dynamic "set" {
    for_each = var.enable_api_management ? [1] : []
    content {
      name  = "hub.apimanagement.enabled"
      value = "true"
    }
  }

  # Redis configuration - only applied when API Management is enabled
  dynamic "set" {
    for_each = var.enable_api_management ? [1] : []
    content {
      name  = "hub.redis.endpoints"
      value = "redis-redis-cluster.traefik.svc:6379"
    }
  }

  dynamic "set" {
    for_each = var.enable_api_management ? [1] : []
    content {
      name  = "hub.redis.password"
      value = "topsecretpassword"
    }
  }

  # Deployment settings
  set {
    name  = "deployment.replicas"
    value = "1"
  }

  # Certificate resolver settings
  set {
    name  = "certificatesResolvers.le.acme.email"
    value = "workshops@traefik.io"
  }
  set {
    name  = "certificatesResolvers.le.acme.storage"
    value = "/data/acme.json"
  }
  set {
    name  = "certificatesResolvers.le.acme.tlsChallenge"
    value = "true"
  }

  # Ingress class settings
  set {
    name  = "ingressClass.enabled"
    value = "false"
  }

  # Provider settings
  set {
    name  = "providers.kubernetesCRD.enabled"
    value = "true"
  }
  set {
    name  = "providers.kubernetesCRD.allowCrossNamespace"
    value = "true"
  }
  set {
    name  = "providers.kubernetesCRD.allowExternalNameServices"
    value = "true"
  }
  set {
    name  = "providers.kubernetesCRD.allowEmptyServices"
    value = "true"
  }
  set {
    name  = "providers.kubernetesIngress.enabled"
    value = "true"
  }
  set {
    name  = "providers.kubernetesIngress.allowExternalNameServices"
    value = "true"
  }
  set {
    name  = "providers.kubernetesIngress.allowEmptyServices"
    value = "true"
  }

  # Logs settings
  set {
    name  = "logs.access.enabled"
    value = "true"
  }
  set {
    name  = "logs.access.format"
    value = "json"
  }
  set {
    name  = "logs.access.addInternals"
    value = "true"
  }
  set {
    name  = "logs.access.fields.general.defaultmode"
    value = "keep"
  }
  set {
    name  = "logs.access.fields.headers.defaultmode"
    value = "keep"
  }

  # Metrics settings
  set {
    name  = "metrics.addInternals"
    value = "true"
  }
  set {
    name  = "metrics.prometheus.entryPoint"
    value = "metrics"
  }
  set {
    name  = "metrics.prometheus.addentrypointslabels"
    value = "true"
  }
  set {
    name  = "metrics.prometheus.addrouterslabels"
    value = "true"
  }
  set {
    name  = "metrics.prometheus.addserviceslabels"
    value = "true"
  }
  set {
    name  = "metrics.otlp.enabled"
    value = "true"
  }
  set {
    name  = "metrics.otlp.addentrypointslabels"
    value = "true"
  }
  set {
    name  = "metrics.otlp.addrouterslabels"
    value = "true"
  }
  set {
    name  = "metrics.otlp.addserviceslabels"
    value = "true"
  }
  set {
    name  = "metrics.otlp.http.enabled"
    value = "true"
  }
  set {
    name  = "metrics.otlp.http.endpoint"
    value = "http://prometheus.monitoring:9090/api/v1/otlp/v1/metrics"
  }
  set {
    name  = "metrics.otlp.http.tls.insecureSkipVerify"
    value = "true"
  }

  # Tracing settings
  set {
    name  = "tracing.addInternals"
    value = "true"
  }
  set {
    name  = "tracing.otlp.enabled"
    value = "true"
  }
  set {
    name  = "tracing.otlp.http.enabled"
    value = "true"
  }
  set {
    name  = "tracing.otlp.http.endpoint"
    value = "http://zipkin.zipkin.svc.cluster.local:9411/api/v2/spans"
  }

  # Environment variables
  set {
    name  = "env[0].name"
    value = "POD_NAME"
  }
  set {
    name  = "env[0].valueFrom.fieldRef.fieldPath"
    value = "metadata.name"
  }
  set {
    name  = "env[1].name"
    value = "POD_NAMESPACE"
  }
  set {
    name  = "env[1].valueFrom.fieldRef.fieldPath"
    value = "metadata.namespace"
  }

  # Service settings
  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  depends_on = [
    azurerm_kubernetes_cluster.this,
    helm_release.redis
  ]
}

# Install Redis Cluster when API Management is enabled
resource "helm_release" "redis" {
  count            = var.enable_api_management ? 1 : 0
  name             = "redis"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "redis"
  version          = "19.6.4"
  namespace        = "traefik"
  create_namespace = true

  set {
    name  = "auth.password"
    value = "topsecretpassword"
  }

  set {
    name  = "replica.replicaCount"
    value = 1
  }
}
