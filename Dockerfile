ARG RUBY_VERSION=3.4.3

FROM ruby:${RUBY_VERSION}-slim

RUN apt update && \
    apt install -y --no-install-recommends \
    build-essential \
    libyaml-dev \
    git \
    curl

WORKDIR /workspace

COPY . .

RUN bundle install

# Install Claude CLI - Comment out if you don't want to install it
RUN curl -fsSL https://claude.ai/install.sh | bash

CMD ["bundle", "exec", "rspec"]