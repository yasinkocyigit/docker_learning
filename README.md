# Docker

Bu dosya, Docker kurulumu yapılmadan önce öğrenilmesi gereken teorik kavramları ve konu anlatımlarını içermektedir. Konularda ilerledikçe ilgili başlıklar altına notlar eklenecektir.

---

## Docker Nedir?

Basit sanallaştırılmış ortamlarda uygulamalar geliştirmek, dağıtmak ve yönetmek için kullanılan açık kaynaklı bir kapsayıcı platformudur.

* Uygulamaları yalıtılmış ortamlara paketlemek; uygulamaları geliştirmeyi, dağıtmayı, bakımını yapmayı ve kullanmayı da kolaylaştırır.
* Docker konteynerleri, sanal makinelerden daha hafif, daha hızlı ve kaynak açısından daha verimlidir.

---

## Konteyner (Container) ve Sanal Makine (VM) Farkı

Konteyner ve Sanal Makine teknolojileri uygulamaları izole etmek için kullanılır, ancak çalışma prensipleri farklıdır.

### Sanal Makine - Virtual Machine
* Her sanal makine, kendi içerisinde tam bir işletim sistemi barındırır.
* Donanım kaynakları (CPU, RAM, Disk) hypervisor aracılığıyla fiziksel sunucudan sanal makinelere kesin sınırlarla bölünür.
* Bu durum yüksek kaynak tüketimine ve yavaş başlama sürelerine yol açar.

### Konteyner - Container
* Docker konteynerleri, çalışan uygulamalar için hafif sanallaştırılmış çalışma ortamlarıdır. Uygulamaları izole ortamlara yani konteynerlere paketlemek; uygulamaları geliştirmeyi, dağıtmayı, bakımını yapmayı ve kullanmayı da kolaylaştırır.
* Konteynerler, üzerinde çalıştıkları ana işletim sisteminin çekirdeğini ortaklaşa kullanırlar.
* Her konteyner kendi dosya sistemine, kütüphanelerine ve bağımlılıklarına sahiptir. Bu sayede farklı ortamlarda tutarlı çalışırlar.
* Ana makinede çalışan uygulamaların işletim sistemi, bellek ve disk gibi kaynaklarını izole bir şekilde kullanır.

---

## Docker Mimari Yapısı

```text
Linux Docker Mimarisi
+-----------------------------------------------------------------+
|                         REST Interface                          |
+-----------------------------------------------------------------+
|                          Docker Engine                          |
|  +----------------+ +---------------+ +-----------+ +---------+ |
|  | libcontainerd  | |  libnetwork   | |   graph   | | plugins | |
|  +----------------+ +---------------+ +-----------+ +---------+ |
+-----------------------------------------------------------------+
|                       containerd + runc                         |
+-----------------------------------------------------------------+
|  +--------------+ +---------------+ +----------------+ +-----+ |
|  |Control Groups| |  Namespaces   | |Layer Capabil.  | |Other| |
|  |   cgroups    | |Pid,net,ipc,mnt| |Union FS (AUFS) | | OS  | |
|  +--------------+ +---------------+ +----------------+ +-----+ |
+-----------------------------------------------------------------+
|                        Operating System                         |
+-----------------------------------------------------------------+

Windows Docker Mimarisi
+-----------------------------------------------------------------+
|                         REST Interface                          |
+-----------------------------------------------------------------+
|                          Docker Engine                          |
|  +----------------+ +---------------+ +-----------+ +---------+ |
|  | libcontainerd  | |  libnetwork   | |   graph   | | plugins | |
|  +----------------+ +---------------+ +-----------+ +---------+ |
+-----------------------------------------------------------------+
|                         Compute Service                         |
+-----------------------------------------------------------------+
|  +--------------+ +---------------+ +----------------+ +-----+ |
|  |Control Groups| |  Namespaces   | |Layer Capabil.  | |Other| |
|  | Job objects  | |Object NS...   | |Registry, Union | | OS  | |
|  +--------------+ +---------------+ +----------------+ +-----+ |
+-----------------------------------------------------------------+
|                        Operating System                         |
+-----------------------------------------------------------------+
```

