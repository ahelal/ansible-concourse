# ansible-concourse [![Build Status](https://travis-ci.org/ahelal/ansible-concourse.svg?branch=master)](https://travis-ci.org/ahelal/ansible-concourse)
An easy way to deploy and manage a [Concourse CI](http://concourse.ci/) with a cluster of workers vie ansible

## Note breaking changes as of version v3.0.0
As of version 3.0.0 of this role all options for web and worker are supported, but you need to adapt to the new config style.
Please look at [config section](https://github.com/ahelal/ansible-concourse#config).

## Requirements
* Ansible 2.0 or higher
* PostgreSQL I recommend [ansible postgresql role](https://github.com/ANXS/postgresql)

Supported platforms
* Ubuntu 14.04/16.04
* MacOS (Early support. Accepting PRs)
* Windows (not supported yet. Accepting PRs)
  
Optional TLS termination
* Use concourse web argument to configure TLS (recommended)
* [ansible nginx role](https://github.com/AutomationWithAnsible/ansible-nginx)

## Overview
I am a big fan of concourse CI, not so much bosh. This role will install concourse CI binaries.

## Examples
### Single node

```yaml
---
- name: Create Single node host
  hosts: ci.example.com
  become: True
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
```yaml
---
- name: Create web nodes
  hosts: concourse-web
  become: True
  roles:
    - { name: "ansible-concourse", tags: "concourse"  }
```

```yaml
---
- name: Create worker nodes
  hosts: concourse-worker
  become: True
  roles:
    - { name: "ansible-concourse", tags: "concourse"  }
```

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

i.e.
```yaml
concourse_web_options                        :
  CONCOURSE_BIND_IP                          : "0.0.0.0"
  CONCOURSE_TSA_HOST                         : "{{ groups[concourseci_web_group][0] }}" # By default we pick the first host in web group if you have multipule web you might need to use index of the group
  CONCOURSE_TSA_BIND_IP                      : "0.0.0.0"
  CONCOURSE_TSA_BIND_PORT                    : "2222"
  CONCOURSE_TSA_AUTHORIZED_KEYS              : "{{ concourseci_ssh_dir }}/tsa_authorization"
  CONCOURSE_TSA_HOST_KEY                     : "{{ concourseci_ssh_dir }}/tsa"
  CONCOURSE_SESSION_SIGNING_KEY              : "{{ concourseci_ssh_dir }}/session_signing"
  CONCOURSE_BASIC_AUTH_USERNAME              : "myuser"
  CONCOURSE_BASIC_AUTH_PASSWORD              : "{{ SUPER_USER_ENCRYPTED_PASS_IN_VAULT }}"
  CONCOURSE_POSTGRES_DATA_SOURCE             : "postgres://concourseci:{{ SUPER_DB_ENCRYPTED_PASS_IN_VAULT }}@127.0.0.1/concourse?sslmode=disable"

concourse_worker_options                     :
  CONCOURSE_WORK_DIR                         : "{{ concourseci_worker_dir }}"
  CONCOURSE_NAME                             : "{{ inventory_hostname }}"
  CONCOURSE_TSA_HOST                         : "{{ concourse_web_options['CONCOURSE_TSA_HOST'] }}"
  CONCOURSE_TSA_PORT                         : "{{ concourse_web_options['CONCOURSE_TSA_BIND_PORT'] }}"
  CONCOURSE_TSA_WORKER_PRIVATE_KEY           : "{{ concourseci_ssh_dir }}/worker"
  CONCOURSE_TSA_PUBLIC_KEY                   : "{{ concourse_web_options['CONCOURSE_TSA_HOST_KEY'] }}.pub"                  :
```

To view all enviornmental options please check
[web options](web_arguments.txt) and [worker options](worker_arguments.txt).


## Concourse versions
This role supports installation of release candidate and final releases.

Simply Overriding **concourseci_version** with https://github.com/concourse/bin/releases/
i.e. ```concourseci_version : "vx.x.x-rc.xx"```
that will install release candidate.

For final release use https://github.com/concourse/concourse/releases
i.e. ```concourseci_version : "vx.x.x"```

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
* Scaling in: You would need to drain the worker first by running `/opt/concourseci/bin/concourse-worker-retire`

## vagrant demo
You can use vagrant to spin a test machine.

```
vagrant up
```

The vagrant machine will have an IP of **192.168.50.150**

You can access the web and API on port 8080 with username **myuser** and **mypass**

Once your done

```
vagrant destroy
```


## TODO
* Support pipeline upload
* Full MacOS support
* Add distributed cluster tests
* Windows support

## License
MIT
