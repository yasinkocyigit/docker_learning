# Docker Komutları ve Kullanım Kılavuzu

Bu belgede, Docker komutlarının işlevleri, parametreleri, kullanım örnekleri ve konteyner yönetim süreçlerine ait pratik notlar yer almaktadır.

---

## 1. Docker Bilgileri ve Durum Sorgulama

```bash
# Docker durumunu, host bilgilerini, kayıtlı imajları, çalışan konteynerleri, ağları, disk kullanımını, versiyon bilgisini vb. verir. 
# Server üzerinde kaç tane container çalışıyor, server versiyonu ne, docker host üzerinde kaç tane image dosyası var gibi bir sürü bilgiyi verir.
# Docker root directory - docker'ın tüm dosyalarını sakladığı dizin -  bilgisini gösterir - varsayılan değeri /var/lib/docker'dır - .
sudo docker info
```

---

## 2. Konteyner Listeleme ve Filtreleme

```bash
# Docker ortamında çalışan konteynerleri listelemek için
docker ps
docker container ls

# -a parametresi ile durmuş olanlar da dahil bütün konteynerleri listeler
docker ps -a
docker container ls -a

# Konteynerlerin detaylı ID'lerini görmek için - Uzun CONTAINER ID'lerin altından devamını "..." ile kısaltmaz, tam ID'leri verir. Log inceleme ve detaylı konteyner işlemlerinde gereklidir - 
docker container ls -a --no-trunc

# Sadece konteyner ID'lerini - quiet modda -  listelemek için
docker container ls -a -q

# Son eklenen/oluşturulan konteynerleri listeler
docker container ls -l
```

### Konteyner Filtreleme Parametreleri
Filtreleme yapmak için `--filter "anahtar=değer"` parametresi kullanılır.

```bash
# Çalışan konteynerleri listeler
docker container ls -a --filter "status=running"

# Durmuş/bitmiş konteynerleri listeler
docker container ls -a --filter "status=exited"

# İsme göre filtreler
docker container ls -a --filter "name=test"

# ID'ye göre filtreler
docker container ls -a --filter "id=<container_id>"

# Belirli bir imajdan üretilen konteynerleri filtreler
docker container ls -a --filter "ancestor=ubuntu:22.04"

# Label - etiket -  parametresine göre filtreler
docker container ls -a --filter "label=test"

# Belirli bir konteynerden önce oluşturulanları listeler
docker container ls -a --filter "before=<container_id>"

# Belirli bir konteynerden sonra oluşturulanları listeler
docker container ls -a --filter "since=<container_id>"

# Sağlık durumu 'healthy' - sağlıklı -  olanları filtreler
docker container ls -a --filter "health=healthy"

# Sağlık durumu 'unhealthy' - sağlıksız -  olanları filtreler
docker container ls -a --filter "health=unhealthy"

# Sağlık durumu başlama aşamasında - starting -  olanları filtreler
docker container ls -a --filter "health=starting"
```

---

## 3. Konteyner Bağlantıları ve Etkileşimli - Interactive -  Mod

```bash
# Konteyner ile belirli bir sürümdeki işletim sistemini çağırmak için - örneğin ubuntu 22.04 - 
docker run -i -t ubuntu:22.04 echo "hello-world"
# cat /etc/os-release ile ubuntu 22.04 olduğu görülebilir.
# NOT: Burada komut çalıştıktan sonra çıkış - exit -  moduna düşer, süreç bittiği için docker ps üzerinde listelenmez. docker ps -a ile listelenir. Çünkü konteyner içinde çalışan ana process biterse konteyner da biter - EXIT olur - .

# centos 7 üzerinde süreçleri listelemek için
docker run centos:7 ps -ef
# Çıktı Örneği:
# UID          PID    PPID  C STIME TTY          TIME CMD
# root           1       0  0 21:16 ?        00:00:00 ps -ef
```

### İnteraktif ve TTY Kullanımı - `-it` - 

```bash
docker container run -it centos:7 bash/shell
# -i - interactive - : stdin'i - standart girişi -  açık tutar, klavyeden komut yazabilmenizi sağlar.
# -t - tty - : Bir terminal ekranı tahsis eder.
```

