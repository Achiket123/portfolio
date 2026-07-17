FROM nginx:latest

COPY ./build/jaspr /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
