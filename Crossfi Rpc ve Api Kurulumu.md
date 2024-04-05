# Crossfi Rpc ve Api Kurulumu

# Domain ve Dns ayarları

Öncelikle ben alan adımı Godaday üzerinden aldım .Sizin farklı bir domain sağlıyacınız olabilir.Önemli olan bu domaini ücretsiz açacağınız cloudflare hesabınıza  taşımak.

GoDaddy'den satın aldığınız bir alan adının ad sunucularını (name servers) Cloudflare'a taşımak, genellikle Cloudflare'ın sunduğu daha iyi performans, güvenlik ve DNS yönetimi avantajlarından faydalanmak için yapılan bir işlemdir. Aşağıda bu işlemi adım adım anlatacağım:

**1. Cloudflare Hesabı Oluşturun**
Cloudflare web sitesine gidin ve bir hesap oluşturun.
Hesabınızı oluşturduktan sonra, "Add a Site" seçeneğine tıklayarak alan adınızı Cloudflare'a ekleyin.

**2. Sitelerinizi Cloudflare'a Ekleyin**
Sitenizin adını girin ve "Add Site" butonuna basın. Cloudflare, sitenizin DNS kayıtlarını otomatik olarak tespit etmeye çalışacaktır.
DNS kayıtlarınızı gözden geçirin ve herhangi bir eksiklik varsa manuel olarak ekleyin. Cloudflare, bu aşamada size DNS kayıtlarınızı yönetme seçeneği sunar.

**3. Cloudflare'dan Yeni Name Server Bilgilerini Alın**
Cloudflare, sitenizi ekledikten ve DNS kayıtlarınızı doğruladıktan sonra, size özel iki adet name server (NS) adresi sağlayacaktır. Bu adresler, Cloudflare'ın DNS sunucularıdır ve sitenizin DNS sorgularını yönetmek için kullanılır.

**4. GoDaddy Hesabınıza Giriş Yapın**
GoDaddy hesabınıza giriş yapın ve "My Products" (Ürünlerim) bölümüne gidin.
Yönetmek istediğiniz alan adını bulun ve alan adı ayarlarına gidin.

