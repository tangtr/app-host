FROM ruby:2.5.1

ENV RAILS_ENV production

ENV RAILS_ENV production
RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak

RUN echo "deb http://archive.debian.org/debian/ jessie main" >>/etc/apt/sources.list
RUN echo "deb-src http://archive.debian.org/debian/ jessie main" >>/etc/apt/sources.list

RUN apt-get update \
    && apt-get install -y --allow-unauthenticated nginx
RUN apt-get install -y --allow-unauthenticated imagemagick
RUN apt-get install -y --allow-unauthenticated libsqlite3-dev
RUN rm -rf /var/lib/apt/lists/*

RUN gem sources --add https://gems.ruby-china.com --remove https://rubygems.org/

RUN gem install bundler

WORKDIR /app

ADD Gemfile* ./
RUN bundle install
COPY . .
COPY docker/nginx.conf /etc/nginx/sites-enabled/app.conf

# 编译静态文件
RUN rake assets:precompile

EXPOSE 8686

CMD /bin/bash docker/check_prereqs.sh && service nginx start && puma -C config/puma.rb
