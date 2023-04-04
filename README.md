# Docker Test SAML 2.0 Identity Provider (IdP)

[![](https://img.shields.io/docker/v/kenchan0130/simplesamlphp?sort=semver)](https://hub.docker.com/r/kenchan0130/simplesamlphp)
[![](https://github.com/kenchan0130/docker-simplesamlphp/workflows/CI/badge.svg)](https://github.com/kenchan0130/docker-simplesamlphp/actions?query=workflow%3ACI)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/kenchan0130/docker-simplesamlphp/blob/master/LICENSE)

Docker container with a plug and play SAML 2.0 Identity Provider (IdP) for development and testing.

Built with [SimpleSAMLphp](https://simplesamlphp.org/). Based on [official PHP8 Apache image](https://hub.docker.com/_/php/).

SimpleSAMLphp is logging to stdout on debug log level. Apache is logging error and access log to stdout.

**You must not use at your production. This is for test.**

## Usage

### Using docker run command

```sh
docker run --name=idp \
  -p 8080:8080 \
  -e SIMPLESAMLPHP_SP_ENTITY_ID=http://app.example.com \
  -e SIMPLESAMLPHP_SP_ASSERTION_CONSUMER_SERVICE=http://localhost/simplesaml/module.php/saml/sp/saml2-acs.php/test-sp \
  -e SIMPLESAMLPHP_SP_SINGLE_LOGOUT_SERVICE=http://localhost/simplesaml/module.php/saml/sp/saml2-logout.php/test-sp \
  -d kenchan0130/simplesamlphp
```

### Using docker-compose

```yml
version: "3"
services:
  idp:
    image: kenchan0130/simplesamlphp
    container_name: idp
    ports:
      - "8080:8080"
    environment:
      SIMPLESAMLPHP_SP_ENTITY_ID: http://app.example.com
      SIMPLESAMLPHP_SP_ASSERTION_CONSUMER_SERVICE: http://localhost/simplesaml/module.php/saml/sp/saml2-acs.php/test-sp
      SIMPLESAMLPHP_SP_SINGLE_LOGOUT_SERVICE: http://localhost/simplesaml/module.php/saml/sp/saml2-logout.php/test-sp
```

There are two static users configured in the IdP with the following data:

Username|Password
---|---
user1|password
user2|password

And there is one admin:

Username|Password
---|---
admin|secret

## Environment Variables

Name|Required/Optional|Description
---|---|---
`SIMPLESAMLPHP_SP_ENTITY_ID`|Required|The entity ID of your SP.
`SIMPLESAMLPHP_SP_ASSERTION_CONSUMER_SERVICE`|Requried|The assertion consumer service of your SP.
`SIMPLESAMLPHP_SP_SINGLE_LOGOUT_SERVICE`|Optional|The single logout url of your SP.
`SIMPLESAMLPHP_IDP_ADMIN_PASSWORD`|Optional|The password of admin of this IdP. Default is `secret`.
`SIMPLESAMLPHP_IDP_SECRET_SALT`|Optional|This is a secret salt used by this IdP when it needs to generate a secure hash of a value. Default is `defaultsecretsalt`.
`SIMPLESAMLPHP_IDP_SESSION_DURATION_SECONDS`|Optional|This value is the duration of the session of this IdP in seconds.
`SIMPLESAMLPHP_IDP_BASE_URL`|Optional|This value allows you to override the base URL. Valuable for setting an `https://` base url behind a reverse proxy. **If you set this variable, please end it with a trailing `/`** example: `https://my.proxy.com/` Default is `` (empty string).

## Advanced Usage

### Customize IdP Users

If you want to customize IdP users, you can define your own users by mounting a configuration file.

```php
<?php
// These attributes mimic those of Azure AD.
$test_user_base = array(
    'http://schemas.microsoft.com/identity/claims/tenantid' => 'ab4f07dc-b661-48a3-a173-d0103d6981b2',
    'http://schemas.microsoft.com/identity/claims/objectidentifier' => '',
    'http://schemas.microsoft.com/identity/claims/displayname' => '',
    'http://schemas.microsoft.com/ws/2008/06/identity/claims/groups' => array(),
    'http://schemas.microsoft.com/identity/claims/identityprovider' => 'https://sts.windows.net/da2a1472-abd3-47c9-95a4-4a0068312122/',
    'http://schemas.microsoft.com/claims/authnmethodsreferences' => array('http://schemas.microsoft.com/ws/2008/06/identity/authenticationmethod/password', 'http://schemas.microsoft.com/claims/multipleauthn'),
    'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress' => '',
    'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname' => '',
    'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname' => '',
    'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name' => ''
);

$config = array(
    'admin' => array(
        'core:AdminPassword',
    ),
    'example-userpass' => array(
        'exampleauth:UserPass',
        'user1:password' => array_merge($test_user_base, array(
            'http://schemas.microsoft.com/identity/claims/objectidentifier' => 'f2d75402-e1ae-40fe-8cc9-98ca1ab9cd5e',
            'http://schemas.microsoft.com/identity/claims/displayname' => 'User1 Taro',
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress' => 'user1@example.com',
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname' => 'Taro',
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname' => 'User1',
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name' => 'user1@example.com'
        )),
        'user2:password' => array_merge($test_user_base, array(
            'http://schemas.microsoft.com/identity/claims/objectidentifier' => 'f2a94916-2fcb-4b68-9eb1-5436309006a3',
            'http://schemas.microsoft.com/identity/claims/displayname' => 'User2 Taro',
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress' => 'user2@example.com',
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname' => 'Taro',
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname' => 'User2',
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name' => 'user2@example.com'
        )),
    ),
);
```

If you save this source as `authsources.php`, you can customize IdP users by volume mount like:

**docker run command**

```sh
docker run --name=idp \
  -p 8080:8080 \
  -e SIMPLESAMLPHP_SP_ENTITY_ID=http://app.example.com \
  -e SIMPLESAMLPHP_SP_ASSERTION_CONSUMER_SERVICE=http://localhost/simplesaml/module.php/saml/sp/saml2-acs.php/test-sp \
  -e SIMPLESAMLPHP_SP_SINGLE_LOGOUT_SERVICE=http://localhost/simplesaml/module.php/saml/sp/saml2-logout.php/test-sp \
  -v $PWD/authsources.php:/var/www/simplesamlphp/config/authsources.php \
  -d kenchan0130/simplesamlphp
```

**docker-compose**

```yml
version: "3"
services:
  idp:
    image: kenchan0130/simplesamlphp
    container_name: idp
    ports:
      - "8080:8080"
    environment:
      SIMPLESAMLPHP_SP_ENTITY_ID: http://app.example.com
      SIMPLESAMLPHP_SP_ASSERTION_CONSUMER_SERVICE: http://localhost/simplesaml/module.php/saml/sp/saml2-acs.php/test-sp
      SIMPLESAMLPHP_SP_SINGLE_LOGOUT_SERVICE: http://localhost/simplesaml/module.php/saml/sp/saml2-logout.php/test-sp
    volumes:
      - authsources.php:/var/www/simplesamlphp/config/authsources.php
```

For detailed attributes, see [SimpleSAMLphp Identity Provider QuickStart#Authentication module](https://simplesamlphp.org/docs/stable/simplesamlphp-idp#section_2).

### Customize SP remote metadata reference

If you want to customize SP remote metadata reference, you can define your own users by mounting a configuration file.

```php
<?php
/* The index of the array is the entity ID of this SP. */
$metadata['entity-id-1'] = array(
    'AssertionConsumerService' => 'http://localhost/simplesaml/module.php/saml/sp/saml2-acs.php/test-sp',
    ForceAuthn => true
);
$metadata['entity-id-2'] = array(
    'AssertionConsumerService' => 'http://localhost/saml/acs',
    'SingleLogoutService' => 'http://localhost/saml/logout'
);
```

If you save this source as `saml20-sp-remote.php`, you can customize IdP users by volume mount like:

**docker run command**

```sh
docker run --name=idp \
  -p 8080:8080 \
  -v saml20-sp-remote.php:/var/www/simplesamlphp/metadata/saml20-sp-remote.php \
  -d kenchan0130/simplesamlphp
```

**docker-compose**

```yml
version: "3"
services:
  idp:
    image: kenchan0130/simplesamlphp
    container_name: idp
    ports:
      - "8080:8080"
    volumes:
      - saml20-sp-remote.php:/var/www/simplesamlphp/metadata/saml20-sp-remote.php
```

For detailed attributes, see [SP remote metadata reference#SAML 2.0 options](https://simplesamlphp.org/docs/stable/simplesamlphp-reference-sp-remote#section_2).

## Inspired By

- https://github.com/kristophjunge/docker-test-saml-idp

## License

MIT
