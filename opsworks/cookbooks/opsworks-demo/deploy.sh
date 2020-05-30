zip -x deploy.sh -r opsworks-demo.zip .

aws s3 cp opsworks-demo.zip s3://russia-testes-gerais/opsworks-demo.zip