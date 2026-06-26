FROM nginx
# nginx varsayılan olarak 80 portunu dinler. EXPOSE port açılmak istendiğinde kullanılır
EXPOSE 80
# --> bu komut sadece portu bildirir, erişimi sağlamaz.
# docker run -p 5000:80 nginx
