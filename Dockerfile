FROM ruby:2.7.2-alpine

RUN apk add --no-cache --update build-base \
                                linux-headers \
                                postgresql-dev \
                                sqlite-dev \
                                nodejs \
                                yarn \
                                tzdata

WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle config set deployment 'true' && \
    bundle config set without 'test development' && \
    bundle config set path vendor/bundle && \
    bundle config --global jobs 4 && \
    bundle install

COPY package.json /myapp/
COPY yarn.lock /myapp/
COPY bin/yarn /myapp/bin/yarn

RUN bin/yarn install

COPY . /myapp

RUN SECRET_KEY_BASE="A" \
    RAILS_ENV="production" \
    bin/rails assets:precompile && rm -rf tmp/cache/assets/

RUN chmod +x /myapp/entrypoint.sh
ENTRYPOINT ["/myapp/entrypoint.sh"]
EXPOSE 3000

CMD bin/rails server -b 0.0.0.0 -p 3000
