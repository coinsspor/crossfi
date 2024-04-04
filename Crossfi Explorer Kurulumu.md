# Ping.Pub Explorer Crossfi için Nasıl Oluşturulur
![image](https://github.com/coinsspor/crossfi/assets/38142283/4bcf45c0-3763-41a4-a281-ba49226beb45)


**Bağımlılıkları Yükle**

`sudo apt autoremove nodejs -y
curl -fsSL https://deb.nodesource.com/setup_19.x | sudo -E bash -
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update
sudo apt install nginx certbot python3-certbot-nginx nodejs git yarn -y`

**NGINX Yapılandırması**

Dosya Yapılandırması

`sudo nano /etc/nginx/sites-enabled/your_explorer_server.conf`
 
Nginx yapılandırma klasöründe explorer dosyası yapılandırması oluşturun not: your_explorer_server.conf kendi site isminizle 

`sudo nano /etc/nginx/sites-enabled/explorer.dnsarz.xyz.conf`

Bu örnek yapılandırmayı oluşturun

    server {
    listen       80;
    listen  [::]:80;
    server_name explorer.dnsarz.xyz;

    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        root /usr/share/nginx/html;
        index  index.html index.htm;
        try_files $uri $uri/ /index.html;
    }

    #error_page  404              /404.html;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    gzip on;
    gzip_proxied any;
    gzip_static on;
    gzip_min_length 1024;
    gzip_buffers 4 16k;
    gzip_comp_level 2;
    gzip_types text/plain application/javascript application/x-javascript text/css application/xml text/javascript application/x-httpd-php application/vnd.ms-fontobject font/ttf font/opentype font/x-woff image/svg+xml;
    gzip_vary off;
    gzip_disable "MSIE [1-6]\.";}
`
not :sunucu_adı'nı kendi sunucunuzla değiştirin .



**# SSL Yapılandırması**

Sertifika SSL'sini yükleyin

`sudo certbot --nginx --register-unsafely-without-email
`
![image](https://github.com/coinsspor/crossfi/assets/38142283/7233b7d4-4b14-4bd6-bfb4-0b56ef4fad61)

2'yi seçin ve enter tuşuna basın. 
BOT 'yönlendirme' isterse EVET'i seçin.

Her şey bittikten sonra NGINX'i yeniden başlatabilirsiniz

`sudo systemctl restart nginx
`

**# Explorer Yapılandırması**

Klonlayalım

`cd $HOME
git clone https://github.com/ping-pub/explorer`

Yapılandırma dosyanızı oluşturun veya düzenleyin

`nano $HOME/explorer/chains/mainnet/crossfi.json`


İşte benim konfigürasyonum örneğin

`{
    "chain_name": "crossfi",
    "api": [
        {"provider": "Coinsspor", "address": "https://crossfi-testnet-api.coinsspor.com/"}
    ],
    "rpc": [
        {"provider": "Coinsspor", "address": "https://crossfi-testnet-rpc.coinsspor.com/"}
    ],
    "snapshot_provider": "",
    "sdk_version": "v0.47.6",
    "keplr_features": ["eth-address-gen", "eth-key-sign"],
    "coin_type": "60",
    "min_tx_fee": "5000000000000000",
    "addr_prefix": "mx",
    "logo": "/logos/crossfi.jpg",
    "assets": [{
        "base": "mpx",
        "symbol": "PX",
        "exponent": "18",
        "coingecko_id": "crossfi",
        "logo": "/logos/crossfi.jpg"
    }]
}`

**# Explorer'ı oluşturun**

`cd $HOME/explorer
yarn && yarn build`

Bir hatayla karşılaşırsanız  bu komutu kullanın

`yarn install --ignore-engines
cd $HOME/explorer
yarn && yarn build`

**# Web dosyasını Nginx html klasörüne kopyalayın**

`sudo cp -r $HOME/explorer/dist/* /usr/share/nginx/html
sudo systemctl restart nginx`







