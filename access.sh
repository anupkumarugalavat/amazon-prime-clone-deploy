#!/bin/bash
# This script is used to get the ArgoCD, Prometheus & Grafana URLs and credentials.
set -euo pipefail

function usage() {
    cat <<EOF
Usage: $0 [AWS_REGION] [EKS_CLUSTER_NAME]

Environment variables supported:
  AWS_REGION          AWS region to use (default: us-east-1)
  CLUSTER_NAME        EKS cluster name (default: your-eks-cluster)
  ARGO_NAMESPACE      Namespace for ArgoCD (default: argocd)
  PROM_NAMESPACE      Namespace for Prometheus/Grafana (default: prometheus)
  ARGO_SERVER_SVC     ArgoCD server service name (default: argocd-server)
  PROM_SVC           Prometheus service name (default: stable-kube-prometheus-sta-prometheus)
  GRAFANA_SVC        Grafana service name (default: stable-grafana)
  GRAFANA_SECRET     Grafana secret name (default: stable-grafana)
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

AWS_REGION="${1:-${AWS_REGION:-us-east-1}}"
CLUSTER_NAME="${2:-${CLUSTER_NAME:-your-eks-cluster}}"
ARGO_NAMESPACE="${ARGO_NAMESPACE:-argocd}"
PROM_NAMESPACE="${PROM_NAMESPACE:-prometheus}"
ARGO_SERVER_SVC="${ARGO_SERVER_SVC:-argocd-server}"
PROM_SVC="${PROM_SVC:-stable-kube-prometheus-sta-prometheus}"
GRAFANA_SVC="${GRAFANA_SVC:-stable-grafana}"
GRAFANA_SECRET="${GRAFANA_SECRET:-stable-grafana}"

aws configure
aws eks update-kubeconfig --region "${AWS_REGION}" --name "${CLUSTER_NAME}"

# ArgoCD Access
argo_url=$(kubectl get svc -n "${ARGO_NAMESPACE}" | grep "${ARGO_SERVER_SVC}" | awk '{print $4}' | head -n 1)
argo_initial_password=$(argocd admin initial-password -n "${ARGO_NAMESPACE}")

# ArgoCD Credentials
argo_user="admin"
argo_password=$(kubectl -n "${ARGO_NAMESPACE}" get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)

# Prometheus and Grafana URLs and credentials
prometheus_url=$(kubectl get svc -n "${PROM_NAMESPACE}" | grep "${PROM_SVC}" | awk '{print $4}')
grafana_url=$(kubectl get svc -n "${PROM_NAMESPACE}" | grep "${GRAFANA_SVC}" | awk '{print $4}')
grafana_user="admin"
grafana_password=$(kubectl get secret "${GRAFANA_SECRET}" -n "${PROM_NAMESPACE}" -o jsonpath="{.data.admin-password}" | base64 --decode)

# Print or use these variables
echo "------------------------"
echo "ArgoCD URL: ${argo_url}"
echo "ArgoCD User: ${argo_user}"
echo "ArgoCD Initial Password: ${argo_initial_password}" | head -n 1
echo
if [[ -n "${prometheus_url}" ]]; then
    echo "Prometheus URL: ${prometheus_url}:9090"
else
    echo "Prometheus URL: not found"
fi
echo
 echo "Grafana URL: ${grafana_url}"
echo "Grafana User: ${grafana_user}"
echo "Grafana Password: ${grafana_password}"
echo "------------------------"

# Run below commands
# chmod a+x access.sh
# ./access.sh [AWS_REGION] [EKS_CLUSTER_NAME]
