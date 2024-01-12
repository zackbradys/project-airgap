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
curl -#OL https://rancher-airgap.s3.amazonaws.com/v1.7.1/hauler/hauler/rancher-airgap-hauler.yaml
curl -#OL https://rancher-airgap.s3.amazonaws.com/v1.7.1/hauler/helm/rancher-airgap-helm.yaml
curl -#OL https://rancher-airgap.s3.amazonaws.com/v1.7.1/hauler/harbor/rancher-airgap-harbor.yaml

### Fetch Project Airgap Components
curl -#OL https://raw.githubusercontent.com/zackbradys/project-airgap/main/hauler/project-airgap-manifest.yaml

### Sync Manifests to Hauler Store
hauler store sync -f rancher-airgap-hauler.yaml
hauler store sync -f rancher-airgap-helm.yaml
hauler store sync -f rancher-airgap-harbor.yaml
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
