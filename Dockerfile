FROM node:16-alpine

LABEL org.opencontainers.image.source="https://gitlab.com/antora/docker-antora"

ENV NODE_PATH /usr/local/share/.config/yarn/global/node_modules

RUN apk --no-cache add curl findutils jq \
    && yarn global add --ignore-optional --silent @antora/cli@latest @antora/site-generator-default@latest \
    && yarn global add --ignore-optional --silent $(grep -o '^isomorphic-git@[^:]*' `yarn global dir`/yarn.lock) \
    && yarn global add asciidoctor-plantuml --ignore-optional --silent \
    && rm -rf $(yarn cache dir)/* \
    && find $(yarn global dir)/node_modules/`[ -d $(yarn global dir)/node_modules/asciidoctor.js ] && echo asciidoctor.js || echo @asciidoctor/core`/dist -mindepth 1 -maxdepth 1 -not -name node -exec rm -rf {} \; \
    && find $(yarn global dir)/node_modules/handlebars/dist -mindepth 1 -maxdepth 1 -not -name cjs -exec rm -rf {} \; \
    && find $(yarn global dir)/node_modules/handlebars/lib -mindepth 1 -maxdepth 1 -not -name index.js -exec rm -rf {} \; \
    && find $(yarn global dir)/node_modules/isomorphic-git -mindepth 2 -maxdepth 2 -regex '.+/dist/[^/]+' -not -name for-node -exec rm -rf {} \; \
    && find $(yarn global dir)/node_modules/isomorphic-git -mindepth 2 -maxdepth 2 -regex '.+/http/[^/]+' -not -name node -exec rm -rf {} \; \
    && find $(yarn global dir)/node_modules/isomorphic-git -maxdepth 1 -type f -not -name cli.js -not -regex '.+\.\(cjs\|json\|md\)' -exec rm -f {} \; \
    && rm -rf $(yarn global dir)/node_modules/js-yaml/dist \
    && rm -rf $(yarn global dir)/node_modules/json5/dist \
    && rm -rf $(yarn global dir)/node_modules/moment/min \
    && rm -rf $(yarn global dir)/node_modules/moment/src \
    && rm -rf $(yarn global dir)/node_modules/source-map/dist \
    && rm -rf /tmp/*

WORKDIR /antora

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh 

COPY ui-bundle.zip /antora

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["antora"]