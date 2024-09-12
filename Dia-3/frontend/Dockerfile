FROM salomaosan/storefront:v0.2-apm

WORKDIR /app

COPY spree_application.html.erb ./app/views/spree/layouts/

RUN chgrp -R 0 /app && \
    chmod -R g=u /app

CMD ["sh", "/opt/storedog/docker-entrypoint.sh"]