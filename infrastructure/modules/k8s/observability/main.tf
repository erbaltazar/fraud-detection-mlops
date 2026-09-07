resource "kubernetes_namespace" "monitoring" {
  metadata { name = "monitoring" }
}

resource "kubernetes_secret" "grafana_auth" {
  metadata {
    name      = "grafana-auth"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }
  data = {
    username = var.grafana_username
    password = var.grafana_api_token
  }
}

resource "helm_release" "kube_prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  
  depends_on = [kubernetes_secret.grafana_auth]

  set { name = "prometheus.prometheusSpec.resources.requests.memory", value = "512Mi" }
  set { name = "prometheus.prometheusSpec.resources.limits.memory", value = "1Gi" }
  set { name = "grafana.enabled", value = "false" }
  set { name = "alertmanager.enabled", value = "false" }
  set { name = "prometheus.prometheusSpec.remoteWrite[0].url", value = var.grafana_remote_url }
  set { name = "prometheus.prometheusSpec.remoteWrite[0].basicAuth.username.name", value = kubernetes_secret.grafana_auth.metadata[0].name }
  set { name = "prometheus.prometheusSpec.remoteWrite[0].basicAuth.username.key", value = "username" }
  set { name = "prometheus.prometheusSpec.remoteWrite[0].basicAuth.password.name", value = kubernetes_secret.grafana_auth.metadata[0].name }
  set { name = "prometheus.prometheusSpec.remoteWrite[0].basicAuth.password.key", value = "password" }
}