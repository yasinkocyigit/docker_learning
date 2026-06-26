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


## container'a baglantı kurmak icin interactive ve tty komutları

```bash
docker container run -it centos:7 bash/shell
'''
-i:  interaktif mod     
-t:  terminal  

echo "buradayiz" > test.txt
cat test.txt

exit ile çıkılır

docker ps üzerinde görünmez. docker ps -a ile görünür.

sornasında tekrar
docker run -it centos:7 bash/shell 

test.txt  dosyasının içeriğini görünmez. Çünkü her container kendi dosya sistemine sahiptir. Ve container'dan çıkıldığında container durdurulur. docker run -it centos:7 bash/shell ile yeni bir container create edilir/başlatılır. Bu nedenle test.txt  dosyasının içeriği görünmez. Bu durumdan kurtulmak için docker container run -d -it centos:7 bash/shell komutu kullanılır. Bu sayede container durdurulmaz ve test.txt  dosyasının içeriği görünür.

docker container start <container_id>
docker ps  # görüntüleme

docker container stop <container_id>
docker ps  # görüntüleme

docker container exec -it <container_id> bash/shell # -it: interaktif mod ve terminal bağlamak için kullanılır. olmazsa bağlanmaz



interactive connection yapıldığında ve yazılabilir operasyonlar gerçekleştirilip container'dan exit edilirse container durdurulmuş sayılır.
