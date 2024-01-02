# Project Airgap

### Welcome to Project Airgap

WIP WIP WIP

#### Step 1: Fetch Dependencies

```bash
### Download and Install Hauler
curl -sfL https://get.hauler.dev | bash

### Setup Directories
mkdir -p /opt/project-airgap
cd /opt/project-airgap

### Fetch Rancher Airgap Hauler Tars
curl -#OL https://rancher-airgap.s3.amazonaws.com/${vRancherAirgap}/hauler/hauler/rancher-airgap-hauler.tar.zst
curl -#OL https://rancher-airgap.s3.amazonaws.com/${vRancherAirgap}/hauler/helm/rancher-airgap-helm.tar.zst
curl -#OL https://rancher-airgap.s3.amazonaws.com/${vRancherAirgap}/hauler/cosign/rancher-airgap-cosign.tar.zst
curl -#OL https://rancher-airgap.s3.amazonaws.com/${vRancherAirgap}/hauler/rke2/rancher-airgap-rke2.tar.zst
curl -#OL https://rancher-airgap.s3.amazonaws.com/${vRancherAirgap}/hauler/rancher/rancher-airgap-rancher.tar.zst
curl -#OL https://rancher-airgap.s3.amazonaws.com/${vRancherAirgap}/hauler/longhorn/rancher-airgap-longhorn.tar.zst
curl -#OL https://rancher-airgap.s3.amazonaws.com/${vRancherAirgap}/hauler/neuvector/rancher-airgap-neuvector.tar.zst
curl -#OL https://rancher-airgap.s3.amazonaws.com/${vRancherAirgap}/hauler/harbor/rancher-airgap-harbor.tar.zst


### Fetch Project Airgap Components
curl -#OL https://raw.githubusercontent.com/zackbradys/project-airgap/main/files/project-airgap-manifest.yaml

### Sync Manifests to Hauler Store
hauler store sync -f project-airgap-manifest.yaml

### Verify Hauler Store
hauler store info

### Compress Hauler Store Contents
hauler store save --filename project-airgap.tar.zst
```

#### Step 2: Across the Airgap

```bash
# steps here
```

### Step 3: Airgapped Build Server

```bash
# steps here
```
