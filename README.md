<!-- PROJECT LOGO -->
<div align="center">
  <h3 align="center">Terraform boilerplate for S3 + CloudFront</h3>  
</div>


<!-- GETTING STARTED -->
## Getting Started

### Prerequisites

#### Terraform CLI
[Install Terraform CLI Link](https://developer.hashicorp.com/terraform/downloads?product_intent=terraform)

### Installation

1. Install Terraform CLI
2. Create User `Terraform` with S3/CloudFront permission using `AWS IAM console`
3. Copy access_key and secret_key from AWS to ~/.aws/credentials file

```bash
File ~/.aws/credentials

[terraform]
aws_access_key_id = yyyyyyyyyyyyyy
aws_secret_access_key = xxxxxxxxxxxxxxx
region=ap-northeast-1
```

4. Change bucket name `simple-blog` to an unique name
5. Deploy to aws using TF CLI
```bash
terraform init
terraform deploy
```
6. Clean up after using
```bash
terraform destroy
```

<!-- LICENSE -->
## License

Distributed under the MIT License.