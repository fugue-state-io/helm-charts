{{/* Generate fullname */}}
{{- define "ssh-jumpbox.fullname" -}}
{{ .Release.Name }}-{{ .Chart.Name }}
{{- end -}}

{{/* Get chart name */}}
{{- define "ssh-jumpbox.name" -}}
{{ .Chart.Name }}
{{- end -}}
