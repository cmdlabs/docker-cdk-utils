# docker-cdk-utils

Docker image with `aws-cdk` and `aws-cli`.

## Why?

This image is used when following the [3 Musketeers] pattern. By running `cdk` inside Docker, we ensure consistency, control and confidence.

  * Consistency: when developing automated processes that use `cdk`, you can be sure that they will function the same whether you run it on your Windows workstation or on a Jenkins build agent.
  * Control: by specifying the version of the image in [docker-compose.yml][], we can deploy to two incompatible versions of CDK simultaneously.
  * Confidence: reliable deployments build confidence in the use of CI/CD pipelines, creating a positive feedback loop that encourages developers to use CI/CD.

[3 Musketeers]: https://3musketeers.io/

## How To Use

Makefile:
```Makefile
deploy:
	docker-compose run --rm cdk deploy
```

docker-compose.yml:
```yaml
services:
  cdk:
    image: cmdlabs/cdk-utils:1.0.0
    volumes:
      - .:/work:Z
```
