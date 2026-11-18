# Terraform AWS Environments

Projeto de **Infraestrutura como Código (IaC)** utilizando Terraform para provisionamento e gerenciamento de recursos de infraestrutura em diferentes ambientes, com módulos reutilizáveis e configurações específicas para cada ambiente.

O projeto utiliza o **Floci** para simular serviços da AWS localmente, permitindo desenvolver, testar e validar configurações de infraestrutura sem a necessidade de provisionar recursos diretamente na AWS durante os testes.

## Objetivos do projeto

- Aplicar conceitos de Infraestrutura como Código (IaC).
- Criar e gerenciar ambientes independentes utilizando Terraform.
- Desenvolver módulos reutilizáveis para os recursos de infraestrutura.
- Implementar comunicação e distribuição de tráfego entre recursos.
- Aplicar boas práticas de organização, parametrização e gerenciamento de variáveis.
- Simular recursos da AWS em ambiente local utilizando Floci.

## Tecnologias utilizadas

| Tecnologia | Finalidade |
|---|---|
| Terraform | Provisionamento e gerenciamento da infraestrutura |
| AWS | Serviços de infraestrutura utilizados como referência |
| Floci | Simulação local de serviços da AWS |
| Docker | Execução do Floci em container |
| Docker Compose | Gerenciamento do ambiente local |
| Linux (Ubuntu WSL) | Ambiente de desenvolvimento |
| Git | Controle de versão |

## Arquitetura do projeto

A infraestrutura foi organizada em três ambientes independentes, cada um com suas próprias configurações e recursos.

### Development (Dev)

Ambiente destinado ao desenvolvimento e testes iniciais.

- VPC dedicada.
- Subnet.
- Instância EC2.
- Security Group com acesso HTTP e SSH restrito por CIDR.
- Recursos provisionados utilizando módulos reutilizáveis.

### Staging

Ambiente destinado à validação da infraestrutura e simulação de uma arquitetura mais próxima de produção.

- VPC dedicada.
- Subnets distribuídas em duas zonas de disponibilidade.
- Duas instâncias EC2.
- Application Load Balancer (ALB).
- Security Groups específicos para o ALB e as instâncias EC2.
- Dois Target Groups: aplicação web (porta 80) e API (porta 3000).
- Listener HTTP com regra de roteamento por caminho para requisições `/api/*`.

O ALB recebe as requisições e direciona o tráfego para o Target Group correspondente, utilizando verificações de saúde (Health Checks) para acompanhar a disponibilidade das instâncias.

### Production (Prod)

Ambiente destinado à infraestrutura de produção, com configurações próprias de recursos e capacidade.

- VPC dedicada.
- Subnets distribuídas em duas zonas de disponibilidade.
- Instâncias EC2.
- Application Load Balancer (ALB).
- Security Groups para controle de acesso.
- Target Groups para distribuição de tráfego.
- Listener HTTP para direcionamento das requisições.

A infraestrutura utiliza os mesmos módulos reutilizáveis dos demais ambientes, mantendo o isolamento das configurações e permitindo gerenciar cada ambiente de forma independente.

## Estrutura de diretórios

```text
terraform-aws-environments/
│
├── modules/
│   ├── vpc/
│   ├── ec2/
│   ├── security_group/
│   └── alb/
│
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
│
├── data/
├── compose.yaml
├── .gitignore
└── README.md
```

### Organização dos módulos

| Módulo | Responsabilidade |
|---|---|
| `vpc` | Criação da VPC, subnets, Internet Gateway e rotas |
| `ec2` | Provisionamento de instâncias EC2 |
| `security_group` | Gerenciamento de regras de acesso e segurança |
| `alb` | Criação do Load Balancer, Listeners, Target Groups e associações |

Cada ambiente possui seus próprios arquivos de configuração, permitindo utilizar os mesmos módulos com diferentes parâmetros.

## Fluxo de tráfego do ALB

Nos ambientes Staging e Prod, o Application Load Balancer utiliza roteamento baseado em caminhos:

```text
                 Internet
                     |
                     v
              Application
              Load Balancer
                     |
               HTTP - Porta 80
                     |
              Listener HTTP
                     |
             +-------+-------+
             |               |
       /api/* (regra)    Demais rotas
             |               |
             v               v
        API Target       Site Target
        Group :3000      Group :80
             |               |
         EC2 - 1 e 2     EC2 - 1 e 2
```

