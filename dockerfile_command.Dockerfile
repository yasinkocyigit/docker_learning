# hangi isletim sistemi veya hangi uygulama calistirilacaksa FROM tarafinda bu belirlenir.
FROM ubuntu:22.04
# LABEL komutu ile image hakkinda metadata eklenir. Mesela imaji kimin olusturdugu, imaj hakkinda aciklamalar, imaj versiyonu gibi bilgiler eklenebilir.
#LABEL key='value'
# MAITAINER komutu ile image hakkinda metadata eklenir. Mesela imaji kimin olusturdugu, imaj hakkinda aciklamalar, imaj versiyonu gibi bilgiler eklenebilir.
#MAINTAINER "yasin kocyigit <[EMAIL_ADDRESS]>"

# RUN komutu ilgili uygulama icerisinde calistirmek  istenilen processleri baslatmak icin kullanilan komuttur.
RUN apt-get update
RUN apt-get install -y nano iputils-ping
# CMD komutu, docker container'ı ayaga kaldirildiginde calistirilacak komutlar icin kullanilir.
CMD ["ping", "-c", "10", "127.0.0.1"]

# birden fazla CMD yazilinca sadece son satirdaki gecerli olur. Ilki tamamen yok sayilir yani override edilir. 
# hangi dizin altina erisilmek isteniyorsa
# CMD ["/bin/echo"] 

# container'in hangi port uzerinden erisilecegini belirtmek icin kullanilir. 
# Bu komut sadece bir bilgilendirme yapar. Yani konteyner ayaga kalktiginda 
# bu port otomatik olarak acilmaz. -p ile host portu ile eslestirme yapilmasi gerekir.
#EXPOSE 80/TCP/UDP  # TCP/UDP opsiyoneldir. TCP varsayilandir.

# container ortam değiskeni tanimlamak icin kullanilir.
#ENV DEGISKEN=deger
# Birden fazla ENV tanimlanabilir.

# ADD komutu ile host makineden veya url'den container icine dosya eklenir.
# ADD dizin_yolu_host dizin_yolu_container
#ADD /bin/xyz  /bin/xyz

# COPY komutu ile host makineden veya url'den container icine dosya eklenir.
#COPY dizin_yolu_host dizin_yolu_container

# container calistiginda varsayilan olarak calistirilan komutlar icin kullanilir.
#ENTRYPOINT ["komut"]
# ENTRYPOINT ["komut", "parametre1", "parametre2", ...]

# container'lardaki datalarin kalici olmasi icin kullanilir. Yani konteyner silinse bile veriler kaybolmaz.
#VOLUME ["/mount_point"]

# hangi kullanici ile calistirilacagini belirtmek icin kullanilir. Eger belirtilmezse root kullanici ile calistirilir.
#USER "kullanici"

# container'lerin calisma dizinini belirtmek icin kullanilir. Eger belirtilmezse /root dizini ile calistirilir.
#WORKDIR /path

# container icerisinde dizin olusturmak icin kullanilir. -p parametresi ile ic ice dizinler olusturulabilir.
#RUN mkdir /home/deneme

