## Project to deploy python/redis app on eks using jenkins and configration with ansible
... 

### To run the project you have to 
1) Go to terraform directory and run
   ```bash
   terrafrom init 
   terraform apply
   ```
2) Go to ansible directory and run 
   ```bash
   ansible-playbook playbook.yml -i inventory.ini 
   ```
###### note: kubernetes files for jenkins on the k8s role

#### Now you have jenkins running on a deployment 

###### you need to:

1) Create Pipeline with scm and add your docker credentials
2) Add this repo in the scm it contains the Jenkinsfile 
https://github.com/gassermohsen/DevOps-Challenge-Demo-Code

```yaml
pipeline {
    agent any

    stages {
        stage('CI') {
            steps {
                git url:  'https://github.com/gassermohsen/DevOps-Challenge-Demo-Code' , branch: 'master'
                withCredentials([usernamePassword(credentialsId: 'Docker', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]){
                sh """
                docker login -u ${USERNAME} -p ${PASSWORD}
                docker build -f Dockerfile --network host -t gassermohsen/app:v1 .
                docker push gassermohsen/app:v1
                """
            
            }
            }
            
        }
        stage('CD'){
            steps{
                     withCredentials([usernamePassword(credentialsId: 'Docker', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]){
                sh """
                docker login -u ${USERNAME} -p ${PASSWORD}
                kubectl create namespace app
                kubectl apply -f deployment-redis.yml
                kubectl apply -f redis-service.yml
                kubectl apply -f app-deployment.yml
                kubectl apply -f lb.yml
                kubectl get svc
                """
                     }
            }
        }
        
    }
}
```
