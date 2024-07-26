# Gitlab CE registry settings to Homelab

Автор не несет ответсвенности за прямоту ваших рук, работоспособность клавиатур
и вашу внимательность, делайте все на свой страх и риск, не делайте так в проде,
делайте бэкапы каждых изменяемых файлов и ВМ до(!) внесений изменений.


Настройка локального Gitlab CE с самоподписанными сертификатами и рабочим 
Gitlab Registry, без использования reverse-proxy, без публичного ip и домена,
без Let`s Encrypt сертификатов, проверено на Gitlab CE 17.2.1

Итак, предполагаем, что имеется VM с Gitlab CE via Omnibus.
Необходимо настроить локальный Gitlab Registry, для этого:

!!Не забываем везде менять 'gitlab.domain.local' на валидный.

## Генерация самоподписанных сертификатов 

генерируем и обновляем самоподписанные сертификаты:

```sh
# Переходим в папку с гитлаб сертами, делаем бэкап существующих сертов
cd /etc/gitlab/ssl

# Генерируем новый самоподписанный сертификат
openssl req -newkey rsa:2048 -nodes -keyout gitlab.domain.local.key -x509 -days 365 -out gitlab.domain.local.crt -addext "subjectAltName = DNS:gitlab.domain.local"

# Заполняем сертификат по скрипту

# копируем созданный сертификат в 'ca-certificates'
cp gitlab.domain.local.crt /usr/local/share/ca-certificates/

# обновляем
update-ca-certificates
```

С сертификатами все, при подключении из браузера к гитлабу принимаем риски 
и добавляем в исключения.

## Конфигурируем Gitlab

Настраиваем gitlab.rb

```sh
cd /etc/gitlab

nano/vim gitlab.rb
```

Меняем указанные ниже параметры:

```sh
external_url 'https://gitlab.domain.local'

registry_external_url 'https://gitlab.domain.local:5050'

gitlab_rails['registry_enabled'] = true
gitlab_rails['registry_host'] = "gitlab.domain.local"
gitlab_rails['registry_port'] = "5050"

nginx['ssl_certificate'] = "/etc/gitlab/ssl/gitlab.domain.local.crt"
nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/gitlab.domain.local.key"
```

Теперь переконфигурируем Gitlab

```sh
gitlab-ctl reconfigure
```

Ждем окончания переконфигурации и переходим на сайт вашего гитлаба, все
страницы должны быть доступны

## Настраиваем локальный Docker

В данном случае Docker Desktop на Windows, работающий через WSL2, 
с включенной интеграцией с Ubuntu 22.04

```sh
cd %username%\.docker
```

открываем docker.json и добавляем параметр 'insecure-registries'

```json
{
  "insecure-registries": [
    "gitlab.domain.local:5050"
  ]
}
```

Логинимся к нашему Gitlab Registry(можно с паролем или токеном)

```sh
docker login gitlab.domain.local:5050
Username: Username
Password: 
# Если видим эту строку, то сконфигурировано успешно
Login Succeeded
```

Проверяем, что образы пушатся корректно:

```sh
docker build -t gitlab.domain.local:5050/username/test .

docker push gitlab.domain.local:5050/username/test

# если видим похожие строки, то вы все сделали верно
Using default tag: latest
The push refers to repository [gitlab.domain.local:5050/username/test]
images_hash: Pushed
images_hash: Pushed
images_hash: Pushed
images_hash: Pushed
images_hash: Pushed
latest: digest: sha256:'' siz
```


На этом настройка и проверка локального Gitlab Registry с самоподписанными 
сертификатами завершена.