**5. GoDaddy'de Name Server Ayarlarını Güncelleyin**
Alan adı ayarları sayfasında, "DNS Management" (DNS Yönetimi) veya "Manage DNS" (DNS'yi Yönet) seçeneğine tıklayın.
"Change" veya "Edit" (Değiştir veya Düzenle) seçeneğine tıklayarak mevcut name server (NS) kayıtlarınızı Cloudflare tarafından sağlanan adreslerle değiştirin.

**6. Yeni Name Server Adreslerini Kaydedin**
Cloudflare tarafından sağlanan yeni name server adreslerini girdikten sonra, değişiklikleri kaydetmek için ilgili butona basın.
Değişikliklerin tüm internet üzerinde yayılması biraz zaman alabilir (genellikle 24 saat içinde tamamlanır, ancak bazen daha uzun sürebilir).

**7. Cloudflare ve GoDaddy'de İşlemleri Tamamlayın**
Cloudflare'da, name server değişikliklerinin doğru bir şekilde yapıldığını doğrulamak için gereken adımları takip edin.
Her iki platformda da gerekli doğrulamaların tamamlanmasını bekleyin.
Son Notlar
DNS değişiklikleri bazen hemen etkili olmayabilir. Yayılma süreci tamamlanana kadar bekleyin.
Herhangi bir hata mesajı alırsanız, hem Cloudflare hem de GoDaddy'nin destek ekipleriyle iletişime geçebilirsiniz.
İşlemler sırasında sitenizin erişilebilirliği konusunda kısa süreli kesintiler yaşanabilir, bu nedenle işlemleri düşük trafikli saatlerde yapmanız iyi olabilir.

not: Ben Explorer'ımı farklı bir sunucuya , crossfi node 'umada farklı bir sunucya kurduğumu hatırlatmak isterim ve buna göre alan adı ve alt alan adalarını
aşağıdaki görsel gibi hazırladım sizdeöncelikle bu tanımlamaları yapmalısınız 

![image](https://github.com/coinsspor/crossfi/assets/38142283/031daa8b-0eaf-41f8-8e50-93562c08584b)

# Bağımlılıkları Yükleme ve Nginx Kurulumu

Crossfi Nodu'nuza bağlanın ve aşağıdaki komutları çalıştırp Nginx 'i kuralım

` sudo apt -q update`

` sudo apt -qy install curl git jq lz4 build-essential snapd unzip nginx`

` sudo apt -qy upgrade`

# API NGINX Yapılandırma Dosyanızı Oluşturma

`sudo nano /etc/nginx/sites-available/crossfi-testnet-api
`

Dosya açıkken API alt alan adınız için gerekli yapılandırmayı girme zamanı gelmiştir. Aşağıda Node.js uygulaması için özel olarak tasarlanmış bir şablon bulunmaktadır. Her bir yönergeyi anladığınızdan ve uygulamanızın özel ihtiyaçlarına, özellikle de proxy_passuygulamanızın çalışan bağlantı noktasını işaret etmesi gereken yönergeye uyacak şekilde değiştirdiğinizden emin olun:
`

    server {
    listen 80;
    server_name crossfi-testnet-api.coinsspor.com;

    location / {
        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Max-Age 3600;
        add_header Access-Control-Expose-Headers Content-Length;
        
        proxy_pass http://127.0.0.1:1317;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
    }


`
*coinsspor.com Bölümü server_namekendi etki alanınıza ve API bağlantı noktanıza değiştirin proxy_pass(bu durumda varsayılan bağlantı noktası)1317*
*Bu yapılandırma, sunucunuzu, HTTP için varsayılan bağlantı noktası olan 80 numaralı bağlantı noktasını dinleyecek şekilde ayarlar. server_nameProjenizin alt alan adıyla eşleşmelidir . Yönerge proxy_pass, NGINX'e bu alt etki alanına giren istekleri nereye* *ileteceğini söylediği için çok önemlidir. Bu örnekte, birçok Node.js uygulaması için varsayılan bağlantı noktası olan 1317 numaralı bağlantı noktasındaki localhost'a ayarlanmıştır.*

# RPC NGINX Yapılandırma Dosyanızı Oluşturma

`sudo nano /etc/nginx/sites-available/crossfi-testnet-rpc`

`

    server {
    listen 80;
    server_name crossfi-testnet-rpc.coinsspor.com;
    
    location / {
        proxy_pass http://127.0.0.1:26657;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
    }


`

*Yine coinsspor.com kendi etki alanınıza ve proxy_pass RPC bağlantı noktanıza geçin; bu durumda varsayılan bağlantı noktası 26657'dir.*

# Yapılandırmanızı Etkinleştirme

Yapılandırma dosyasını ihtiyaçlarınıza göre uyarladıktan ve değişikliklerinizi kaydettikten sonra, bir sonraki adım bu dosyayı sites-enabledetkinleştirmek için dizine bağlamaktır:

`sudo ln -s /etc/nginx/sites-available/crossfi-testnet-* /etc/nginx/sites-enabled/`

sites-availableBu komut, ve dizinleri arasında sembolik bir bağlantı oluşturarak sites-enabledyapılandırmanızı etkili bir şekilde etkinleştirir.

Son olarak NGINX yapılandırmasını sözdizimi hataları açısından test edin:

`sudo nginx -t`

Test sorunsuz bir şekilde geçerse değişiklikleri uygulamak için NGINX'i yeniden yükleyin:

`sudo systemctl reload nginx`

Alt alan adlarınız artık ayarlanmıştır ve belirtilen alt alan adı üzerinden erişilebilir olmalıdır. Bu kurulum, uygulamanızın farklı bölümleri arasında net bir ayrım yaparak projenizin yapısını geliştirir ve geliştiricilerin ve kullanıcıların uç noktalarınızla etkileşim kurmasını kolaylaştırır.

Ancak tüm uç noktalarınız hala güvenli olmayan HTTP kullanıyor. Bir sonraki bölümde tüm uç noktalarımız için SSL kuracağız

# CertBot'u kurma

CertBot'u SSL yöneticimiz olarak kullanacağız. Aşağıdaki komutları kullanarak yükleyebilirsiniz:

`sudo snap install --classic certbot`
`sudo ln -s /snap/bin/certbot /usr/bin/certbot`
`sudo snap set certbot trust-plugin-with-root=ok`

# SSL Ayarları

`sudo certbot --nginx --register-unsafely-without-email`


**Evet buraya kadar geldiyseniz yapılcak son şey app.toml dosyasını bulup editlmek olacak**

# app.toml Dosyasını Düzenleme

En kolay yol MoboXterm ile aşağıdaki resimdeki gibi app.toml dosyasını bulup sağ tuşla editlemek olacak

![image](https://github.com/coinsspor/crossfi/assets/38142283/6ab87166-9447-4586-843a-fe8b8c69c5f9)

gösterilen yerdeki false u true yapınız 

![image](https://github.com/coinsspor/crossfi/assets/38142283/57ffad6d-8108-4e7b-a776-c532219a6560)


Hepsi bukadar herşeyi doğu yaptysanız eğer . Aşğıdaki benim api ve rpc linklerim var bu şekide çalıyor olması lazım.

[https://crossfi-testnet-api.coinsspor.com/](url)

