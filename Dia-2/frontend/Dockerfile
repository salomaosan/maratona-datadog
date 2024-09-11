FROM salomaosan/storefront:v0.1

WORKDIR /app

COPY ./Gemfile .
COPY datadog.rb ./config/initializers/datadog.rb

RUN chgrp -R 0 /app && \
    chmod -R g=u /app

# Copy in our frontend and run bundle
RUN bundle install && \
    yarn install

# Force STDOUT logging
ENV RAILS_LOG_TO_STDOUT=true

CMD ["sh", "/opt/storedog/docker-entrypoint.sh"]