#!/bin/bash



function links_for_mirrors(){
    if [ -L /var/www/html/mirrors ];then
        echo "mirrors links is ok!"
    else
        ln -sf $DATA_DIR /var/www/html
        echo "links now if ok"
    fi
}

CENTOS_VERSION_BY_RPM=`rpm -q --queryformat '%{VERSION}' centos-release`

function _mirrors_server(){
    if [ $CENTOS_VERSION_BY_RPM -eq 6 ];then
        _mirrors_server_6
    elif [[  $CENTOS_VERSION_BY_RPM -eq 7 ]]; then
        _mirrors_server_7
    fi
}

function _mirrors_server_7(){
    _firewalld_httpd

}

function _mirrors_server_6(){
    _no_iptables_httpd
}

function _no_iptables_httpd(){
    service httpd start
    chkconfig httpd on
}

function _firewalld_httpd(){
    firewall-cmd --permanent --add-service=http
    firewall-cmd --permanent --add-service=https
    firewall-cmd --reload
    _check_command_and_yum_install httpd
    sleep 3
    chcon -R -t httpd_sys_content_t $DATA_DIR
    systemctl enable httpd
    systemctl start httpd
}


IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d '/')


function _chage_add_repos(){
    cp ./add.sh $DATA_DIR/repo/add.sh
    sed -i "s/10.0.0.10/${IP}/g" $DATA_DIR/repo/add.sh
}
function _create_repos_file(){
    cat > $REPO/centos-7.repo << EOF
[base]
name = base
baseurl = http://$IP/$WEB/centos/7/os
enable = 1
gpgcheck = 0

[update]
name = update
baseurl = http://$IP/$WEB/centos/7/updates
enable = 1
gpgcheck = 0


[extras]
name = extras
baseurl = http://$IP/$WEB/centos/7/extras
enable = 1
gpgcheck = 0

EOF

    cat > $REPO/centos-6.repo << EOF
[base]
name = base
baseurl = http://$IP/$WEB/centos/6/os
enable = 1
gpgcheck = 0

[update]
name = update
baseurl = http://$IP/$WEB/centos/6/updates
enable = 1
gpgcheck = 0


[extras]
name = extras
baseurl = http://$IP/$WEB/centos/6/extras
enable = 1
gpgcheck = 0
EOF


# EPEL
    cat > $REPO/epel-7.repo << EOF
[epel]
name = epel7
baseurl = http://$IP/$WEB/epel/7
enable = 1
gpgcheck = 0

EOF

    cat > $REPO/epel-6.repo << EOF
[epel]
name = epel6
baseurl = http://$IP/$WEB/epel/6
enable = 1
gpgcheck = 0
EOF

    cat > $REPO/mongodb-6.repo << EOF
[mongodb]
name = mongodb6
baseurl = http://$IP/$WEB/mongodb/6
enable = 1
gpgcheck = 0
EOF
    cat > $REPO/mongodb-7.repo << EOF
[mongodb]
name = mongodb7
baseurl = http://$IP/$WEB/mongodb/7
enable = 1
gpgcheck = 0
EOF

    cat > $REPO/mariadb-7.repo << EOF
[mariadb]
name = mariadb7
baseurl = http://$IP/$WEB/mariadb/7
enable = 1
gpgcheck = 0
EOF
    cat > $REPO/mariadb-6.repo << EOF
[mariadb]
name = mariadb6
baseurl = http://$IP/$WEB/mariadb/6
enable = 1
gpgcheck = 0
EOF

    cat > $REPO/nginx-6.repo << EOF
[nginx]
name = nginx6
baseurl = http://$IP/$WEB/nginx/6
enable = 1
gpgcheck = 0
EOF

    cat > $REPO/nginx-7.repo << EOF
[nginx]
name = nginx7
baseurl = http://$IP/$WEB/nginx/7
enable = 1
gpgcheck = 0
EOF


    cat > $REPO/zabbix-6.repo << EOF
[zabbix]
name = zabbix6
baseurl = http://$IP/$WEB/zabbix/6/x86_64
enable = 1
gpgcheck = 0

[zabbix-non-supported]
name = non-supported
baseurl = http://$IP/$WEB/zabbix/6/non-supported/x86_64/
enable = 1
gpgcheck = 0
EOF

cat > $REPO/zabbix-7.repo << EOF

[zabbix]
name = zabbix7
baseurl = http://$IP/$WEB/zabbix/7/x86_64
enable = 1
gpgcheck = 0

[zabbix-non-supported]
name = non-supported
baseurl = http://$IP/$WEB/zabbix/7/non-supported/x86_64/
enable = 1
gpgcheck = 0
EOF

    cat > $REPO/glibc.repo << EOF
[glibc]
name = glibc
baseurl = http://$IP/$WEB/glibc/6
enable = 1
gpgcheck = 0
EOF

    cat > $REPO/jdk.repo << EOF
[jdk]
name = jdk
baseurl = http://$IP/$WEB/jdk
enable = 1
gpgcheck = 0
EOF

    cat > $REPO/elk.repo << EOF
[elk]
name = elk
baseurl = http://$IP/$WEB/elk
enable = 1
gpgcheck = 0
EOF

    cat > $REPO/rocky.repo << EOF

[rocky]
name = rocky
baseurl = http://$IP/$WEB/centos/7/rocky
enable = 1
gpgcheck = 0

EOF


    cat > $REPO/docker.repo << EOF

[docker]
name = docker-ce
baseurl = http://$IP/$WEB/docker/
enable = 1
gpgcheck = 0

EOF


}
