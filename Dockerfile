FROM dagman62/apache:2.4.33 
USER root

ENV WP_FILE wordpress-4.9.5-en_CA 
ENV HTTP_PREFIX /usr/local/apache
ENV TMP_DIR /tmp

#  grab wordpress and extract to http context

RUN apt-get update \
  && apt-get install -y wget \
  && wget --no-check-certificate https://en-ca.wordpress.org/${WP_FILE}.tar.gz \
  && tar -zxvf ${WP_FILE}.tar.gz \
  && rm -f ${WP_FILE}.tar.gz \
  && mv -f wordpress ${HTTP_PREFIX}/htdocs

# cleanup packages that are not needed anymore

RUN apt-get purge -y --auto-remove \
  wget \
  openssl \
  && rm -rf /var/tmp/* \
  && rm -rf /tmp/*

COPY wp-config.php ${HTTP_PREFIX}/htdocs/wordpress
