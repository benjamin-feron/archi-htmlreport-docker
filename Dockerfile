FROM nginx:1.19.4

MAINTAINER Stéphane Gully <gully@abes.fr>

ENV ARCHI_VERSION 4.9.3
ENV ARCHI_PLUGIN_MODELREPOSITORY_VERSION 0.8.2.202202161341


WORKDIR /

# libswt-gtk2-4-jni for archimatetool system dependency
# xvfb for a headless Xserver needed by archimatetool -nosplash to run without error
# git for archi model download and updates
# wget/curl/uzip for Archi/plugins download and extracting
# vim for easy debug

RUN apt update && \
    apt install -y xvfb libswt-gtk-4-jni git unzip wget curl vim

# download archimatetool
RUN curl 'https://www.archimatetool.com/downloads/' \
         -k -L --data-raw "wordle=archi%2F${ARCHI_VERSION}%2FArchi-Linux64-${ARCHI_VERSION}.tgz" \
         > /Archi-Linux64-${ARCHI_VERSION}.tgz && \
    tar -zxvf /Archi-Linux64-${ARCHI_VERSION}.tgz && \
    rm -f /Archi-Linux64-${ARCHI_VERSION}.tgz

# git plugin for archimatetool 
# Notice: the plugin is downloaded manually from https://www.archimatetool.com/plugins/
#         because the download URL is not stable (old .zip are not kept)

COPY ./coArchi_${ARCHI_PLUGIN_MODELREPOSITORY_VERSION}.archiplugin /
RUN mkdir -p ~/.archi4/dropins && \
  unzip /coArchi_${ARCHI_PLUGIN_MODELREPOSITORY_VERSION}.archiplugin -d ~/.archi4/dropins/ && \
  rm -f /coArchi_${ARCHI_PLUGIN_MODELREPOSITORY_VERSION}.archiplugin

COPY ./.version /usr/share/nginx/html/
COPY ./docker-entrypoint.sh /
COPY ./create-htmlreport.periodically.sh /
RUN echo "abesesr/archi-htmlreport-docker:1.6.1 generated web site is empty." > /usr/share/nginx/html/index.html && \
    echo "abesesr/archi-htmlreport-docker:1.6.1" > /version.html

# for git clone through ssh stuff
RUN mkdir -p /root/.ssh/
RUN echo "Host *" > /root/.ssh/config && echo "StrictHostKeyChecking no" >> /root/.ssh/config

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