Os Target Groups possuem verificações de saúde independentes, permitindo acompanhar a disponibilidade dos serviços.

## Ambiente local com Floci

O Floci é utilizado para simular serviços da AWS durante o desenvolvimento.

A execução é realizada por meio do Docker Compose, disponibilizando o endpoint local:

```text
http://localhost:4566
```

Os dados persistidos do Floci são armazenados no diretório `data/`, permitindo manter os dados entre reinicializações do container, conforme o modo de persistência configurado.

## Pré-requisitos

Para executar o projeto, são necessários:

- Linux ou Ubuntu via WSL2.
- Terraform instalado.
- Docker instalado e em execução.
- Docker Compose.
- Git.

## Como executar

### 1. Clonar o repositório

```bash
git clone <URL_DO_REPOSITORIO>
```

```bash
cd terraform-aws-environments
```

### 2. Iniciar o Floci

Na raiz do projeto:

```bash
docker compose up -d
```

Verifique se o container está em execução:

```bash
docker compose ps
```

### 3. Configurar o ambiente desejado

Acesse o diretório do ambiente que deseja executar.

Exemplo para Dev:

```bash
cd environments/dev
```

### 4. Configurar as variáveis

Cada ambiente pode possuir variáveis específicas que devem ser configuradas antes da execução do Terraform.

No ambiente Dev, é necessário informar o CIDR autorizado a acessar a instância EC2 por SSH.

Crie o arquivo `terraform.tfvars` dentro de `environments/dev/`:

```hcl
ssh_cidr = "SEU_IP_PUBLICO/32"
```

Substitua `SEU_IP_PUBLICO` pelo seu endereço IPv4 público.

O sufixo `/32` restringe o acesso a um único endereço IP.

**Importante:**

- Não utilize `0.0.0.0/0` para liberar SSH publicamente.
- O arquivo `terraform.tfvars` não deve ser versionado no Git.
- O `.gitignore` já está configurado para ignorar arquivos `.tfvars`.
- Caso seu IP público mude, atualize o valor no arquivo antes de executar o Terraform.

Para os ambientes Staging e Prod, configure os arquivos `terraform.tfvars` caso existam variáveis obrigatórias nesses ambientes.

### 5. Inicializar o Terraform

Dentro do diretório do ambiente selecionado:

```bash
terraform init
```

### 6. Validar a configuração

```bash
terraform fmt -recursive
terraform validate
```

### 7. Visualizar o plano de execução

```bash
terraform plan
```

### 8. Aplicar a infraestrutura

```bash
terraform apply
```

Para remover os recursos gerenciados pelo Terraform no ambiente selecionado:

```bash
terraform destroy
```

**Atenção:** antes de executar `plan`, `apply` ou `destroy`, confirme que o provider AWS está configurado para utilizar o endpoint local do Floci. Não execute essas operações apontando para uma conta AWS real sem revisar as configurações.

## Segurança e boas práticas

Durante o desenvolvimento, foram adotadas práticas para melhorar a organização e a segurança da infraestrutura:

- Separação dos ambientes.
- Reutilização de módulos Terraform.
- Parametrização de recursos por meio de variáveis.
- Restrição de acesso SSH por CIDR.
- Controle de acesso entre ALB e instâncias EC2 por Security Groups.
- Utilização de `.gitignore` para evitar o versionamento de arquivos sensíveis.
- Exclusão de arquivos de estado, variáveis locais e dados persistidos do controle de versão.

## Aprendizados

Este projeto foi desenvolvido com foco na aplicação prática de conceitos de DevOps e infraestrutura, envolvendo:

- Infraestrutura como Código (IaC).
- Modularização com Terraform.
- Gerenciamento de múltiplos ambientes.
- Redes e conectividade na AWS.
- Security Groups e controle de acesso.
- Balanceamento de carga com Application Load Balancer.
- Docker e Docker Compose.
- Simulação de serviços AWS em ambiente local.
- Versionamento de código com Git.

---

**Projeto desenvolvido para fins de estudo e prática em DevOps, Cloud e Infraestrutura como Código.**