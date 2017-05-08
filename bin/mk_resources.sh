#!/bin/bash

OUTPUT=/var/rundeck/projects/Foo/etc/resources.xml 

HOSTS_LIST=$(wget -q http://admin.example.com/hosts/list -O - | grep -v "^#")
HOSTS_AUTH=$(wget -q http://auth.example.com/accounts -O - | cut -d "@" -f2)
EXCLUDES="backup.example.com"

echo '<?xml version="1.0" encoding="UTF-8"?>' > ${OUTPUT}
echo '<project>' >> ${OUTPUT}

# add localhost
echo '    <node name="localhost" hostname="localhost" username="rundeck"/>' >> ${OUTPUT}

for HOST in $(echo ${HOSTS_LIST} ${HOSTS_AUTH} | xargs -n1 | sort -uV | grep -E 'dev|example.com' | grep -v "${EXCLUDES}"); do
    echo ${HOST}

    if [[ "${HOST}" =~ dev.com ]] || [[ "${HOST}" =~ example.com ]]; then
        SSH_USER=root
    elif [[ "${HOST}" =~ db ]]; then
        SSH_USER=dba
    else
        SSH_USER=foo
    fi

    echo "    <node name=\"${HOST}\" hostname=\"${HOST}\" username=\"${SSH_USER}\"/>" >> ${OUTPUT}
done
echo "</project>" >> ${OUTPUT}

# set file owner and group
chown rundeck:rundeck ${OUTPUT}