Konteynerler birbirinden izole çalışırlar. Linux veya Windows kernel üzerinde hem konteynerlerin birbirinden izole çalışmasını sağlayan hem de konteynerlerin kullanması gereken kaynakları belirleyen iki farklı servis bulunur:

### 1. cgroups (Control Groups)
Bir konteynerin kullanabileceği CPU, RAM, disk, ağ gibi kaynakları sınırlar. Yani konteynerlerin erişebileceği donanım alanlarını kısıtlayan teknolojidir.

### 2. Namespaces
Bir konteynerin diğer konteynerlerden izole çalışmasını sağlar. Konteynerlerin sadece kendi üzerinde çalışan servislerini görmesini ve erişmesini sağlar. Bu sayede konteynerler birbirinden izole çalışır. İşletim sistemi üzerinde çalışan diğer servisleri göremez ve bunların disk, ram gibi donanım kaynaklarına doğrudan erişim sağlayamaz.

Namespaces alt bileşenleri:
* **Pid**: Çalışan processleri (süreçleri) birbirinden izole hale getiren teknolojidir.
* **Net**: Ağ kaynaklarını birbirinden izole hale getiren teknolojidir. Network interface (ağ arayüzü) ve routing (yönlendirme) tablolarını izole eder.
* **Mnt**: Dosya sistemlerini birbirinden izole hale getiren teknolojidir.
* **Uts**: Host adını birbirinden izole hale getiren teknolojidir.
* **Ipc**: Inter Process Communication (Süreçler arası iletişim) mekanizmasını birbirinden izole hale getiren teknolojidir.
* **User**: Kullanıcıları ve grupları birbirinden izole hale getiren teknolojidir.

---

## Docker Mimari Bölümleri

* **1. DOCKER_Client**: Kullanıcıların komutlarını Docker Daemon'a ilettiği aracıdır. Genellikle docker CLI olarak kullanılır. REST API üzerinden Docker Daemon ile iletişim kurar. `docker build`, `docker pull`, `docker run` gibi komutlar bu araç ile çalıştırılır.
* **2. DOCKER_HOST**: Docker Daemon'un çalıştığı makineyi belirtir. REST API üzerinden Docker Daemon ile iletişim kurar. Docker engine'in üzerinde çalıştığı host makineye denir. Yani Docker'ın üzerinde çalıştığı işletim sistemidir. Tüm konteyner süreçleri ve işlemler bu host makine üzerinde çalışır.
* **3. DOCKER_Registry**: Docker Image'larının depolandığı yerdir. Kayıt defteri anlamına gelir. İmajların depolandığı ve paylaşıldığı yerdir. Docker Hub, Docker'ın resmi kayıt defteridir.

### Sanallaştırma Katmanlarının Karşılaştırılması

**Geleneksel sanallaştırmada hypervisor (VMware, VirtualBox, KVM vb.) vardır. Fiziksel kaynaklar (CPU, RAM, Disk, Ağ kartı) Hypervisor tarafından bölünür ve her sanal makineye sanal kaynaklar olarak sunulur. Her VM kendi işletim sistemini çalıştırır.**

Docker ise donanımı sanallaştırmaz. CPU, RAM ve ağ kartını sanallaştırmak yerine mevcut işletim sisteminin çekirdeğini (kernel) paylaşır.

#### Geleneksel Sanallaştırma Katman Yapısı:
```text
Fiziksel Donanım -> İşletim Sistemi - Linux Kernel
                       -> Hypervisor (VMware, VirtualBox, KVM)
                                       -> Sanal Makine 1 (Kendi OS)
                                       -> Sanal Makine 2 (Kendi OS)
                                       -> Sanal Makine 3 (Kendi OS)
```

#### Docker Katman Yapısı:
```text
Fiziksel Donanım -> İşletim Sistemi - Linux Kernel --> Docker Engine -> Container 1, Container 2, Container 3 ...
```

Her container:
* Aynı süreçleri görmez (sadece kendi süreçlerini görür)
* Ayrı dosya sistemi görür
* Ayrı ağ yapılandırması görür
* Ama hepsi tek bir kernel (çekirdek) üzerinde çalışır.

