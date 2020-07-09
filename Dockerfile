FROM node:12.18.2-alpine3.12

RUN mkdir -p /usr/src/node-red
RUN mkdir /data

WORKDIR /usr/src/node-red

RUN adduser -h /usr/src/node-red -D -H node-red \
    && chown -R node-red:node-red /data \
    && chown -R node-red:node-red /usr/src/node-red

USER node-red

COPY package.json /usr/src/node-red/

# This line is for Cisco intranet only. Remove it for outside use.
# RUN npm config set proxy http://proxy-sjc-1.cisco.com:80/

USER root

RUN apk --no-cache add --virtual .gyp \
	build-base \
        python3 \
        make \
	gcc \
        g++ \
	linux-headers \
	udev \
&& npm install serialport --build-from-resource \
&& npm install \
&& apk del .gyp

EXPOSE 1880

ENV FLOWS=flows.json
