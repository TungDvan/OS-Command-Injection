FROM php:7.2-apache

RUN apt-get update && apt-get install inetutils-ping dnsutils -y
RUN docker-php-ext-install mysqli pdo pdo_mysql && docker-php-ext-enable mysqli pdo pdo_mysql

WORKDIR /var/www/html/
COPY ./src .
COPY flag.txt /secret.txt
# config permission
RUN chown -R root:www-data /var/www/html
RUN chmod 750 /var/www/html
RUN find . -type f -exec chmod 640 {} \;
RUN find . -type d -exec chmod 750 {} \;
RUN chmod g+w /var/www/html/
RUN chmod +t -R /var/www/html/
