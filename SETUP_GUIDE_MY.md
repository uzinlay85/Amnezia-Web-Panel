# Amnezia Web Panel - Setup & Troubleshooting Guide (မြန်မာဘာသာ)

ဤ Guide သည် **Amnezia Web Panel** ကို Linux VPS (Ubuntu 20.04/22.04/24.04/Debian) ပေါ်တွင် စတင်တပ်ဆင်ခြင်းမှသည် လက်တွေ့ကြုံတွေ့ရတတ်သော Error များ၊ Permission ပြဿနာများ၊ SSH Key Authentication နှင့် မြန်မာနိုင်ငံ ISP အပိတ်အပင်များကြား အောင်မြင်စွာ ချိတ်ဆက်နိုင်သည်အထိ အဆင့်ဆင့် လက်တွေ့ဖြေရှင်းနည်း အပြည့်အစုံ ဖြစ်ပါသည်။

---

## 📑 မာတိကာ (Table of Contents)
1. [၁။ Linux VPS ပေါ်တွင် Panel စတင်တပ်ဆင်ခြင်း (Root / Non-Root User)](#၁-linux-vps-ပေါ်တွင်-panel-စတင်တပ်ဆင်ခြင်း)
2. [၂။ Background Service (Systemd) အမြဲ Run နေစေရန် ပြုလုပ်ခြင်း](#၂-background-service-systemd-အမြဲ-run-နေစေရန်-ပြုလုပ်ခြင်း)
3. [၃။ Docker Package Conflict ဖြေရှင်းနည်း (Ubuntu 22.04 / 24.04)](#၃-docker-package-conflict-ဖြေရှင်းနည်း)
4. [၄။ User Permissions & Sudo Configuration](#၄-user-permissions--sudo-configuration)
5. [၅။ Panel ထဲတွင် Server အသစ် ထည့်သွင်းခြင်း (Password vs SSH Key)](#၅-panel-ထဲတွင်-server-အသစ်-ထည့်သွင်းခြင်း)
6. [၆။ AmneziaWG 3.1 Install လုပ်ခြင်းနှင့် Port ရွေးချယ်မှု](#၆-amneziawg-31-install-လုပ်ခြင်းနှင့်-port-ရွေးချယ်မှု)
7. [၇။ Client App ချိတ်ဆက်ခြင်းနှင့် အရေးကြီးသတိပြုဖွယ်များ](#၇-client-app-ချိတ်ဆက်ခြင်းနှင့်-အရေးကြီးသတိပြုဖွယ်များ)
8. [၈။ လက်တွေ့စစ်ဆေးနည်းများနှင့် Troubleshooting Commands](#၈-လက်တွေ့စစ်ဆေးနည်းများနှင့်-troubleshooting-commands)
9. [၉။ NGINX Web Server နှင့် Free Let's Encrypt SSL တပ်ဆင်နည်း](#၉-nginx-web-server-နှင့်-free-lets-encrypt-ssl-တပ်ဆင်နည်း)
10. [၁၀။ Web Panel အား HTTPS SSL (`https://<YOUR_DOMAIN>:5000`) ဖွင့်လှစ်အသုံးပြုနည်း](#၁၀-web-panel-အား-https-ssl-httpsyour_domain5000-ဖွင့်လှစ်အသုံးပြုနည်း)
11. [၁၁။ VPN Keys / Configs များတွင် IP အစား Domain Name ဖြင့် ထွက်ရှိစေနည်း](#၁၁-vpn-keys--configs-များတွင်-ip-အစား-domain-name-ဖြင့်-ထွက်ရှိစေနည်း)

---

## ၁။ Linux VPS ပေါ်တွင် Panel စတင်တပ်ဆင်ခြင်း

### အဆင့် ၁.၁: Packages များ သွင်းယူခြင်း
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git python3 python3-pip python3-venv curl
```

### အဆင့် ၁.၂: Repository Clone လုပ်ပြီး Virtual Environment ဆောက်ခြင်း

**ရွေးချယ်မှု (A) - Non-Root User (ဥပမာ `zinko`) ဖြင့် Run လိုပါက:**
```bash
cd ~
git clone https://github.com/uzinlay85/Amnezia-Web-Panel.git
cd Amnezia-Web-Panel

python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

**ရွေးချယ်မှု (B) - Root User ဖြင့် Run လိုပါက:**
```bash
cd /root
git clone https://github.com/uzinlay85/Amnezia-Web-Panel.git
cd Amnezia-Web-Panel

python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

---

## ၂။ Background Service (Systemd) အမြဲ Run နေစေရန် ပြုလုပ်ခြင်း

Panel ကို ၂၄ နာရီ မပြတ် background တွင် run နေစေရန်နှင့် Server reboot ကျသွားပါက အလိုအလျောက် ပွင့်လာစေရန် Service ဆောက်ပါမည်။

### ရွေးချယ်မှု (A) - Non-Root User (ဥပမာ `zinko`) အတွက် Service:
```bash
sudo bash -c 'cat << "EOF" > /etc/systemd/system/amnezia-panel.service
[Unit]
Description=Amnezia Web Panel Service
After=network.target

[Service]
Type=simple
User=zinko
WorkingDirectory=/home/zinko/Amnezia-Web-Panel
ExecStart=/home/zinko/Amnezia-Web-Panel/venv/bin/python app.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF'
```
*(💡 မှတ်ချက်: `zinko` နေရာတွင် မိမိ၏ username အတိုင်း အစားထိုးနိုင်ပါသည်)*

### ရွေးချယ်မှု (B) - Root User အတွက် Service:
```bash
sudo bash -c 'cat << "EOF" > /etc/systemd/system/amnezia-panel.service
[Unit]
Description=Amnezia Web Panel Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/Amnezia-Web-Panel
ExecStart=/root/Amnezia-Web-Panel/venv/bin/python app.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF'
```

### Service ကို စတင် (Start & Enable) လုပ်ပါ:
```bash
sudo systemctl daemon-reload
sudo systemctl start amnezia-panel
sudo systemctl enable amnezia-panel
sudo systemctl status amnezia-panel
```

---

## ၃။ Docker Package Conflict ဖြေရှင်းနည်း

### ⚠️ ကြုံတွေ့ရတတ်သော Error (Ubuntu 22.04 / 24.04):
> `The following packages have unmet dependencies: containerd.io : Conflicts: containerd`

### 🛠️ ဖြေရှင်းနည်း:
Official Docker Repository ရှိနေချိန် `docker.io` အစား `docker-ce` ကို အောက်ပါအတိုင်း သွင်းပေးရပါမည်:

```bash
sudo apt remove -y containerd
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker

# မိမိ User ကို docker group ထဲ ထည့်ပါ (<YOUR_USER> နေရာတွင် မိမိ username ထည့်ပါ)
sudo usermod -aG docker <YOUR_USER>

# စစ်ဆေးပါ
docker --version
```

---

## ၄။ User Permissions & Sudo Configuration

### ⚠️ ကြုံတွေ့ရတတ်သော Error:
> `sudo: a terminal is required to read the password; either use the -S option to read from standard input or configure an askpass helper sudo: a password is required`

### 💡 ဖြေရှင်းနည်း (၂) မျိုး:
1. **နည်းလမ်း ၁ (အကြံပြုချက် - NOPASSWD မသုံးဘဲ လုံခြုံစွာထားခြင်း):**  
   Web Panel တွင် Server ထည့်သွင်းစဉ် **Password** နေရာတွင် User ၏ Sudo Password ကို ထည့်ပေးထားပါက Panel က `echo 'password' | sudo -S` ဖြင့် အလိုအလျောက် ဖြည့်ဆည်းပေးသွားမည် ဖြစ်သောကြောင့် Server ပေါ်တွင် `NOPASSWD` ဖိုင်များ သွားပြင်စရာ မလိုပါ။
2. **နည်းလမ်း ၂ (Passwordless Sudo ခွင့်ပြုခြင်း):**  
   Server Terminal တွင် Password လုံးဝ မတောင်းစေလိုပါက:
   ```bash
   echo "<YOUR_USER> ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/<YOUR_USER>
   sudo chmod 0440 /etc/sudoers.d/<YOUR_USER>
   ```

---

## ၅။ Panel ထဲတွင် Server အသစ် ထည့်သွင်းခြင်း

1. Browser မှတစ်ဆင့် `http://<YOUR_VPS_IP>:5000` သို့ သွားပါ။
2. **Default Login:** `admin` / `admin` (Login ဝင်ပြီးပါက Users menu တွင် password ချက်ချင်း ပြောင်းပါ)။
3. **"Servers"** tab > **"＋ Add Server"** ကို နှိပ်ပြီး:
   - **Server Name:** `Main-VPN-01` (မိမိကြိုက်နှစ်သက်ရာ)
   - **Host:** VPS IP (သို့မဟုတ် `<YOUR_DOMAIN>`)
   - **SSH Port:** VPS ၏ SSH Port (ဥပမာ `22` သို့မဟုတ် custom port)
   - **Username:** `<YOUR_USER>` (သို့မဟုတ် `root`)
   - **Auth Type:**
     - 🔑 **SSH Key ဖြင့်သုံးပါက (Root Login ပိတ်ထားသော Server များအတွက်):** **SSH Private Key** နေရာတွင် `id_ed25519` / `id_rsa` စာသားတစ်ခုလုံးကို Paste ထည့်ပြီး **Password** နေရာတွင် Sudo password ကို ထည့်ပါ။
     - 🔒 **Password ဖြင့်သုံးပါက:** **Password** နေရာတွင် SSH password ကို ထည့်ပါ။
4. **Save** နှိပ်ပါ။ Panel က အစိမ်းရောင် Live Ping ဖြင့် ချိတ်ဆက်ပြသပါမည်။

---

## ၆။ AmneziaWG 3.1 Install လုပ်ခြင်းနှင့် Port ရွေးချယ်မှု

### 🇲🇲 မြန်မာနိုင်ငံ ISP များအတွက် အရေးကြီးသော Port ရွေးချယ်မှု:
- AmneziaWG ၏ Default Port ဖြစ်သော `55424/udp` (Port နံပါတ်ကြီးများ) သည် မြန်မာပြည်ရှိ အင်တာနက်လိုင်းများ (MPT, Atom, Ooredoo, Fiber) နှင့် Hosting Provider Firewall များတွင် Block / Drop ခံရတတ်ပါသည်။
- ထို့ကြောင့် Port နေရာတွင် **`443`** (သို့မဟုတ် **`53`**) ကို ထည့်သွင်းရန် **အထူးအကြံပြုပါသည်**။

### Install လုပ်ဆောင်ရန် အဆင့်များ:
1. Web Panel ရှိ **AmneziaWG 3.1** အောက်တွင် **"Install"** နှိပ်ပါ။
2. **PORT (UDP):** နေရာတွင် **`443`** ဟု ထည့်ပါ။
3. VPS Firewall တွင် Port 443 ဖွင့်ပေးပါ:
   ```bash
   sudo ufw allow 443/udp
   sudo ufw reload
   ```
4. *(Cloud Provider Dashboard ရှိပါကလည်း Inbound Rule တွင် UDP 443 ကို ဖွင့်ပေးထားရပါမည်)*။

---

## ၇။ Client App ချိတ်ဆက်ခြင်းနှင့် အရေးကြီးသတိပြုဖွယ်များ

### ⚠️ သတိပြုရန် (App Compatibility):
- **AmneziaWG 3.1** တွင်ပါဝင်သော `HeaderProtectionKey`, `Range Parameters (H1-H4)`, `RandomTrailers` များကို **မူလ Standard WireGuard App မှ နားမလည်ပါ** (ချိတ်ဆက်၍ မရပါ)။
- သို့ဖြစ်ပါ၍ **[Official Amnezia VPN App](https://amnezia.org)** (သို့မဟုတ် **AmneziaWG Android App**) ကိုသာ အသုံးပြုရပါမည်။

### ချိတ်ဆက်နည်း:
1. Web Panel တွင် **"Add Connection"** နှိပ်ပြီး Client တစ်ခု ဆောက်ပါ (ဥပမာ `me`)။
2. Client ဘေးရှိ **စာရွက်ပုံ Icon (Copy/View)** ကို နှိပ်ပြီး **QR Code** (သို့မဟုတ် `vpn://...` key) ကို ရယူပါ။
3. ဖုန်းရှိ **Amnezia VPN App** ဖြင့် Scan ဖတ်ပြီး **"Connect"** နှိပ်ပါ။

---

## ၈။ လက်တွေ့စစ်ဆေးနည်းများနှင့် Troubleshooting Commands

### 🔍 ၁။ All-in-One Server Health Check
```bash
echo "=== [1] Docker Container Status ==="
docker ps --filter "name=amnezia"

echo -e "\n=== [2] AmneziaWG Interface & Keys ==="
docker exec -it amnezia-awg3 awg show 2>/dev/null

echo -e "\n=== [3] Listening UDP Port on Host ==="
sudo ss -ulpn | grep -E '443|55424'

echo -e "\n=== [4] IP Forwarding Status ==="
sysctl net.ipv4.ip_forward
```

### 🔍 ၂။ VPN ချိတ်ဆက်မိပြီး Data စီးဆင်းမှု စစ်ဆေးခြင်း
```bash
docker exec -it amnezia-awg3 awg show
```

**အောင်မြင်စွာ ချိတ်ဆက်မိပါက အောက်ပါအတိုင်း ပေါ်လာပါမည်:**
```ini
peer: <CLIENT_PUBLIC_KEY>
  endpoint: <CLIENT_IP>:<PORT>
  allowed ips: 10.8.1.2/32
  latest handshake: 46 seconds ago
  transfer: 19.04 KiB received, 40.79 KiB sent
```

- **`latest handshake:`** ပေါ်လာခြင်း = လုံခြုံရေးသော့ အောင်မြင်စွာ ဖလှယ်ပြီးပြီ။
- **`transfer: X KiB received, X KiB sent:`** ပေါ်လာခြင်း = အင်တာနက် Data အမှန်တကယ် အပြန်အလှန် စီးဆင်းနေပြီ ဖြစ်ပါသည်။

---

## ၉။ NGINX Web Server နှင့် Free Let's Encrypt SSL တပ်ဆင်နည်း

NGINX သည် သင့် VPN Server အား ပုံမှန် Website တစ်ခုကဲ့သို့ ဖုံးကွယ်ပေးရန် (Camouflage) နှင့် Free Let's Encrypt SSL Certificate ထုတ်ယူရန် အသုံးပြုပါသည်။

### အဆင့် ၉.၁: ကြိုတင်ပြင်ဆင်မှု (DNS A Record)
- Domain Name ဝယ်ယူထားသော Dashboard (ဥပမာ Cloudflare) တွင် **A Record** ချိန်ပေးပါ:
  - **Type:** `A`
  - **Name:** `vpn` (သို့မဟုတ် `@`)
  - **IPv4 Address:** `<YOUR_VPS_IP>`
  - **Proxy status:** `DNS only` (Cloudflare သုံးပါက Grey Cloud ထားပါ)

### အဆင့် ၉.၂: Firewall Port ဖွင့်ပေးပါ
```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw reload
```

### အဆင့် ၉.၃: Web Panel တွင် NGINX Install လုပ်ပါ
1. Web Panel > Server စာမျက်နှာရှိ **Web servers** အောက်က **NGINX** ဘေးရှိ **"Install"** ကို နှိပ်ပါ။
2. အချက်အလက်များ ဖြည့်ပါ:
   - **Domain Name:** `<YOUR_DOMAIN>` (ဥပမာ `vpn.example.com`)
   - **Email:** `<YOUR_EMAIL>` (Let's Encrypt အတွက်)
   - **Port:** `443`
3. **"Install"** နှိပ်ပါ။ Certbot က Free SSL Certificate ကို အလိုအလျောက် ထုတ်ယူတပ်ဆင်ပေးသွားပါမည်။
4. ပြီးလျှင် Browser မှ `https://<YOUR_DOMAIN>` ဖြင့် လုံခြုံသော HTTPS Website စာမျက်နှာ ပွင့်လာပါမည်။

---

## ၁၀။ Web Panel အား HTTPS SSL (`https://<YOUR_DOMAIN>:5000`) ဖွင့်လှစ်အသုံးပြုနည်း

NGINX တပ်ဆင်ပြီးပါက Let's Encrypt SSL Certificate များသည် Server ပေါ်ရှိ လမ်းကြောင်းတွင် ရှိနှင့်ပြီး ဖြစ်ပါသည်။ Web Panel ကိုယ်တိုင်အား အစိမ်းရောင်သော့ခလောက် (HTTPS) ဖြင့် လုံခြုံစွာ ဝင်ရောက်နိုင်ရန်:

1. Web Panel ၏ အပေါ်ဘက် Navigation Bar ရှိ **"Settings" (⚙️)** သို့ သွားပါ။
2. **"🔒 SSL / HTTPS Settings"** ကဏ္ဍတွင် အောက်ပါအတိုင်း ဖြည့်ပါ:
   - **ENABLE HTTPS:** [✓] **အမှန်ခြစ်ပေးပါ**
   - **PANEL PORT:** `5000`
   - **DOMAIN NAME:** `<YOUR_DOMAIN>` (ဥပမာ `vpn.example.com`)
   - **SSL CERTIFICATE PATH (.PEM):**
     ```text
     /opt/amnezia/nginx/letsencrypt/live/<YOUR_DOMAIN>/fullchain.pem
     ```
   - **PRIVATE KEY PATH (.PEM):**
     ```text
     /opt/amnezia/nginx/letsencrypt/live/<YOUR_DOMAIN>/privkey.pem
     ```
3. ညာဘက်အောက်ရှိ **"💾 Save changes"** ကို နှိပ်ပါ။
4. VPS Terminal တွင် Service ကို Restart ချပေးပါ:
   ```bash
   sudo systemctl restart amnezia-panel
   ```
5. ယခုအခါ **`https://<YOUR_DOMAIN>:5000`** ဖြင့် လုံခြုံသော HTTPS ဖြင့် တိုက်ရိုက် ဝင်ရောက်နိုင်ပါပြီ။

---

## ၁၁။ VPN Keys / Configs များတွင် IP အစား Domain Name ဖြင့် ထွက်ရှိစေနည်း

ထုတ်ယူသမျှ VPN Keys/Configs များအားလုံးတွင် IP Address အစား Domain Name ဖြင့် ထွက်ရှိစေရန်:

1. Web Panel ရှိ **"Servers"** tab သို့ သွားပါ။
2. မိမိ Server ဘေးရှိ **Edit (ခဲတံပုံ - ✏️)** ကို နှိပ်ပါ။
3. **Host / IP:** နေရာတွင် IP အစား **`<YOUR_DOMAIN>`** (ဥပမာ `vpn.example.com`) ဟု ပြောင်းထည့်ပြီး **Save** လုပ်ပါ။
4. ထိုအခါ Client Connection အသစ် ဆောက်တိုင်း Config ထဲတွင်:
   ```ini
   Endpoint = <YOUR_DOMAIN>:443
   ```
   ဟု Domain Name ဖြင့် အလိုအလျောက် ထွက်လာပါမည်။

---

## 🔄 Upstream Repository မှ Update ဆွဲယူနည်း

နောင်တွင် မူရင်း Developer ဆီမှ Update အသစ်များ ထွက်လာပါက မိမိ Server ပေါ်တွင် Update ရယူရန်:

```bash
cd ~/Amnezia-Web-Panel
git pull upstream main
sudo systemctl restart amnezia-panel
```

---
*Created with ❤️ for Amnezia & Myanmar Internet Freedom.*
