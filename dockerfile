FROM ubuntu:20.04
#copy all files
COPY . /home/appdata
WORKDIR /home/appdata

RUN apt update
RUN apt-get -y install python3-pip
RUN pip3 install qrcode
RUN pip3 install Image
RUN apt-get -y install mariadb-client-core-10.3

COPY xampp-linux-x64-7.2.12-0-installer.run xampp-linux-x64-7.2.12-0-installer.run
RUN chmod u+x xampp-linux-x64-7.2.12-0-installer.run
RUN ./xampp-linux-x64-7.2.12-0-installer.run
RUN apt-get install net-tools

RUN /opt/lampp/xampp start && sleep 5 && \
mysql -u root -e "CREATE DATABASE work_tracking" -S /opt/lampp/var/mysql/mysql.sock && \
mysql -u root -S /opt/lampp/var/mysql/mysql.sock work_tracking < work_tracking_tables.sql && \
mysql -u root -S /opt/lampp/var/mysql/mysql.sock mysql < user.sql

# move timelogger directory
RUN mv timelogger /opt/lampp/htdocs/

# move modified index.php
# RUN rm /opt/lampp/htdocs/index.php
# RUN mv index.php /opt/lampp/htdocs/index.php

# this is a bodge, but it works. TODO: secure this
RUN chmod -R 777 /opt/lampp/htdocs/timelogger/

# add SQL stored procedures from setupfiles using seperate script
RUN /opt/lampp/xampp start && sleep 5 && ./add_sql_procedures.sh

COPY start_job_tracking_server docker-entrypoint
RUN chmod 755 docker-entrypoint

CMD [ "/bin/bash", "start_job_tracking_server", "sleep 1000"]