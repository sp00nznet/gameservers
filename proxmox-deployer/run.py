#!/usr/bin/env python3
"""
Silverware Game Server Deployer - Entry Point
Run this script to start the web application.
"""

import os

from app import create_app

app = create_app()

if __name__ == '__main__':
    # The debugger runs arbitrary code, and this listens on every interface: opt in only.
    app.run(host='0.0.0.0', port=5555, debug=os.environ.get('FLASK_DEBUG') == '1')