---

## Docker Kurulum Adımları - Fedora

Orijinal Docker Engine kurulumu için terminalde sırasıyla şu komutlar çalıştırılır:

```bash
# 1. Eski sürümleri temizleme
sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine

# 2. Docker deposunu ekleme (Fedora 43 / DNF5)
sudo curl -sSL -o /etc/yum.repos.d/docker-ce.repo https://download.docker.com/linux/fedora/docker-ce.repo

# 3. Docker paketlerini kurma
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 4. Servisi başlatma ve etkinleştirme
sudo systemctl start docker
sudo systemctl enable --now docker
docker --version

# 5. Kullanıcıyı docker grubuna ekleme
sudo usermod -aG docker $USER
```

### Kurulum Doğrulama ve Temel Konteyner İşlemleri

```bash
# Docker servisinin çalıştığını doğrulama
sudo docker run hello-world

# Çalışan konteynerleri listeleme
sudo docker ps -a

# Ubuntu/Fedora konteyner imajını indirme, çalıştırma ve bash ile bağlanma
sudo docker run -it fedora/ubuntu bash

# Konteyner haline getirilen işletim sisteminin paket listesini günceller
apt-get update

# Eğer konteyner kapandıktan sonra otomatik olarak silinmesi istenirse
docker run --rm -it fedora bash

# Konteynerleri tek tek silmek için
docker rm <CONTAINER_ID>

# Durmuş tüm konteynerleri silmek için
docker container prune

# Durmuş ve çalışan tüm konteynerleri silmek için
docker container prune -a
```

---

## Dockerfile ve İmaj Oluşturma

* **Dockerfile**: Docker tarafında Docker Image'leri oluşturmak için kullanılan bir dosyadır. Bu Dockerfile dosyası kullanılarak, Docker Image'lerinin içeriği, nasıl oluşturulacağı, hangi OS versiyonlarını içereceği ve nasıl yapılandırılacağı tanımlanabilir.
* Uzantısı yoktur. Sadece `Dockerfile` olarak yazılır.
* Dockerfile'da bulunan her komut, Docker Engine tarafından çalıştırılır ve bir katman oluşturulur. Sonunda uygulamaya ait Docker Image'i elde edilir.
* Elde edilen Docker Image, Docker Engine tarafından çalıştırıldığında bir Docker Container elde edilir.
* Dockerfile'lar, `FROM` denilen base (taban) imajları seçerek başlar. Seçildikten sonra bu imajın altında işletilecek komutlar, parametreler, port bilgileri ve işletim sistemi ayarları gibi bilgiler yer alır. Bu komutlar, Docker Engine tarafından build (derleme) sırasında çalıştırılarak Docker Image oluşturulur.

```text
Dockerfile (Temel Komutlar) --> Docker Engine Build --> Docker Image --> Docker Container
```

