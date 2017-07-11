#!/bin/bash

echo -e "Starting supervisord..."
supervisord -c /etc/supervisord.conf
