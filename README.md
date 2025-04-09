# AWS Infrastructure

## Definição

Esse projeto contempla alguns recursos da AWS que serão criados com Terraform.
O objetivo é mapear tendencias, aprender as melhores práticas e documentar tudo o que pode ser utilizado.

## Como rodar o projeto

```bash
terraform init
terraform plan -out=./plan/tfplan
terraform apply -state-out=./plan/tfplan
```

## Melhores práticas

### Princípio do menor privilégio

- Conceda apenas as permissões necessárias para que sua aplicação funcione.
- Sempre restrinja as permissões ao mínimo necessário para a execução da tarefa.

### Monitoramento contínuo

- Use ferramentas como o Checkov para identificar e corrigir problemas de segurança em sua infraestrutura como código.
