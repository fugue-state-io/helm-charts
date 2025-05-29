{{/*
Expand the name of the chart.
*/}}
{{- define "postfix.name" -}}
postfix
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "postfix.fullname" -}}
{{ .Release.Name }}-postfix
{{- end }}
