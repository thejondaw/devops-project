import {
  to = kubernetes_namespace.argocd
  id = "argocd"
}

import {
  to = kubernetes_namespace.applications["develop"]
  id = "develop"
}

import {
  to = kubernetes_namespace.applications["stage"]
  id = "stage"
}

import {
  to = kubernetes_namespace.applications["prod"]
  id = "prod"
}

import {
  to = kubernetes_cluster_role.argocd_admin
  id = "argocd-admin-role"
}
