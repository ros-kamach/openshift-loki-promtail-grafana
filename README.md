oc new-project loki-metrics
oc new-project test1
oc new-project test2


oc label nodes openshift-loki-demo4-node-0 loki=true
oc label nodes openshift-loki-demo1-node-1 loki=true
oc label nodes openshift-loki-demo-node-1 loki=false --overwrite=true

Install Grafana
oc process -f grafana_oauth.yaml -p NAMESPACE=loki-metrics | oc apply -f -

Promtail
oc process -f promtail/rbac.yaml -p PROMTAIL_PROJECT_NAME=kube-system | oc apply -f -
oc process -f promtail/cfgmap.yaml -p PROMTAIL_PROJECT_NAME=kube-system -p LOKI_PROJECT_NAME=loki-metrics | oc apply -f -
oc process -f promtail/daemonset.yaml -p PROMTAIL_PROJECT_NAME=kube-system | oc apply -f -

Show Targets
oc port-forward -n kube-system $(oc get pods -n kube-system -l name=promtail -o jsonpath='{.items[0].metadata.name}') 3101:3101

Minio
oc process -f minio/minio.yaml -p NAMESPACE=default | oc apply -f -

Loki
oc process -f loki/loki_deployment.yaml -p NAMESPACE=loki-metrics | oc apply -f -


oc adm pod-network join-projects --to=loki-metrics kube-system