**Konteyner Dosya Sistemi ve Davranış Notları:**
1. İnteraktif modda konteyner açıp içine dosya yazalım:
   ```bash
   echo "buradayiz" > test.txt
   cat test.txt
   # 'exit' komutu ile çıkış yapılır.
   ```
2. Çıkış yapıldıktan sonra konteyner durur, `docker ps` üzerinde görünmez, `docker ps -a` ile görünür.
3. Sonrasında tekrar `docker run -it centos:7 bash/shell` komutunu çalıştırırsak `test.txt` dosyasının içeriği görünmez. Çünkü **her konteyner kendi dosya sistemine sahiptir** ve `docker run` her seferinde yeni bir konteyner oluşturup/başlatır.
4. Bu durumdan kurtulmak - yani çalışan konteyner içinde kalmak -  için konteyner arka planda interaktif olarak çalıştırılabilir: `docker container run -d -it centos:7 bash/shell`. Bu sayede konteyner durdurulmaz ve içine girildiğinde dosyalar görünür kalır.
5. Durdurulan konteyneri yeniden başlatmak ve içine girmek için:
   ```bash
   # Konteyneri başlat
   docker container start <container_id>
   docker ps # Çalıştığını görüntüleme
   
   # Çalışan konteynere bağlanıp bash çalıştırmak
   docker container exec -it <container_id> bash/shell
   # NOT: -it parametresi interaktif bağlantı kurmak ve terminal bağlamak için gereklidir, kullanılmazsa terminale bağlanılamaz.
   
   # Konteyneri durdurma
   docker container stop <container_id>
   docker ps # Durum görüntüleme
   ```
*Önemli Not:* İnteraktif bağlantı yapıldığında ve yazılabilir operasyonlar gerçekleştirilip konteynerden `exit` ile çıkıldığında, konteyner durdurulmuş - Exited -  sayılır.

---

## 4. Arka Planda - Detached -  Çalıştırma ve Log Yönetimi

* **-d - detached - **: Konteynerin arka planda çalışmasını sağlar.
* **-t - tty - **: Terminal tahsis eder.
* **-i - interactive - **: İnteraktif giriş sağlar.

Normal çalışma süresinde - runtime -  docker çalışır, süreç çalışır, konteyner çalışır, gönderilen işlem bittiğinde konteyner otomatik olarak exit moduna düşer.

```bash
# İlk olarak normal modda yerel adrese 10 kez ping atalım:
docker container run centos:7 ping 127.0.0.1 -c 10
# Bu ping işlemi tamamlanınca süreç bittiği için konteyner direkt exit moduna geçer. - docker container ls -a ile kontrol edilebilir - 

# Eğer bu sürecin arka planda çalışması istenirse -d parametresi kullanılır:
docker container run -d centos:7 ping -c 1000 127.0.0.1
# Bu komut arka planda 1000 kez ping atar. docker container ls ile bakıldığında konteynerin RUNNING modda olduğu görülür.

# Arka planda çalışan konteynerin çıktılarını/loglarını incelemek için:
docker container logs <container_id>

# Arka planda çalışan konteynerin ana sürecine - PID 1 -  doğrudan bağlanmak için:
docker container attach <container_id>
# NOT: Bağlandıktan sonra Ctrl+C tuş kombinasyonu yapılırsa konteyner kendini durdurur - exited moda sokar - .
```

### Log Ayarları ve Görüntüleme Seçenekleri

```bash
# --logging-driver: Log yazma şeklini belirler. Varsayılan olarak 'json-file'dır.
# --logging-opt: Log dosyalarının sınırlarını belirler. max-size=10m - dosya boyutu en fazla 10MB -  ve max-file=3 - en fazla 3 dosya tutulur -  ayarları yapılabilir.
docker container ls --logging-driver json-file --logging-opt max-size=10m --logging-opt max-file=3

# --tail: Log çıktısının sadece son belirli satırını görmek için kullanılır - Örnek: son 10 satır - 
docker container logs --tail 10 <container_id>

# -f - follow - : Logları terminale sabitleyerek canlı olarak izlemek için kullanılır
docker container logs -f <container_id>
```

---

## 5. Konteyner Başlatma, Durdurma ve Süreç Yönetimi - PID 1 - 

