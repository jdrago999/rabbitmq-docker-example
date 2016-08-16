
# rabbitmq

```bash
docker build -t my/rabbitmq:latest .
```

```bash
docker run \
  --name rabbitmq \
  -e RABBITMQ_DEFAULT_USER=foobar \
  -e RABBITMQ_DEFAULT_PASS=changeme \
  -e RABBITMQ_DEFAULT_VHOST=foo \
  my/rabbitmq:latest
```
