#!/usr/bin/env python3

#import newrelic.agent
from loris.webapp import create_app

# `Unsupported web frameworks` section at:
# https://docs.newrelic.com/docs/agents/python-agent/installation-configuration/python-agent-integration 
#application = newrelic.agent.WSGIApplicationWrapper(create_app(config_file_path='/etc/loris2/loris2.conf'))

# just for now while container is developed
application = create_app(config_file_path='/etc/loris2/loris2.conf', debug=False)
