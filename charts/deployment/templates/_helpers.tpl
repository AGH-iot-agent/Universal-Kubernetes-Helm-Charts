{{/*
Define the standardized name of this helm chart and its objects.
*/}}
{{- define "name" -}}
{{- required "A valid Values.name is required!" .Values.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "chart" -}}
{{ if and (hasKey .Values "labelsIncludeChartVersion") (eq (coalesce .Values.labelsIncludeChartVersion "1" | toString) "1") }}
{{- printf "%s" .Chart.Name | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Generate basic labels for pods/services/etc.
*/}}
{{- define "labels" -}}
labels:
{{- if .Values.usingNewRecommendedLabels }}
{{- if .Values.labelsEnableDefault }}
  app.kubernetes.io/name: {{ .Values.name | trunc 63 | trimSuffix "-" | quote }}
  app.kubernetes.io/instance: {{ .Values.name | trunc 63 | trimSuffix "-" | quote }}
{{- end }}
  app.kubernetes.io/version: {{ .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" | quote }}
  app.kubernetes.io/component: {{ .Chart.Name | replace "+" "_" | trunc 63 | trimSuffix "-" | quote }}
  app.kubernetes.io/created-by: "devops-nirvana"
  app.kubernetes.io/managed-by: "helm"
{{- if .Values.labels }}
{{ toYaml .Values.labels | indent 2 }}
{{- end }}
{{- else }}
{{- if .Values.labelsEnableDefault }}
  app: {{ .Values.name | trunc 63 | trimSuffix "-" | quote }}
{{- end }}
  chart: {{ include "chart" . | quote }}
  release: {{ .Release.Name | quote }}
  heritage: {{ .Release.Service | quote }}
  helm_chart_author: "devops-nirvana"
  generator: "helm"
{{- if .Values.labels }}
{{ toYaml .Values.labels | indent 2 }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "labels_without_key_or_name" -}}
{{- if .Values.usingNewRecommendedLabels }}
app.kubernetes.io/version: {{ .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" | quote }}
app.kubernetes.io/component: {{ .Chart.Name | replace "+" "_" | trunc 63 | trimSuffix "-" | quote }}
app.kubernetes.io/created-by: "devops-nirvana"
app.kubernetes.io/managed-by: "helm"
{{- if .Values.labels }}
{{ toYaml .Values.labels }}
{{- end }}
{{- else }}
chart: {{ include "chart" . | quote }}
release: {{ .Release.Name | quote }}
heritage: {{ .Release.Service | quote }}
helm_chart_author: "devops-nirvana"
generator: "helm"
{{- if .Values.labels }}
{{ toYaml .Values.labels }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Resolve image repository.
*/}}
{{- define "get-repository" -}}
{{- required "A valid Values.image.repository is required!" .Values.image.repository | trimSuffix ":" -}}
{{- end -}}

{{/*
Resolve image tag.
*/}}
{{- define "get-release-tag" -}}
{{- if .Values.image.repository -}}
{{- if .Values.image.tag -}}
{{- .Values.image.tag -}}
{{- else if .Values.global.image.tag -}}
{{- .Values.global.image.tag -}}
{{- else -}}
latest
{{- end -}}
{{- else -}}
{{- if .Values.global.image.tag -}}
{{- .Values.global.image.tag -}}
{{- else if .Values.image.tag -}}
{{- .Values.image.tag -}}
{{- else -}}
no-image-tag-could-be-found
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for poddisruptionbudget.
*/}}
{{- define "pdb.apiVersion" -}}
	{{- if (default $.Capabilities "").APIVersions.Has "policy/v1" }}
		{{- print "policy/v1" -}}
	{{- else -}}
		{{- print "policy/v1beta1" -}}
	{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for horizontalpodautoscaler.
*/}}
{{- define "hpa.apiVersion" -}}
	{{ ternary "autoscaling/v2" "autoscaling/v2beta2" (.Capabilities.APIVersions.Has "autoscaling/v2") }}
{{- end }}