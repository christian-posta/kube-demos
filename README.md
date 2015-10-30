# kube-demos
Kubernetes demos

To run these demos you need 'pv' and 'tmux' installed.

To make best use of these demos:

SSH to your kubernetes-master and set the following flags:
  * kube-controllermanager: --pod-eviction-timeout=10s
  * kube-apiserver: --runtime-config=extensions/v1beta1/daemonsets=true

