kubectl port-forward svc/productpage --address 0.0.0.0 9080:9080 (Port forward)
kubectl apply -f xxxx.yaml
kubectl delete -f xxxx.yaml
kubectl get all
kubectl get all -n
kubectl get pod

kubectl get pods -A
kubectl get pods -A -o wide
kubectl get pods -A -o wide | grep Pending (checking the pending pods)
kubectl get pod <pod> -o yaml (to check container port)
kubectl port-forward svc/prodcutpage --address 0.0.0.0 9080:9080
kubectl port-forward service/productpage --address 0.0.0.0 9080:9080 -n product-page (specific namespace)
kubectl get ns
kubectl get nodes
kubectl get nodes -o wide
$ kubectl config get-contexts
kubectl get nodes -o wide --context 132
kubectl config use-context 132
kubectl get svc

cilium install  --version 1.17.3

kubectl delete pods -n kube-system -l k8s-app=cilium
kubectl delete pods -n kube-system -l k8s-app=cilium-operator

kubectl create ns book-test (create with own name space)
kubectl get pods -o wide
kubectl get ep details -n "book-service" (ep - endpoint check)
kubectl get ep reviews -n default
kubectl get ep ratings -n default
kubectl get ep productpage -n default
kubectl describe pod productpage-v1-54bb874995-tzcdr
kubectl describe replicaset.apps/productpage-v1-54bb874995
to scaleup 
kubectl scale --help (check)
kubectl scale --current-replicas=2 --replicas=3 deployment/mysql
kubectl scale --replicas=3 deployment/productpage-v1
kubectl delete pod "Podname"

kubectl get sa (Service account) ***Super Important Service account means ID 
watch kubectl get sa 

kubectl delete sa book.xx
kubectl create sa productxxxx
kubectl rollout restart deployment rating-1 xxxx (if even after crerating service account, not come back yet , then need to use this rollout)
watch kubectl get ep productpage

kubectl get sa -A
every namespace has "default" service account.
kubectl api -resources (to check all api namespaces status, if it is true - then need to have the namespaces, if it is false - then not required namespace level, can be under cluster level)

kubectl delete all -l app=details
kubectl delete all -l app=ratings
kubectl delete all -l app=reviews
kubectl delete all -l app=productpage

Kubectl exec -it pod name -n namespace
kubectl exec -it productpage-v1-54bb874995-6b59k -n product-page -- sh
kubectl explain sa
kubectl explain sa.metadata
kubectl explain sa.metadata.labels
kubectl explain pod

kubectl api-resources #how to write and how it come the api
while true; do curl http://localhost:xxxx; sleep 1; done

kubectl patch service http-echo-blue -p '{"spec":{"selector":{"version":"green"}}}'
kubectl create deployment webserver --image=nginx --replicas=3 --dry-run=client -o yaml > webserver.yaml
kubectl expose --help
kubectl expose deployment webserver --port=80 --protocol=TCP --target-port=80 --type=ClusteIP
kubectl expose deployment webserver --port=80 --protocol=TCP --target-port=80 --type=LoadBalancer -n webserver

#Job
kubectl create job myjob --image=busybox:latest --dry-run=client -o yaml > job.yaml
kubectl get job
kubectl logs [pod name]

staticpod
docker exec -it 132-worker2 sh
cd /etc/kubernetes/manifests (at worker-2)
apt update
apt install vim -y
#vi static.pod (under worknode 2)
# vi staticpd.yaml
# exitvagrant@hellocloud-native-box1:~/cka-lab$ kubectl get pods
NAME                        READY   STATUS              RESTARTS   AGE
hello-29205478-wmsbg        0/1     Completed           0          2m30s
hello-29205479-w66jk        0/1     Completed           0          90s
hello-29205480-s8md2        0/1     Completed           0          30s
myjob-h5v7x                 0/1     Completed           0          63m
staticpodtest-132-worker2   0/1     ContainerCreating   0          14s


#configmap
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: myconfigmap
  name: myconfigmap
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myconfigmap
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: myconfigmap
    spec:
      containers:
      - image: postgres
        name: postgress
        resources: {}
        envFrom:
        - configMapRef:
            name: myconfigmap


#environment variable
apiVersion: v1
data:
  POSTGRES_PASSWORD: mypgpasss
kind: ConfigMap
metadata:
  creationTimestamp: null
  name: myconfigmap

#Ubutu
uname -a (#check the spec)
ip a (#check for IP)
sudo hostnamectl set-hostname master-node
sudo hostnamectl set-hostname worker-1
sudo hostnamectl set-hostname worker-2
sudo vi /etc/hosts


#work node join
sudo kubeadm join 192.168.90.87:6443 \
  --token 1w41g1.89bqajnffu6a4jwq \
  --discovery-token-ca-cert-hash sha256:49ce07c7093fc13a5bc7f28b30476e4442dabd11c669576fdf28a6e418423676 \
  --control-plane \
  --certificate-key 0a34a5e61fb1b7f8dd1ca23db04fa25a718e3362bba695b1ff0034e99ef28059 \
  --cri-socket unix:///run/cri-dockerd.sock

  USERNAME=vagrant
SCRIPT="pwd; kubeadm token create --print-join-command"
ssh -l ${USERNAME} vagrant "${SCRIPT}"

sudo KUBECONFIG=/etc/kubernetes/admin.conf kubectl get nodes

#always do
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl get nodes

or
sudo kubectl get nodes --kubeconfig=/etc/kubernetes/admin.conf


1. No Worker Node Yet ❗
You only have 1 control-plane node.

Calico DaemonSet (calico-node) tries to deploy to all schedulable nodes — but if you tainted the master (NoSchedule by default), it can't run properly.

2. Insufficient Resources
If your VM has low RAM (less than 2GB) or CPU cores (less than 2), Calico or CoreDNS may be pending due to resource starvation.

3. Missing or Broken Network (CNI not fully applied)
Sometimes Calico needs a few seconds to pull images or create necessary interfaces.

✅ How to Fix
✔️ Step 1: Check Node Taints
Run:

bash
Copy
Edit
kubectl describe node | grep Taint
If you see something like:

bash
Copy
Edit
Taints: node-role.kubernetes.io/control-plane:NoSchedule
That means Pods like Calico can't be scheduled on the master.

🛠 To allow scheduling on the master (for single-node clusters):

bash
Copy
Edit
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
Or for older versions:

bash
Copy
Edit
kubectl taint nodes --all node-role.kubernetes.io/master-


kubeadm token create --print-join-command #Token-create-to-join-the-cluster)

#if clsuter IP is wrong 
ip a | grep inet #check my cluster IP
sudo kubeadm token create --print-join-command --ttl 0


# #ingress minifest
# wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.0/deploy/static/provider/cloud/deploy.yaml

# #if with helm
# helm upgrade --install ingress-nginx ingress-nginx \
#   --repo https://kubernetes.github.io/ingress-nginx \
#   --namespace ingress-nginx --create-namespace

helm repo add metallb https://metallb.github.io/metallb

helm install my-metallb metallb/metallb --version 0.15.2