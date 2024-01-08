# mintos

Prerequisites:
- driver (Docker)
- helm 3+
- minikube
- Terraform


Infrastructure Engineer home assignment
Your task is to deploy the Sonarqube application Helm chart (https://github.com/Oteemo/charts/tree/master/charts/sonarqube) to a Minikube cluster (https://minikube.sigs.k8s.io/docs/start/) using Terraform.
The implementation of this task will be considered representative of you at your best.
Requirements
1. Configure Helm and Tiller for use with Kubernetes cluster (or Helm 3 can be used);
2. Configure Nginx ingress controller (minikube plugin can be used);
3. Install Postgresql using a separate Helm chart (https://github.com/bitnami/charts/tree/master/bitnami/postgresql);
4. Configure Sonarqube to use the DB instance provisioned in the previous step;
5. Install Sonarqube (should use a persistent disk volume);
6. The environment set-up and provisioning should be in the form of a bash script
7. There should be a readme file.
The task is considered to be implemented correctly if, after running the provided scripts, a Sonarqube
instance is up and running within the Kubernetes cluster.
Delivery
The script should be delivered as either an archive or a link to a Git reposito



helm install mintos-postgre oci://registry-1.docker.io/bitnamicharts/postgresql
helm install mintos-postgre \
    --set auth.postgresPassword=secretMintos
    oci://REGISTRY_NAME/REPOSITORY_NAME/postgresql

export POSTGRES_PASSWORD=$(kubectl get secret --namespace default mintos-postgre-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)
kubectl run mintos-postgre-postgresql-client --rm --tty -i --restart='Never' --namespace default --image docker.io/bitnami/postgresql:16.1.0-debian-11-r18 --env="PGPASSWORD=$POSTGRES_PASSWORD" \
      --command -- psql --host mintos-postgre-postgresql -U postgres -d postgres -p 5432

 > NOTE: If you access the container using bash, make sure that you execute "/opt/bitnami/scripts/postgresql/entrypoint.sh /bin/bash" in order to avoid the error "psql: local user with ID 1001} does not exist"

To connect to your database from outside the cluster execute the following commands:

    kubectl port-forward --namespace default svc/mintos-postgre-postgresql 5432:5432 &
    PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432


