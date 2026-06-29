### Dockerfile İçerisinde Oluşturulan Dosyanın Volume'a Aktarılması

Dockerfile içerisinde oluşturulan dosyalar, aynı dizine mount edilen bir volume kullanıldığında volume içerisine aktarılır. Böylece image içerisinde bulunan başlangıç dosyaları volume içerisinde de kullanılabilir.

Örnek Dockerfile:

```dockerfile
FROM ubuntu

RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get -y install nano

RUN mkdir /data
WORKDIR /data

RUN echo "docker file example volume" > test.txt
VOLUME /data
```

İmaj oluşturulur.

```bash
docker image build --tag dockervolume:1 .
```

Volume oluşturulur.

```bash
docker volume create image
```

Oluşturulan volume, `/data` dizinine bağlanarak konteyner çalıştırılır.

```bash
docker container run -it \
  -v image:/data \
  dockervolume:1 bash
```

Konteyner içerisinde dosya kontrol edilir.

```bash
cd /data

ls

# Çıktı:
# test.txt

cat test.txt

# Çıktı:
# docker file example volume
```

Volume'un host üzerindeki fiziksel konumu öğrenilir.

```bash
docker volume inspect image

# Çıktı:
# "Mountpoint": "/var/lib/docker/volumes/image/_data"
```

Host makineden volume dizinine gidilir.

```bash
sudo -i

cd /var/lib/docker/volumes/image/_data

ls

# Çıktı:
# test.txt
```
