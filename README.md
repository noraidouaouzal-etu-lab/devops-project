# Projet DevOps — Infrastructure CI/CD avec Kubernetes et Terraform

## Membres
- Hajar — Application + Docker
- Hiba — Terraform + Azure  
- Nora — Ansible + Kubernetes
- Sara — CI/CD + GitHub Actions

## Livrables
- [Rapport PDF](rapport.pdf)
- [Presentation PPT](presentation devops.pptx)

## Architecture
Code → GitHub Actions → Docker Hub → Kubernetes (Azure)

## Lien GitHub Actions
https://github.com/noraidouaouzal-etu-lab/devops-project/actions

## Comment reproduire ce projet

1. Cloner le repository
   git clone https://github.com/noraidouaouzal-etu-lab/devops-project

2. Créer les VMs Azure
   cd terraform
   terraform init && terraform plan && terraform apply

3. Configurer le cluster
   cd ansible
   ansible-playbook -i inventory.ini install_k3s.yml

4. Déployer l'application
   kubectl apply -f k8s/deployment.yaml
   kubectl apply -f k8s/service.yaml

5. Vérifier
   kubectl get nodes
   kubectl get pods
