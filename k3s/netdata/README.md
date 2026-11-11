# Netdata on k3s

Release `netdata`, namespace `netdata`, chart `netdata/netdata`.

## Upgrade
    helm repo update
    helm upgrade netdata netdata/netdata -n netdata -f values.yaml
    kubectl get svc -n netdata   # must show 19999:30152/TCP

## If the NodePort changed (chart has no nodePort option)
    kubectl patch svc netdata -n netdata --type=json \
      -p '[{"op":"replace","path":"/spec/ports/0/nodePort","value":30152}]'

## Notes
- PVCs use local-path (not resizable): database 5Gi, alarms 1Gi, k8s-state 1Gi.
  Chart default for the database is 15Gi, so the volumesize settings in values.yaml are required.
- Upgrading 3.7.165 -> 3.7.179 failed with "cannot patch PVC" until volume sizes were pinned.
