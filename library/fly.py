#!/usr/bin/python

# import module snippets
from ansible.module_utils.basic import *
from ansible.module_utils.facts import *

from ansible.module_utils._text import to_bytes, to_native

class Fly(object):
  def __init__(self, module):
    self.module              = module
    self.url                 = module.params['url']
    self.token               = module.params['token']
    self.username            = module.params['username']
    self.password            = module.params['password']
    self.teams               = module.params['teams']
    self.manage_exclusively  = module.params['manage_exclusively']
    self.fly_path            = module.params['fly_path']
    self.auto_sync           = module.params['auto_sync']

    self.target_name = "ansible_concourse"
    #print get_platform()
    self.changed             = False
    # if self.username and self.password == "":
    #       self.module.fail_json(msg='Password is required')

  def _run_command(self, command, fail_if=True):
    rc, out, err = self.module.run_command(command)
    if rc != 0 and fail_if:
      self.module.fail_json(msg="Command '%s' failed rc=%d, out=%s, err=%s" % (command, rc, out, err))
    return rc, out, err

  def authenticate(self):
    command = self._construct_login_command()
    self._login(command)
    self.check_api()

  def _login(self, command):
    rc, out, err = self._run_command(command, fail_if=False)
    if rc != 0:
      self.module.fail_json(msg="Failed to login: '{}'".format(err))

  def _construct_login_command(self):
    if self.username:
      login_option = "--username={} --password={}".format(self.username, self.password)
    else:
      self.module.fail_json(msg="Token not supported for now")
    return "{} login --target={} --concourse-url={} --team-name=main {}".format(self.fly_path, self.target_name, self.url, login_option)

  def check_api(self):
    # Just to make sure we get response from API
    command = "{} --target={} workers".format(self.fly_path, self.target_name)
    rc, out, err = self._run_command(command)
    if rc != 0:
      self.module.fail_json(msg="Failed to login")

  def _sync(self):
      command = "{} --target={} sync".format(self.fly_path, self.target_name)

  def _construct_set_team_command(self, teams):
    for team in teams:
      if not isinstance(team,dict):
        self.module.fail_json(msg="Team should be a dictionary not '%s'" % type(team))

      if not team.get("name", False):
        self.module.fail_json(msg="Team should have name")
      #TODO: Should check duplicate
      if

  def manage_teams(self):
    if self.manage_exclusively:
      self.module.fail_json(msg="Error managing teams exclusively is not support at the moment.")
    else:
      self._construct_set_team_command(self.teams)
      self.module.exit_json(changed=False, msg=self.teams)


  def take_off(self):
    self.authenticate()
    # if self.auto_sync:
    #   self._sync()
    if self.teams:
      self.manage_teams()
    self.module.exit_json(changed=False, msg="")

def main():
  module = AnsibleModule(
    argument_spec = dict(
      url=dict(required=True),
      token=dict(type='str'),
      username=dict(type='str'),
      password=dict(type='str'),
      teams=dict(type='list'),
      manage_exclusively=dict(default=False, type='bool'),
      fly_path=dict(default="/opt/concourseci/bin/fly", type='str'),
      auto_sync=dict(default=True, type='bool')
    ),
    required_together = [['username', 'password']],
    required_one_of   = [['username', 'token']]
  )
  fly = Fly(module)
  fly.take_off()
  # changed = hostname.update_current_and_permanent_hostname()

if __name__ == '__main__':
    main()