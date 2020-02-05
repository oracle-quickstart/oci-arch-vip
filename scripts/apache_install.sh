# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


#!/bin/bash -x

INSTANCE_DNS=$1

# Install apache
yum install -y httpd

echo '<html>
    <head>
        <title>Hello World from Apache running on '${INSTANCE_DNS}' !</title>
    </head>
    <body>
Hello World from Apache running on '${INSTANCE_DNS}'!
    </body>
</html>
' > /var/www/html/index.html

# echo "Listen 80" >> /etc/httpd/conf/httpd.conf
service httpd start

# make httpd service start at boot
chkconfig --add httpd
chkconfig httpd on

#enable port 80 at the OS firewall level
sudo firewall-cmd --permanent --zone=public --add-service=http 
sudo firewall-cmd --reload

# END install apache
