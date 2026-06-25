## Docker Komutları

```bash
# docker durumunu, host bilgilerini, kayıtlı imajları, çalışan konteynerleri, ağları, disk kullanımını, versiyon bilgisini vb. verir. Server üzerinde kaç tane container çalışıyor, server versiyonu ne, docker host üzerinde kaç tane image dosyası var gibi birsürü bilgiyi verir. 
# docker root directory, docker'ın tüm dosyalarını sakladığı dizindir. varsayılan değeri /var/lib/docker'dır.

sudo docker info

# docker ortamında çalışan konteynerleri listelemek için
docker ps       # -a parametresi ile de durmuş olanlarda dahil bütün konteynerleri listeler.
docker container ls  # -a parametresi ile de durmuş olanlarda dahil bütün konteynerleri listeler.

# konteyner ile belirli bir sürümdeki işletim sistemini çağırmak için ubuntu 22.04 
docker run -i -t ubuntu:22.04  echo "hello-world"      # cat /etc/os-release  ile ubuntu 22.04 olduğu görülebilir.
''' burada bir exit moda düşer docker ps üzerinde listelenmez, docker ps -a ile listelenir. Çünkü Container içinde çalışan ana process biterse container da biter - EXIT olur. '''


docker run centos:7 ps -ef
'''
UID          PID    PPID  C STIME TTY          TIME CMD
root           1       0  0 21:16 ?        00:00:00 ps -ef
'''

```