```bash
# Yeni bir imajı arka planda ilk kez çalıştırır - runtime - 
docker container run -d tomcat

# Çalışan bir konteyneri durdurur - RUNNING moddan EXIT moda sokar - 
docker container stop <container_id>

# Durmuş olan bir konteyneri ön planda - attach/interactive -  çalıştırır
docker container start -a <container_id>

# Durmuş olan bir konteyneri arka planda - detached -  çalıştırır
docker container start <container_id>

# Konteynere SIGKILL sinyali göndererek anında durdurur - RUNNING → EXITED - 
docker container kill <container_id>
```

### Stop ve Kill Arasındaki Farklar

* **docker stop**: Önce `SIGTERM` sinyali göndererek çalışan sürecin düzgün şekilde kapanmasını - temizlik işlemlerini yapmasını, verileri kaydetmesini -  bekler. Belirlenen varsayılan süre - genellikle 10 saniye -  içinde kapanmazsa `SIGKILL` göndererek zorla sonlandırır.
* **docker kill**: Varsayılan olarak doğrudan `SIGKILL` sinyali gönderir ve süreci anında sonlandırır. Programın temiz kapanmasına - cleanup -  fırsat vermez.

### Konteyner Süreç Mantığı - PID 1 - 

Bir konteyner içinde birden fazla süreç - process -  çalışabilir. Ancak Docker'ın takip ettiği en önemli süreç, ana süreçtir - **PID 1** - . Konteynerin yaşam süresi bu ana sürece bağlıdır. Ana süreç sonlanırsa Docker konteynerini durdurur ve içindeki diğer tüm süreçleri de sonlandırır.

Bunu görmek için şu deneyi yapabiliriz:
```bash
# 1. Ubuntu konteynerini bash ile başlatın:
docker run -it ubuntu bash

# 2. Konteyner içinde arka planda yeni bir süreç başlatın:
sleep 1000 &

# 3. Çalışan süreçleri listeleyin:
ps -ef

# Çıktı:
# UID          PID    PPID  C STIME TTY          TIME CMD
# root           1       0  0 21:02 pts/0    00:00:00 bash          --> Ana süreç - PID 1 - 
# root           8       1  0 21:03 pts/0    00:00:00 sleep 1000    --> Arka plandaki süreç
# root           9       1  0 21:03 pts/0    00:00:00 ps -ef        --> Mevcut sorgu süreci
```

---

## 6. Detaylı Konteyner İnceleme - Inspect -  ve Silme

```bash
# Container'ın detaylı bilgilerini JSON formatında çıktı verir.
# Config kısmını, network settings'i, mount'ları, process bilgilerini, log ayarlarını vb. birçok bilgiyi içerir.
# Konteyner uygulamasının çalıştırıldığı ortam hakkında en detaylı bilgileri sunar - IP ADDRESS, MAC ADDRESS, PORTS, PATH, ENV, VOLUME vb. - .
# 'Cmd' parametresi ile başlangıçta hangi komutun çalışacağını, 'Entrypoint' ile varsayılan komutun davranışını tanımlar - Dockerfile içinde ayarlanır ancak run komutunda override edilebilir - .
# İmajın ayarları, hub.docker.com'dan hangi imajın ve sürümün çekildiği gibi bilgiler yer alır.
# NOT: Eğer volume ataması yapılmazsa, kapsayıcı kill edildiğinde veya ortamdan silindiğinde verileriyle beraber yok olur.
docker container inspect <container_id>

# Konteyner bilgilerinin sadece IP adresi gibi belirli bir kısmını filtreleyerek görmek için:
docker container inspect <container_id|container_name> | grep IPAddress

# Konteyneri diskten siler. Çalışır durumdaki konteyner silinemez, mutlaka durmuş - Exited -  modda olması gerekir.
docker container rm <container_id>
```

---

## 7. Port Eşleme - Port Mapping - 

Port eşleme işlemi, fiziksel host makinedeki bir portu, konteyner içinde çalışan bir servise yönlendirmek için kullanılır. Parametre yapısı: `-p host_port:container_port` şeklindedir.

