"""
Flask routes for the Game Server Deployer
Handles web UI and API endpoints for deployment management.
"""

from flask import Blueprint, render_template, request, jsonify, redirect, url_for
from app import db
from app.models import ProxmoxConnection, Deployment, Credential
from app.proxmox_client import ProxmoxClient
from app.game_servers import (
    GAME_SERVERS, CATEGORIES, STATS,
    get_servers_by_category, get_server, search_servers
)

main_bp = Blueprint('main', __name__)


# ============================================
# PAGE ROUTES
# ============================================

@main_bp.route('/')
def index():
    """Dashboard showing servers, connections, and recent deployments."""
    connections = ProxmoxConnection.query.all()
    deployments = Deployment.query.order_by(Deployment.created_at.desc()).limit(10).all()
    credentials = Credential.query.all()

    return render_template('index.html',
                         servers=GAME_SERVERS,
                         categories=CATEGORIES,
                         stats=STATS,
                         connections=connections,
                         deployments=deployments,
                         credentials=credentials)


@main_bp.route('/servers')
def servers():
    """Browse all available game servers."""
    category = request.args.get('category')
    search = request.args.get('search')

    if search:
        filtered_servers = search_servers(search)
    elif category:
        filtered_servers = get_servers_by_category(category)
    else:
        filtered_servers = GAME_SERVERS

    return render_template('servers.html',
                         servers=filtered_servers,
                         categories=CATEGORIES,
                         current_category=category,
                         search_query=search,
                         stats=STATS)


@main_bp.route('/server/<server_key>')
def server_detail(server_key):
    """Detailed view and deployment form for a specific server."""
    server = get_server(server_key)
    if not server:
        return render_template('error.html', message='Server not found'), 404

    connections = ProxmoxConnection.query.all()
    credentials = Credential.query.all()

    return render_template('server_detail.html',
                         server_key=server_key,
                         server=server,
                         connections=connections,
                         credentials=credentials,
                         categories=CATEGORIES)


@main_bp.route('/deployments')
def deployments():
    """View deployment history."""
    all_deployments = Deployment.query.order_by(Deployment.created_at.desc()).all()
    return render_template('deployments.html',
                         deployments=all_deployments,
                         categories=CATEGORIES)


@main_bp.route('/settings')
def settings():
    """Manage Proxmox connections and credentials."""
    connections = ProxmoxConnection.query.all()
    credentials = Credential.query.all()
    return render_template('settings.html',
                         connections=connections,
                         credentials=credentials,
                         categories=CATEGORIES)


# ============================================
# CONNECTION API ROUTES
# ============================================

@main_bp.route('/api/connections', methods=['GET'])
def api_get_connections():
    """Get all Proxmox connections."""
    connections = ProxmoxConnection.query.all()
    return jsonify([c.to_dict() for c in connections])


@main_bp.route('/api/connections', methods=['POST'])
def api_create_connection():
    """Create a new Proxmox connection."""
    data = request.get_json()

    # Validate required fields
    required = ['name', 'host', 'username']
    for field in required:
        if not data.get(field):
            return jsonify({'error': f'Missing required field: {field}'}), 400

    # Check for duplicate name
    existing = ProxmoxConnection.query.filter_by(name=data['name']).first()
    if existing:
        return jsonify({'error': 'Connection name already exists'}), 400

    # Handle default connection
    if data.get('is_default'):
        ProxmoxConnection.query.update({'is_default': False})

    connection = ProxmoxConnection(
        name=data['name'],
        host=data['host'],
        port=data.get('port', 8006),
        username=data['username'],
        password=data.get('password'),
        token_name=data.get('token_name'),
        token_value=data.get('token_value'),
        verify_ssl=data.get('verify_ssl', False),
        is_default=data.get('is_default', False)
    )

    db.session.add(connection)
    db.session.commit()

    return jsonify(connection.to_dict()), 201


