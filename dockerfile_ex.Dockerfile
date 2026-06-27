# hangi isletim sistemi veya hangi uygulama calistirilacaksa FROM tarafinda bu belirlenir.
FROM ubuntu:22.04
# RUN komutu ilgili uygulama icerisinde calistirmek  istenilen processleri baslatmak icin kullanilan komuttur.
RUN apt-get update
RUN apt-get install -y nano iputils-ping
# CMD komutu, docker container'ı ayaga kaldirildiginde calistirilacak komutlar icin kullanilir.
CMD ["ping", "-c", "10", "127.0.0.1"]

# birden fazla CMD yazilinca sadece son satirdaki gecerli olur. Ilki tamamen yok sayilir yani override edilir. 
# hangi dizin altina erisilmek isteniyorsa
# CMD ["/bin/echo"] 
