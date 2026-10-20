"""Smoke test: every page renders and a deploy reaches the Proxmox client.

Guards issue #13, where a rewrite of game_servers.py dropped STATS and get_server and
error.html crashed for want of `categories`. No Proxmox needed: the client is mocked.
Run from proxmox-deployer/:  python -m unittest discover tests
"""
import os
import tempfile
import unittest
from unittest import mock

os.environ['DATABASE_URL'] = 'sqlite:///' + os.path.join(tempfile.mkdtemp(), 'test.db')

from app import create_app  # noqa: E402
from app.game_servers import GAME_SERVERS  # noqa: E402


class Smoke(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.c = create_app().test_client()

    def test_pages_render(self):
        pages = ['/', '/servers', '/servers?category=coop', '/servers?search=rim',
                 '/deployments', '/settings', '/api/stats', '/api/servers']
        for url in pages + [f'/server/{k}' for k in GAME_SERVERS]:
            self.assertEqual(self.c.get(url).status_code, 200, url)

    def test_install_scripts_match_catalog_keys(self):
        # A script under a stale key never runs: the game deploys as an empty container.
        from app.install_scripts import INSTALL_SCRIPTS
        orphans = set(INSTALL_SCRIPTS) - set(GAME_SERVERS) - {'linuxgsm'}  # linuxgsm: API-only
        self.assertFalse(orphans)

    def test_unknown_server_is_404_not_500(self):
        self.assertEqual(self.c.get('/server/nope').status_code, 404)

    def test_deploy_reaches_proxmox(self):
        conn = self.c.post('/api/connections', json={
            'name': 'test', 'host': 'pve.invalid', 'username': 'root@pam', 'password': 'x'}).get_json()
        with mock.patch('app.routes.ProxmoxClient') as client:
            client.return_value.create_lxc.return_value = {'success': True, 'vmid': 123}
            client.return_value.provision_container.return_value = {'success': True}
            with mock.patch('time.sleep'):
                r = self.c.post('/api/deploy', json={
                    'connection_id': conn['id'], 'server_key': 'rimworldtogether',
                    'node': 'pve', 'template': 'local:vztmpl/debian-12.tar.zst'})
        self.assertEqual(r.status_code, 200, r.get_json())
        self.assertEqual(r.get_json()['vmid'], 123)


if __name__ == '__main__':
    unittest.main()