@main_bp.route('/api/connections/<int:connection_id>', methods=['PUT'])
def api_update_connection(connection_id):
    """Update an existing Proxmox connection."""
    connection = ProxmoxConnection.query.get_or_404(connection_id)
    data = request.get_json()

    if 'name' in data:
        existing = ProxmoxConnection.query.filter(
            ProxmoxConnection.name == data['name'],
            ProxmoxConnection.id != connection_id
        ).first()
        if existing:
            return jsonify({'error': 'Connection name already exists'}), 400
        connection.name = data['name']

    if 'host' in data:
        connection.host = data['host']
    if 'port' in data:
        connection.port = data['port']
    if 'username' in data:
        connection.username = data['username']
    if 'password' in data:
        connection.password = data['password']
    if 'token_name' in data:
        connection.token_name = data['token_name']
    if 'token_value' in data:
        connection.token_value = data['token_value']
    if 'verify_ssl' in data:
        connection.verify_ssl = data['verify_ssl']

    if data.get('is_default'):
        ProxmoxConnection.query.update({'is_default': False})
        connection.is_default = True

    db.session.commit()
    return jsonify(connection.to_dict())


@main_bp.route('/api/connections/<int:connection_id>', methods=['DELETE'])
def api_delete_connection(connection_id):
    """Delete a Proxmox connection."""
    connection = ProxmoxConnection.query.get_or_404(connection_id)
    db.session.delete(connection)
    db.session.commit()
    return jsonify({'success': True})


@main_bp.route('/api/connections/<int:connection_id>/test', methods=['POST'])
def api_test_connection(connection_id):
    """Test a Proxmox connection."""
    connection = ProxmoxConnection.query.get_or_404(connection_id)
    client = ProxmoxClient(connection)
    result = client.test_connection()
    return jsonify(result)


@main_bp.route('/api/connections/<int:connection_id>/nodes', methods=['GET'])
def api_get_nodes(connection_id):
    """Get available nodes for a connection."""
    connection = ProxmoxConnection.query.get_or_404(connection_id)
    client = ProxmoxClient(connection)
    try:
        nodes = client.get_nodes()
        return jsonify(nodes)
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@main_bp.route('/api/connections/<int:connection_id>/nodes/<node>/templates', methods=['GET'])
def api_get_templates(connection_id, node):
    """Get available templates on a node."""
    connection = ProxmoxConnection.query.get_or_404(connection_id)
    client = ProxmoxClient(connection)
    try:
        templates = client.get_templates(node)
        return jsonify(templates)
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@main_bp.route('/api/connections/<int:connection_id>/nodes/<node>/storage', methods=['GET'])
def api_get_storage(connection_id, node):
    """Get available storage pools on a node."""
    connection = ProxmoxConnection.query.get_or_404(connection_id)
    client = ProxmoxClient(connection)
    try:
        storage = client.get_storage_pools(node)
        return jsonify(storage)
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@main_bp.route('/api/connections/<int:connection_id>/nodes/<node>/networks', methods=['GET'])
def api_get_networks(connection_id, node):
    """Get available network bridges on a node."""
    connection = ProxmoxConnection.query.get_or_404(connection_id)
    client = ProxmoxClient(connection)
    try:
        networks = client.get_networks(node)
        return jsonify(networks)
    except Exception as e:
        return jsonify({'error': str(e)}), 500


# ============================================
# DEPLOYMENT API ROUTES
# ============================================

