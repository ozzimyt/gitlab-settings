## GitLab configuration settings
external_url 'https://gitlab.domain.local'


################################################################################
## Container Registry settings
################################################################################

registry_external_url 'https://gitlab.domain.local:5050'


### Settings used by GitLab application
gitlab_rails['registry_enabled'] = true
gitlab_rails['registry_host'] = "gitlab.domain.local"
gitlab_rails['registry_port'] = "5050"


################################################################################
## GitLab NGINX
################################################################################

nginx['ssl_certificate'] = "/etc/gitlab/ssl/gitlab.domain.local.crt"
nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/gitlab.domain.local.key"
