{{/*
Expand the name of the chart.
*/}}
{{- define "helm-common.name" -}}
{{- default .Chart.Name .Values.app | trunc 50 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "helm-common.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 50 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.app }}
{{- if contains $name .Release.Name }}
{{- printf "%s-%s" .Release.Name ( .Values.global.env | default .Values.env ) | trunc 50 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s-%s" .Release.Name $name ( .Values.global.env | default .Values.env ) | trunc 50 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "helm-common.chart" -}}
{{- printf "%s-%s" "helm-common" .Chart.Version | replace "+" "_" | trunc 50 | trimSuffix "-" }}
{{- end }}

{{/*
helm-common labels
*/}}
{{- define "helm-common.labels" -}}
helm.sh/chart: {{ include "helm-common.chart" . }}
{{ include "helm-common.selectorLabels" . }}
{{- if .Values.image.tag }}
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "helm-common.selectorLabels" -}}
app: {{ include "helm-common.fullname" . }}
app.kubernetes.io/component: {{ include "helm-common.name" . }}
app.kubernetes.io/service: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "helm-common.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "helm-common.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Convert variables names and values into Environmental Variables for a deployment
*/}}
{{- define "helm-common.variables" -}}
{{- range $key, $value := .Values.variables }}
- name: {{ upper ($key) }}
  value: {{ tpl $value $ | quote }}
{{- end }}
{{- end }}

{{/*
Attach 1password service secrets items as secret Environmental Variables for a deployment
*/}}
{{- define "helm-common.secrets" -}}
{{- range .Values.secrets.values }}
- name: {{ . }}
  valueFrom:
    secretKeyRef:
      name: {{ include "helm-common.fullname" $ }}-secrets
      key: {{ . }}
{{- end }}
{{- end }}

{{/*
Create helm-common Affinity and antiAffinity rules
*/}}
{{- define "helm-common.affinity" -}}
{{- if .Values.affinity }}
{{- with .Values.affinity }}
  {{- toYaml . | nindent 8 }}
{{- end }}
{{- else }}
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - {{ include "helm-common.fullname" . }}
              topologyKey: kubernetes.io/hostname
          - weight: 50
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - {{ include "helm-common.fullname" . }}
              topologyKey: topology.kubernetes.io/zone
{{- end }}
{{- end }}