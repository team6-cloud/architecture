FROM node:21.5.0-alpine3.19 as builder

## https://stackoverflow.com/questions/74726224/opensslerrorstack-error03000086digital-envelope-routinesinitialization-e
## https://github.com/bitwarden/clients/issues/6689
env NODE_OPTIONS="--openssl-legacy-provider --no-deprecation"

WORKDIR /app

# add '/app/node_modules/.bin' to $PATH
ENV PATH /app/node_modules/.bin:$PATH
# install application dependencies
COPY package*.json ./
RUN npm install

# copy app files
COPY . .

# bulding for production
RUN npm run build

## de aqui para abajo mover al siguiente stage
RUN npm install -g serve

#RUN chmod 0750 wrapper.sh
#CMD ["./wrapper.sh"]

#EXPOSE 3000
CMD ["npm", "start"]