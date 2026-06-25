# Docker

Bu dosya, Docker kurulumu yapılmadan önce öğrenilmesi gereken teorik kavramları ve konu anlatımlarını içermektedir. Konularda ilerledikçe ilgili başlıklar altına notlar eklenecektir.

## Docker Nedir?
Basit sanallaştırılmış ortamlarda uygulamalar geliştirmek, dağıtmak ve yönetmek için kullanılan açık kaynaklı bir kapsayıcı platformudur.

* Uygulamaları yalıtılmış ortamlara paketlemek; uygulamaları geliştirmeyi, dağıtmayı, bakımını yapmayı ve kullanmayı da kolaylaştırır.
* Docker konteynerleri, sanal makinelerden daha hafif, daha hızlı ve kaynak açısından daha verimlidir.

---

## Konteyner - Container ve Sanal Makine - VM Farki

Konteyner ve Sanal Makine teknolojileri uygulamaları izole etmek için kullanılır, ancak çalışma prensipleri farklıdır.

### Sanal Makine - Virtual Machine
* Her sanal makine, kendi içerisinde tam bir işletim sistemi barındırır.
* Donanım kaynakları (CPU, RAM, Disk) hypervisor aracılığıyla fiziksel sunucudan sanal makinelere kesin sınırlarla bölünür.
* Bu durum yüksek kaynak tüketimine ve yavaş başlama sürelerine yol açar.

### Konteyner - Container
* Docker konteynerleri, çalışan uygulamalar için hafif sanallaştırılmıi çalışma ortamlarıdır.Uygulamaları izole ortamlara yani konteynerlere paketlemek; uygulamaları geliştirmeyi, dağıtmayı bakımını yapmayı ve kullanmayı da kolaylaştırır.
* Konteynerler, üzerinde çalıştıkları ana işletim sisteminin çekirdeğini ortaklaşa kullanırlar.
* Her konteyner kendi dosya sistemine, kütüphanelerine ve bağımlılıklarına sahiptir. Bu sayede farklı ortamlarda tutarlı çalışırlar.
* Ana makinede çalışan uygulamaların işletim sistemi, bellek ve disk gibi kaynaklarını izole bir şekilde kullanır.

---

### Docker Mimari Yapisi

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

* Konteynerlar birbirinden izole çalışırlar. Linux veya Windows kernel da  hem konteynerlerin birbirinden izole çalışmasını sağlayan hem de konteynerlerin kullanması gereken kaynakları belirleyen iki farklı servis bulunur:
  * **cgroups**: Bir konteynerin kullanabileceği CPU, RAM, disk, ağ gibi kaynakları sınırlar.Yani konteynerlerin erişebileceği alanları kısıtlayan teknolojidir. 
  * **Namespaces**: Bir konteynerin diğer konteynerlerden izole çalışmasını sağlar.Konteynerlerin sadece kendi üzerinde çalışan servislerini görmesini ve erişmesini sağlar.Bu sayede konteynerler birbirinden izole çalışır. İşletim sistemi üzerinde çalışan servisleri göremez ve bunların disk ram gibi donanım kaynaklarına erişimleri sağlayamaz.
    * **Pid**: Çalışan processleri birbirinden izole hale getiren teknolojidir.
    * **Net**: Ağ kaynaklarını birbirinden izole hale getiren teknolojidir.Network interface ve routing tablolarını izole eder
    * **Mnt**: Dosya sistemlerini birbirinden izole hale getiren teknolojidir. .
    * **Uts**: Host adını birbirinden izole hale getiren teknolojidir.
    * **Ipc**: Inter process communication, Processler arası iletişimi birbirinden izole hale getiren teknolojidir.
    * **User**: Kullanıcıları birbirinden izole hale getiren teknolojidir.

---

### Docker Mimari Bölümleri
**1. DOCKER_Client**: Kullanıcıların komutlarını Docker Daemon'a ilettiği aracıdır. Genellikle docker CLI olarak kullanılır. REST API üzerinden Docker Daemon ile iletişim kurar. docker build, docker pull, docker run gibi komutları bu araç ile çalıştırılır.
**2. DOCKER_HOST**: Docker Daemon'un çalıştığı makineyi belirtir. REST API üzerinden Docker Daemon ile iletişim kurar.Docker engine'in üzerinde çalıştığı host makineye denir. Yani Docker'ın üzerinde çalıştığı işletim sistemidir.Tüm konteyner süreçleri ve işlemler bu host makine üzerinde çalışır.
**3. DOCKER_Registery**: Docker Image'larının depolandığı yerdir.Kayıt defteri anlamına gelir.İmajların depolandığı ve paylaşıldığı yerdir.Docker Hub, Docker'ın resmi kayıt defteridir. 


**Geleneksel sanallaştırmada hypervisor - VMware, VirtualBox, KVM- vardır. Fiziksel kaynaklar -CPU, RAM, Disk, Ağ kartı- Hypervisor tarafından bölünür ve her sanal makineye sanal kaynaklar olarak sunulur. Her VM kendi işletim sistemini çalıştırır.**

Docker ise donanımı sanallaştırmaz. CPU RAM ve ağ kartını sanallaştırma yerine mevcut işletim sisteminin çekirdeğini - kernel - paylaşır.

Fiziksel Donanım -> İşletim Sistemi - Linux Kernel --> Docker Engine ->  Container1, Container2, Container3 ... 

Geleneksel Sanallaştırma
Fiziksel Donanım -> İşletim Sistemi - Linux Kernel
                       -> Hypervisor - VMware, VirtualBox, KVM -
                                       -> Sanal Makine1  
                                       -> Sanal Makine2
                                       -> Sanal Makine3

Her container:
  * Aynı süreçler görür
  * Ayrı dosya sistemi görür
  * Ayrı ağ yapılandırması görür  
  * Ama hepsi tek bir kernel üzerinde çalışır.
---


## Docker Kurulum Adimlari - Fedora

Orijinal Docker Engine kurulumu icin terminalde sirasiyla su komutlar calistirilir:

```bash
# 1. Eski surumleri temizleme
sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine

# 2. Docker deposunu ekleme (Fedora 43 / DNF5)
sudo curl -sSL -o /etc/yum.repos.d/docker-ce.repo https://download.docker.com/linux/fedora/docker-ce.repo

# 3. Docker paketlerini kurma
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 4. Servisi baslatma ve etkinlestirme
sudo systemctl start docker
sudo systemctl enable --now docker
docker --version

# 5. Kullaniciyi docker grubuna ekleme
sudo usermod -aG docker $USER


# docker servisinin çalıştığını doğrulama
sudo docker run hello-world

# Çalışan konteynerleri listeleme
sudo docker ps -a

# ubuntu/ fedora konteyner imajını indirme ve çalıştırmave bash ile bağlanma
sudo docker run -it fedora/ubuntu bash

# konteyner haline getirilen işletim sisteminin paket listesini günceller
apt-get update

# eğer konteyner kapandıktan sonra silinmesi istenirse
docker run --rm it fedora bash

# containerleri tek tek silmek için
docker rm <CONTAINER_ID>

# durmuş tüm konteynerleri silmek için
docker container prune

# durmuş ve çalışan tüm konteynerleri silmek için
docker container prune -a

```
---
