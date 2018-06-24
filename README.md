# ansible-concourse

[![Build Status](https://travis-ci.org/ahelal/ansible-concourse.svg?branch=master)](https://travis-ci.org/ahelal/ansible-concourse)

An easy way to deploy and manage a [Concourse CI](https://concourse-ci.org/) with a cluster of workers using ansible

## Note breaking changes as of version v3.0.0

As of version 3.0.0 of this role all options for web and worker are supported, but you need to adapt to the new config style.
Please look at [configuration section](https://github.com/ahelal/ansible-concourse#configuration).

## Requirements

* Ansible 2.3 or higher
* PostgreSQL I recommend [ansible postgresql role](https://github.com/ANXS/postgresql)

Supported platforms:

* Ubuntu 14.04/16.04
* MacOS (Early support. Accepting PRs)
* Windows (not supported yet. Accepting PRs)

Optional TLS termination

* Use concourse web argument to configure TLS (recommended)
* [ansible nginx role](https://github.com/AutomationWithAnsible/ansible-nginx)

## Overview

I am a big fan of concourse. This role will install and manage concourse.

## Examples

### Single node

```yaml
---
- name: Create Single node host
  hosts: ci.example.com
  become: True
  vars:
    concourse_web_options:
      CONCOURSE_BASIC_AUTH_USERNAME              : "myuser"
      # Set your own password and save it securely in vault
      CONCOURSE_BASIC_AUTH_PASSWORD              : "CHANGEME_DONT_USE_DEFAULT_PASSWORD"
      # Set your own password and save it securely in vault
      CONCOURSE_POSTGRES_DATABASE                : "concourse"
      CONCOURSE_POSTGRES_HOST                    : "127.0.0.1"
      CONCOURSE_POSTGRES_PASSWORD                : "conpass"
      CONCOURSE_POSTGRES_SSLMODE                 : "disable"
      CONCOURSE_POSTGRES_USER                    : "concourseci"
    # ********************* Example Keys (YOU MUST OVERRIDE THEM) *********************
    # This keys are demo keys. generate your own and store them safely i.e. ansible-vault
    # Check the key section on how to auto generate keys.
    # **********************************************************************************
    concourseci_key_session_public             : ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6tKH.....
    concourseci_key_session_private            : |
                                                  -----BEGIN RSA PRIVATE KEY-----
                                                  MIIEowIBAAKCAQEAurSh5kbUadGuUgHqm1ct6SUrqFkH5kyJNdOjHdWxoxCzw5I9
                                                  ................................
                                                  N1EQdIhtxo4mgHXjF/8L32SqinAJb5ErNXQQwT5k9G22mZkHZY7Y
                                                  -----END RSA PRIVATE KEY-----

    concourseci_key_tsa_public                  : ssh-rsa AAAAB3NzaC1yc2EAAAADAQ......
    concourseci_key_tsa_private                 : |
                                                  -----BEGIN RSA PRIVATE KEY-----
                                                  MIIEogIBAAKCAQEAo3XY74qhdwY1Z8a5XnTbCjNMJu28CcEYJ1KJi1a8B143wKxM
                                                  .........
                                                  uPTcE+vQzvMV3lJo0CHTlNMo1JgHOO5UsFZ1cBxO7MZXCzChGE8=
                                                  -----END RSA PRIVATE KEY-----
    concourseci_worker_keys                     :
                                  - public      : ssh-rsa AAAAB3N.....
                                    private     : |
                                                    -----BEGIN RSA PRIVATE KEY-----
                                                    MIIEpQIBAAKCAQEAylt9UCFnAkdhofItX6HQzx6r4kFeXgFu2b9+x87NUiiEr2Hi
                                                   .......
                                                    ZNJ69MjK2HDIBIpqFJ7jnp32Dp8wviHXQ5e1PJQxoaXNyubfOs1Cpa0=
                                                    -----END RSA PRIVATE KEY-----
  roles:
    - { name: "postgresql",        tags: "postgresql" }
    - { name: "ansible-concourse", tags: "concourse"  }
```

```ìni
[concourse-web]
ci.example.com
[concourse-worker]
ci.example.com
```

## Clustered nodes 2x web & 4x worker

In order to make a cluster of servers you can easily add the host to groups

```ini
[concourse-web]
ci-web01.example.com
ci-web02.example.com
[concourse-worker]
ci-worker01.example.com
ci-worker02.example.com
ci-worker03.example.com
ci-worker04.example.com
```

You would also need to generate keys for workers check [key section](https://github.com/ahelal/ansible-concourse#keys)

## Configuration

All command line options are now supported as of ansible-concourse version 3.0.0 in *Web* and *worker* as a dictionary.
**Note:** *if you are upgrade from a version prior to 3.0.0 you would need to accommodate for changes*

The configuration is split between two dictionaries *concourse_web_options* and *concourse_worker_options* all key values defined will be exported as an environmental variable to concourse process.

```yaml
concourse_web_options                        :
  CONCOURSE_BASIC_AUTH_USERNAME              : "apiuser"
  CONCOURSE_BASIC_AUTH_PASSWORD              : "CHANGEME_DONT_USE_DEFAULT_PASSWORD_AND_USEVAULT"
  CONCOURSE_POSTGRES_DATABASE                : "concourse"
  CONCOURSE_POSTGRES_HOST                    : "127.0.0.1"
  CONCOURSE_POSTGRES_PASSWORD                : "NO_PLAIN_TEXT_USE_VAUÖT"
  CONCOURSE_POSTGRES_SSLMODE                 : "disable"
  CONCOURSE_POSTGRES_USER                    : "concourseci"

concourse_worker_options                     :
  CONCOURSE_GARDEN_NETWORK_POOL              : "10.254.0.0/22"
  CONCOURSE_GARDEN_MAX_CONTAINERS            : 150
```

To view all environmental options please check
[web options](web_arguments.txt) and [worker options](worker_arguments.txt).

ansible-concourse has some sane defaults defined `concourse_web_options_default` and `concourse_worker_options_default` in [default.yml](default.yml) those default will merge with `concourse_web_option` and `concourse_worker_option`. `concourse_web_option` and `concourse_worker_option`has higher precedence.


## Concourse versions

This role supports installation of release candidate and final releases. Simply overriding **concourseci_version** with desired version.

* Fpr [rc](https://github.com/concourse/bin/releases/). `concourseci_version : "vx.x.x-rc.xx"` that will install release candidate.
* For [final release](https://github.com/concourse/concourse/releases). ```concourseci_version : "vx.x.x"```

By default this role will try to have the latest stable release look at [defaults/main.yml](https://github.com/ahelal/ansible-concourse/blob/master/defaults/main.yml#L2-L3)

## Default variables

Check [defaults/main.yml](/defaults/main.yml) for all bells and whistles.

## Keys

**Warning** the role comes with default keys. This keys are used for demo only you should generate your own and store them **safely** i.e. ansible-vault

You would need to generate 2 keys for web and one key for each worker node.
An easy way to generate your keys to use a script in ```keys/key.sh``` or you can reuse the same keys for all workers.

The bash script will ask you for the number of workers you require. It will then generate ansible compatible yaml files in ```keys/vars```
You can than copy the content in your group vars or any other method you prefer.

## Managing teams

This role supports Managing teams :

*NOTE* if you use manage _DO NOT USE DEFAULT PASSWORD_ your should set your own password and save it securely in vault. or you can look it up from web options

```yaml
concourseci_manage_credential_user          : "{{ concourse_web_options['CONCOURSE_BASIC_AUTH_USERNAME'] }}"
concourseci_manage_credential_password      : "{{ concourse_web_options['CONCOURSE_BASIC_AUTH_PASSWORD'] }}"
```

```yaml
    concourseci_manage_teams                : True
    concourseci_manage_credential_user      : "USER_TO_USE"
    concourseci_manage_credential_password  : "{{ ENCRYPTED_VARIABLE }}"

    concourseci_teams                 :
          - name: "team_1"
            state: "present"
            flags:
              basic-auth-username: user1
              basic-auth-password: pass1
          - name: "team_2"
            state: "absent"
          - name: "team_3"
            state: "present"
            flags:
              github-auth-client-id=XXX
              github-auth-client-secret=XXX
              github-auth-organization=ORG
              github-auth-team=ORG/TEAM
              github-auth-user=LOGIN
              github-auth-auth-url=SOMETHING
              github-auth-token-url=XX
              github-auth-api-url=XX
          - name: "team_4"
            state: "present"
            flags:
                no-really-i-dont-want-any-auth: ""
          - name: "x5"
            state: "absent"
            flags:
                basic-auth-username: user5
                basic-auth-password: pass5
```

The role supports all arguments passed to fly for more info  `fly set-team --help`.
*Please note if you delete a team you remove all the pipelines in that team*

## Auto scaling

* Scaling out: Is simple just add a new instance :)
* Scaling in: You would need to drain the worker first by running `service concourse-worker stop`

## Vagrant demo

You can use vagrant to spin a test machine. 

```bash
# Install postgresql role in test/helper_roles
./test/setup_roles.sh
vagrant up
```

The vagrant machine will have an IP of **192.168.50.150** you can access the web `http://192.168.50.150:8080`

You can access the web and API on port 8080 with username **myuser** and **mypass**

Once your done

```
vagrant destroy
```

## Contribution

Pull requests on GitHub are welcome on any issue.

Thanks for all the [contrubtors](https://github.com/ahelal/ansible-concourse/graphs/contributors)


## TODO

* Support pipeline upload
* Full MacOS support
* Add distributed cluster tests
* Windows support

## License

MIT