@main_bp.route('/api/deploy', methods=['POST'])
def api_deploy():
    """Deploy a game server."""
    data = request.get_json()

    # Validate required fields
    required = ['connection_id', 'server_key', 'node']
    for field in required:
        if not data.get(field):
            return jsonify({'error': f'Missing required field: {field}'}), 400

    # Get server definition
    server = get_server(data['server_key'])
    if not server:
        return jsonify({'error': 'Invalid server key'}), 400

    # Get connection
    connection = ProxmoxConnection.query.get(data['connection_id'])
    if not connection:
        return jsonify({'error': 'Invalid connection'}), 400

    # Build deployment configuration
    config = {
        'hostname': data.get('hostname', server['hostname']),
        'cores': data.get('cores', server['cores']),
        'memory': data.get('memory', server['memory']),
        'disk_size': data.get('disk_size', server['disk_size']),
        'storage': data.get('storage', 'local-lvm'),
        'bridge': data.get('bridge', 'vmbr0'),
        'dhcp': data.get('dhcp', True),
        'ip_address': data.get('ip_address'),
        'cidr': data.get('cidr', 24),
        'gateway': data.get('gateway'),
        'start': data.get('start', True),
        'onboot': data.get('onboot', True),
        'privileged': server.get('privileged', False),
        'nesting': server.get('nesting', False),
        'env_vars': data.get('env_vars', {}),
    }

    # Add template for LXC or template_vmid for VM
    if server['deployment_type'] == 'lxc':
        if not data.get('template'):
            return jsonify({'error': 'LXC template required'}), 400
        config['template'] = data['template']
    else:
        if not data.get('template_vmid'):
            return jsonify({'error': 'VM template VMID required'}), 400
        config['template_vmid'] = data['template_vmid']

    # Add SSH keys if provided
    if data.get('ssh_public_keys'):
        config['ssh_public_keys'] = data['ssh_public_keys']

    # Create deployment record
    deployment = Deployment(
        connection_id=connection.id,
        server_key=data['server_key'],
        server_name=server['name'],
        deployment_type=server['deployment_type'],
        node=data['node'],
        status='pending',
        config_snapshot=config
    )
    db.session.add(deployment)
    db.session.commit()

    # Execute deployment
    client = ProxmoxClient(connection)
    try:
        if server['deployment_type'] == 'lxc':
            result = client.create_lxc(data['node'], config)
        else:
            result = client.create_vm(data['node'], config)

        if result['success']:
            deployment.vmid = result['vmid']
            deployment.status = 'running' if config.get('start') else 'stopped'
            if not config.get('dhcp') and config.get('ip_address'):
                deployment.ip_address = config['ip_address']
        else:
            deployment.status = 'failed'
            deployment.error_message = result.get('error', 'Unknown error')

        db.session.commit()
        return jsonify(deployment.to_dict())

    except Exception as e:
        deployment.status = 'failed'
        deployment.error_message = str(e)
        db.session.commit()
        return jsonify({'error': str(e), 'deployment': deployment.to_dict()}), 500


@main_bp.route('/api/deployments', methods=['GET'])
def api_get_deployments():
    """Get all deployments."""
    deployments = Deployment.query.order_by(Deployment.created_at.desc()).all()
    return jsonify([d.to_dict() for d in deployments])


@main_bp.route('/api/deployments/<int:deployment_id>', methods=['GET'])
def api_get_deployment(deployment_id):
    """Get a specific deployment."""
    deployment = Deployment.query.get_or_404(deployment_id)
    return jsonify(deployment.to_dict())


@main_bp.route('/api/deployments/<int:deployment_id>/start', methods=['POST'])
def api_start_deployment(deployment_id):
    """Start a deployed server."""
    deployment = Deployment.query.get_or_404(deployment_id)
    connection = deployment.connection
    client = ProxmoxClient(connection)

    result = client.start_container(
        deployment.node,
        deployment.vmid,
        deployment.deployment_type
    )

    if result['success']:
        deployment.status = 'running'
        db.session.commit()

    return jsonify(result)


@main_bp.route('/api/deployments/<int:deployment_id>/stop', methods=['POST'])
def api_stop_deployment(deployment_id):
    """Stop a deployed server."""
    deployment = Deployment.query.get_or_404(deployment_id)
    connection = deployment.connection
    client = ProxmoxClient(connection)

    result = client.stop_container(
        deployment.node,
        deployment.vmid,
        deployment.deployment_type
    )

    if result['success']:
        deployment.status = 'stopped'
        db.session.commit()

    return jsonify(result)


@main_bp.route('/api/deployments/<int:deployment_id>/status', methods=['GET'])
def api_deployment_status(deployment_id):
    """Get current status of a deployed server."""
    deployment = Deployment.query.get_or_404(deployment_id)
    connection = deployment.connection
    client = ProxmoxClient(connection)

    result = client.get_container_status(
        deployment.node,
        deployment.vmid,
        deployment.deployment_type
    )

    if result['success']:
        deployment.status = result['status']
        db.session.commit()

    return jsonify(result)


