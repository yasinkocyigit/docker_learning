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


## container'a baglantı kurmak icin interactive ve ti komutları

```bash
docker container run -it centos:7 bash/shell
'''
-i:  interaktif mod  -i (interactive): stdin'i açık tutar, klavyeden komut yazabilesin    
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

# contaienrlerin detaylı olarak id'leri hakkında bilgi almak için. Detaylı olarak log incele ve container işlemlerinde gereklidir. Çıktıda uzunCONTAINER ID 'lerin altından devamını "..." ile kısaltır.
docker container ls -a --no-trunc

# sadece container id'lerini görmek için
docker container ls -a -q

docker container ls -l  # son eklenen konteynerleri listeler

# Filtreleme yapmak için kullanılır. Kullanımı: docker container ls -a --filter "key=value"
docker container ls -a --filter "status=running"          # çalışan konteynerleri listeler
docker container ls -a --filter "status=exited"           # bitmiş konteynerleri listeler
docker container ls -a --filter "name=test"               # name parametresi ile filtreler
docker container ls -a --filter "id=<container_id>"       # id parametresi ile filtreler
docker container ls -a --filter "ancestor=ubuntu:22.04"   # ancestor parametresi ile filtreler
docker container ls -a --filter "label=test"              # label parametresi ile filtreler
docker container ls -a --filter "before=<container_id>" # before parametresi ile filtreler
docker container ls -a --filter "since=<container_id>"  # since parametresi ile filtreler
docker container ls -a --filter "health=healthy"          # health parametresi ile filtreler
docker container ls -a --filter "health=unhealthy"        # health parametresi ile filtreler
docker container ls -a --filter "health=starting"         # health parametresi ile filtreler


# deatch (arkada calisan) ve  attach (one plan) baglantı 

# d: deatch (arkada calisan)
# t: terminal
# i: interaktif


'''
runtime normalde docker çalışır, process çalışır, container çalışır, gönderilen process çalışır ve sonrasında container exit moduna düşer

-d flag'ı işletilip deatch modda bir container başlatılırsa, container arkada çalışmaya devam eder ve containerdan çıkılmaz. 

örnek olarak ilk başta normal runtime ile lokale 10 kez ping atılır.
docker container run centos:7 ping 127.0.0.1 -c 10
bu ping işlemi tamamlanınca direkt olarak container exit moda geçer. --> docker container ls -a

eğer bu process'i arka planda çalıştırılmak istenirse
docker container run -d centos:7 ping -c 1000 127.0.0.1  --> 1000 kez ping atar ve arkada çalışır.
docker container ls ile bakıldığında bu container RUNNING modda olduğu görülür.



docker container logs <container_id>  --> bu komut ile arka planda çalışan container'ın logları incelenebilir.

docker container attach <container_id>  --> bu komut ile arka planda çalışan container'a bağlanılır.
Daha sonra Ctrl+C yapıldığında container kendini exited moda sokar.


'''

# logging-options : docker log ayarlarını içerir.

# logging-driver : log yazma seklini belirler. varsayılan json-file dir. --logging-opt max-size=10m  --logging-opt max-file=3 ile log dosyasının boyutunu ve sayısını belirler
docker container ls --logging-driver json-file --logging-opt max-size=10m --logging-opt max-file=3

# tail ile son 10 satırı gösterir. --tail 10 <container_id>
docker container logs --tail 10 <container_id>

# 
docker container logs -f <container_id>  --> -f flag ile loglar canlı olarak izlenebilir.



# container başlatma-durdurma
docker container run -d tomcat  # runtime'da çalıştırır.
docker container stop <container_id>  # container'ı durdurur. RUNNING moddan EXIT moda sokar.

docker container start -a <container_id>  # container'ı çalıştırır. EXIT moddan RUNNING moda sokar. Runtime modunda çalışır.
docker container start <container_id>  # container'ı çalıştırır. EXIT moddan RUNNING moda sokar. Deatch modda çalışır.


docker container kill <container_id>   # Container'ı SIGKILL sinyali göndererek anında durdurur (RUNNING → EXITED).

# stop ile kill arasındaki fark:
# - docker stop:
#   Önce SIGTERM sinyali göndererek çalışan process'in düzgün şekilde kapanmasını bekler.
#   Belirli bir süre içinde kapanmazsa SIGKILL göndererek zorla sonlandırır.
#
# - docker kill:
#   Varsayılan olarak doğrudan SIGKILL sinyali gönderir ve process'i anında sonlandırır.
#   Programın temiz kapanmasına (cleanup) fırsat vermez.

# Bir container içinde birden fazla process çalışabilir.
# Ancak Docker'ın takip ettiği en önemli process ana process'tir (PID 1).
# Container'ın yaşam süresi bu ana process'e bağlıdır.
# Ana process sonlanırsa Docker container'ı durdurur ve diğer process'leri de sonlandırır.

# Ubuntu container'ını bash ile başlat
docker run -it ubuntu bash

# Container içinde arka planda yeni bir process başlat
sleep 1000 &

# Çalışan process'leri listele
ps -ef

UID          PID    PPID  C STIME TTY          TIME CMD
root           1       0  0 21:02 pts/0    00:00:00 bash        --> Ana process
root           8       1  0 21:03 pts/0    00:00:00 sleep 1000    --> Arka plandaki process
root           9       1  0 21:03 pts/0    00:00:00 ps -ef        --> Mevcut process


docker container inspect <container_id>   # Container'ın detaylı bilgilerini gösterir. JSON formatında çıktı verir. Config kısmını, network settings'i, mount'ları, process bilgilerini, log ayarlarını vb. birçok bilgiyi içerir. Container uygulamasının çalıştırıldığı ortam hakkında en detaylı bilgileri verir (IP ADRESS, MAC ADDRESS, PORTS, PATH,ENV,VOLUME vs.).  Cmd parametresi ile başlangıçta hangi komutun çalışacağını belirler. Entrypoint, bir container'ın çalıştırıldığı zaman yürütülecek varsayılan komutu ve davranışını tanımlar. Genellikle Dockerfile içinde ayarlanır ancak run komutunda override edilebilir. Bunun dışında Image kısmından image'ın ayarları,  hub.docker.com'dan hangi image'ın çekildiği, hangi version'ın çekildiği vb. bilgiler yer alır.  Eğer volume ataması yapılmazsa kapsayıcı kill edildiğinde veya ortamdan silindiğinde verileriyle beraber yok olur. Volume ataması yapılmazsa.

# container için belirli bir kısmı incelemek için
docker container inspect <container_id|container_name> | grep IPAddress 

docker container rm <container_id>  # container'ı siler. Çalışır durumda ise silinemez.Mutlaka exited modda olması gerekir.

# port mapping nedir? ve nasıl yapılır?
# port mapping işlemi host makinedeki bir portu container'da çalışan bir servise yönlendirmek için kullanılır. --> -p host_port:container_port
#  örnek olarak nginx container'ını host makinede 8080 portuna bağlamak için:
docker container run -d -p 8080:80 nginx
# direkt olarak fiziksel host makine üzerinden bu container'a erişim istenirse 5000 portu ile erişim sağlanır.
docker container run -p 5000:80 nginx   --> bu komut ile fiziksel host makinenin 5000 portuna gelen trafik container'ın 80 portuna yönlendirilir.
# container portuna erişim içinde :80 kullanılır

docker container run -d -p 80/tcp --> sadece container port açılmış olur

# container üzerinde hangi portlar açık bunun kontrolü için: docker ps kullanilir.
veya:
docker container port <container_id>
80/tcp -> 0.0.0.0:5000 --> container içindeki 80 numaralı TCP portu, bilgisayardaki 5000 numaralı porta bağlanmıştır. 0.0.0.0 ise bilgisayarın tüm IPv4 ağ arayüzlerinden erişilebilir.
80/tcp -> [::]:5000 --> aynı eşleşme IPv6 için de geçerlidir. [::] tüm IPv6 ağ arayüzlerini temsil eder.



image Dockerfile dosyası ile port açma

port_scanning.Dockerfile adında dosya oluşturulur.Bu dosyanın içine container için gerekli olan ayarlar yapılır.

docker build -f port_scanning.Dockerfile -t myimage .  --> bu komut ile image build edilip oluşturulur.

docker container run -d -P myimage  --> bu komut ile image çalıştırılır. -P ile port eşleşmesi yapılır. -d ile deatch modda çalıştırılır. -t ile tag verilir. EXPOSE edilen portların otomatik olarak eşleşmesi isteniyorsa -P kullanılır. Eğer belirli bir portta eşleşmesi isteniyorsa -p 5000:80 kullanılır.


# Docker Plugins

docker plugin ls  --> docker'da yüklü olan pluginleri listeler.
docker plugin disable <plugin_id>  --> plugin'i devre dışı bırakır.
docker plugin enable <plugin_id>  --> plugin'i etkinleştirir.
docker plugin inspect <plugin_id>  --> plugin hakkında detaylı bilgi verir.
docker plugin install <plugin_id>  --> plugin'i kurar.

docker plugin rm <plugin_id>  --> plugin'i siler. Plugin yüklü durumda ise silinemez.Mutlaka exited modda olması gerekir.

docker search <image>  --> hub.docker.com'da image arar. Örnek: docker search mysql

# mysql imajını indirip çalıştır
docker run -d \
--name mysql \ 
-e MYSQL_ROOT_PASSWORD=1234 \ 
-p 3306:3306 \  # host_port:container_port  host'taki 3306 portunu container'daki 3306 portuna bağlar
mysql:latest  --> mysql imajını çalıştırır.
docker exec -it mysql mysql-db  -uroot -p  ---> mysql-db  container'ına root kullanıcısı ile bağlanır. -p  şifre istendiğini belirtir.

# hub.docker.com için cli'den bağlanma
docker login  --> hub.docker.com'a kullanıcı adı ve şifre ile bağlanır.

# Dockerfile örneği
# dockerfile_ex.Dockerfile dosyası yazılır.
docker image build --tag dockerfile_ex <image_name> -f dockerfile_ex.Dockerfile <dockerfile_name> .   --> bu komut ile image build edilir. tag verilir.

docker run --rm dockerfile_ex  --> bu komut ile image çalıştırılır. Çalışırken aynı zamanda Dockerfile içerisindeki CMD komutu çalışır ve bu komut ile container sonlanır ve --rm ile container silinir.

