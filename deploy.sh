DOCKER_LOGIN_USER=6114d1ce-ecfd-4360-b8d8-7e1311ce47e4
DOCKER_LOGIN_PASSWORD=mp6ymcWFcJ/lHIj9ciylvrCjP/YUpmyqDw1YszEYvbo=
AKS_HOST=one-f56aedc5.hcp.westeurope.azmk8s.io
AKS_STEPS_JENKINS_JWT=eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJzdGVwcy1qZW5raW5zLXRva2VuLXpibG10Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6InN0ZXBzLWplbmtpbnMiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiJkZTYxMzE1MC00NjYxLTExZTktOTBlYi04YWZmZTU4NDJkNTYiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZS1zeXN0ZW06c3RlcHMtamVua2lucyJ9.YYDhqoxs5prZ3dDC374IWZyQgq8xVJEsD2uhd4J-BVUoVDcfCeWnmCGEHlKgXNL3Y1KB2twgYIOuPk_CRJzeF7EuQQAhhhwk7CjEEOeNeI9r7EU5gv2nGi3K_dvBPHBFtlDLNrKbcLJZi24zkksgbltQ4ONzfjjDO7ZAW69tkTqasV6G4VZjiPiTzrwUuiFaojf2EuWgmf4FKXIuSuvbkXlqmo7P-h_-DL4ptpqLPxut3fyvVvjKDrid2LRRgPVfeR7z8cz3HfxGc3MiVSfJ3PuDz0e8qj15SvZTxwDA2cgnHhL6amf0kVfqCH3CQWgECYvyCR3wpRtMu9vSc52dG8t-fT9IlKHri3oDX_CvEMLLOvvce0SjilDynkgWjakFkZLgWOtH-DVuJRGUgRECLy-wZJOYOl4y1r5KzNURFwjCv81Xrvp8K8niqdjirnrognikmLj-OXo9ZDFUVLc9N2tOkzCV9AhoThnjXeUpuXcSnEcvA8CahIQEOwb_7Inu_znVCXHF6CmzEQE6ud2upF58aj5m3doMqle14LfjQhH6ljOY8jMEEd1mHxZzqvwpqvI89-lWd2t-vzFmQJAvC7ohLjpK4IFnD6AlARz25wToFrfWhBU4rLXuh5dIlcJxLmyV26G667rmlxZVEtTz9xYemS8ueQjl9BAJwlKV1dI
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