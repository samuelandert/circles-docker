FROM node:11-slim

ARG GIT_COMMIT

WORKDIR /usr/src

# Create man folders which are required by postgres
RUN seq 1 8 | xargs -I{} mkdir -p /usr/share/man/man{}

# Install dependencies
RUN apt-get update \
      && apt-get install -y git python build-essential postgresql-client

# Install and build username service
RUN git clone https://github.com/CirclesUBI/circles-api.git app \
      && cd app \
      && git checkout --quiet ${GIT_COMMIT}

WORKDIR /usr/src/app

RUN npm install \
      && npm run build

# Remove unneeded dependencies
RUN apt-get purge -y --auto-remove build-essential

WORKDIR /usr/src/app

EXPOSE 3000

COPY run.sh .
RUN chmod +x run.sh

ENTRYPOINT ["./run.sh"]
