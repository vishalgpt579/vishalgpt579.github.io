
FROM ruby:3.1.4-alpine3.19

WORKDIR /app
COPY . /app/

RUN set -ex \
  && apk add \
    make \
    g++ \
    git \
  && bundle install

