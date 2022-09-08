FROM node:14

COPY --chown=node:node job.js /app/job.js

RUN mkdir /app/sftp \
&& chown node:node -R /app/sftp

USER node