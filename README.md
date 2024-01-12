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
curl -#OL https://rancher-airgap.s3.amazonaws.com/v1.7.0/hauler/hauler/rancher-airgap-hauler.tar.zst
curl -#OL https://rancher-airgap.s3.amazonaws.com/v1.7.0/hauler/helm/rancher-airgap-helm.tar.zst
#curl -#OL https://rancher-airgap.s3.amazonaws.com/v1.7.0/hauler/rke2/rancher-airgap-rke2.tar.zst
#curl -#OL https://rancher-airgap.s3.amazonaws.com/v1.7.0/hauler/rancher/rancher-airgap-rancher.tar.zst
curl -#OL https://rancher-airgap.s3.amazonaws.com/v1.7.0/hauler/harbor/rancher-airgap-harbor.tar.zst

### Fetch Project Airgap Components
curl -#OL https://raw.githubusercontent.com/zackbradys/project-airgap/main/files/project-airgap-manifest.yaml

### Sync Manifests to Hauler Store
hauler store sync -f project-airgap-manifest.yaml

### Verify Hauler Store
hauler store info

### Compress Hauler Store Contents
hauler store save --filename project-airgap.tar.zst
```

#### Step 2: Move TARs Over the Airgap

```bash
### Move the TARs Over the Airgap
```

### Step 3: Airgapped Build Server

```bash
### steps here
```
