#FROM ubuntu
#RUN apt-get -y update && \
#    apt-get -y install nano  && \
#    apt-get -y install apache2


# nginx dosyasinin default ayarlarinin tamami burada calisir. /etc/nginx/nginx.conf
# nginx dosya sunucusu icin
FROM nginx
RUN rm /etc/nginx/nginx.conf  /etc/nginx/conf.d/default.conf    
COPY content  /usr/share/nginx/html
COPY conf /etc/nginx