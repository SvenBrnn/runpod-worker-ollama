#!/bin/bash

cd /runpod-volume/
/usr/local/bin/inflect recipe -r $MODEl_CONFIG_URL

echo "Model preloading complete."
