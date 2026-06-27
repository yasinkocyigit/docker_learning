# Ubuntu Python Uygulama Ortamı

Bu projede, Ubuntu tabanlı bir imaj oluşturup içine Python3, pip ve nano editörünü kurarak temel bir çalışma ortamı hazırlıyoruz.

---

## Proje Klasör Yapısı

```text
ubuntu_python/
├── Dockerfile
└── README.md
```

---

## Dockerfile Açıklaması

Oluşturulan `Dockerfile` içeriği şu adımlardan oluşur:

* **FROM ubuntu**: Taban imaj olarak Ubuntu seçilir.
* **LABEL maintainer="yasin"**: İmaja metadata olarak yapımcı bilgisi eklenir.
* **RUN apt-get -y update**: Paket listesi güncellenir.
* **RUN apt-get -y upgrade**: Mevcut paketler yükseltilir.
* **RUN apt-get -y install nano**: Dosya düzenleme için nano editörü kurulur.
* **RUN apt-get install -y python3 python3-pip**: Python 3 ve pip paket yöneticisi kurulur.
* **COPY . /app**: Bulunulan dizindeki tüm dosyalar konteyner içindeki `/app` dizinine kopyalanır.
* **WORKDIR /app**: Çalışma dizini `/app` olarak ayarlanır.
* **EXPOSE 5000**: Konteynerin 5000 portunu dinleyeceği bildirilir.

---

## Giriş Noktası (ENTRYPOINT) ve Konteyner Yaşam Döngüsü Notları

Konteynerin açık kalma süresi doğrudan ana sürecine (PID 1) bağlıdır.

### 1. Geçici Komut Çalıştırma 
Eğer Dockerfile içine şu yazılırsa:
```dockerfile
ENTRYPOINT echo "Hello World"
```
* Konteyner ayağa kalktığında ekrana "Hello World" yazar.
* Ekrana yazma işlemi (süreç) bittiği anda ana süreç (PID 1) sonlanmış olur.
* Bu nedenle konteyner doğrudan **exited** (durmuş) moda geçer.

### 2. Etkileşimli Terminal Çalıştırma
Eğer Dockerfile içine şu yazılırsa:
```dockerfile
ENTRYPOINT ["bash"]
```
* Konteyner `-it` parametreleri ile çalıştırıldığında (`docker run -it <imaj_adi>`) karşımıza bir bash terminali gelir.
* Bu bash oturumu açık kaldığı sürece konteyner çalışmaya devam eder.
* Terminalde `exit` yazıp bash oturumundan çıkıldığında ana süreç sonlanır ve konteyner **exited** moda geçer.

---

## Derleme ve Çalıştırma Adımları

İmajı derlemek için:
```bash
docker build -t ubuntu-python-env .
```

Konteyneri etkileşimli modda başlatıp içine bağlanmak için:
```bash
docker run -it ubuntu-python-env
```
*(Bu komutla bash terminaline bağlanırsınız. Çıkış yaptığınızda konteyner durur).*
