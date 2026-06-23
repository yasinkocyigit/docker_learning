# Docker Teorik Ogrenme Sureci

Bu dosya, Docker kurulumu yapilmadan once ogrenilmesi gereken teorik kavramlari ve konu anlatimlarini icermektedir. Konularda ilerlendikce ilgili basliklar altina notlar eklenecektir.

## Docker Nedir?
Uygulamalari ve bagimliliklarini isletim sistemi seviyesinde izole bir sekilde calistiran platformdur.

* Uygulamanin "benim bilgisayarimda calisiyordu, sunucuda neden calismiyor" problemini ortadan kaldirmak; her ortamda (yerel bilgisayar, test sunucusu, canli sunucu) ayni sekilde calismasini saglamaktır.
* Linux cekirdegindeki **namespaces** (izolasyon) ve **cgroups** (kaynak sinirlama) ozelliklerini kullanarak uygulamalari hafif, hizli ve guvenli sekilde paketler ve calistirir.

---

## Konteyner - Container ve Sanal Makine - VM Farki

Konteyner ve Sanal Makine teknolojileri uygulamalari izole etmek icin kullanilir, ancak calisma prensipleri farklidir.

### Sanal Makine - Virtual Machine
* Her sanal makine, kendi icerisinde tam bir isletim sistemi (Guest OS) barindirir.
* Donanim kaynaklari (CPU, RAM, Disk) hypervisor araciligiyla fiziksel sunucudan sanal makinelere kesin sinirlarla bolusturulur.
* Bu durum yüksek kaynak tüketimine ve yavas baslama surelerine yol acar.

### Konteyner - Container
* Konteynerler, uzerinde calistiklari ana isletim sisteminin (Host OS) cekirdegini (kernel) ortaklasa kullanirlar.
* Kendi iclerinde tam bir isletim sistemi barindirmazlar; sadece uygulamanin calismasi icin gereken kütüphaneleri ve dosyalari icerirler.
* Kaynaklar dinamik olarak kullanilir, baslama sureleri milisaniyeler seviyesindedir.

---

## Docker Temel Bileşenleri

### Docker Engine
Docker Daemon (arka plan servisi), REST API (iletisim koprusu) ve Docker CLI (komut satiri arayuzu) bilesenlerinin tamamini kapsayan, konteynerlerin olusturulup yonetilmesini saglayan ana istemci-sunucu uygulamasidir.

### Docker Daemon
* Arka planda calisan ve konteynerleri, imajlari, aglari ve birimleri yoneten servistir.

### Docker CLI
* Kullanicinin Docker ile iletisim kurmasini saglayan komut satiri arayuzudur. Komutlar Docker Daemon'a iletilir.

### Docker Image
* Konteynerlerin olusturulmasinda kullanilan, uygulamanin calisma ortamini barindiran salt okunur (read-only) sablondur.

### Docker Container
* Imajlarin calisabilir durumdaki canli ornekleridir.

### Dockerfile
Bir uygulamanin calismasi icin gereken tum adimlari ve bagimliklari iceren, Docker'in otomatik imaj uretmesini saglayan, uzantisi olmayan metin tabanli bildirimsel bir dosyadir.

---

## Imaj Katmanlari ve Kayit Defteri - Registry

### Katmanli Dosya Sistemi
* Bir Docker imaji ust uste binen salt okunur katmanlardan (read-only layers) olusur.
* `Dockerfile` icindeki her bir komut (ornegin `COPY` veya `RUN`) yeni bir katman olusturur.
* Konteyner calistirildiginda, bu salt okunur katmanlarin en ustune gecici bir yazilabilir katman (read-write container layer) eklenir. Yapilan tum degisiklikler bu katmanda tutulur. Konteyner silindiginde bu katman da silinir, alttaki orijinal imaj degismez.

### Kayit Defteri ve Docker Hub
* Olusturulan imajlarin depolandigi ve paylasildigi merkezi depolardir.
* **Docker Hub**, varsayilan resmi ve halka acik imaj deposudur. Resmi veri tabanlari (PostgreSQL, Redis), isletim sistemleri (Ubuntu, Alpine) ve dil platformlari (Node.js, Python) buradan indirilir.

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
sudo systemctl enable docker

# 5. Kullaniciyi docker grubuna ekleme
sudo usermod -aG docker $USER
```

---

## Ilk Pratik Uygulama - hello-world

Kurulum sonrasi calistirilacak ilk test komutudur:
```bash
docker run hello-world
```

---

## `docker run` Nedir?
Yeni bir konteyner olusturmak ve calistirmak icin kullanilan temel Docker komutudur.

* Imaj halindeki pasif uygulamanin bilgisayarda calisir bir surec (proses) haline getirilmesini saglar.
* Arka planda `docker pull` (gerekirse indirir), `docker create` (konteyner yapisini hazirlar) ve `docker start` (calistirir) komutlarini tek adimda birlestirir.

### Calisma Adimlari:
1. **Yerel Kontrol:** Imaj bilgisayarda var mi bakar.
2. **Indirme (Pull):** Yoksa Docker Hub'dan indirir.
3. **Olusturma (Create):** En uste yazilabilir katman ekler.
4. **Ag Atama:** Sanal ag ve IP tanimlar.
5. **Baslatma (Start):** Uygulama surecini (prosesini) baslatir.


---

## Imaj ve Konteyner Listeleme

### 1. Yerel Imajlarin Listelenmesi
```bash
docker images
```

### 2. Konteynerlerin Listelenmesi
* Sadece calisan konteynerleri gormek icin:
  ```bash
  docker ps
  ```
* Calismis ve durdurulmus olanlar dahil tum konteynerleri gormek icin:
  ```bash
  docker ps -a
  ```

---

## Arka Planda Calistirma - Detached ve Port Yonlendirme - Publishing

Sadece calisip duran degil, arka planda surekli istek dinleyen servisler (web sunucusu vb.) icin yeni parametreler kullanilir.

### Kullanilacak Komut:
```bash
docker run -d -p 8080:80 nginx
```

* `-d` (Detached): Konteynerin arka planda calismasini saglar. Terminal ekranini kilitlemez.
* `-p 8080:80` (Port Publishing): Host (kendi bilgisayariniz) ile konteyner arasinda port koprusu kurar. 
  * `8080` -> Bilgisayarinizdaki disari acik port.
  * `80` -> Konteynerin icinde Nginx'in dinledigi port.
* `nginx`: Docker Hub'dan indirilecek resmi Nginx web sunucusu imaji.

---

## Konteyner Durdurma - docker stop
Calisan bir konteynerin calismasini guvenli sekilde sonlandirmak icin kullanilir.

* Calisan bir sureci (prosesi) durdurma komutudur.
* Konteynerin kaynak (CPU/RAM) tüketmesini engellemek ve isi bittiginde durdurmak.
* Konteyner icindeki ana prosese `SIGTERM` sinyali gondererek uygulamanin verileri kaydedip guvenli kapanmasini saglar. Eger belirlenen surede kapanmazsa `SIGKILL` ile zorla kapatir.
* Kullanimi: `docker stop <konteyner_id_veya_adi>`

---

## Konteyner Silme - docker rm
Durdurulmus olan konteynerleri diskten kalici olarak silmek icin kullanilir.

* Konteyner dosya yapisini ve metadata kaydini bilgisayardan temizleme komutudur.
* Artik ihtiyac duyulmayan eski konteynerlerin diskte yer kaplamasini onlemek.
* Konteynerin en ust katmanindaki yazilabilir (read-write) katmani ve konteyner tanimini tamamen siler.
* Kullanimi: `docker rm <konteyner_id_veya_adi>`
