# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

[.claude/github_actions.md](requirements for github actions)

## Repository Purpose

This repository contains reusable GitHub Actions workflows for Bonitasoft presales demos. The workflows automate:
- AWS EC2 server provisioning and management
- Bonita SCA (Software Composition Architecture) Docker image building and deployment
- UI Builder (UIB) application deployment
- Integration testing with the Bonita Test Toolkit
- Data generation for demos

## Architecture

### Workflow Structure

All reusable workflows are in `.github/workflows/` with the naming convention:
- `reusable_*.yml` - Workflows meant to be called from other repositories
- `test_*.yml` - Test workflows for validating reusable workflows

### Key Workflows

| Workflow | Purpose |
|----------|---------|
| `reusable_create_server.yml` | Provisions an AWS EC2 instance with Docker and Docker Compose |
| `reusable_build_sca.yml` | Builds Bonita SCA Docker image using Maven |
| `reusable_deploy_sca.yml` | Deploys SCA container via docker-compose on AWS |
| `reusable_deploy_uib.yml` | Deploys UI Builder applications via REST API |
| `reusable_deploy_uib_aws.yml` | Deploys UIB applications directly on AWS via SSH |
| `reusable_run_it.yml` | Runs integration tests from `IT/` folder |
| `reusable_run_datagen.yml` | Runs data generation from `datagen/` folder |
| `reusable_prerequisites.yml` | Checks for IT and datagen folders existence |
| `reusable_status_server.yml` | Gets status of existing AWS server |
| `reusable_get_bonita_logs.yml` | Retrieves Docker logs from AWS instance |

### AWS Infrastructure

Uses `bonita-aws` library (v1.8) for EC2 management:
- Region: `eu-west-1`
- AMI: Ubuntu Server 2024.04 LTS x86 (`ami-0776c814353b4814d`)
- Instance type: `t3.large`
- Stack ID format: `{repo-name}_{branch-name}`

### Artifact Flow Between Jobs

Workflows pass data via GitHub artifacts:
- `aws_instance.yaml` - Contains EC2 instance info (publicDnsName)
- `pre_requisites.yaml` - Contains IT_FOLDER_EXISTS and DATAGEN_FOLDER_EXISTS flags

## Required Secrets Per Workflow

Each reusable workflow explicitly declares its required secrets. Callers must pass these secrets.

| Workflow | Required Secrets |
|----------|-----------------|
| `reusable_create_server.yml` | `JFROG_USER`, `JFROG_TOKEN`, `GHP_USER`, `GHP_TOKEN`, `AWS_KEY_ID`, `AWS_ACCESS_KEY`, `AWS_SECURITY_GROUP_ID`, `AWS_PRIVATE_KEY`, `AWS_SSH_USER` |
| `reusable_build_sca.yml` | `JFROG_USER`, `JFROG_TOKEN`, `GHP_USER`, `GHP_TOKEN`, `AWS_KEY_ID`, `AWS_ACCESS_KEY`, `AWS_SECURITY_GROUP_ID`, `AWS_PRIVATE_KEY`, `AWS_SSH_USER` |
| `reusable_deploy_sca.yml` | `licence_base64`, `AWS_PRIVATE_KEY`, `AWS_KEY_ID`, `AWS_ACCESS_KEY`, `AWS_SECURITY_GROUP_ID`, `AWS_SSH_USER`, `JFROG_USER`, `JFROG_TOKEN`, `HEALTHZ_USERNAME`, `HEALTHZ_PASSWORD` |
| `reusable_deploy_uib.yml` | None (uses REST API with credentials in request) |
| `reusable_deploy_uib_aws.yml` | `AWS_PRIVATE_KEY`, `AWS_KEY_ID`, `AWS_ACCESS_KEY`, `AWS_SECURITY_GROUP_ID`, `AWS_SSH_USER` |
| `reusable_prerequisites.yml` | None |
| `reusable_status_server.yml` | `JFROG_USER`, `JFROG_TOKEN`, `GHP_USER`, `GHP_TOKEN`, `AWS_KEY_ID`, `AWS_ACCESS_KEY` |
| `reusable_run_it.yml` | `JFROG_USER`, `JFROG_TOKEN`, `GHP_USER`, `GHP_TOKEN` |
| `reusable_run_datagen.yml` | `JFROG_USER`, `JFROG_TOKEN`, `GHP_USER`, `GHP_TOKEN` |
| `reusable_get_bonita_logs.yml` | `AWS_PRIVATE_KEY`, `AWS_KEY_ID`, `AWS_ACCESS_KEY`, `AWS_SECURITY_GROUP_ID`, `AWS_SSH_USER` |

### Secret Descriptions

