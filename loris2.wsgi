#!/usr/bin/env python3

import os, sys
import newrelic.agent
from loris.webapp import create_app

application = create_app(config_file_path='/opt/loris/etc/loris2.conf')

if os.environ.get("NEW_RELIC_ENABLED", "false").lower() == "true":
    newrelic_licence_file = "/etc/newrelic.ini"
    if not os.path.exists(newrelic_licence_file):
        raise SystemExit("newrelic licence file not found: %s" % newrelic_licence_file)

    # see the `Unsupported web frameworks` section:
    # - https://docs.newrelic.com/docs/agents/python-agent/installation-configuration/python-agent-integration
    application = newrelic.agent.WSGIApplicationWrapper(application)
