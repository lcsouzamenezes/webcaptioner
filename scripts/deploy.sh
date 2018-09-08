# Get env variables for this deployment environment
# https://gitlab.com/gitlab-org/gitlab-ce/issues/20367#note_89285011
ENV_VAR_SUFFIX="__${CI_ENVIRONMENT_SLUG}"
for var in $(compgen -e | grep "${ENV_VAR_SUFFIX}$")
do
    declare -x ${var%${ENV_VAR_SUFFIX}}="${!var}"
done 


# Install awscli
apk add --update python python-dev py-pip nodejs
pip install awscli --upgrade

node scripts/write-task-definition.js >> testfile2

cat testfile2

exit 1

docker pull $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_NAME

# AWS configs used during get-login
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

# Log into AWS docker registry
$(aws ecr get-login --no-include-email --region $AWS_REGION | tr -d '\r')

docker tag $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_NAME $AWS_REGISTRY_IMAGE:$CI_ENVIRONMENT_SLUG
docker push $AWS_REGISTRY_IMAGE:$CI_ENVIRONMENT_SLUG

# Create a new version of the task definition
aws ecs register-task-definition --family webcaptioner-$CI_ENVIRONMENT_SLUG	 --requires-compatibilities FARGATE --cpu 256 --memory 512 --cli-input-json file://aws/webcaptioner-task-definition-$CI_ENVIRONMENT_SLUG.json --region $AWS_REGION

# Use latest version of task definition in service
aws ecs update-service --cluster webcaptioner-$CI_ENVIRONMENT_SLUG --service webcaptioner --task-definition webcaptioner-$CI_ENVIRONMENT_SLUG --region $AWS_REGION