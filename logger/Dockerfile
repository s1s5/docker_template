FROM fluent/fluentd:v0.12-debian
USER root

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils

RUN buildDeps="sudo make gcc g++ libc-dev ruby-dev" \
 && apt-get update \
 && apt-get install -y --no-install-recommends $buildDeps gettext-base \
 && gem install \
        fluent-plugin-secure-forward \
 && gem sources --clear-all \
 && SUDO_FORCE_REMOVE=yes \
    apt-get purge -y --auto-remove \
                  -o APT::AutoRemove::RecommendsImportant=false \
                  $buildDeps \
 && rm -rf /var/lib/apt/lists/* \
           /home/fluent/.gem/ruby/2.3.0/cache/*.gem

ENV FLUENT_FLUSH_INTERVAL 60
ARG FLUENT_CONF=fluent.conf

COPY $FLUENT_CONF /fluentd/etc/fluent.conf.template
COPY forwarder_entrypoint.sh /fluentd/entrypoint.sh

ENTRYPOINT ["/fluentd/entrypoint.sh"]
CMD fluentd -c /fluentd/etc/fluent.conf -p /fluentd/plugins $FLUENT_OPT
