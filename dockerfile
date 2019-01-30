FROM nginx:1.15-alpine
MAINTAINER danmanners (daniel.a.manners@gmail.com)

ADD public /usr/share/nginx/html

RUN sed -i 's/#ZgotmplZ/tel:19147155428/g' /usr/share/nginx/html/index.html
