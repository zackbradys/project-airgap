#!/bin/bash

### Set Variables
export DOMAIN=${DOMAIN}
export TOKEN=${TOKEN}
export vRKE2=${vRKE2}
export vRancher=${vRancher}
export vLonghorn=${vLonghorn}
export vNeuVector=${vNeuVector}
export vCertManager=${vCertManager}
export vCarbide=${vCarbide}
export CarbideRegistry=${CarbideRegistry}
export CarbideUsername=${CarbideUsername}
export CarbidePassword=${CarbidePassword}
export RegistryToken=${RegistryToken}
export AccessKey=${AccessKey}
export SecretKey=${SecretKey}

### Apply System Settings
cat << EOF >> /etc/sysctl.conf
### Modified System Settings
vm.swappiness=0
vm.panic_on_oom=0
vm.overcommit_memory=1
kernel.panic=10
kernel.panic_on_oops=1
vm.max_map_count = 262144
net.ipv4.ip_local_port_range=1024 65000
net.core.somaxconn=10000
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_fin_timeout=15
net.core.somaxconn=4096
net.core.netdev_max_backlog=4096
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_max_syn_backlog=20480
net.ipv4.tcp_max_tw_buckets=400000
net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_syn_retries=2
net.ipv4.tcp_synack_retries=2
net.ipv4.tcp_wmem=4096 65536 16777216
net.ipv4.neigh.default.gc_thresh1=8096
net.ipv4.neigh.default.gc_thresh2=12288
net.ipv4.neigh.default.gc_thresh3=16384
net.ipv4.tcp_keepalive_time=600
net.ipv4.ip_forward=1
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
fs.inotify.max_user_instances=8192
fs.inotify.max_user_watches=1048576
EOF
sysctl -p > /dev/null 2>&1

### Install Packages
yum install -y iptables container-selinux libnetfilter_conntrack libnfnetlink libnftnl policycoreutils-python-utils cryptsetup
yum install -y nfs-utils iscsi-initiator-utils; yum install -y zip zstd tree jq

### Modify Settings
echo "InitiatorName=$(/sbin/iscsi-iname)" > /etc/iscsi/initiatorname.iscsi && systemctl enable --now iscsid
systemctl stop firewalld; systemctl disable firewalld; systemctl stop nm-cloud-setup; systemctl disable nm-cloud-setup; systemctl stop nm-cloud-setup.timer; systemctl disable nm-cloud-setup.timer
echo -e "[keyfile]\nunmanaged-devices=interface-name:cali*;interface-name:flannel*" > /etc/NetworkManager/conf.d/rke2-canal.conf

### Setup RKE2 Server
mkdir -p /opt/rke2-artifacts/ /etc/rancher/rke2/ /var/lib/rancher/rke2/server/manifests/
useradd -r -c "etcd user" -s /sbin/nologin -M etcd -U

### Configure RKE2 Config
cat << EOF >> /etc/rancher/rke2/config.yaml
profile: cis-1.23
selinux: true
secrets-encryption: true
write-kubeconfig-mode: 0600
use-service-account-credentials: true
kube-controller-manager-arg:
- bind-address=127.0.0.1
- use-service-account-credentials=true
- tls-min-version=VersionTLS12
- tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
kube-scheduler-arg:
- tls-min-version=VersionTLS12
- tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
kube-apiserver-arg:
- tls-min-version=VersionTLS12
- tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
- authorization-mode=RBAC,Node
- anonymous-auth=false
- admission-control-config-file=/etc/rancher/rke2/rancher-pss.yaml
- audit-policy-file=/etc/rancher/rke2/audit-policy.yaml
- audit-log-mode=blocking-strict
- audit-log-maxage=30
kubelet-arg:
- protect-kernel-defaults=true
- read-only-port=0
- authorization-mode=Webhook
- streaming-connection-idle-timeout=5m
token: $TOKEN
tls-san:
  - $DOMAIN
system-default-registry: $CarbideRegistry
EOF

### Configure RKE2 Audit Policy
cat << EOF >> /etc/rancher/rke2/audit-policy.yaml
apiVersion: audit.k8s.io/v1
kind: Policy
metadata:
  name: rke2-audit-policy
rules:
  - level: Metadata
    resources:
    - group: ""
      resources: ["secrets"]
  - level: RequestResponse
    resources:
    - group: ""
      resources: ["*"]
EOF

