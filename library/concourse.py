#!/usr/bin/python

# import module snippets
from ansible.module_utils.basic import *
from ansible.module_utils.facts import *
from ansible.module_utils.urls import *
import urllib2
import base64
import json

from ansible.module_utils._text import to_bytes, to_native


class Fly(object):

  def __init__(self, module):
    self.module = module
    self.url = module.params['url']
    self.token = module.params['token']
    self.username = module.params['username']
    self.password = module.params['password']
    self.teams = module.params['teams']
    self.manage_exclusively = module.params['manage_exclusively']
    self.changed = False
    self.authorization_header = None
    self.base_api_path = "/api/v1"
    self.concourse_teams = {}
    self.teams_to_update = []
    self.teams_to_remove = []

  def _api_call(self, action_url, action_name, return_json=False, headers=None, method="GET", payload=None, use_authorization=False):
    ''' Responsible to do RAW api call to ATC '''

    if use_authorization:
        if headers is None:
          headers = {}
        headers.update(self.authorization_header)

    try:
        # TODO: concat string safer
        api_url = self.url + self.base_api_path + action_url
        r = open_url(api_url, method=method, headers=headers, data=payload)
    except urllib2.HTTPError, err:
        response_code = err.getcode()
        response_msg = err.read()
        self.module.fail_json(msg="Failed to {}. HTTP Code '{}' body '{}'".format(
            action_name, response_code, response_msg), url=api_url)

    if return_json:
      try:
        response = json.loads(r.read())
      except Exception as e:
        self.module.fail_json(msg="Failed to serialize response of action '{}'. Error '{}'".format(
            action_name, e), raw_output=r.read(), url=api_url)
    else:
      response = r.read()

    return response

  def _authenticate(self):
    ''' Use basic authenticate to get a token that will be used for API calls '''

    base64string = base64.b64encode('%s:%s' % (self.username, self.password))
    headers = {'Authorization': "Basic %s" % base64string}
    token_response = self._api_call(
        "/teams/main/auth/token", "authenticate", headers=headers, return_json=True)
    if not token_response.get("type", False) or not token_response.get("value", False):
        self.module.fail_json(
            msg="Failed to authenticate the response from server is invalid or misformed '{}'".format(raw_response))
    # Set Authorization header
    self.authorization_header = {
        'Authorization': "Bearer {}".format(token_response.get("value"))}

  def _get_team_auth_method(self, team):
    ''' Get Authentication methods associated with a team (currently not used) '''

    team_response = self._api_call("/teams/{}/auth/methods".format(
        team), "get team info '{}'".format(team), return_json=True, use_authorization=True)
    return team_response

  def _set_team(self, team, auth):
    ''' Create/Update team and authentication method for that team '''

    headers = {'Content-Type': 'application/json'}
    team_response = self._api_call("/teams/{}".format(team), "set team {}".format(team), return_json=True,
                                   headers=headers, method="PUT", payload=json.dumps(auth), use_authorization=True)

  def _delete_team(self, team):
    ''' Delete a team '''

    self._api_call("/teams/{}".format(team), "delete team {}".format(team),
                   method="DELETE", use_authorization=True)

  def _get_teams(self):
    ''' Get a list of teams '''

    team_response = self._api_call(
        "/teams", "get teams", return_json=True, use_authorization=True)
    for team in team_response:
        team_name = team.get('name')
        temp_dic = {}
        temp_dic[team_name] = self._get_team_auth_method(team_name)
        self.concourse_teams.update(temp_dic)
    # We always need to ignore team main
    self.concourse_teams.pop('main', None)

  def _compile_list(self, teams_in_concourse, desired_teams, manage_true=False):
      ''' Create a list of teams that need updating and removing '''

      desired_to_be_present = [ t.get("name") for t in desired_teams if t.get("state", "present").lower() == "present"]
      desired_to_be_absent  = [ t.get("name") for t in desired_teams if t.get("state"," present").lower() == "absent"]
      desired_to_be_latest  = [ t.get("name") for t in desired_teams if t.get("state", "present").lower() == "latest"]

      self.teams_to_update = list( set(desired_to_be_present) - set(teams_in_concourse) ) + desired_to_be_latest
      if manage_true:
          self.teams_to_remove = list( set(teams_in_concourse) - set( teams_to_update  + desired_to_be_present) )
      else:
          self.teams_to_remove = list( set(desired_to_be_absent).intersection(set(teams_in_concourse)) )

  def manage_teams(self):
    ''' Main function that manages teams  '''

    if len([ t.get("name") for t in self.teams if t.get("name").lower() == "main"]) == 1:
      self.module.fail_json(msg="You can't manage team 'main' with this module.")
    # Get teams in concourse
    self._get_teams()
    self._compile_list(self.concourse_teams, self.teams, self.manage_exclusively)

    if len(self.teams_to_update) > 0:
        self.changed = True
        for team_to_update in self.teams_to_update:
          team_auth = [ t.get("auth",{}) for t in self.teams if t.get("name") == team_to_update]
          self._set_team(team_to_update, team_auth[0])

    if len(self.teams_to_remove) > 0:
        self.changed = True
        for team_to_delete in self.teams_to_remove:
          self._delete_team(team_to_delete)

  def _ping(self):
    ''' Ping concourse to see if it's alive '''

    self._api_call("/info", "ping")

  def take_off(self):
    ''' Main function '''

    self._ping()
    self._authenticate()
    if self.teams:
        self.manage_teams()
    self.module.exit_json(changed=self.changed, msg="", removed=self.teams_to_remove, updated=self.teams_to_update)


def main():
  module = AnsibleModule(
    argument_spec = dict(
      url=dict(required=True),
      token=dict(type='str'),
      username=dict(type='str'),
      password=dict(type='str'),
      teams=dict(type='list'),
      manage_exclusively=dict(default=False, type='bool'),
    ),
    required_together = [['username', 'password']],
    required_one_of   = [['username', 'token']]
  )
  fly = Fly(module)
  fly.take_off()
  # changed = hostname.update_current_and_permanent_hostname()

if __name__ == '__main__':
    main()
