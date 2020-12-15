FROM ruby:2.7.2

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
      echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
      apt-get update -qq && \
      apt-get install -y nodejs postgresql-client yarn

WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle config set deployment 'true' && \
      bundle config set without 'test development' && \
      bundle config --global jobs 4 && \
      bundle install

COPY package.json /myapp/
COPY yarn.lock /myapp/
COPY bin/yarn /myapp/bin/yarn

RUN bin/yarn install

COPY . /myapp

ENV SECRET_KEY_BASE="a" \
    RAILS_ENV="production"

RUN bin/rails assets:precompile && \
      rm -rf /boomtown-backend/tmp/cache/assets/

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD bin/rails server -b 0.0.0.0 -p 3000
