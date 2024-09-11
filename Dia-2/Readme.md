# Dia 2

>## Pre-requisitos
>
>Esssa é uma continuação do ***Dia 1*** então recrie os acontecimentos do dia anterior e vamos em frente.
>
>Então, para acelerar o processo acesso o diretório do ***Dia 1*** para pegar as alterações feitas.
>```bash
>kubectl apply spree-ecommerce/
>```

>**💡NOTA**
>
>Os arquivo dentros do diretório ***spree-ecommerce*** é o resultado das alterações ao final do Dia 2. Na dúvida consulte-os arquivos

## APM

Veremos três instrumentações diferente conforme foi abordado na maratona, para exemplos de aprendizado.

### Instrumentando o Serviço _discounts_

Para esse serviço realizaremos a instrumentação via **Datadog Admission Controler** que injeta código para instruentação do serviço.

Adicione as seguinte _labels_ a nível de Deployment no arquivo _discounts.yaml_
```yaml
      labels:
        tags.datadoghq.com/env: 'maratona'
        tags.datadoghq.com/service: 'discounts'
        tags.datadoghq.com/version: '1.0'
```

Adicione as seguinte _labels_ e _annotation_ a nível de Template no arquivo _discounts.yaml_
```yaml
      labels:
        tags.datadoghq.com/env: 'maratona'
        tags.datadoghq.com/service: 'discounts'
        tags.datadoghq.com/version: '1.0'
        admission.datadoghq.com/enabled: "true"
      annotations:
        admission.datadoghq.com/python-lib.version: v2.12.1
        ad.datadoghq.com/discounts.logs: '[{"source": "python", "service": "discounts"}]'
```

Adicione também as seguinte _variables_ para o pod
```yaml
        env:
          - name: DD_LOGS_INJECTION
            value: "true"
```

Vejo o arquivo com todas atualizações atualizações [discounts.yaml](./spree-ecommerce/discounts.yaml)

### Instrumentando Serviço _advertisements_

Seguido para o serviço _advertisements_ vamos adicionar a lib do trace datadog direto na imagem, para facilitar essa demanda há um diretório chamado ***ads*** nesse diretório ha dois arquivos um _Dockerfile_ para rebuild da imagem e outro _requirements-dd_ para buildar a imagem com a intrumentação necessária.

Comando para buildar a imagem instrumentada
```bash
docker image build --progress=plain --tag salomaosan/ads:v0.2-apm .
```

Adicione as seguinte _labels_ a nível de Deployment e Template no arquivo _advertisements.yaml_
```yaml
      labels:
        tags.datadoghq.com/env: 'maratona'
        tags.datadoghq.com/service: 'advertisements'
        tags.datadoghq.com/version: '1.0'
```

Adicione ae monte os segintes _volumes_ no spec no arquivo _advertisements.yaml_
```yaml
      volumes:
      - hostPath:
          path: /var/run/datadog/
        name: apmsocketpath
      containers:
      - image: salomaosan/ads:v0.1
        name: advertisements
        volumeMounts:
          - name: apmsocketpath
            mountPath: /var/run/datadog
```

Adicione também as seguinte _variables_ para o pod
```yaml
        env:
          - name: DD_LOGS_INJECTION
            value: "true"
          - name: DD_AGENT_HOST
            valueFrom:
              fieldRef:
                fieldPath: status.hostIP
          - name: DD_ENV
            valueFrom:
              fieldRef:
                fieldPath: metadata.labels['tags.datadoghq.com/env']
          - name: DD_SERVICE
            valueFrom:
              fieldRef:
                fieldPath: metadata.labels['tags.datadoghq.com/service']
          - name: DD_VERSION
            valueFrom:
              fieldRef:
                fieldPath: metadata.labels['tags.datadoghq.com/version']
```

Por fim para a do container seguimos da seguinte forma, para que o ```ddtrace-run``` execute o codigo e capture as requisições.

```yaml
      containers:
      - image: salomaosan/ads:v0.1
        name: advertisements
        command: ["ddtrace-run"]
        args: ["flask", "run", "--port=5002", "--host=0.0.0.0"]
```

Vejo o arquivo com todas atualizações atualizações [advertisements.yaml](./spree-ecommerce/advertisements.yaml)

### Instrumentando Serviço _store-frontend_

Por fim, vamos para o serviço _store-frontend_ que é ruby, aqui o processo é um pouco diferente mas vamos rebuildar a imagem também para instrumentar a aplicação, acesse o diretório ***frontend*** que também tem três arquivos _Dockerfile_, _Gemfile_ e _datadog.rb_ para buildar a imagem com a intrumentação.

Comando para buildar a imagem instrumentada
```bash
docker image build --progress=plain --tag salomaosan/frontend:v0.2-apm .
```

Adicione as seguinte _labels_ a nível de Deployment e Template no arquivo _frontend.yaml_
```yaml
      labels:
        tags.datadoghq.com/env: 'maratona'
        tags.datadoghq.com/service: 'store-frontend'
        tags.datadoghq.com/version: '1.0'
```

Adicione também as seguinte _variables_ para o pod
```yaml
        env:
          - name: DD_LOGS_INJECTION
            value: "true"
          - name: DD_AGENT_HOST
            valueFrom:
              fieldRef:
                fieldPath: status.hostIP
          - name: DD_ENV
            valueFrom:
              fieldRef:
                fieldPath: metadata.labels['tags.datadoghq.com/env']
          - name: DD_SERVICE
            valueFrom:
              fieldRef:
                fieldPath: metadata.labels['tags.datadoghq.com/service']
          - name: DD_VERSION
            valueFrom:
              fieldRef:
                fieldPath: metadata.labels['tags.datadoghq.com/version']
```

Vejo o arquivo com todas atualizações atualizações [frontend.yaml](./spree-ecommerce/frontend.yaml)

## LOGS

### Coletando via auto discovery

#### Service _advertisements_

Adicione a seguinte _annotation_ ao nível de template no arquivo _advertisements.yaml_
```yaml
annotations:
    ad.datadoghq.com/advertisements.logs: '[{"source": "python", "service": "advertisements"}]'
```
#### Service _db_

Adicione a seguinte _annotation_ ao nível de template no arquivo _db.yaml_
```yaml
annotations:
    ad.datadoghq.com/postgres.logs: '[{"source": "postgresql", "service": "database"}]'
```
#### Service _discounts_

Adicione a seguinte _annotation_ ao nível de template no arquivo _discounts.yaml_
```yaml
annotations:
    ad.datadoghq.com/discounts.logs: '[{"source": "python", "service": "discounts"}]'
```

#### Service _frontend_

Adicione a seguinte _annotation_ ao nível de template no arquivo _frontend.yaml_
```yaml
annotations:
    ad.datadoghq.com/storefront.logs: '[{"source": "ruby", "service": "store-frontend"}]'
```

**Após as adições dos annotation faça o redeploy dos serviços**

### Curiosidade:
Se você queser pode coleter logs de todos os containers sem o autodiscovery via parâmetro do agente _containerCollectAll_

Habilite esse parâmetro no helm do agente para coletar logs de todos os containers, e nesse caso não há necessidade do anntation para discovery de quais serviços precisam ser coletados

```yaml
datadog.logs.containerCollectAll: true
```
**FIM DO DIA 2**