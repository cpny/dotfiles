#!/bin/sh

# Send the header so that i3bar knows we want to use JSON:
echo '{ "version": 1, "click_events": true }'
echo '['
echo '[],'
exec conky -c ~/.conkyrc