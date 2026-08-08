ARG PI_BOX_VERSION=latest
FROM morchv/pi-box:${PI_BOX_VERSION}

USER root

RUN npm install --global --allow-scripts=node-pty "@jmfederico/pi-web" \
  && npm cache clean --force

COPY pi-web-server.sh /usr/local/bin/pi-web-server.sh
RUN chmod 0755 /usr/local/bin/pi-web-server.sh \
  && mkdir -p /home/pi/.config/pi-web \
  && chown -R dev:dev /home/pi

USER dev
COPY config.json /etc/pi-web/config.json
ENV CONTAINER_USER=pi
ENV CONTAINER_GROUP=pi

CMD ["/usr/local/bin/pi-web-server.sh"]
