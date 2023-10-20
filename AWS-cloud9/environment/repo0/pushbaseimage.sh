cd "$(dirname "${BASH_SOURCE[0]}")"

#Create Images
docker build -t amazoncorretto -f amazoncorretto/Dockerfile .
docker build -t nginx -f nginx/Dockerfile .

#Rename Images
REPO1=$(aws ecr describe-repositories --repository-names base-amazoncorretto --output text --query "repositories[0].repositoryUri")
REPO2=$(aws ecr describe-repositories --repository-names base-nginx --output text --query "repositories[0].repositoryUri")
IMAGE1=$REPO1:latest
IMAGE3=$REPO2:latest
docker tag amazoncorretto $IMAGE1
docker tag nginx $IMAGE2

#Push Images
Account=$(aws sts get-caller-identity --query "Account" --output text)
Region=$(aws configure get region)
aws ecr get-login-password --region $Region | docker login --username AWS --password-stdin $Account.dkr.ecr.$Region.amazonaws.com
docker push $IMAGE1
docker push $IMAGE2