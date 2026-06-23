# Proje: Basic Dockerfile

Bu dosyada roadmap.sh uzerindeki "Basic Dockerfile" projesinin adimlari takip edilmektedir.

---

## 1. Adim: Dockerfile Dosyasinin Olusturulmasi ve Temel Imaj Secimi

### Gorev:
Proje dizininde `Dockerfile` adinda bir dosya olusturulmali ve taban imaj (base image) olarak `alpine:latest` secilmelidir.

### Bilgi:
`FROM` direktifi, imajin uzerine kurulacagi taban isletim sistemini veya platformu belirler. `alpine` cok kucuk boyutlu (~5MB) ve guvenli bir Linux dagitimdir.

### Yapilacaklar:
1. `docker_learning` dizininde ismi sadece `Dockerfile` (uzantisi olmayan) bir dosya olusturulur.
2. Dosyanin ilk satirina su satir eklenir:
   ```dockerfile
   FROM alpine:latest
   ```

---

## 2. Adim: Varsayilan Komutun Tanimlanmasi (CMD)

### Gorev:
Konteyner calistiginda ekrana "Hello, Captain!" yazdiracak tek bir talimat eklenmelidir.

### Bilgi:
`CMD`, imajdan bir konteyner calistirildiginda varsayilan olarak yurutulecek komutu belirler. JSON array formatinda (`["komut", "parametre1", "parametre2"]`) yazilmasi standart kabul edilir.

### Yapilacaklar:
`Dockerfile` dosyasinin sonuna su satir eklenir:
```dockerfile
CMD ["echo", "Hello, Captain!"]
```

---

## 3. Adim: Imajinin Derlenmesi (Build)

### Gorev:
Olusturulan `Dockerfile` dosyasini kullanarak bir Docker imaji uretilmelidir.

### Bilgi:
`docker build` komutu, Dockerfile'daki talimatlari sirayla isleyerek yeni bir imaj olusturur. 
* `-t basic-dockerfile`: Olusturulacak imaja bir isim (tag) verir.
* `.`: Docker'a, Dockerfile'in ve ilgili kaynaklarin (build context) su an bulunulan dizinde oldugunu belirtir.

### Yapilacaklar:
1. Terminalde `basic_dockerfile` klasorunun icine girilir:
   ```bash
   cd basic_dockerfile
   ```
2. Imajı derlemek icin su komut calistirilir:
   ```bash
   docker build -t basic-dockerfile .
   ```

### Derleme Loglarinin Analizi:
Derleme sırasında terminalde gerçekleşen adımlar:
* **load build definition:** Dockerfile dosyasını okur ve içeriğini doğrular.
* **load metadata:** `FROM` kısmında belirtilen taban imajın (`alpine:latest`) güncelliğini ve detaylarını Docker Hub üzerinden kontrol eder.
* **load .dockerignore:** İmajın içine dahil edilmeyecek (hariç tutulacak) dosyalar listesini kontrol eder.
* **FROM docker.io/library/alpine:** Alpine imajının sıkıştırılmış katmanını indirir (boyutu sadece ~3.85 MB'tır).
* **exporting to image / naming / unpacking:** İndirilen katmanları bir araya getirerek nihai imajı hazırlar ve ona `basic_dockerfile:latest` etiketini atar.

---

## 4. Adim: Konteynerin Calistirilmasi (Run)

### Gorev:
Olusturulan `basic-dockerfile` imajindan bir konteyner calistirilmalidir. Ekrana "Hello, Captain!" yazmasi saglanmalidir.

### Yapilacaklar:
Terminalde su komut calistirilir:
```bash
docker run basic-dockerfile
```

Ekranda "Hello, Captain!" ciktisi gorulur.

---

## Temel Docker Komutlari ve Ciktilari

Bu projede kullanılan temel komutlar, genel tanımları ve örnek çıktıları şu şekildedir:

### 1. docker build
Dockerfile dosyasındaki adımları takip ederek yeni bir Docker imajı (paket) derler.

* **Kullanım:** `docker build -t basic_dockerfile .`
* **Çıktı:**
```
[+] Building 5.6s (5/5) FINISHED
 => [internal] load build definition from Dockerfile
 => => transferring dockerfile: 358B
 => [internal] load metadata for docker.io/library/alpine:latest
 => [1/1] FROM docker.io/library/alpine:latest
 => exporting to image
 => => naming to docker.io/library/basic_dockerfile:latest
```

### 2. docker images
Bilgisayarda yerel olarak saklanan tüm Docker imajlarını listeler.

* **Kullanım:** `sudo docker images`
* **Çıktı:**
```
IMAGE                     ID             DISK USAGE   CONTENT SIZE   EXTRA
basic_dockerfile:latest   d24c77755d71       12.9MB         3.85MB    U   
hello-world:latest        96498ffd522e       25.9kB         9.49kB    U   
```

### 3. docker run
Belirtilen imajdan yeni bir konteyner oluşturur ve çalıştırır.

* **Kullanım:** `sudo docker run basic_dockerfile`
* **Çıktı:**
```
Hello, Captain!
```

### 4. docker ps -a
Bilgisayardaki aktif, pasif veya durdurulmuş tüm konteynerleri listeler.

* **Kullanım:** `sudo docker ps -a`
* **Çıktı:**
```
CONTAINER ID   IMAGE              COMMAND                  CREATED             STATUS                         PORTS     NAMES
f36983308ce3   basic_dockerfile   "echo 'Hello, Captai…"   About an hour ago   Exited (0) About an hour ago             distracted_wright
4236d3d6235d   hello-world        "/hello"                 2 hours ago         Exited (0) 2 hours ago                   laughing_sammet
```