### Configure RKE2 Pod Security Standards
cat << EOF >> /etc/rancher/rke2/rancher-pss.yaml
apiVersion: apiserver.config.k8s.io/v1
kind: AdmissionConfiguration
plugins:
  - name: PodSecurity
    configuration:
      apiVersion: pod-security.admission.config.k8s.io/v1
      kind: PodSecurityConfiguration
      defaults:
        enforce: "restricted"
        enforce-version: "latest"
        audit: "restricted"
        audit-version: "latest"
        warn: "restricted"
        warn-version: "latest"
      exemptions:
        usernames: []
        runtimeClasses: []
        namespaces: [calico-apiserver,
                     calico-system,
                     carbide-docs-system,
                     carbide-stigatron-system,
                     cattle-alerting,
                     cattle-csp-adapter-system,
                     cattle-elemental-system,
                     cattle-epinio-system,
                     cattle-externalip-system,
                     cattle-fleet-local-system,
                     cattle-fleet-system,
                     cattle-gatekeeper-system,
                     cattle-global-data,
                     cattle-global-nt,
                     cattle-impersonation-system,
                     cattle-istio,
                     cattle-istio-system,
                     cattle-logging,
                     cattle-logging-system,
                     cattle-monitoring-system,
                     cattle-neuvector-system,
                     cattle-prometheus,
                     cattle-provisioning-capi-system,
                     cattle-resources-system,
                     cattle-sriov-system,
                     cattle-system,
                     cattle-ui-plugin-system,
                     cattle-windows-gmsa-system,
                     cert-manager,
                     cis-operator-system,
                     fleet-default,
                     fleet-local,
                     ingress-nginx,
                     istio-system,
                     kube-node-lease,
                     kube-public,
                     kube-system,
                     longhorn-system,
                     rancher-alerting-drivers,
                     security-scan,
                     tigera-operator]
EOF

### Setup Carbide Registry
cat << EOF >> /etc/rancher/rke2/registries.yaml
mirrors:
  docker.io:
    endpoint:
      - "https://$CarbideRegistry"

configs:
  "$CarbideRegistry":
    auth:
      username: $CarbideUsername
      password: $CarbidePassword
EOF

### Download and Install RKE2 Server
curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION=$vRKE2 INSTALL_RKE2_TYPE=server sh -

### Enable and Start RKE2 Server
systemctl enable rke2-server.service && systemctl start rke2-server.service

### Symlink kubectl and containerd
sudo ln -s /var/lib/rancher/rke2/data/v1*/bin/kubectl /usr/bin/kubectl
sudo ln -s /var/run/k3s/containerd/containerd.sock /var/run/containerd/containerd.sock

### Update and Source BASHRC
cat << EOF >> ~/.bashrc
export PATH=$PATH:/var/lib/rancher/rke2/bin:/usr/local/bin/
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
export CRI_CONFIG_FILE=/var/lib/rancher/rke2/agent/etc/crictl.yaml
export DOMAIN=${DOMAIN}
export TOKEN=${TOKEN}
export vRKE2=${vRKE2}
export vRancher=${vRancher}
export vLonghorn=${vLonghorn}
export vNeuVector=${vNeuVector}
export vCertManager=${vCertManager}
export vCarbide=${vCarbide}
export CarbideRegistry=${CarbideRegistry}
export CarbideUsername=${CarbideUsername}
export CarbidePassword=${CarbidePassword}
export RegistryToken=${RegistryToken}
alias k=kubectl
EOF

### Source BASHRC
source ~/.bashrc

### Verify End of Script
date >> /opt/rancher/COMPLETED

### Install Cosign
mkdir -p /opt/rancher/cosign
cd /opt/rancher/cosign
curl -#OL https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64
mv cosign-linux-amd64 /usr/bin/cosign
chmod 755 /usr/bin/cosign

### Install Helm
mkdir -p /opt/rancher/helm
cd /opt/rancher/helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 755 get_helm.sh && ./get_helm.sh
mv /usr/local/bin/helm /usr/bin/helm

### Install Cert Manager
helm repo add jetstack https://charts.jetstack.io
helm repo update

kubectl create namespace cert-manager

helm upgrade -i cert-manager jetstack/cert-manager -n cert-manager --version=$vCertManager --set installCRDs=true --set image.repository=$CarbideRegistry/jetstack/cert-manager-controller --set webhook.image.repository=$CarbideRegistry/jetstack/cert-manager-webhook --set cainjector.image.repository=$CarbideRegistry/jetstack/cert-manager-cainjector --set acmesolver.image.repository=$CarbideRegistry/jetstack/cert-manager-acmesolver --set startupapicheck.image.repository=$CarbideRegistry/jetstack/cert-manager-ctl

sleep 15

### Configure Cert Manager
kubectl create secret generic aws-creds -n cert-manager --from-literal=access_key=$AccessKey --from-literal=secret_key=$SecretKey

