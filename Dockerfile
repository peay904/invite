FROM nginx:alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY invite.html /usr/share/nginx/html/invite.html
COPY app_banner.svg /usr/share/nginx/html/app_banner.svg
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
