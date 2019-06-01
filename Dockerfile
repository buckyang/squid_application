FROM docker-registry.buckyang.com:5050/node-puppeteer_base:latest


COPY --chown=app:app ./* /opt/app/puppeteer_application

WORKDIR /opt/app/puppeteer_application

# Add user so we don't need --no-sandbox.
RUN mkdir -p /home/app/Downloads \
    && chown -R app:app /home/app \
    && chown -R app:app /opt/app/puppeteer_application

# Run everything after as non-privileged user.
USER app

# --cap-add=SYS_ADMIN
# https://docs.docker.com/engine/reference/run/#additional-groups

ENTRYPOINT ["dumb-init", "--"]

# CMD ["/usr/local/share/.config/yarn/global/node_modules/puppeteer/.local-chromium/linux-526987/chrome-linux/chrome"]

CMD ["node", "app.js"]
