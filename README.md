# AWS Batch POC

## Setup

Para iniciar el proyecto se requiere contar con las siguientes variables de ambiente:
- AWS_DEFAULT_REGION
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY

Se recomienda contar con un archivo que tenga las variables. 

Por ejemplo (para Linux o Mac), para cargar estas variables:

```shell
export AWS_DEFAULT_REGION="us-east-1"
export AWS_ACCESS_KEY_ID="<access_key_id>"
export AWS_SECRET_ACCESS_KEY="<secret_access_key>"
```

El contenido del archivo de ejemplo debería ser almacenado en un archivo .env y para cargar las variable ejecutaremos lo siguiente:

```shell
. .env
```

> Este archivo no debe ser enviado al repositorio por NINGUN motivo. Incluir el archivo en en `.gitignore`, para evitar que se agregue al repositorio.

Por último debe crear un perfil con sus credenciales de CLI (https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html)

## Terraform

Para usar el proyecto Terraform se debe acceder al directorio `aws-terraform` y ejecutar los siguientes comandos:

```shell
terraform init
terraform plan
terraform apply
```

> No usar esto para una versión produciva, es mejor incluir esto dentro de un módulo de Terragrunt.

Una vez probado, borrar la infraestructura.

```shell
terraform destroy
```

### Serverless

Instalar binario de serverless: https://www.serverless.com/framework/docs/getting-started/. Luego deberá acceder al directorio `aws-serverless`, para desplegar la aplicación. Una vez que se hayan realizado los pasos anteriores, se puede usar la siguiente instrucción para desplegar:

```shell
serverless deploy --stage dev --region <region> --aws-profile <perfil>
```

### Docker

Primero debe crear un repositorio en AWS ECR y con la región y perfile de CLI definidos en los pasos anteriores, ejecutar los siguientes comandos:

```shell
aws ecr get-login-password --region <region> --profile <perfil> | docker login --username AWS --password-stdin <cuenta-aws>.dkr.ecr.<region>.amazonaws.com
docker build -t <repositorio> .
docker tag <repositorio>:latest <cuenta-aws>.dkr.ecr.<region>.amazonaws.com/<repositorio>:latest
docker push <cuenta-aws>.dkr.ecr.<region>.amazonaws.com/<repositorio>:latest
```

> Lo anterior es detallado también en el mismo repositorio de AWS ECR