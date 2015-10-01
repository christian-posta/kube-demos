# kube-demos
Kubernetes demos

To make best use of these demos:

SSH to your kubernetes-master and set the following flags:
  * kube-apiserver: --runtime-config=experimental/v1alpha1
  * kube-controllermanager: --pod-eviction-timeout=15s

