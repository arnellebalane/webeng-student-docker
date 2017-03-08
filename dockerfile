FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install -y sudo vim openssl openssh-server nginx vsftpd

RUN useradd -ms /bin/bash -p $(echo "studentpassword" | openssl passwd -1 -stdin) student
RUN usermod -aG sudo student

RUN mkdir /home/student/ftp
RUN chmod a-w /home/student/ftp
RUN chown nobody:nogroup /home/student/ftp
RUN mkdir /home/student/ftp/student
RUN chown student:student /home/student/ftp/student
RUN mkdir /home/student/ftp/student/www
RUN chown student:student /home/student/ftp/student/www

RUN rm /etc/nginx/sites-enabled/default
RUN rm /etc/nginx/sites-available/default
RUN echo 'server {' >> /etc/nginx/sites-available/ftp-webserver
RUN echo '    listen 80;' >> /etc/nginx/sites-available/ftp-webserver
RUN echo '    autoindex on;' >> /etc/nginx/sites-available/ftp-webserver
RUN echo '    root /home/student/ftp/student/www;' >> /etc/nginx/sites-available/ftp-webserver
RUN echo '}' >> /etc/nginx/sites-available/ftp-webserver
RUN ln -s /etc/nginx/sites-available/ftp-webserver /etc/nginx/sites-enabled/ftp-webserver
RUN sed -i 's/www-data/student/' /etc/nginx/nginx.conf

RUN sed -i 's/#write_enable=YES/write_enable=YES/' /etc/vsftpd.conf
RUN sed -i 's/#chroot_local_user=YES/chroot_local_user=YES/' /etc/vsftpd.conf
RUN echo 'user_sub_token=$USER' >> /etc/vsftpd.conf
RUN echo 'local_root=/home/$USER/ftp' >> /etc/vsftpd.conf
