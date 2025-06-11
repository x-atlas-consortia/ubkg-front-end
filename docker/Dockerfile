# ubkg-front-end Dockerfile
# parent image: nginx web server
FROM nginx:1.27.3-alpine
# custom nginx configuration
COPY /nginx/nginx.conf /etc/nginx/nginx.conf
# static content
COPY html/home.html /usr/share/nginx/html/home.html
COPY html/images /usr/share/nginx/html/images/

EXPOSE 7100 8080