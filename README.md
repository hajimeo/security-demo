# security-demo
LDAP, Kerberos, SAML, haproxy, nginx, apache2

```
mkdir -m 777 -p /var/tmp/share/security-demo
curl -O https://raw.githubusercontent.com/hajimeo/security-demo/master/resources/Dockerfile
# Modify the "ENV ..." to use Nexus's apt-proxy and pypi-proxy repositories
docker build -t security-demo .
docker run -tid -p 80:80 -p 443:443 -p 389:389 -p 636:636 -p 8444:8444 \
  --name=nexus-security security-demo /sbin/init
```