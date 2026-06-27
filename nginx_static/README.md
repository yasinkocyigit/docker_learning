# Nginx Statik Web Sunucusu (Docker)

Bu mini proje, **Nginx** tabanlı bir Docker imajı oluşturarak statik bir web sitesini konteyner içinde çalıştırmayı amaçlamaktadır.

## Klasör Yapısı

```
nginx-static-server/
├── Dockerfile
├── README.md
├── content/
│   └── index.html
└── conf/
    ├── nginx.conf
    └── conf.d/
        └── default.conf
```

### Dosya ve Klasorlerin Gorevleri

* **content/**: Web sunucusunda yayinlanacak HTML, CSS ve JS gibi statik dosyalarin bulundugu klasordur.
* **conf/**: Nginx yapılandırma dosyalarını barındırır.
  * **nginx.conf**: Nginx'in ana yapılandırma dosyasıdır. Genel sunucu ayarlarını (çalışan süreç sayısı, bağlantı sınırları, log biçimleri vb.) tanımlar ve `conf.d/` altındaki tüm `.conf` uzantılı dosyaları otomatik olarak içeri aktarır.
  * **conf.d/**: Farklı web siteleri veya alt alan adları - subdomain- için özel sunucu bloklarının - virtual host- tanımlandığı klasördür.
  * **default.conf**: Varsayılan sunucu yapılandırmasını içerir. Sunucunun hangi portu dinleyeceğini, hangi istekleri karşılayacağını ve istek geldiğinde hangi dizindeki  dosyaları sunacağını belirler.

## Dockerfile İçeriği

```dockerfile
FROM nginx
RUN rm /etc/nginx/nginx.conf /etc/nginx/conf.d/default.conf
COPY content /usr/share/nginx/html
COPY conf /etc/nginx
```

### Satır satır açıklama

| Satır | Açıklama |
|---|---|
| `FROM nginx` | Resmi Nginx imajını temel alır. |
| `RUN rm ...` | İmajla birlikte gelen varsayılan `nginx.conf` ve `default.conf` dosyalarını siler. |
| `COPY content /usr/share/nginx/html` | Yerel `content/` klasöründeki dosyaları, Nginx'in web içeriği sunduğu dizine kopyalar. |
| `COPY conf /etc/nginx` | Yerel `conf/` klasöründeki ayar dosyalarını Nginx'in config dizinine kopyalar. |

## Bu Kurulum Ne İşe Yarar?

Bu, klasik bir **statik web sitesi sunucusudur**; tarayıcıdan adrese gidildiğinde `content/index.html` dosyası web sayfası olarak gösterilir. Dosya listeleme/indirme görünümü (Index of /) isteniyorsa `conf/conf.d/default.conf` içine `autoindex on;` eklenmelidir.

## Build ve Çalıştırma

Bu klasörün içindeyken (`Dockerfile` adıyla kaydedildiği için `-f` gerekmez):

```bash
docker build --tag nginx-static-server .
docker run -p 80:80 -d nginx-static-server
```

Çalışan konteynerleri kontrol etme:

```bash
docker ps
```

Logları görüntüleme (hata ayıklama için):

```bash
docker logs <container_id>
```

Tarayıcıdan test:

```
http://localhost
```

## Notlar / Sık Yapılan Hatalar

- `conf.d` klasör adında "d" harfi unutulmamalı (`conf./` değil `conf.d/`).
- `docker run` komutunda seçenekler (`-p`, `-d`) image adından **önce** gelmelidir.
- `content/` ve `conf/` klasörleri build context'inde (Dockerfile ile aynı dizinde) fiziksel olarak bulunmalıdır; aksi halde `COPY` adımı başarısız olur.
- Konfigürasyon dosyalarını güncelledikten sonra `docker build --no-cache ...` ile cache'siz build almak, eski katmanların kullanılmasını önler.