- **AWS credentials**: `AWS_KEY_ID`, `AWS_ACCESS_KEY`, `AWS_PRIVATE_KEY`, `AWS_SECURITY_GROUP_ID`, `AWS_SSH_USER`
- **JFrog credentials**: `JFROG_USER`, `JFROG_TOKEN` - For Bonitasoft artifact repository access
- **GitHub Packages**: `GHP_USER`, `GHP_TOKEN` - For GitHub Packages access
- **Bonita license**: `licence_base64` - Base64-encoded Bonita license
- **Health check**: `HEALTHZ_USERNAME`, `HEALTHZ_PASSWORD` - For health check authentication

### How to Pass Secrets When Calling Workflows

There are two ways to pass secrets to reusable workflows:

#### Option 1: Using `secrets: inherit` (Recommended)

The simplest approach - automatically passes all secrets from the calling repository:

```yaml
name: Deploy Demo
on:
  push:
    branches: [main]

jobs:
  create_server:
    uses: bonitasoft-presales/presales_workflows/.github/workflows/reusable_create_server.yml@v1.4.0
    secrets: inherit

  build_sca:
    needs: create_server
    uses: bonitasoft-presales/presales_workflows/.github/workflows/reusable_build_sca.yml@v1.4.0
    secrets: inherit

  deploy_sca:
    needs: build_sca
    uses: bonitasoft-presales/presales_workflows/.github/workflows/reusable_deploy_sca.yml@v1.4.0
    secrets: inherit
```

#### Option 2: Explicit Secret Passing

Pass only the required secrets explicitly (useful for fine-grained control):

```yaml
name: Deploy Demo
on:
  push:
    branches: [main]

jobs:
  create_server:
    uses: bonitasoft-presales/presales_workflows/.github/workflows/reusable_create_server.yml@v1.4.0
    secrets:
      JFROG_USER: ${{ secrets.JFROG_USER }}
      JFROG_TOKEN: ${{ secrets.JFROG_TOKEN }}
      GHP_USER: ${{ secrets.GHP_USER }}
      GHP_TOKEN: ${{ secrets.GHP_TOKEN }}
      AWS_KEY_ID: ${{ secrets.AWS_KEY_ID }}
      AWS_ACCESS_KEY: ${{ secrets.AWS_ACCESS_KEY }}
      AWS_SECURITY_GROUP_ID: ${{ secrets.AWS_SECURITY_GROUP_ID }}
      AWS_PRIVATE_KEY: ${{ secrets.AWS_PRIVATE_KEY }}
      AWS_SSH_USER: ${{ secrets.AWS_SSH_USER }}
```

#### Workflows with Inputs

Some workflows require both inputs and secrets:

```yaml
jobs:
  get_logs:
    uses: bonitasoft-presales/presales_workflows/.github/workflows/reusable_get_bonita_logs.yml@v1.4.0
    with:
      bonita_dns_name: "ec2-xx-xxx-xxx-xxx.eu-west-1.compute.amazonaws.com"
      bonita_service: "bonita"
    secrets: inherit

  deploy_uib:
    uses: bonitasoft-presales/presales_workflows/.github/workflows/reusable_deploy_uib_aws.yml@v1.4.0
    with:
      bonita_dns_name: "ec2-xx-xxx-xxx-xxx.eu-west-1.compute.amazonaws.com"
    secrets: inherit
```

### Complete Example: Full Deployment Pipeline

```yaml
name: Full Demo Deployment
on:
  workflow_dispatch:

jobs:
  prerequisites:
    uses: bonitasoft-presales/presales_workflows/.github/workflows/reusable_prerequisites.yml@v1.4.0

  create_server:
    uses: bonitasoft-presales/presales_workflows/.github/workflows/reusable_create_server.yml@v1.4.0
    secrets: inherit

  build_sca:
    needs: [prerequisites, create_server]
    uses: bonitasoft-presales/presales_workflows/.github/workflows/reusable_build_sca.yml@v1.4.0
    secrets: inherit

  deploy_sca:
    needs: build_sca
    uses: bonitasoft-presales/presales_workflows/.github/workflows/reusable_deploy_sca.yml@v1.4.0
    secrets: inherit

  run_tests:
    needs: deploy_sca
    uses: bonitasoft-presales/presales_workflows/.github/workflows/reusable_run_it.yml@v1.4.0
    secrets: inherit
```

## Maven Configuration

Uses Java 17 (Temurin) with these repositories:
- `bonitasoft.jfrog.io/artifactory/releases` (Bonita Artifact Repository)
- `maven.pkg.github.com/bonitasoft-presales/*`
- `maven.pkg.github.com/laurentleseigneur/*`

## Exposed Ports (after deployment)

- Bonita: `8081` (direct) / `80` (via proxy)
- Keycloak: `8084`
- Mail (Roundcube): `8088`