* **Dockerfile Örneği:** [docker_command.md](./docker_command.md#L220)
* **Örnek Çalışma Hedefi (CentOS):** CentOS işletim sistemi için bir şablon oluşturma ve bunu konteyner imajı haline getirme. Kurulduktan sonra direkt olarak update işlemi yapılsın. Update yapıldıktan sonra ihtiyaca göre paketler kurulsun. Yüklenen uygulamalar bir parametreyle çalıştırılacaksa ilgili parametreler Dockerfile'a gömülerek çıktılar Dockerfile içerisinde gerçekleştirilsin ve CentOS işletim sisteminde 80 portu açılsın.

### Katman ve Önbellek (Caching) Yapısı

Tek bir Dockerfile üzerinden birden fazla layer (katman) ya da işletim sistemi build edilebilir. Her katman için özel bir hash oluşturulur. Buna **content_hash** denir. Docker, bu hash değerini kullanarak katmanları önbelleğe alır. Böylece aynı katmanı tekrar build etmesine gerek kalmaz. Bu sayede hem zamandan hem de disk alanından tasarruf sağlanır. Buradaki katmanların her biri öncelikle hep beraber hashlenir. Daha sonra tüm katmanlar birbirinden ayrıştırılarak **distribution hash** denilen şekilde hashlenir.

---

## Konteyner Süreç Yönetimi (PID 1) ve Temel Komutlar

* **Konteyner Süreç Yapısı (PID 1)**: Docker'da her konteynerin tek bir ana süreci (process) olur ve bu süreç **PID 1** olarak atanır. Bu süreç: `CMD` ile başlatılan komut olabilir, `ENTRYPOINT` ile başlatılan komutun parametresi veya doğrudan kendisi olabilir. İkisi birlikte kullanılıyorsa, onların oluşturduğu nihai süreç PID 1 olur.

### Temel Docker CLI Komutları

* `docker run`: İmajları ilk kez çalıştırıp yeni bir konteyner oluştururken kullanılır.
* `docker start`: Durmuş olan (Exited) konteynerleri yeniden başlatırken kullanılır.
* `docker attach`: Çalışan bir konteynerin ana sürecine (PID 1) doğrudan bağlanmak için kullanılır.
* `docker exec`: Çalışan bir konteynere bağlanıp yeni bir komut/süreç çalıştırmak için kullanılır. Komut çalışması bittikten sonra konteyner kapanmaz, çalışmaya devam eder.
* `docker stop`: Çalışan bir konteynerin ana sürecine kapatma sinyali (SIGTERM) göndererek durdurur.
* `docker kill`: Çalışan bir konteyneri zorla sonlandırır (SIGKILL).
* `docker rm`: Durdurulmuş bir konteyneri diskten tamamen siler.

## Multi-Stage Build

Multi-Stage Build, tek bir Dockerfile içerisinde birden fazla base image (FROM) kullanılmasına olanak sağlayan bir Docker özelliğidir. Amaç, uygulamanın derlenmesi (build) ve çalıştırılması (runtime) için gereken ortamları birbirinden ayırmaktır.
İlk aşamada uygulama; derleyiciler, SDK'lar ve gerekli geliştirme araçları kullanılarak oluşturulur. Daha sonraki aşamada ise yalnızca çalıştırmak için gerekli dosyalar yeni ve daha hafif bir base image'e kopyalanır.

Bu yöntem sayesinde:
* Dockerfile daha düzenli ve okunabilir hale gelir.
* Gereksiz derleme araçları son imaja dahil edilmez.
* İmaj boyutu önemli ölçüde küçülür.
* Güvenlik artar çünkü gereksiz paketler ve araçlar final imajında bulunmaz.
* Build ve runtime süreçleri birbirinden ayrıldığı için bakım ve yönetim kolaylaşır.

* **Tek Aşamalı (Single-Stage) Dockerfile:** İlk başta [multi_stage_operation](./multi_stage_operation) klasöründeki uygulama için şu şekilde tek aşamalı bir yapı kurulmuştu:
    ```dockerfile
    FROM alpine:3.5
    RUN apk update && \
        apk add --update alpine-sdk
    RUN mkdir /app
    WORKDIR /app
    COPY helloworld.c /app
    RUN mkdir bin
    RUN gcc -Wall helloworld.c -o bin/helloworld
    CMD /app/bin/helloworld
    ```
    Bu komutlar ile `my_app_large` adında bir imaj build ediliyor.

* **Çok Aşamalı (Multi-Stage) Dockerfile:** Sonrasında Dockerfile dosyası içerisinde derleyici araçları ve çalışma ortamını ayırmak için şu yapıya geçildi:
    ```dockerfile
    # AS build: Bu imajın derleme (build) aşaması olduğunu belirtir
    FROM alpine:3.5 AS build
    RUN apk update && \
        apk add --update alpine-sdk
    RUN mkdir /app
    WORKDIR /app
    COPY helloworld.c /app
    RUN mkdir bin
    RUN gcc -Wall helloworld.c -o bin/helloworld

    # İkinci aşama: Sadece çalışma ortamı (runtime)
    FROM alpine:3.5
    COPY --from=build /app/bin/helloworld /app/helloworld
    CMD ["/app/helloworld"]
    ```
    Tek aşamalı imajın boyutu çok daha büyükken, `my_app_small` adında çok aşamalı imaj build edildiğinde derleme işlemleri ilk aşamada gerçekleşir ve ikinci aşamaya sadece derlenmiş dosya aktarıldığı için nihai imaj boyutu çok daha küçük olur.

`my_app_small` build loglarında bu durum net şekilde görülür:
```text
 => [build 1/7] FROM docker.io/library/alpine:3.5@sha256:66952b313e  0.0s
 => => resolve docker.io/library/alpine:3.5@sha256:66952b313e51c3bd  0.0s
 => CACHED [build 2/7] RUN apk update && apk add --update alpine-sd  0.0s
 => CACHED [build 3/7] RUN mkdir /app                                0.0s
 => CACHED [build 4/7] WORKDIR /app                                  0.0s
 => CACHED [build 5/7] COPY helloworld.c /app                        0.0s
 => CACHED [build 6/7] RUN mkdir bin                                 0.0s
 => CACHED [build 7/7] RUN gcc -Wall helloworld.c -o bin/helloworld  0.0s
```
*(Bu aşamalar derlemenin yapıldığı ilk aşamadır: gcc çalışır, kod derlenir, helloworld binary dosyası oluşturulur).*

```text
 => CACHED [stage-1 2/2] COPY --from=build /app/bin/helloworld /app  0.0s
```
*(Bu kısım ise derlenmiş kodun kopyalandığı yerdir: runtime ortamı olan multi-stage build'in kendisidir).*

İmaj boyutlarının karşılaştırılması:
```text
my_app_large:latest         c6c28c6298f9        276MB         68.3MB        
my_app_small:latest         68b69c6725f9       6.47MB         1.98MB      
```

* **Boyut Sonucu:** `my_app_small` imajı boyut olarak çok daha küçüktür.
* **Multi-stage build mantığı:** Bu örnekte 1. aşama (derleme kısmı) son imaja dahil edilmez; sadece 2. aşamadaki kopyalanan dosya imaj içinde yer alır. `gcc`, `apk update` ve derleme araçları son imajda bulunmaz.

## Lokal Kişisel Docker Registry Kurulumu

Lokalde kişisel bir Docker Registry oluşturarak test, gelişim ve üretim ortamları için imajlar güvenle saklanabilir, yönetilebilir ve paylaşılabilir.

### 1. İşlem: Registry İmajının Çekilmesi ve Çalıştırılması

İlk olarak resmi `registry` imajını çekiyoruz:
```sh
docker pull registry
```

İmajın verilerinin kalıcı olması için host üzerinde bir klasör oluşturulur:
```sh
mkdir -p /var/lib/docker/registry
```

Registry konteynerini başlatma komutu:
```sh
# -d: detached mode (arka planda çalıştır)
# -p 5000:5000: host'taki 5000 portunu container'daki 5000 portuna bağla
# -v /var/lib/docker/registry/:/var/lib/registry: host'taki dizini container'daki dizine bağla
# registry:2: kullanılacak imaj ve versiyonu
docker run -d -p 5000:5000 -v /var/lib/docker/registry/:/var/lib/registry registry:2
```

### 2. İşlem: daemon.json Dosyasının Düzenlenmesi

hub.docker.com yerine lokaldeki güvensiz (HTTP) registry'nin kullanılabilmesi için `daemon.json` dosyasının düzenlenmesi gerekir.

Dosyayı düzenlemek için açın:
```sh
sudo nano /etc/docker/daemon.json
```

Dosya içeriğini aşağıdaki gibi ayarlayın (lokal 5000 portu güvenli olmayan registry listesine eklenir):
```json
{
  "experimental": true,
  "debug": true,
  "log-level": "info",
  "insecure-registries": ["127.0.0.1:5000"]
}
```

Değişikliklerin geçerli olması için docker servisi yeniden başlatılır:
```sh
sudo systemctl restart docker
```

### 3. İşlem: İmajın Lokal Registry'ye Yüklenmesi (Push)

Yerelde bulunan bir imajı (örneğin `nginx`), lokal registry'ye yönlendirecek şekilde etiketliyoruz:
```sh
docker tag nginx 127.0.0.1:5000/nginx:my_registry
```

Etiketlenen imajı lokal registry'ye push ediyoruz:
```sh
docker push 127.0.0.1:5000/nginx:my_registry
```

Bu işlem başarılı bir şekilde tamamlandığında Registry arka planda şunları yapar:
* İmaj dosyalarını katmanlarına (layer) göre parçalar.
* Her katmana benzersiz bir şifreli isim (sha256) verir.
* Dosyaları kendi iç sisteminde depolar.

### 4. İşlem: Registry İçeriğini Sorgulama

Registry'nin içindeki imajları ve etiketleri görmek için API üzerinden sorgulama yapılabilir:
```sh
# Depodaki imaj listesini görmek için:
curl http://127.0.0.1:5000/v2/_catalog

# nginx imajına ait etiketleri listelemek için:
curl http://127.0.0.1:5000/v2/nginx/tags/list
```

Sorgu çıktısı (örnek):
```json
{"repositories":["nginx"]}
```

Lokal imaj listesinde görünümü:
```text
127.0.0.1:5000/nginx:my_registry   ec4ed8b5299e        241MB           66MB
```

### 5. Sorun Giderme: Veriler Host'ta Görünmüyorsa

`-v` parametresi ile container başlatılmış olsa bile, bazı durumlarda host dizini (`/var/lib/docker/registry`) boş kalabilir. Bunun en sık sebebi, container'ın **farklı bir isimle** veya **yanlış volume yolu** ile başlatılmış olmasıdır.

**Adım 1: Çalışan container'ı tespit edin**

```sh
docker ps
```

Container'ın adı `registry` değilse (örneğin otomatik atanmış bir isimse), bu container `--name registry` belirtilmeden başlatılmış demektir.

**Adım 2: Verinin container içinde olup olmadığını kontrol edin**

```sh
docker exec <container_id_veya_isim> ls /var/lib/registry/docker/registry/v2/repositories
```

Burada push ettiğiniz imajın adını (örneğin `nginx`) görüyorsanız, registry verisi **container'ın kendi iç dosya sisteminde** duruyor demektir; sadece host'a mount edilmemiştir.

**Adım 3: Mevcut veriyi host'a yedekleyin (isteğe bağlı ama önerilir)**

```sh
docker cp <container_id>:/var/lib/registry /home/<kullanici>/registry-backup
```

**Adım 4: Container'ı doğru isim ve volume mount ile yeniden oluşturun**

```sh
docker stop <container_id>
docker rm <container_id>
docker run -d -p 5000:5000 --restart=always --name registry \
  -v /var/lib/docker/registry:/var/lib/registry \
  registry:2
```

**Adım 5: Doğrulayın**

```sh
ls -l /var/lib/docker/registry/docker/registry/v2/repositories
```

Bu komut artık host üzerinde `nginx` (veya push ettiğiniz diğer imajları) göstermelidir. Bu noktadan sonra yapılan tüm `docker push` işlemleri host dizininde kalıcı olarak saklanacaktır.


## Docker Volume
* Container silinse dahi içerisindeki dataları tutmak için volume kullanılır.
* Volumes, Docker Container'ları tarafından üretilen ve kullanılan verileri kalıcı kılmak için tercih edilen yöntemdir.
* Volume oluştururken ana-host makinenin diskleri kullanılarak volume ataması gerçekleştirilir.Container'in üzerinde tutmuş olduğu veriler, host makine üzerinde belirli bir dizinde tutulur.

### Docker Volume Özellikleri
* Container silinse dahi docker volume içerisindeki datalar silinmez.
* Docker volume içerisindeki datalar birden fazla container kullanabilir.
* Docker Image güncellemesi yapılsa bile volume içerisindeki datalar değişmez.
* Docker volume içerisindeki datalar taşınabilir ve yedeklenebilir.

### Docker Volume Avantajları
* Yedekleme ve migrate yapmak kolaydır.
* Docker CLI komutlarını kullanarak docker volumes yönetilebilir.
* Hem linux hem de windows Container'larında çalışır.
* Containerlar arasında paylaşım yapılabilir.
* Volume içeriği Container tarafından önceden doldurulabilir.
* Docker volumes container boyutunu artırmaz.

