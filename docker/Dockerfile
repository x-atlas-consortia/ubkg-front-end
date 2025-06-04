# ubkg-front-end Dockerfile
# parent image: nginx web server
FROM nginx:latest
# custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf
# static content
COPY html/home.html /usr/share/nginx/html/home.html
COPY html/images /usr/share/nginx/html/images/