{{/*
Create name used to reference CNPG cluster.
*/}}
{{- define "cnpg.clusterName" -}}
{{- printf "%s-%s" (include "common.names.fullname" .) .Values.cnpg.clusterSuffix | trunc 63 | trimSuffix "-" }}
{{- end -}}