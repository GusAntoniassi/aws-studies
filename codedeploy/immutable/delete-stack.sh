aws cloudformation delete-stack \
--stack-name $1 \
--region=${AWS_DEFAULT_REGION:-us-east-1}