kubectl apply -f - << EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-production
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: zack.brady@ranchergovernment.com
    privateKeySecretRef:
      name: letsencrypt-production
    solvers:
    - dns01:
        route53:
          region: us-east-1
          accessKeyIDSecretRef:
            name: aws-creds
            key: access_key
          secretAccessKeySecretRef:
            name: aws-creds
            key: secret_key
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: tls-certs
  namespace: cert-manager
spec:
  issuerRef:
    name: letsencrypt-production
    kind: ClusterIssuer
  secretName: tls-certs
  commonName: "$DOMAIN"
  dnsNames:
  - "$DOMAIN"
  - "*.$DOMAIN"
EOF

sleep 300

### Export Cert Manager Certs
mkdir -p /opt/rancher/certs
cd /opt/rancher/certs
kubectl get secret tls-certs -n cert-manager -o json -o=jsonpath="{.data.tls\.crt}" | base64 -d > tls.pem
kubectl get secret tls-certs -n cert-manager -o json -o=jsonpath="{.data.tls\.key}" | base64 -d > tls.key

### Install Rancher
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo add carbide-charts https://rancherfederal.github.io/carbide-charts
helm repo update

kubectl create namespace cattle-system

kubectl get secret tls-certs -n cert-manager -o yaml | sed 's/namespace: .*/namespace: cattle-system/' | kubectl apply -f -

helm upgrade -i rancher carbide-charts/rancher -n cattle-system --version=$vRancher --set bootstrapPassword=Pa22word --set replicas=3 --set auditLog.level=2 --set auditLog.destination=hostPath --set ingress.tls.source=secret --set ingress.tls.secretName=tls-certs --set systemDefaultRegistry=$CarbideRegistry --set rancherImage=$CarbideRegistry/rancher/rancher --set hostname=rancher.$DOMAIN

sleep 30

### Install Longhorn
helm repo add longhorn https://charts.longhorn.io
helm repo update

kubectl create namespace longhorn-system

helm upgrade -i longhorn longhorn/longhorn -n longhorn-system --version=$vLonghorn --set global.cattle.systemDefaultRegistry=$CarbideRegistry

kubectl apply -f https://raw.githubusercontent.com/zackbradys/code-templates/main/k8s/yamls/longhorn-encrypted-sc.yaml
kubectl apply -f https://raw.githubusercontent.com/zackbradys/code-templates/main/k8s/yamls/longhorn-encrypted-volume.yaml

sleep 60

### Install NeuVector
helm repo add neuvector https://neuvector.github.io/neuvector-helm
helm repo update

kubectl create namespace cattle-neuvector-system

helm upgrade -i neuvector neuvector/core -n cattle-neuvector-system --version=$vNeuVector --set k3s.enabled=true --set manager.svc.type=ClusterIP --set internal.certmanager.enabled=true --set controller.pvc.enabled=true --set controller.pvc.capacity=10Gi --set global.cattle.url=https://rancher.$DOMAIN --set controller.ranchersso.enabled=true --set rbac=true --set registry=$CarbideRegistry

sleep 120

### Install Carbide
kubectl create namespace carbide-stigatron-system

kubectl create secret generic stigatron-license -n carbide-stigatron-system --from-literal=license=$RegistryToken

kubectl apply -f https://raw.githubusercontent.com/zackbradys/rgs-carbide/main/fleet/gitrepo-local.yaml

kubectl apply -f https://raw.githubusercontent.com/zackbradys/rgs-carbide/main/fleet/gitrepo-default.yaml

sleep 15

### Install Additional Apps
kubectl apply -f https://raw.githubusercontent.com/zackbradys/fleet/main/gitrepo-local.yaml

kubectl apply -f https://raw.githubusercontent.com/zackbradys/fleet/main/gitrepo-default.yaml

sleep 15

### Add Classification Banners
kubectl apply -f https://raw.githubusercontent.com/zackbradys/code-templates/main/k8s/yamls/rancher-banner-ufouo.yaml

### Deploy Fleet to Local Cluster
# kubectl label clusters.management.cattle.io local -n fleet-local monitoring=enabled
kubectl label clusters.management.cattle.io local -n fleet-local carbide=enabled

### Add Cloud Credentials
kubectl create secret -n cattle-global-data generic aws-creds --from-literal=amazonec2credentialConfig-defaultRegion=us-east-1 --from-literal=amazonec2credentialConfig-accessKey=$AccessKey --from-literal=amazonec2credentialConfig-secretKey=$SecretKey

kubectl annotate secret -n cattle-global-data aws-creds provisioning.cattle.io/driver=aws

### Add Registry Credentials
kubectl create secret -n fleet-default generic --type kubernetes.io/basic-auth registry-creds --from-literal=username=$CarbideUsername --from-literal=password=$CarbidePassword

### Verify End of Script
date >> /opt/rancher/COMPLETED