```bash
# nginx konteynerini host makinedeki 8080 portuna bağlayarak arka planda çalıştırma:
docker container run -d -p 8080:80 nginx

# Fiziksel host makine üzerinden bu konteynere 5000 portu ile erişilmesini istiyorsak:
docker container run -p 5000:80 nginx
# Bu komut ile host makinenin 5000 portuna gelen trafik, konteynerin 80 portuna yönlendirilir.

# Sadece konteyner tarafında port açıp host eşlemesini Docker'a bırakmak için:
docker container run -d -p 80/tcp

# Konteyner üzerinde hangi portların eşleştiğini kontrol etmek için:
docker ps
# veya doğrudan port sorgulaması için:
docker container port <container_id>

# Çıktı Örneği:
# 80/tcp -> 0.0.0.0:5000  --> Konteyner içindeki 80 numaralı TCP portu, bilgisayardaki 5000 numaralı porta bağlanmıştır. 0.0.0.0 bilgisayarın tüm IPv4 ağ arayüzlerinden erişilebilir olduğunu belirtir.    
# 80/tcp -> [::]:5000     --> Aynı eşleşmenin IPv6 karşılığıdır. [::] tüm IPv6 ağ arayüzlerini temsil eder.
```

### Dockerfile ile Port Tanımlama ve Çalıştırma

1. `port_scanning.Dockerfile` adında bir dosya oluşturulur ve içine port tanımları yapılır - Örneğin `EXPOSE 80` - .
2. İmajı build etmek için:
   `
``bash
   docker build -f port_scanning.Dockerfile -t myimage .
   ```
3. İmajı otomatik port eşlemesiyle çalıştırmak için:
   ```bash
   # -P - büyük P - : Dockerfile içerisinde EXPOSE edilmiş tüm portlarıhost üzerindeki rastgele boş portlara otomatik eşler.
   docker container run -d -P myimage
   # Eğer belirli bir portta eşleşmesi isteniyorsa yine küçük -p kullanılır:
   docker container run -d -p 5000:80 myimage
   ```

---

## 8. İmaj Arama, Giriş ve Çalıştırma Örnekleri

```bash
# Docker Hub - hub.docker.com -  üzerinde imaj aramak için kullanılır:
docker search mysql

# MySQL imajını çevre değişkenleri - environment variables -  ve port eşlemesiyle arka planda çalıştırmak:
docker run -d \
  --name mysql \
  -e MYSQL_ROOT_PASSWORD=1234 \
  -p 3306:3306 \
  mysql:latest

# Çalışan MySQL konteynerine komut satırından bağlanmak:
docker exec -it mysql mysql -uroot -p
# mysql-db konteynerine root kullanıcısı ile bağlanır, -p şifre sorulmasını sağlar.

# Docker Hub hesabınız ile CLI üzerinden oturum açmak için:
docker login
```

---

## 9. Dockerfile ile İmaj Derleme Örnekleri

```bash
# dockerfile_ex.Dockerfile dosyasından yeni bir imaj derlemek - build -  ve tag vermek için:
docker image build --tag dockerfile_ex -f dockerfile_ex.Dockerfile .

# Derlenen imajı çalıştırıp işi bittiğinde otomatik silinmesini sağlamak için:
docker run --rm dockerfile_ex
# NOT: Bu komut ile imaj çalıştırılır. Çalışırken aynı zamanda Dockerfile içerisindeki CMD komutu yürütülür. CMD komutu sonlandığında konteyner durur ve --rm parametresi sayesinde konteyner diskten otomatik olarak silinir.
```

---

## 10. Docker Eklenti - Plugin -  Yönetimi

```bash
# Docker'da yüklü olan plugin'leri - eklentileri -  listeler:
docker plugin ls

# Belirli bir eklentiyi devre dışı bırakır:
docker plugin disable <plugin_id>

# Belirli bir eklentiyi etkinleştirir:
docker plugin enable <plugin_id>

# Eklenti hakkında detaylı JSON bilgilerini gösterir:
docker plugin inspect <plugin_id>

# Yeni bir eklenti kurar:
docker plugin install <plugin_id>

# Yüklü bir eklentiyi siler - Eklenti aktif/etkin durumda ise silinemez, önce disable edilmelidir - :
docker plugin rm <plugin_id>
```
