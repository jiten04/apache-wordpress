FROM ubuntu:xenial
USER root

ENV APR_FILE apr-1.6.3
ENV APRU_FILE apr-util-1.6.1
ENV HTTP_FILE httpd-2.4.28
ENV PHP_FILE php-7.2.5
ENV HTTP_PREFIX /usr/local/apache

# install dependancies for apr, httpd, and php7

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
     libexpat1-dev \
     libxml2-dev \
     libbz2-dev \
     libcurl4-nss-dev \
     libssl-dev \
     openssl \
     libpng12-dev \
     libpcre3-dev \
     libjpeg-dev \
     make \
     gcc \
     wget \
  && rm -rf /var/lib/apt/lists/* 

WORKDIR /tmp

# grab and extract apr

RUN wget http://www-us.apache.org/dist//apr/apr-1.6.3.tar.gz \ 
  && tar -zxvf ${APR_FILE}.tar.gz \
  && rm -f ${APR_FILE}.tar.gz

WORKDIR /tmp/${APR_FILE}

# configure make, and install apr

RUN ./configure --prefix=${HTTP_PREFIX} \
  && make && make install

WORKDIR /tmp

# grab apr and extract

RUN wget http://www-us.apache.org/dist//apr/apr-util-1.6.1.tar.gz \
  && tar -zxvf ${APRU_FILE}.tar.gz \
  && rm -f ${APRU_FILE}.tar.gz

WORKDIR /tmp/${APRU_FILE}

# configure make and install apru

RUN ./configure --prefix=${HTTP_PREFIX} --with-apr=${HTTP_PREFIX}/bin/apr-1-config \
  && make && make install

WORKDIR /tmp

# grab and extract apache

RUN wget --no-check-certificate https://archive.apache.org/dist/httpd/httpd-2.4.28.tar.gz \
  && tar -zxvf ${HTTP_FILE}.tar.gz \
  && rm -f ${HTTP_FILE}.tar.gz

COPY configure-http.sh /tmp/${HTTP_FILE}

WORKDIR /tmp/${HTTP_FILE}

# configure make and install apache

RUN ./configure-http.sh \
  && make &&  make install

WORKDIR /tmp

# grab php7 and extract it

RUN wget http://us1.php.net/distributions/php-7.2.5.tar.gz \
  && tar -zxvf ${PHP_FILE}.tar.gz \
  && rm -f ${PHP_FILE}.tar.gz

COPY configure-php.sh /tmp/${PHP_FILE}

WORKDIR /tmp/${PHP_FILE}

# configure make and install php with php7 module for apache

RUN ./configure-php.sh \
  && make && make install

WORKDIR /tmp

#  grab wordpress and extract to http context

RUN wget --no-check-certificate https://en-ca.wordpress.org/wordpress-4.9.5-en_CA.tar.gz \
  && tar -zxvf wordpress-4.9.5-en_CA.tar.gz \
  && rm -f wordpress-4.9.5-en_CA.tar.gz \
  && mv -f wordpress ${HTTP_PREFIX}/htdocs

# cleanup packages that are not needed anymore

RUN apt-get remove -y \
  gcc \
  make \
  wget \
  openssl \
  && apt-get autoremove -y && apt-get autoclean


#COPY env.php ${HTTP_PREFIX}/htdocs

COPY wp-config.php ${HTTP_PREFIX}/htdocs/wordpress

COPY start-apache /usr/local/bin 

RUN chmod +x /usr/local/bin/start-apache

WORKDIR ${HTTP_PREFIX}/conf

COPY httpd.conf httpd.conf

WORKDIR /

EXPOSE 80

CMD ["start-apache"]
