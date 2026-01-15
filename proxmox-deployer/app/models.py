"""
Database models for the Game Server Deployer
"""

from datetime import datetime
from app import db


class ProxmoxConnection(db.Model):
    """Proxmox server connection configuration."""
    __tablename__ = 'proxmox_connections'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), unique=True, nullable=False)
    host = db.Column(db.String(255), nullable=False)
    port = db.Column(db.Integer, default=8006)
    username = db.Column(db.String(100), nullable=False)
    password = db.Column(db.String(255), nullable=True)
    token_name = db.Column(db.String(100), nullable=True)
    token_value = db.Column(db.String(255), nullable=True)
    verify_ssl = db.Column(db.Boolean, default=False)
    is_default = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    deployments = db.relationship('Deployment', backref='connection', lazy=True)

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'host': self.host,
            'port': self.port,
            'username': self.username,
            'has_password': bool(self.password),
            'has_token': bool(self.token_name and self.token_value),
            'verify_ssl': self.verify_ssl,
            'is_default': self.is_default,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }


class Deployment(db.Model):
    """Record of a game server deployment."""
    __tablename__ = 'deployments'

    id = db.Column(db.Integer, primary_key=True)
    connection_id = db.Column(db.Integer, db.ForeignKey('proxmox_connections.id'), nullable=False)
    server_key = db.Column(db.String(100), nullable=False)
    server_name = db.Column(db.String(200), nullable=False)
    deployment_type = db.Column(db.String(20), nullable=False)  # 'lxc' or 'vm'
    node = db.Column(db.String(100), nullable=False)
    vmid = db.Column(db.Integer, nullable=True)
    ip_address = db.Column(db.String(50), nullable=True)
    status = db.Column(db.String(50), default='pending')  # pending, running, stopped, failed
    error_message = db.Column(db.Text, nullable=True)
    config_snapshot = db.Column(db.JSON, nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'connection_id': self.connection_id,
            'server_key': self.server_key,
            'server_name': self.server_name,
            'deployment_type': self.deployment_type,
            'node': self.node,
            'vmid': self.vmid,
            'ip_address': self.ip_address,
            'status': self.status,
            'error_message': self.error_message,
            'config_snapshot': self.config_snapshot,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }


class Credential(db.Model):
    """Stored credentials for game servers (Steam tokens, passwords, etc.)."""
    __tablename__ = 'credentials'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), unique=True, nullable=False)
    credential_type = db.Column(db.String(50), nullable=False)  # steam_token, password, ssh_key, api_key
    value = db.Column(db.Text, nullable=False)
    description = db.Column(db.String(255), nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def to_dict(self, include_value=False):
        result = {
            'id': self.id,
            'name': self.name,
            'credential_type': self.credential_type,
            'description': self.description,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
        if include_value:
            result['value'] = self.value
        return result
