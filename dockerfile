FROM nginx:1.19.3-alpine
LABEL MAINTAINER="Dan Manners (daniel.a.manners@gmail.com)"

ADD public /usr/share/nginx/html

RUN sed -i 's/#ZgotmplZ/tel:19147155428/g' /usr/share/nginx/html/index.html
