{{/*
Expand the name of the chart.
*/}}
{{- define "mautic.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mautic.fullname" -}}
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
{{- define "mautic.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mautic.labels" -}}
helm.sh/chart: {{ include "mautic.chart" . }}
{{ include "mautic.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "mautic.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mautic.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Volumes
*/}}
{{- define "mautic.volumes" -}}
{{- with .Values.volumes }}
{{- toYaml . }}
{{- end }}
- name: files
  persistentVolumeClaim:
    claimName: {{ include "mautic.fullname" . }}-files
- name: images
  persistentVolumeClaim:
    claimName: {{ include "mautic.fullname" . }}-images
- name: config
  persistentVolumeClaim:
    claimName: {{ include "mautic.fullname" . }}-config
- name: cache
  persistentVolumeClaim:
    claimName: {{ include "mautic.fullname" . }}-cache
- name: sessions
  persistentVolumeClaim:
    claimName: {{ include "mautic.fullname" . }}-sessions
- name: import
  persistentVolumeClaim:
    claimName: {{ include "mautic.fullname" . }}-import
- name: logs
  persistentVolumeClaim:
    claimName: {{ include "mautic.fullname" . }}-logs
{{- end }}

{{/*
Volume mounts
*/}}
{{- define "mautic.volumeMounts" -}}
{{- with .Values.volumeMounts }}
{{- toYaml . }}
{{- end }}
- mountPath: /var/www/html/docroot/media/files
  name: files
- mountPath: /var/www/html/docroot/media/images
  name: images
- mountPath: /var/www/html/config
  name: config
- mountPath: /var/www/html/var/cache
  name: cache
- mountPath: /var/www/html/var/sessions
  name: sessions
- mountPath: /var/www/html/var/import
  name: import
- mountPath: /var/www/html/var/logs
  name: logs
{{- end }}

{{/*
EnvFrom
*/}}
{{- define "mautic.envFrom" -}}
# DB ConfigMap
{{- if .Values.mautic.db.existingConfigMap }}
- configMapRef:
    name: {{ .Values.mautic.db.existingConfigMap }}
{{- else }} 
- configMapRef:
    name: {{ include "mautic.fullname" . }}-db
{{- end }}
# DB Secret
{{- if .Values.mautic.db.existingSecret }}
- secretRef:
    name: {{ .Value.mautic.db.existingSecret }}
{{- else }}
- secretRef:
    name: {{ include "mautic.fullname" . }}-db
{{- end }}
# Maustic ConfigMap
{{- if .Values.mautic.existingConfigMap }}
- configMapRef:
    name: {{ .Values.mautic.existingConfigMap }}
{{- else }}
- configMapRef:
    name: {{ include "mautic.fullname" . }}-config
{{- end }}
# Mautic Secret
{{- if .Values.mautic.existingSecret }}
- secretRef:
    name: {{ .Values.mautic.existingSecret }}
{{- else }}
- secretRef:
    name: {{ include "mautic.fullname" . }}-secret
{{- end }}
{{- end }}
