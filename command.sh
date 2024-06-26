minikube start
docker build -t academix-project .     
docker run -p 8000:8000 academix-project
docker tag academix-project pyzone49/academix_project:1
docker push pyzone49/academix_project:1

docker build -t academix-api .     
docker run -p 8000:8000 academix-api
docker tag academix-api pyzone49/academix_api:2
docker push pyzone49/academix_api:2


kubectl create deployment academix-service --image=pyzone49/academix_project:1
kubectl describe pods

kubectl expose deployment academix-service --type=NodePort --port=8080

minikube service academix-service --url

kubectl create namespace production

kubectl apply -f myservice-deployment.yml

kubectl expose deployment academix-deployment --type=NodePort --port=8080 --target-port=8000 --namespace=production

minikube service academix-deployment --namespace=production --url


kubectl label namespace production istio-injection=enabled

minikube start tunnel

export PATH=$PWD/bin:$PATH
istioctl install --set profile=demo -y

kubectl apply -f infrastructure.yaml       
kubectl apply -f microservices.yaml 
kubectl get svc istio-ingressgateway -n istio-system

kubectl get gateway -n production
kubectl get virtualservice -n production

istioctl proxy-config routes istio-ingressgateway-5f5f6bcd7c-86r5x -n istio-system

kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80