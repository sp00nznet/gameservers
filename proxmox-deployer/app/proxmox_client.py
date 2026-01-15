"""
Proxmox VE API Client for Game Server Deployment
Handles LXC container and VM creation, management, and monitoring.
"""

import time
import urllib3
from typing import Optional, Dict, Any, List
from proxmoxer import ProxmoxAPI

# Disable SSL warnings for self-signed certificates
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Try to import paramiko for SSH provisioning
try:
    import paramiko
    HAS_PARAMIKO = True
except ImportError:
    HAS_PARAMIKO = False


class ProxmoxClient:
    """Client for interacting with Proxmox VE API."""

    def __init__(self, connection):
        """
        Initialize the Proxmox client from a connection model.

        Args:
            connection: ProxmoxConnection model instance
        """
        self.connection = connection
        self._api = None

    @property
    def api(self):
        """Lazy-load the Proxmox API connection."""
        if self._api is None:
            if self.connection.token_name and self.connection.token_value:
                self._api = ProxmoxAPI(
                    self.connection.host,
                    port=self.connection.port,
                    user=self.connection.username,
                    token_name=self.connection.token_name,
                    token_value=self.connection.token_value,
                    verify_ssl=self.connection.verify_ssl
                )
            else:
                self._api = ProxmoxAPI(
                    self.connection.host,
                    port=self.connection.port,
                    user=self.connection.username,
                    password=self.connection.password,
                    verify_ssl=self.connection.verify_ssl
                )
        return self._api

    def test_connection(self) -> Dict[str, Any]:
        """Test the connection to Proxmox and return version info."""
        try:
            version = self.api.version.get()
            return {
                'success': True,
                'version': version.get('version', 'unknown'),
                'release': version.get('release', 'unknown')
            }
        except Exception as e:
            return {
                'success': False,
                'error': str(e)
            }

    def get_nodes(self) -> List[Dict[str, Any]]:
        """Get list of available Proxmox nodes."""
        nodes = self.api.nodes.get()
        return [{
            'node': n['node'],
            'status': n.get('status', 'unknown'),
            'cpu': n.get('cpu', 0),
            'maxcpu': n.get('maxcpu', 0),
            'mem': n.get('mem', 0),
            'maxmem': n.get('maxmem', 0),
            'disk': n.get('disk', 0),
            'maxdisk': n.get('maxdisk', 0)
        } for n in nodes]

    def get_templates(self, node: str) -> Dict[str, List[Dict]]:
        """Get available LXC templates and VM templates on a node."""
        templates = {'lxc': [], 'vm': []}

        # Get LXC templates from storage
        storages = self.api.nodes(node).storage.get()
        for storage in storages:
            if 'vztmpl' in storage.get('content', ''):
                try:
                    content = self.api.nodes(node).storage(storage['storage']).content.get()
                    for item in content:
                        if item.get('content') == 'vztmpl':
                            templates['lxc'].append({
                                'volid': item['volid'],
                                'name': item.get('volid', '').split('/')[-1],
                                'size': item.get('size', 0),
                                'storage': storage['storage']
                            })
                except Exception:
                    pass

        # Get VM templates (VMs with template flag)
        try:
            vms = self.api.nodes(node).qemu.get()
            for vm in vms:
                if vm.get('template', 0) == 1:
                    templates['vm'].append({
                        'vmid': vm['vmid'],
                        'name': vm.get('name', f"template-{vm['vmid']}"),
                        'status': vm.get('status', 'unknown')
                    })
        except Exception:
            pass

        return templates

    def get_storage_pools(self, node: str) -> List[Dict[str, Any]]:
        """Get available storage pools on a node."""
        storages = self.api.nodes(node).storage.get()
        pools = []
        for s in storages:
            # Filter for usable storage types
            content = s.get('content', '')
            if any(t in content for t in ['rootdir', 'images', 'vztmpl']):
                pools.append({
                    'storage': s['storage'],
                    'type': s.get('type', 'unknown'),
                    'content': content,
                    'avail': s.get('avail', 0),
                    'total': s.get('total', 0),
                    'used': s.get('used', 0)
                })
        return pools

    def get_networks(self, node: str) -> List[Dict[str, Any]]:
        """Get available network bridges on a node."""
        networks = self.api.nodes(node).network.get()
        bridges = []
        for n in networks:
            if n.get('type') == 'bridge':
                bridges.append({
                    'iface': n['iface'],
                    'address': n.get('address', ''),
                    'netmask': n.get('netmask', ''),
                    'gateway': n.get('gateway', ''),
                    'active': n.get('active', 0)
                })
        return bridges

    def get_next_vmid(self) -> int:
        """Get the next available VMID."""
        return self.api.cluster.nextid.get()

    def _netmask_to_cidr(self, netmask: str) -> int:
        """Convert netmask to CIDR notation."""
        return sum([bin(int(x)).count('1') for x in netmask.split('.')])

    def create_lxc(self, node: str, config: Dict[str, Any]) -> Dict[str, Any]:
        """
        Create an LXC container.

        Args:
            node: Target Proxmox node
            config: Container configuration dict

        Returns:
            Dict with vmid and status
        """
        vmid = config.get('vmid') or self.get_next_vmid()

        # Build network string
        if config.get('dhcp', True):
            net_config = f"name=eth0,bridge={config.get('bridge', 'vmbr0')},ip=dhcp"
        else:
            ip = config.get('ip_address', '')
            cidr = config.get('cidr', 24)
            gw = config.get('gateway', '')
            net_config = f"name=eth0,bridge={config.get('bridge', 'vmbr0')},ip={ip}/{cidr},gw={gw}"

        # Container parameters
        params = {
            'vmid': vmid,
            'hostname': config.get('hostname', f'gameserver-{vmid}'),
            'ostemplate': config['template'],
            'storage': config.get('storage', 'local-lvm'),
            'rootfs': f"{config.get('storage', 'local-lvm')}:{config.get('disk_size', 20)}",
            'cores': config.get('cores', 2),
            'memory': config.get('memory', 2048),
            'swap': config.get('swap', 512),
            'net0': net_config,
            'start': config.get('start', True),
            'onboot': config.get('onboot', True),
            'unprivileged': not config.get('privileged', False),
        }

        # Add SSH keys if provided
        if config.get('ssh_public_keys'):
            params['ssh-public-keys'] = config['ssh_public_keys']

        # Add password if provided
        if config.get('password'):
            params['password'] = config['password']

        # Add features if needed
        features = []
        if config.get('nesting', False):
            features.append('nesting=1')
        if config.get('fuse', False):
            features.append('fuse=1')
        if features:
            params['features'] = ','.join(features)

        # Add mount points for NFS/bind mounts
        if config.get('mounts'):
            for i, mount in enumerate(config['mounts']):
                params[f'mp{i}'] = f"{mount['source']},mp={mount['target']}"

        try:
            # Create the container
            task = self.api.nodes(node).lxc.create(**params)

            # Wait for task completion
            self._wait_for_task(node, task)

            return {
                'success': True,
                'vmid': vmid,
                'type': 'lxc'
            }
        except Exception as e:
            return {
                'success': False,
                'error': str(e),
                'vmid': vmid
            }

    def create_vm(self, node: str, config: Dict[str, Any]) -> Dict[str, Any]:
        """
        Create a VM by cloning a template.

        Args:
            node: Target Proxmox node
            config: VM configuration dict

        Returns:
            Dict with vmid and status
        """
        vmid = config.get('vmid') or self.get_next_vmid()
        template_vmid = config['template_vmid']

        try:
            # Clone the template
            clone_params = {
                'newid': vmid,
                'name': config.get('hostname', f'gameserver-{vmid}'),
                'full': True,
                'target': node,
            }

            if config.get('storage'):
                clone_params['storage'] = config['storage']

            task = self.api.nodes(node).qemu(template_vmid).clone.create(**clone_params)
            self._wait_for_task(node, task)

            # Configure the cloned VM
            vm_config = {}

            if config.get('cores'):
                vm_config['cores'] = config['cores']
            if config.get('memory'):
                vm_config['memory'] = config['memory']
            if config.get('balloon'):
                vm_config['balloon'] = config['balloon']

            # Network configuration
            if config.get('dhcp', True):
                net_config = f"virtio,bridge={config.get('bridge', 'vmbr0')}"
            else:
                net_config = f"virtio,bridge={config.get('bridge', 'vmbr0')}"
            vm_config['net0'] = net_config

            # Cloud-init configuration
            if config.get('ciuser'):
                vm_config['ciuser'] = config['ciuser']
            if config.get('cipassword'):
                vm_config['cipassword'] = config['cipassword']
            if config.get('sshkeys'):
                vm_config['sshkeys'] = config['sshkeys']
            if not config.get('dhcp', True):
                vm_config['ipconfig0'] = f"ip={config.get('ip_address')}/{config.get('cidr', 24)},gw={config.get('gateway')}"
            else:
                vm_config['ipconfig0'] = 'ip=dhcp'

            if vm_config:
                self.api.nodes(node).qemu(vmid).config.put(**vm_config)

            # Start the VM if requested
            if config.get('start', True):
                self.api.nodes(node).qemu(vmid).status.start.post()

            return {
                'success': True,
                'vmid': vmid,
                'type': 'vm'
            }
        except Exception as e:
            return {
                'success': False,
                'error': str(e),
                'vmid': vmid
            }

    def _wait_for_task(self, node: str, task: str, timeout: int = 300):
        """Wait for a Proxmox task to complete."""
        start_time = time.time()
        while time.time() - start_time < timeout:
            status = self.api.nodes(node).tasks(task).status.get()
            if status.get('status') == 'stopped':
                if status.get('exitstatus') != 'OK':
                    raise Exception(f"Task failed: {status.get('exitstatus')}")
                return
            time.sleep(2)
        raise Exception(f"Task timeout after {timeout} seconds")

    def start_container(self, node: str, vmid: int, container_type: str = 'lxc') -> Dict[str, Any]:
        """Start an LXC container or VM."""
        try:
            if container_type == 'lxc':
                self.api.nodes(node).lxc(vmid).status.start.post()
            else:
                self.api.nodes(node).qemu(vmid).status.start.post()
            return {'success': True}
        except Exception as e:
            return {'success': False, 'error': str(e)}

    def stop_container(self, node: str, vmid: int, container_type: str = 'lxc') -> Dict[str, Any]:
        """Stop an LXC container or VM."""
        try:
            if container_type == 'lxc':
                self.api.nodes(node).lxc(vmid).status.stop.post()
            else:
                self.api.nodes(node).qemu(vmid).status.stop.post()
            return {'success': True}
        except Exception as e:
            return {'success': False, 'error': str(e)}

    def delete_container(self, node: str, vmid: int, container_type: str = 'lxc') -> Dict[str, Any]:
        """Delete an LXC container or VM."""
        try:
            if container_type == 'lxc':
                self.api.nodes(node).lxc(vmid).delete()
            else:
                self.api.nodes(node).qemu(vmid).delete()
            return {'success': True}
        except Exception as e:
            return {'success': False, 'error': str(e)}

    def get_container_status(self, node: str, vmid: int, container_type: str = 'lxc') -> Dict[str, Any]:
        """Get the status of an LXC container or VM."""
        try:
            if container_type == 'lxc':
                status = self.api.nodes(node).lxc(vmid).status.current.get()
            else:
                status = self.api.nodes(node).qemu(vmid).status.current.get()
            return {
                'success': True,
                'status': status.get('status', 'unknown'),
                'cpu': status.get('cpu', 0),
                'mem': status.get('mem', 0),
                'maxmem': status.get('maxmem', 0),
                'disk': status.get('disk', 0),
                'maxdisk': status.get('maxdisk', 0),
                'uptime': status.get('uptime', 0),
                'netin': status.get('netin', 0),
                'netout': status.get('netout', 0)
            }
        except Exception as e:
            return {'success': False, 'error': str(e)}

    def provision_container(self, node: str, vmid: int, script: str, timeout: int = 600) -> Dict[str, Any]:
        """
        Provision an LXC container by running an installation script inside it.

        Uses SSH to connect to the Proxmox host and runs 'pct exec' to execute
        the script inside the container.

        Args:
            node: Proxmox node name
            vmid: Container VMID
            script: Bash script to execute inside the container
            timeout: SSH command timeout in seconds

        Returns:
            Dict with success status and output/error
        """
        if not HAS_PARAMIKO:
            return {
                'success': False,
                'error': 'paramiko not installed. Run: pip install paramiko'
            }

        if not self.connection.password:
            return {
                'success': False,
                'error': 'Password authentication required for provisioning. API tokens cannot use SSH.'
            }

        try:
            # Connect to Proxmox host via SSH
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh.connect(
                hostname=self.connection.host,
                port=22,
                username=self.connection.username.split('@')[0],  # Remove @pam, @pve suffix
                password=self.connection.password,
                timeout=30
            )

            # Write script to a temp file on the Proxmox host
            script_path = f'/tmp/provision_{vmid}.sh'
            sftp = ssh.open_sftp()
            with sftp.file(script_path, 'w') as f:
                f.write(script)
            sftp.close()

            # Make script executable
            ssh.exec_command(f'chmod +x {script_path}')

            # Copy script into container
            stdin, stdout, stderr = ssh.exec_command(
                f'pct push {vmid} {script_path} /tmp/provision.sh',
                timeout=60
            )
            stdout.read()  # Wait for completion

            # Execute script inside the container using pct exec
            # Use bash -c to run the script
            stdin, stdout, stderr = ssh.exec_command(
                f'pct exec {vmid} -- bash /tmp/provision.sh',
                timeout=timeout
            )

            output = stdout.read().decode('utf-8', errors='replace')
            error = stderr.read().decode('utf-8', errors='replace')
            exit_code = stdout.channel.recv_exit_status()

            # Cleanup temp script on host
            ssh.exec_command(f'rm -f {script_path}')
            ssh.close()

            if exit_code == 0:
                return {
                    'success': True,
                    'output': output,
                    'exit_code': exit_code
                }
            else:
                return {
                    'success': False,
                    'error': error or output,
                    'output': output,
                    'exit_code': exit_code
                }

        except paramiko.AuthenticationException:
            return {
                'success': False,
                'error': 'SSH authentication failed. Check username/password.'
            }
        except paramiko.SSHException as e:
            return {
                'success': False,
                'error': f'SSH error: {str(e)}'
            }
        except Exception as e:
            return {
                'success': False,
                'error': f'Provisioning failed: {str(e)}'
            }

    def exec_in_container(self, node: str, vmid: int, command: str, timeout: int = 60) -> Dict[str, Any]:
        """
        Execute a single command inside an LXC container.

        Args:
            node: Proxmox node name
            vmid: Container VMID
            command: Command to execute

        Returns:
            Dict with success status and output/error
        """
        if not HAS_PARAMIKO:
            return {
                'success': False,
                'error': 'paramiko not installed. Run: pip install paramiko'
            }

        if not self.connection.password:
            return {
                'success': False,
                'error': 'Password authentication required. API tokens cannot use SSH.'
            }

        try:
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh.connect(
                hostname=self.connection.host,
                port=22,
                username=self.connection.username.split('@')[0],
                password=self.connection.password,
                timeout=30
            )

            stdin, stdout, stderr = ssh.exec_command(
                f'pct exec {vmid} -- {command}',
                timeout=timeout
            )

            output = stdout.read().decode('utf-8', errors='replace')
            error = stderr.read().decode('utf-8', errors='replace')
            exit_code = stdout.channel.recv_exit_status()

            ssh.close()

            return {
                'success': exit_code == 0,
                'output': output,
                'error': error if exit_code != 0 else None,
                'exit_code': exit_code
            }

        except Exception as e:
            return {
                'success': False,
                'error': str(e)
            }
