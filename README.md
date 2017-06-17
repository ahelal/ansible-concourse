# ansible-concourse [![Build Status](https://travis-ci.org/ahelal/ansible-concourse.svg?branch=master)](https://travis-ci.org/ahelal/ansible-concourse)
An easy way to deploy and manage a [Concourse CI](http://concourse.ci/) with a cluster of workers vie ansible

## Requirements
* Platforms
  * Ubuntu 14.04/16.04
  * MacOS (Early support. Accepting PRs)
  * Windows (not supported yet. Accepting PRs)

* Ansible 2.0 or higher
* PostgreSQL I recommend [ansible postgresql role](https://github.com/ANXS/postgresql)
* Optional TLS termination
  * Use concourse web argument to configure TLS (recommended)
  * [ansible nginx role](https://github.com/AutomationWithAnsible/ansible-nginx)

## Overview
I am a big fan of concourse CI, not so much bosh. This role will install concourse CI binaries.

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

## Examples
### Single node

```yaml
---
- name: Create Single node host
  hosts: ci.example.com
  become: True
  vars:
    CONCOURSE_WEB_EXTERNAL_URL        : "http://{{ inventory_hostname }}:8080"
    CONCOURSE_WEB_BASIC_AUTH_USERNAME : "myuser"
    CONCOURSE_WEB_BASIC_AUTH_PASSWORD : "mypass"
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
  vars:
    CONCOURSE_WEB_EXTERNAL_URL        : "http://{{ inventory_hostname }}:8080"
    CONCOURSE_WEB_BASIC_AUTH_USERNAME : "myuser"
    CONCOURSE_WEB_BASIC_AUTH_PASSWORD : "mypass"
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

## Config
All command line options are now supported since version 1.0.0 in *Web* and *worker*

If your upgrading you have to change some variables. You can simply look at the template for [template/concourse-web](https://github.com/ahelal/ansible-concourse/blob/master/templates/concourse-web.j2) and [template/concourse-worker](https://github.com/ahelal/ansible-concourse/blob/master/templates/concourse-worker.j2) for all options.

The options are one to one match to the binary variables in concourse with the exceptions of **WEB** and **WORKER**.

i.e. **CONCOURSE_BAGGAGECLAIM_BIND_IP** becomes **CONCOURSE_WORKER_BAGGAGECLAIM_BIND_IP**

## Concourse versions
This role supports installation of release candidate and final releases.

Simply Overriding **concourseci_version** with https://github.com/concourse/bin/releases/
i.e. ```concourseci_version : "vx.x.x-rc.xx"```
that will install release candidate.

For final release use https://github.com/concourse/concourse/releases
i.e. ```concourseci_version : "vx.x.x"```

By default this role will try to have the latest stable release look at [defaults/main.yml](https://github.com/ahelal/ansible-concourse/blob/master/defaults/main.yml#L2-L3)

## Keys

**Warning** the role comes with default keys. This keys are used for demo only you should generate your own and store them **safely** i.e. ansible-vault

You would need to generate 2 keys for web and one key for each worker node.
An easy way to generate your keys to use a script in ```keys/key.sh```

The bash script will ask you for the number of workers you require. It will then generate ansible compatible yaml files in ```keys/vars```
You can than copy the content in your group vars or any other method you prefer.

## Default variables

Check [defaults/main.yml](/defaults/main.yml) for all bells and whistles.

## Managing teams
This role supports Managing teams. here is an example:
```
    concourseci_manage_teams          : True
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


## Note breaking changes as of version 1.0.0
version 1.0.0 now support all options for web and worker, but you need to adapt to the new config.
Please look at [config section](https://github.com/ahelal/ansible-concourse#config).

## TODO
* Support pipeline upload
* Full MacOS support
* Add distributed cluster tests
* Windows support

## License
MIT
