#
# COPYRIGHT Ericsson 2019
#
#
#
# The copyright to the computer program(s) herein is the property of
#
# Ericsson Inc. The programs may be used and/or copied only with written
#
# permission from Ericsson Inc. or in accordance with the terms and
#
# conditions stipulated in the agreement/contract under which the
#
# program(s) have been supplied.
#

{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "eric-eo-evnfm-vm-rbac.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create release name used for cluster role.
*/}}
{{- define "eric-eo-evnfm-vm-rbac.release.name" -}}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create image registry url
*/}}
{{- define "eric-eo-evnfm-vm-rbac.registryUrl" -}}
{{- if .Values.imageCredentials.registry -}}
{{- if .Values.imageCredentials.registry.url -}}
{{- print .Values.imageCredentials.registry.url -}}
{{- else if .Values.global.registry.url -}}
{{- print .Values.global.registry.url -}}
{{- else -}}
""
{{- end -}}
{{- else if .Values.global.registry.url -}}
{{- print .Values.global.registry.url -}}
{{- else -}}
""
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "eric-eo-evnfm-vm-rbac.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create Ericsson product app.kubernetes.io info
*/}}
{{- define "eric-eo-evnfm-vm-rbac.kubernetes-io-info" -}}
app.kubernetes.io/name: {{ .Chart.Name | quote }}
app.kubernetes.io/version: {{ .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- end -}}

{{/*
Create Ericsson Product Info
*/}}
{{- define "eric-eo-evnfm-vm-rbac.helm-annotations" -}}
ericsson.com/product-name: {{ (fromYaml (.Files.Get "eric-product-info.yaml")).productName | quote }}
ericsson.com/product-number: {{ (fromYaml (.Files.Get "eric-product-info.yaml")).productNumber | quote }}
ericsson.com/product-revision: {{ regexReplaceAll "(.*)[+|-].*" .Chart.Version "${1}" | quote }}
{{- end }}

{{/*
Create keycloak-client image pull secrets
*/}}
{{- define "eric-eo-evnfm-vm-rbac.keycloak-client.pullSecrets" -}}
    {{- if .Values.imageCredentials.registry -}}
        {{- if .Values.imageCredentials.pullSecret -}}
            {{- print .Values.imageCredentials.pullSecret -}}
        {{- else if .Values.global.pullSecret -}}
            {{- print .Values.global.pullSecret -}}
        {{- end -}}
    {{- else if .Values.global.pullSecret -}}
        {{- print .Values.global.pullSecret -}}
    {{- end -}}
{{- end -}}

Create keycloak-client image registry url
*/}}
{{- define "eric-eo-evnfm-vm-rbac.keycloak-client.registryUrl" -}}
  {{ if index .Values "imageCredentials" "keycloak-client" "registry" "url" -}}
    {{- print (index .Values "imageCredentials" "keycloak-client" "registry" "url") -}}
  {{- else -}}
    {{- print .Values.global.registry.url -}}
  {{- end -}}
{{- end -}}

{{- define "vnfm-rbac.mainImagePath" -}}
    {{- $productInfo := fromYaml (.Files.Get "eric-product-info.yaml") -}}
    {{- $registryUrl := $productInfo.images.mainImage.registry -}}
    {{- $repoPath := $productInfo.images.mainImage.repoPath -}}
    {{- $name := $productInfo.images.mainImage.name -}}
    {{- $tag := $productInfo.images.mainImage.tag -}}
    {{- if .Values.global -}}
        {{- if .Values.global.registry -}}
            {{- if .Values.global.registry.url -}}
                {{- $registryUrl = .Values.global.registry.url -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if .Values.imageCredentials -}}
        {{- if .Values.imageCredentials.mainImage -}}
            {{- if .Values.imageCredentials.mainImage.registry -}}
                {{- if .Values.imageCredentials.mainImage.registry.url -}}
                    {{- $registryUrl = .Values.imageCredentials.mainImage.registry.url -}}
                {{- end -}}
            {{- end -}}
            {{- if .Values.imageCredentials.mainImage.repoPath -}}
                {{- $repoPath = .Values.imageCredentials.mainImage.repoPath -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if $repoPath -}}
        {{- $repoPath = printf "%s/" $repoPath -}}
    {{- end -}}
    {{- printf "%s/%s%s:%s" $registryUrl $repoPath $name $tag -}}
{{- end -}}

{{- define "eric-eo-evnfm-vm.imagePullPolicy" -}}
{{- if .Values.global.registry.imagePullPolicy -}}
{{- print .Values.global.registry.imagePullPolicy  -}}
{{- else -}}
{{- print .Values.imageCredentials.registry.imagePullPolicy -}}
{{- end -}}
{{- end -}}

{{/*
The name of the cluster role used during openshift deployments.
This helper is provided to allow use of the new global.security.privilegedPolicyClusterRoleName if set, otherwise
use the previous naming convention of <release_name>-allowed-use-privileged-policy for backwards compatibility.
*/}}
{{- define "eric-eo-evnfm-vm-rbac.privileged.cluster.role.name" -}}
  {{- if hasKey (.Values.global.security) "privilegedPolicyClusterRoleName" -}}
    {{ .Values.global.security.privilegedPolicyClusterRoleName }}
  {{- else -}}
    {{ template "eric-eo-evnfm-vm-rbac.release.name" . }}-allowed-use-privileged-policy
  {{- end -}}
{{- end -}}
