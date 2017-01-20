from __future__ import (absolute_import, division)
__metaclass__ = type

from ansible.compat.tests import unittest
from ansible.compat.tests.mock import call, create_autospec, patch
from ansible.module_utils.basic import AnsibleModule

from concourse import Concourse


class TestFirstMod(unittest.TestCase):

   def __init__(self, *args, **kwargs):
        super(TestFirstMod, self).__init__(*args, **kwargs)
        self.desired_state = [{'auth': {'basic_auth': {'basic_auth_password': 'pass2',
                                                  'basic_auth_username': 'user2'}},
                          'name': 'Added1',
                          'state': 'present'},
                         {'name': 'Remove2', 'state': 'absent'},
                         {'name': 'Removed3', 'state': 'absent'},
                         {'auth': {'basic_auth': {'basic_auth_password': 'pass2',
                                                  'basic_auth_username': 'user2'},
                                   'github_auth': {'client_id': '21cxre7d1f12666nv721',
                                                   'client_secret': '10b246hxf612f0c5d42ba97dbb5f33r115112g2x',
                                                   'organizations': ['AutomationWithAnsible'],
                                                   'users': ['ahelal']}},
                          'name': 'Added4'},
                         {'auth': {'basic_auth': {'basic_auth_password': 'pass2',
                                                  'basic_auth_username': 'user2'},
                                   'github_auth': {'client_id': '21cxre7d1f12666nv721',
                                                   'client_secret': '10b246hxf612f0c5d42ba97dbb5f33r115112g2x',
                                                   'users': ['ahelal']}},
                          'name': 'Add5',
                          'state': 'latest'}]
        mod_cls = create_autospec(AnsibleModule)
        self.mod = mod_cls.return_value
        self.mod.params = dict(
            url="https://127.0.0.1:9012",
            username="test",
            password="test",
            teams=False,
            manage_exclusively=False
        )

   def test__compile_list_empty_state(self):
        concourse_server_teams = []

        concourse = Concourse(self.mod)
        concourse._compile_list(teams_in_concourse=concourse_server_teams, desired_teams=self.desired_state, exec_manage=False)
        # Teams to remove
        self.assertItemsEqual(concourse.teams_to_remove, [])
        # Teams to update
        self.assertItemsEqual(concourse.teams_to_update, ['Added4', 'Added1', 'Add5'])

   def test__compile_list_with_state(self):
        concourse_server_teams = ['Added1', 'Remove2', 'Added4', 'ServerOnly6']
        concourse = Concourse(self.mod)
        concourse._compile_list(teams_in_concourse=concourse_server_teams, desired_teams=self.desired_state, exec_manage=False)
        # Teams to remove
        self.assertItemsEqual(concourse.teams_to_remove, ['Remove2'])
        # Teams to update
        self.assertItemsEqual(concourse.teams_to_update, ['Add5'])

   def test__compile_list_with_state_managed(self):
        concourse_server_teams = ['Added1', 'Remove2', 'Added4', 'ServerOnly6']
        concourse = Concourse(self.mod)
        concourse._compile_list(teams_in_concourse=concourse_server_teams, desired_teams=self.desired_state, exec_manage=True)
        # Teams to remove
        self.assertItemsEqual(concourse.teams_to_remove, ['Remove2', 'ServerOnly6'])
        # Teams to update
        self.assertItemsEqual(concourse.teams_to_update, ['Add5'])