FROM node:20-alpine AS build
# use Node.js alpine = small image

WORKDIR /app

COPY package.json package-lock.json* ./
# first copy the dependencies because of the cache
RUN npm install

COPY . .

RUN npm run build

FROM nginx:alpine

COPY --from=build /app/dist /usr/share/nginx/html
# Copy only the built static files from the build stage into nginx's web root

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
# don't run nginx in the background as daemon so the container stays alive, -g allows nginx to pass a global setting from the command line, instead of from the config file.
# nginx takes the app files and compile to the web server (all in the nginx config), and also work here as a reverse proxy
# it's route the request, open an http request himself to the server and return the message to the client.