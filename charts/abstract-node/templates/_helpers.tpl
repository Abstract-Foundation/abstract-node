{{/*
Expand the name of the chart.
*/}}
{{- define "abstract-node.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "abstract-node.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "abstract-node.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "abstract-node.labels" -}}
helm.sh/chart: {{ include "abstract-node.chart" . }}
{{ include "abstract-node.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "abstract-node.selectorLabels" -}}
app.kubernetes.io/name: {{ include "abstract-node.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "abstract-node.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "abstract-node.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Render OpenTelemetry environment variables for the external node container.
*/}}
{{- define "abstract-node.otelEnv" -}}
{{- with .Values.otel }}
{{- if .enabled }}
- name: OPENTELEMETRY_LEVEL
  value: {{ .level | quote }}
{{- with .endpoint }}
- name: OTLP_ENDPOINT
  value: {{ . | quote }}
{{- end }}
{{- with .serviceName }}
- name: SERVICE_NAME
  value: {{ . | quote }}
{{- end }}
- name: EN_EXTENDED_RPC_TRACING
  value: {{ .extendedRpcTracing | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
HA core StatefulSet / governing service name.
*/}}
{{- define "abstract-node.haCoreName" -}}
{{- $name := include "common.names.fullname" . | trunc 58 | trimSuffix "-" -}}
{{- printf "%s-core" $name -}}
{{- end }}

{{/*
HA API Deployment name.
*/}}
{{- define "abstract-node.haApiName" -}}
{{- $name := include "common.names.fullname" . | trunc 59 | trimSuffix "-" -}}
{{- printf "%s-api" $name -}}
{{- end }}

{{/*
Default HA core components. The tree API is included by default so API replicas can
proxy proof requests to the singleton tree.
*/}}
{{- define "abstract-node.haCoreComponents" -}}
{{- if .Values.ha.core.components -}}
{{- .Values.ha.core.components -}}
{{- else if .Values.ha.treeApi.enabled -}}
core,tree,tree_fetcher,tree_api
{{- else -}}
core,tree,tree_fetcher
{{- end -}}
{{- end }}

{{/*
Default HA API components.
*/}}
{{- define "abstract-node.haApiComponents" -}}
{{- default "api" .Values.ha.api.components -}}
{{- end }}

{{/*
Render external node command / args, preserving the existing shutdown wrapper behavior.
*/}}
{{- define "abstract-node.nodeArgs" -}}
{{- $root := .root -}}
{{- $args := default (list) .args -}}
{{- $kubeVersion := $root.Capabilities.KubeVersion.Version | trimPrefix "v" -}}
{{- $supportsStopSignal := semverCompare ">=1.33.0-0" $kubeVersion -}}
{{- if and $root.Values.shutdownWrapper.enabled (not $supportsStopSignal) }}
command:
  - /bin/sh
  - -ec
args:
  - |
    set -eu

    child=0

    forward_int() {
      if [ "$child" -ne 0 ]; then
        echo "Forwarding SIGINT to child process ${child}"
        kill -INT "$child" 2>/dev/null || true
      fi
    }

    trap 'forward_int' TERM
    trap 'forward_int' INT

    /usr/bin/entrypoint.sh "$@" &
    child=$!

    status=0
    wait "$child" || status=$?
    exit "$status"
  - wrapper
  {{- range $args }}
  - {{ . | quote }}
  {{- end }}
{{- else if $args }}
args:
  {{- range $args }}
  - {{ . | quote }}
  {{- end }}
{{- end }}
{{- end }}
