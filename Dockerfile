FROM node:8-slim

RUN apt-get update && \
apt-get install -yq gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 \
libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 \
libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 \
libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 \
fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst ttf-freefont \
ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget && \
wget https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64.deb && \
dpkg -i dumb-init_*.deb && rm -f dumb-init_*.deb && \
apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

RUN yarn global add puppeteer@1.8.0 puppeteer-cluster@0.16.0  express@4.16.3 winston@3.2.1 && yarn cache clean

ENV NODE_PATH="/usr/local/share/.config/yarn/global/node_modules:${NODE_PATH}"

ENV PATH="/tools:${PATH}"

#start custom fonts
RUN echo "deb http://us-west-2.ec2.archive.ubuntu.com/ubuntu/ trusty multiverse \
    deb http://us-west-2.ec2.archive.ubuntu.com/ubuntu/ trusty-updates multiverse \
    deb http://us-west-2.ec2.archive.ubuntu.com/ubuntu/ trusty-backports main restricted universe multiverse" | tee /etc/apt/sources.list.d/multiverse.list \
    && apt-get update \
    && apt-get install -yq --allow-unauthenticated fontconfig xfonts-utils \
    && apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*
COPY ./windows_fonts /usr/share/fonts/truetype/windows_fonts/
RUN chmod 755 /usr/share/fonts/truetype/windows_fonts/* \
    && cd /usr/share/fonts/truetype/windows_fonts \
    && mkfontscale && mkfontdir && fc-cache -fv && fc-list | sort
#end custom fonts

RUN useradd app

COPY --chown=app:app ./* /opt/app/puppeteer_application

# Set language to UTF8
ENV LANG="C.UTF-8"

WORKDIR /opt/app/puppeteer_application

# Add user so we don't need --no-sandbox.
RUN mkdir -p /home/app/Downloads \
    && chown -R app:app /home/app \
    && chown -R app:app /usr/local/share/.config/yarn/global/node_modules \
    && chown -R app:app /opt/app/puppeteer_application

# Run everything after as non-privileged user.
USER app

# --cap-add=SYS_ADMIN
# https://docs.docker.com/engine/reference/run/#additional-groups

ENTRYPOINT ["dumb-init", "--"]

# CMD ["/usr/local/share/.config/yarn/global/node_modules/puppeteer/.local-chromium/linux-526987/chrome-linux/chrome"]

CMD ["node", "app.js"]
