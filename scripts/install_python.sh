# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


#!/bin/bash -x

# Install python
#yum install -y python

# Download and install pip
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py
pip install --upgrade --force-reinstall pip==9.0.3
sudo pip install pip==9.0.3

# install python OCI SDK
pip install oci --disable-pip-version-check

# END install python