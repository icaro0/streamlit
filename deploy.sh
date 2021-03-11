DOCKER_LOGIN_USER=
DOCKER_LOGIN_PASSWORD=
AKS_HOST=one-f56aedc5.hcp.westeurope.azmk8s.io
AKS_STEPS_JENKINS_JWT=
AKS_NAMESPACE=deptapps-uat
FECHA=`date '+%F-%H-%M'`
DOCKER_TAG_NAME=deptapps-stream-portfolios-uat-$FECHA

set -ex

export AKS_DEPLOYMENT_NAME=deptapps-stream-portfolios-uat
export DOCKER_IMAGE_BASE_NAME=deptapps-stream-portfolios

export DOCKER_FINAL_NAME_IMAGE=${DOCKER_IMAGE_BASE_NAME}:${DOCKER_TAG_NAME}
export DOCKER_REMOTE_BASE_NAME_IMAGE=oneregistry01.azurecr.io/deptapps/${DOCKER_IMAGE_BASE_NAME}
export DOCKER_REMOTE_FINAL_NAME_IMAGE=oneregistry01.azurecr.io/deptapps/${DOCKER_FINAL_NAME_IMAGE}

docker login -u ${DOCKER_LOGIN_USER} -p ${DOCKER_LOGIN_PASSWORD} oneregistry01.azurecr.io

docker build -t ${DOCKER_FINAL_NAME_IMAGE} .
docker tag ${DOCKER_FINAL_NAME_IMAGE} ${DOCKER_REMOTE_FINAL_NAME_IMAGE}
docker push ${DOCKER_REMOTE_BASE_NAME_IMAGE}

echo 'kubectl set image....'
# Replace image in Kubernetes cluster
curl --insecure -H "Authorization: Bearer ${AKS_STEPS_JENKINS_JWT}" \
-H "Content-Type: application/json-patch+json" -X PATCH \
-d "[{ \
    \"op\":\"replace\", \
    \"path\":\"/spec/template/spec/containers/0/image\", \
    \"value\": \"${DOCKER_REMOTE_FINAL_NAME_IMAGE}\" \
    }]" \
https://${AKS_HOST}/apis/apps/v1/namespaces/${AKS_NAMESPACE}/deployments/${AKS_DEPLOYMENT_NAME}
