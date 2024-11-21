#!/bin/bash

# Create base directories
mkdir -p helm/charts/api/templates
mkdir -p helm/charts/web/templates
mkdir -p helm/environments/develop
mkdir -p helm/environments/stage
mkdir -p helm/environments/prod

# Create API Chart files
cat > helm/charts/api/Chart.yaml << 'EOF'
apiVersion: v2
name: api
description: API application Helm chart
type: application
version: 0.1.0
appVersion: "1.0.0"
EOF

cat > helm/charts/api/values.yaml << 'EOF'
replicaCount: 1
image:
  repository: jondaw/devops-api
  tag: develop
  pullPolicy: IfNotPresent

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 200m
    memory: 256Mi

livenessProbe:
  path: /api/status
  initialDelaySeconds: 15
  periodSeconds: 20

readinessProbe:
  path: /api/status
  initialDelaySeconds: 5
  periodSeconds: 10

service:
  type: LoadBalancer
  port: 80
  targetPort: 3000

database:
  host: ""
  port: "5432"
  name: "devopsdb"
  username: "jondaw"
  password: "password"
EOF

# Create Web Chart files
cat > helm/charts/web/Chart.yaml << 'EOF'
apiVersion: v2
name: web
description: Web application Helm chart
type: application
version: 0.1.0
appVersion: "1.0.0"
EOF

cat > helm/charts/web/values.yaml << 'EOF'
replicaCount: 1
image:
  repository: jondaw/devops-web
  tag: develop
  pullPolicy: IfNotPresent

resources:
  requests:
    cpu: 50m
    memory: 64Mi
  limits:
    cpu: 100m
    memory: 128Mi

service:
  type: ClusterIP
  port: 80
  targetPort: 4000

api:
  host: "http://api-svc"

ingress:
  enabled: true
  className: nginx
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "600"
  path: /
  pathType: Prefix
EOF

# Create environment values
cat > helm/environments/develop/values.yaml << 'EOF'
api:
  replicaCount: 1
  image:
    tag: develop
  database:
    host: ""
    port: "5432"
    name: "devopsdb"
    username: "jondaw"
    password: "password"

web:
  replicaCount: 1
  image:
    tag: develop
  api:
    host: "http://develop-api-svc"
EOF

# Create Helm templates for API
cat > helm/charts/api/templates/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-api
  labels:
    {{- include "api.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "api.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "api.selectorLabels" . | nindent 8 }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - containerPort: {{ .Values.service.targetPort }}
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
          livenessProbe:
            httpGet:
              path: {{ .Values.livenessProbe.path }}
              port: {{ .Values.service.targetPort }}
            initialDelaySeconds: {{ .Values.livenessProbe.initialDelaySeconds }}
            periodSeconds: {{ .Values.livenessProbe.periodSeconds }}
          readinessProbe:
            httpGet:
              path: {{ .Values.readinessProbe.path }}
              port: {{ .Values.service.targetPort }}
            initialDelaySeconds: {{ .Values.readinessProbe.initialDelaySeconds }}
            periodSeconds: {{ .Values.readinessProbe.periodSeconds }}
          env:
            - name: DBHOST
              value: {{ .Values.database.host | quote }}
            - name: DBPORT
              value: {{ .Values.database.port | quote }}
            - name: DB
              value: {{ .Values.database.name | quote }}
            - name: DBUSER
              value: {{ .Values.database.username | quote }}
            - name: DBPASS
              value: {{ .Values.database.password | quote }}
          securityContext:
            allowPrivilegeEscalation: false
            runAsNonRoot: true
            runAsUser: 1000
            capabilities:
              drop:
                - ALL
EOF

cat > helm/charts/api/templates/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-api-svc
  labels:
    {{- include "api.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.targetPort }}
  selector:
    {{- include "api.selectorLabels" . | nindent 4 }}
EOF

cat > helm/charts/api/templates/_helpers.tpl << 'EOF'
{{/*
Common labels
*/}}
{{- define "api.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "api.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
EOF

# Create Helm templates for Web
cat > helm/charts/web/templates/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-web
  labels:
    {{- include "web.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "web.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "web.selectorLabels" . | nindent 8 }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - containerPort: {{ .Values.service.targetPort }}
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
          env:
            - name: API_HOST
              value: {{ .Values.api.host | quote }}
          securityContext:
            allowPrivilegeEscalation: false
            runAsNonRoot: true
            runAsUser: 1000
            capabilities:
              drop:
                - ALL
EOF

cat > helm/charts/web/templates/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-web-svc
  labels:
    {{- include "web.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.targetPort }}
  selector:
    {{- include "web.selectorLabels" . | nindent 4 }}
EOF

cat > helm/charts/web/templates/ingress.yaml << 'EOF'
{{- if .Values.ingress.enabled -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ .Release.Name }}-web-ingress
  labels:
    {{- include "web.labels" . | nindent 4 }}
  {{- with .Values.ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  ingressClassName: {{ .Values.ingress.className }}
  rules:
    - http:
        paths:
          - path: {{ .Values.ingress.path }}
            pathType: {{ .Values.ingress.pathType }}
            backend:
              service:
                name: {{ .Release.Name }}-web-svc
                port:
                  number: {{ .Values.service.port }}
{{- end }}
EOF

cat > helm/charts/web/templates/_helpers.tpl << 'EOF'
{{/*
Common labels
*/}}
{{- define "web.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "web.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
EOF

echo "Helm chart structure created successfully!"
