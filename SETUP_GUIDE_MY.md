# Amnezia Web Panel - Setup & Troubleshooting Guide (မြန်မာဘာသာ)

ဤ Guide သည် **Amnezia Web Panel** ကို Linux VPS (Ubuntu/Debian) ပေါ်တွင် စတင်တပ်ဆင်ခြင်းမှသည် လက်တွေ့ကြုံတွေ့ရတတ်သော Error များ၊ Permission ပြဿနာများနှင့် မြန်မာနိုင်ငံ ISP အပိတ်အပင်များကြား အောင်မြင်စွာ ချိတ်ဆက်နိုင်သည်အထိ အဆင့်ဆင့် လက်တွေ့ဖြေရှင်းနည်း အပြည့်အစုံ ဖြစ်ပါသည်။

---

## 📑 မာတိကာ (Table of Contents)
1. [၁။ Linux VPS ပေါ်တွင် Panel စတင်တပ်ဆင်ခြင်း](#၁-linux-vps-ပေါ်တွင်-panel-စတင်တပ်ဆင်ခြင်း)
2. [၂။ Background Service (Systemd) ပြုလုပ်ခြင်း](#၂-background-service-systemd-ပြုလုပ်ခြင်း)
3. [၃။ အရေးကြီးသော User & Sudo Permissions ပြင်ဆင်ခြင်း](#၃-အရေးကြီးသော-user--sudo-permissions-ပြင်ဆင်ခြင်း)
4. [၄။ Docker Package Conflict ဖြေရှင်းနည်း](#၄-docker-package-conflict-ဖြေရှင်းနည်း)
5. [၅။ Panel ထဲတွင် Server ထည့်သွင်းခြင်း](#၅-panel-ထဲတွင်-server-ထည့်သွင်းခြင်း)
6. [၆။ AmneziaWG 3.1 Install လုပ်ခြင်းနှင့် Port ရွေးချယ်မှု](#၆-amneziawg-31-install-လုပ်ခြင်းနှင့်-port-ရွေးချယ်မှု)
7. [၇။ Client App ချိတ်ဆက်ခြင်းနှင့် အရေးကြီးသတိပြုဖွယ်များ](#၇-client-app-ချိတ်ဆက်ခြင်းနှင့်-အရေးကြီးသတိပြုဖွယ်များ)
8. [၈။ လက်တွေ့စစ်ဆေးနည်းများနှင့် Troubleshooting Commands](#၈-လက်တွေ့စစ်ဆေးနည်းများနှင့်-troubleshooting-commands)

---

## ၁။ Linux VPS ပေါ်တွင် Panel စတင်တပ်ဆင်ခြင်း

### အဆင့် ၁.၁: Packages များ သွင်းယူခြင်း
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git python3 python3-pip python3-venv curl
```

### အဆင့် ၁.၂: Repository Clone လုပ်ပြီး Virtual Environment ဆောက်ခြင်း
```bash
cd /root
git clone https://github.com/uzinlay85/Amnezia-Web-Panel.git
cd Amnezia-Web-Panel

# Virtual Environment ဖန်တီးပြီး dependencies သွင်းပါ
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

---

## ၂။ Background Service (Systemd) ပြုလုပ်ခြင်း

Panel ကို ၂၄ နာရီ မပြတ် background တွင် run နေစေရန်နှင့် Server reboot ကျသွားပါက အလိုအလျောက် ပွင့်လာစေရန် Service ဆောက်ပါမည်။

```bash
cat << 'EOF' > /etc/systemd/system/amnezia-panel.service
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
EOF
```

Service ကို စတင်ပါ:
```bash
sudo systemctl daemon-reload
sudo systemctl start amnezia-panel
sudo systemctl enable amnezia-panel
sudo systemctl status amnezia-panel
```

---

## ၃။ အရေးကြီးသော User & Sudo Permissions ပြင်ဆင်ခြင်း

### ⚠️ ကြုံတွေ့ရတတ်သော Error:
> `sudo: a terminal is required to read the password; either use the -S option to read from standard input or configure an askpass helper sudo: a password is required`

### 💡 ဖြစ်ရသည့် အကြောင်းရင်း:
Panel က SSH မှတစ်ဆင့် Protocol များကို Install လုပ်သည့်အခါ `sudo` အခွင့်အရေး လိုအပ်ပါသည်။ အသုံးပြုသော User (ဥပမာ `zinko`) သည် password မရိုက်ဘဲ sudo run ခွင့် (NOPASSWD) မရရှိထားပါက ဤ Error တက်ပြီး ရပ်သွားတတ်ပါသည်။

### 🛠️ ဖြေရှင်းနည်း:
VPS Terminal (root) ထဲတွင် အောက်ပါ command များ run ပေးပါ:

```bash
# User အား sudo password မတောင်းစေရန် သတ်မှတ်ခြင်း
echo "zinko ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/zinko
chmod 0440 /etc/sudoers.d/zinko

# User အား sudo နှင့် docker group များထဲ ထည့်သွင်းခြင်း
usermod -aG sudo,docker zinko

# စမ်းသပ်စစ်ဆေးခြင်း (Password မတောင်းဘဲ container list ပြရမည်)
su - zinko -c "sudo docker ps"
```

---

## ၄။ Docker Package Conflict ဖြေရှင်းနည်း

### ⚠️ ကြုံတွေ့ရတတ်သော Error:
> `The following packages have unmet dependencies: containerd.io : Conflicts: containerd`

### 🛠️ ဖြေရှင်းနည်း:
Ubuntu တွင် Official Docker Repository ရှိနေချိန် `docker.io` အစား `docker-ce` ကို အောက်ပါအတိုင်း သွင်းပေးရပါမည်:

```bash
apt remove -y containerd
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl start docker
systemctl enable docker
docker --version
```

---

## ၅။ Panel ထဲတွင် Server ထည့်သွင်းခြင်း

1. Browser မှတစ်ဆင့် `http://<YOUR_VPS_IP>:5000` သို့ သွားပါ။
2. **Default Login:** `admin` / `admin` (Login ဝင်ပြီးပါက Users menu တွင် password ချက်ချင်း ပြောင်းပါ)။
3. **"Add Server"** ကို နှိပ်ပြီး:
   - **Server Name:** `qqq-us` (မိမိကြိုက်နှစ်သက်ရာ)
   - **Host:** VPS IP (ဥပမာ `50.114.172.236`)
   - **SSH Port:** VPS ၏ SSH Port (ဥပမာ `22` သို့မဟုတ် `2213`)
   - **Username:** `zinko` (သို့မဟုတ် `root`)
   - **Password:** User ၏ SSH Password
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
peer: k+FTUmZGoIXOR7P0sw7SRF5DRZDFTqPJuGuBHlWlRlc=
  endpoint: 37.111.41.89:26199
  allowed ips: 10.8.1.2/32
  latest handshake: 46 seconds ago
  transfer: 19.04 KiB received, 40.79 KiB sent
```

- **`latest handshake:`** ပေါ်လာခြင်း = လုံခြုံရေးသော့ အောင်မြင်စွာ ဖလှယ်ပြီးပြီ။
- **`transfer: X KiB received, X KiB sent:`** ပေါ်လာခြင်း = အင်တာနက် Data အမှန်တကယ် အပြန်အလှန် စီးဆင်းနေပြီ ဖြစ်ပါသည်။

---

## 🔄 Upstream Repository မှ Update ဆွဲယူနည်း

နောင်တွင် မူရင်း Developer ဆီမှ Update အသစ်များ ထွက်လာပါက မိမိ Server ပေါ်တွင် Update ရယူရန်:

```bash
cd /root/Amnezia-Web-Panel
git pull upstream main
sudo systemctl restart amnezia-panel
```

---
*Created with ❤️ for Amnezia & Myanmar Internet Freedom.*
