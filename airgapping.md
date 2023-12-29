
#### Collect Required Dependencies

```bash
### Set Variables
export vRancherAirgap=v1.6.3

### Setup Directories
mkdir -p /opt/rancher/hauler
cd /opt/rancher/hauler

### Download and Install Hauler
curl -sfL https://get.hauler.dev | bash

### Fetch Rancher Airgap Manifests
curl -#OL https://rancher-airgap.s3.amazonaws.com/${vRancherAirgap}/hauler/hauler/rancher-airgap-hauler.yaml
curl -#OL https://rancher-airgap.s3.amazonaws.com/${vRancherAirgap}/hauler/helm/rancher-airgap-helm.yaml
curl -#OL https://rancher-airgap.s3.amazonaws.com/${vRancherAirgap}/hauler/cosign/rancher-airgap-cosign.yaml
curl -#OL https://rancher-airgap.s3.amazonaws.com/${vRancherAirgap}/hauler/rke2/rancher-airgap-rke2.yaml
curl -#OL https://rancher-airgap.s3.amazonaws.com/${vRancherAirgap}/hauler/rancher/rancher-airgap-rancher.yaml
curl -#OL https://rancher-airgap.s3.amazonaws.com/${vRancherAirgap}/hauler/longhorn/rancher-airgap-longhorn.yaml
curl -#OL https://rancher-airgap.s3.amazonaws.com/${vRancherAirgap}/hauler/neuvector/rancher-airgap-neuvector.yaml

### Sync Manifests to Hauler Store
hauler store sync -f rancher-airgap-hauler.yaml
hauler store sync -f rancher-airgap-helm.yaml
hauler store sync -f rancher-airgap-cosign.yaml
hauler store sync -f rancher-airgap-rke2.yaml
hauler store sync -f rancher-airgap-rancher.yaml
hauler store sync -f rancher-airgap-longhorn.yaml
hauler store sync -f rancher-airgap-neuvector.yaml

### Verify Hauler Store
hauler store info

### Compress Hauler Store Contents
hauler store save --filename rancher-airgap.tar.zst
```