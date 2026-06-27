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