# Repository guidance

This is a cluster-specific K3s GitOps repository. Preserve existing user changes and read the relevant inventory, role, Application and component manifests before editing. Keep changes focused and follow the established YAML, Kustomize, Helm and Ansible patterns.

## Layout and reconciliation

- `ansible/` prepares hosts and bootstraps K3s and foundational controllers. Run Ansible from that directory to use its config and inventory. `provisioning.yaml` runs server provisioning serially.
- `kubernetes/bootstrap/bootstrap.yaml` is the root Argo CD Application. Its Kustomization registers projects and child Applications; child Applications reference component directories under `kubernetes/`.
- Components typically have a `kustomization.yaml`, chart `values.yaml` where applicable, and related resources. Chart versions are pinned in the Kustomizations. External DNS uses plain manifests instead of a chart.
- Applications track `main` and use automated sync, prune and self-heal. Consider deletion and dependency ordering when changing Applications, projects, namespaces, CRDs, networking or storage. Do not assume a local edit is deployed.

## Operational care

- Ask before executing commands that change the live cluster or hosts unless the user explicitly requested that action. Provisioning can format configured disks, reboot machines and restart K3s; bootstrap changes SSH access. Do not run `reset.yaml` as a routine check: it references a missing `k3s` role.
- Never expose or commit plaintext credentials, kubeconfigs, decrypted vault contents or secret keys. Use existing Ansible Vault and Sealed Secrets conventions. `ansible/kubeconfig` may be generated locally and is not currently Git-ignored.
- Respect the cluster's mixed architectures, node taints, network addresses, kube-vip interface and Longhorn disk configuration. Do not change them without understanding their dependencies.
- When adding an Argo CD application, include its manifest in `kubernetes/bootstrap/kustomization.yaml`, select an appropriate project and destination, and ensure referenced resources and CRDs exist.

## Validation

Use the narrowest non-mutating checks relevant to the change. `kustomize build kubernetes/bootstrap` checks the app-of-apps; build affected component directories too. Helm-based Kustomizations require `kustomize build --enable-helm <path>`, Helm and access to the pinned charts (some resources are remote). From `ansible/`, use `ansible-playbook <playbook>.yaml --syntax-check` when collections and vault access are available. Do not print rendered secret material or kubeconfig contents. Report checks that could not run and do not claim a live deployment was verified without evidence.
