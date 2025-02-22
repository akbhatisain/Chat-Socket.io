# What Socket.IO is
Socket.IO is a library that enables low-latency, bidirectional and event-based communication between a client and a server.

The Socket.IO connection can be established with different low-level transports:
HTTP long-polling
WebSocket
WebTransport

Socket.IO will automatically pick the best available option, depending on:
the capabilities of the browser (see here and here)
the network (some networks block WebSocket and/or WebTransport connections)
Check out how it is working :- https://socket.io/docs/v4/how-it-works/

## Features
Multiple users can join a chat room by each entering a unique username on website load.
Users can type chat messages to the chat room.
A notification is sent to all users when a user joins or leaves the chatroom.
For more detailed documentation visit :- https://socket.io/docs/v4/tutorial/introduction

## Socket.IO Chatapp Server Implementation
Please check our documentation here:- https://socket.io/docs/v4/

## Prerequisites:
Node.js
npm
Docker and Minikube (Linux). 
Docker-desktop with Kubernetes enabled.(Windows).

## How to use locally
1. Clone the repo:-
    $ git clone https://github.com/akbhatisain/Chat-Socket.io
2. Switch to project directory:
    $ cd Chat-Socket.io
3. Setup the project:
    $ npm i
    $ npm start
4. Test your environment :- Search on your browser http://localhost:3000.
5. Once you finish with testing Stop the server with Ctrl+c in terminal.

## Dockerize the Application
1. Create a Docker Image
    $ docker build -t chatapp:v1 ./

2. Run the container 
    $ docker run -itd -p 3001:3000 --name chat-app chatapp:v1

3. Checking the container:-
    $ Docker ps

4. Details about the container
    $ docker container inspect <CONTAINER ID>

5. Test your environment :- Search on your browser http://localhost:3000. OR http://127.0.0.1:3000

6. Once you finish with testing destroy the container.
    $ docker rm <CONTAINER ID>

## Deploy Chatapp service on Kubernetes:-
1. Install NGINX ingress controller:-
    $ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml

2. Review the Ingress Controller:-
    $ kubectl get pods -n ingress-nginx
    NAME                                       READY   STATUS      RESTARTS      AGE
    ingress-nginx-admission-create-4fgnz       0/1     Completed   0             46h
    ingress-nginx-admission-patch-kkg95        0/1     Completed   1             46h
    ingress-nginx-controller-cbb88bdbc-w7vx8   1/1     Running     1 (29m ago)   46h

3. Review the Ingress Controller service:-
    $ kubectl get svc -n ingress-nginx

4. Deploy the stack (Deployemnt, Service) 
    $ kubectl apply -f deployment.yaml
    $ kuberctl apply -f ingress.yaml

5. check the resources:
    $ kubectl get node
    $ kubectl get deploy
    $ kubectl get svc
    $ kubectl get ingress
    $ kubectl get pods
    $ kubectl describe ingress chatapp-ingress
      Name:             chatapp-ingress
      Labels:           <none>
      Namespace:        default
      Address:          localhost
      Ingress Class:    <none>
      Default backend:  <default>
      Rules:
        Host         Path  Backends
        ----         ----  --------
        friends.com
                     /   chatapp-service:80 (10.1.0.40:3000,10.1.0.41:3000)
      Annotations:   kubernetes.io/ingress.class: nginx
                     nginx.ingress.kubernetes.io/rewrite-target: /
      Events:
        Type    Reason  Age   From                      Message
        ----    ------  ----  ----                      -------
        Normal  Sync    25m   nginx-ingress-controller  Scheduled for sync

    $ kubectl get svc -n ingress-nginx
    NAME                                 TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
    ingress-nginx-controller             LoadBalancer   10.101.20.110   localhost     80:31991/TCP,443:32484/TCP   46h
    ingress-nginx-controller-admission   ClusterIP      10.111.23.57    <none>        443/TCP                      46h

Note: Here you can see that the Ingress Controller is running on localhost (External-IP).
🖥️ To run your application with domain Map "friends.com" to Localhost
Since your Ingress Controller is running on localhost, you must update your Windows/Linux hosts file to resolve friends.com:

1. Open Notepad as Administrator.
Open: C:\Windows\System32\drivers\etc\hosts
Add this line:
127.0.0.1 friends.com
Save and close the file.

2. In powershell Flush the DNS cache
ipconfig /flushdns

🔬 Test If It Works
Now, test if your Ingress is forwarding traffic correctly:
curl -v http://friends.com
or open http://friends.com in your browser.

## Troubleshooting Resources:-

kubectl describe ingress chatapp-ingress
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx

## Clean up the resources:-
kubectl delete deployment chatapp-deployment
kubectl delete service chatapp-service
kubectl delete ingress chatapp-ingress

## Add auto-scaling in your local Docker Desktop Kubernetes cluster

1. Ensure the Metrics Server Is Running:
$ kubectl get pods -n kube-system
                OR
$ kubectl get pods -n kube-system | grep metrics-server

If you don’t see a running metrics server, you can install one using:
Please consider this below command only if you are not fully  familiar with the Kubernetes.
$ kubectl apply -f metrics-server.yaml
              OR
You can also use the following command to install the metrics server:(Additional changes needed)
$ kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

Wait a couple of minutes, then verify again.
$ kubectl get pods -n kube-system

$ kubectl get pods -n kube-system -l k8s-app=metrics-server
NAME                              READY   STATUS    RESTARTS   AGE
metrics-server-6574b5696c-rcd8c   1/1     Running   0          3m8s

# Check Pods
kubectl get pods -n kube-system -l k8s-app=metrics-server

# Check APIService Status
kubectl get apiservice v1beta1.metrics.k8s.io -o yaml

# Check Metrics Server Logs
kubectl logs -n kube-system metrics-server-7555b99666-9cdrl

# Test Metrics
kubectl top nodes
kubectl top pods


2. Create an HPA for Your Deployment
$ kubectl apply -f hpa.yaml

$ kubectl get hpa


### Troubleshooting Parts:-

$kubectl top nodes
$kubectl top pods

### Remove the Existing Metrics-Server Pods
kubectl delete deployment metrics-server -n kube-system
kubectl get pods -n kube-system -l k8s-app=metrics-server
kubectl delete pod <pod-name> -n kube-system

### Reomve HPA 
kubectl delete hpa chatapp-hpa
kubectl get hpa

kubectl logs -n kube-system metrics-server-55c8cb4bfc-pprf9

kubectl delete pod metrics-server-d5865ff47-5kkkt -n kube-system

3. Testing Auto-scaling
$for i in {1..100}; do curl -s http://friends.com > /dev/null; done

###Simulate Load to Trigger Scaling:
To trigger auto-scaling, we can generate CPU load:
kubectl run -i --tty load-generator --rm --image=busybox -- /bin/sh

Inside the pod run below command:-
while true; do wget -q -O- http://<your-service-ip>:<port>; done
OR
if you are testing locally then use below command:-
while true; do echo "scale test" | sha256sum; done

Ctrl+C to exit the load-generator pod.

🚀 Final Checklist
✅ Ingress Class set to nginx
✅ Ingress is correctly routing to chatapp-service
✅ Windows hosts file maps friends.com to 127.0.0.1
✅ Ingress Controller logs show no errors

Try these steps and let me know what errors you get! 🚀🔥