@main_bp.route('/api/deployments/<int:deployment_id>', methods=['DELETE'])
def api_delete_deployment(deployment_id):
    """Delete a deployment and its container/VM."""
    deployment = Deployment.query.get_or_404(deployment_id)
    connection = deployment.connection

    # Delete from Proxmox if VMID exists
    if deployment.vmid:
        client = ProxmoxClient(connection)
        client.delete_container(
            deployment.node,
            deployment.vmid,
            deployment.deployment_type
        )

    # Delete from database
    db.session.delete(deployment)
    db.session.commit()

    return jsonify({'success': True})


# ============================================
# CREDENTIALS API ROUTES
# ============================================

@main_bp.route('/api/credentials', methods=['GET'])
def api_get_credentials():
    """Get all credentials (values hidden)."""
    credentials = Credential.query.all()
    return jsonify([c.to_dict(include_value=False) for c in credentials])


@main_bp.route('/api/credentials', methods=['POST'])
def api_create_credential():
    """Create a new credential."""
    data = request.get_json()

    required = ['name', 'credential_type', 'value']
    for field in required:
        if not data.get(field):
            return jsonify({'error': f'Missing required field: {field}'}), 400

    existing = Credential.query.filter_by(name=data['name']).first()
    if existing:
        return jsonify({'error': 'Credential name already exists'}), 400

    credential = Credential(
        name=data['name'],
        credential_type=data['credential_type'],
        value=data['value'],
        description=data.get('description')
    )

    db.session.add(credential)
    db.session.commit()

    return jsonify(credential.to_dict(include_value=False)), 201


@main_bp.route('/api/credentials/<int:credential_id>', methods=['PUT'])
def api_update_credential(credential_id):
    """Update a credential."""
    credential = Credential.query.get_or_404(credential_id)
    data = request.get_json()

    if 'name' in data:
        existing = Credential.query.filter(
            Credential.name == data['name'],
            Credential.id != credential_id
        ).first()
        if existing:
            return jsonify({'error': 'Credential name already exists'}), 400
        credential.name = data['name']

    if 'credential_type' in data:
        credential.credential_type = data['credential_type']
    if 'value' in data:
        credential.value = data['value']
    if 'description' in data:
        credential.description = data['description']

    db.session.commit()
    return jsonify(credential.to_dict(include_value=False))


@main_bp.route('/api/credentials/<int:credential_id>', methods=['DELETE'])
def api_delete_credential(credential_id):
    """Delete a credential."""
    credential = Credential.query.get_or_404(credential_id)
    db.session.delete(credential)
    db.session.commit()
    return jsonify({'success': True})


# ============================================
# SERVER INFO API ROUTES
# ============================================

@main_bp.route('/api/servers', methods=['GET'])
def api_get_servers():
    """Get all server definitions."""
    category = request.args.get('category')
    search = request.args.get('search')

    if search:
        servers = search_servers(search)
    elif category:
        servers = get_servers_by_category(category)
    else:
        servers = GAME_SERVERS

    return jsonify(servers)


@main_bp.route('/api/servers/<server_key>', methods=['GET'])
def api_get_server(server_key):
    """Get a specific server definition."""
    server = get_server(server_key)
    if not server:
        return jsonify({'error': 'Server not found'}), 404
    return jsonify(server)


@main_bp.route('/api/categories', methods=['GET'])
def api_get_categories():
    """Get all categories."""
    return jsonify(CATEGORIES)


@main_bp.route('/api/stats', methods=['GET'])
def api_get_stats():
    """Get deployment statistics."""
    deployment_stats = {
        'total': Deployment.query.count(),
        'running': Deployment.query.filter_by(status='running').count(),
        'stopped': Deployment.query.filter_by(status='stopped').count(),
        'failed': Deployment.query.filter_by(status='failed').count(),
    }
    return jsonify({
        'servers': STATS,
        'deployments': deployment_stats
    })
