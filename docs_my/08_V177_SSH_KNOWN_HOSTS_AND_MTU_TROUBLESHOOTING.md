# Amnezia Web Panel v1.7.7 - SSH Known Hosts, MTU/MSS Clamping နှင့် Outbound Network ပြဿနာများ ဖြေရှင်းနည်းလမ်းညွှန်
(Amnezia Web Panel v1.7.7 SSH Host Key Verification, MTU/MSS Clamping & Outbound Network Troubleshooting Guide)

---

## 📌 နိဒါန်း (Overview)

Amnezia Web Panel ကို **Version v1.7.7** သို့ အဆင့်မြှင့်တင်ပြီးနောက်နှင့် Cloud VPS များ (Cloudflare-Protected IP အသုံးပြုသော VPS များ) တွင် ကြုံတွေ့ရတတ်သည့် အဓိက ကွန်ရက်နှင့် ချိတ်ဆက်မှုဆိုင်ရာ ပြဿနာ (၃) ခု၏ အကြောင်းရင်းများနှင့် လက်တွေ့ အောင်မြင်စွာ ဖြေရှင်းခဲ့သော နည်းလမ်းများကို ဤလမ်းညွှန်တွင် မှတ်တမ်းတင်ထားပါသည်။

---

## ၁။ SSH "Server not found in known_hosts" နှင့် "backing off 300s/60s" ပြဿနာ

### (က) ပြဿနာ လက္ခဏာရပ်များ:
* Panel တွင် ဆာဗာကို Check လုပ်ချိန် သို့မဟုတ် Protocol သွင်းချိန်တွင်:
  ```text
  Connection failed: Server '[192.238.244.231]:2213' not found in known_hosts
  ✕ Error: SSH to awg3-serverreca.truehand.top recently failed, backing off 300s
  ✕ Error: SSH to rnawgpannel.truehand.top recently failed, backing off 60s
  ```
* ဆာဗာ အလုပ်လုပ်နေသော်လည်း Panel ပေါ်တွင် အနီရောင် ပြနေခြင်း။

### (ခ) ဖြစ်ပွားရသည့် အကြောင်းရင်း (Root Cause):
1. **v1.7.7 SSH Host Key Verification စနစ်သစ်:**
   v1.7.7 တွင် Man-in-the-Middle attack များကို ကာကွယ်ရန် Panel ၏ SSH Manager တွင် `RejectPolicy()` ကို စတင် အသုံးပြုထားသည်။ Panel သည် `~/.ssh/known_hosts` သို့မဟုတ် `ssh_known_hosts` ထဲ၌ ကြိုတင် မှတ်ပုံမတင်ထားသော ဆာဗာများကို ချိတ်ဆက်ခွင့် လုံးဝ ပယ်ချသည်။
2. **Circuit Breaker (Backoff Cooldown):**
   SSH ချိတ်ဆက်မှု တစ်ကြိမ် မအောင်မြင်ပါက ဆာဗာကို မကြာခဏ သွားရောက် မနှောင့်ယှက်စေရန် Panel က ၃၀ စက္ကန့်၊ ၆၀ စက္ကန့်၊ ၁၂၀ စက္ကန့် မှ အများဆုံး စက္ကန့် ၃၀၀ (၅ မိနစ်) အထိ အလိုအလျောက် ဆိုင်းငံ့ (backing off) ထားသည်။
3. **SSH Port မကိုက်ညီခြင်း:**
   ဆာဗာများတွင် လုံခြုံရေးအရ Default Port `22` မဟုတ်ဘဲ Custom Port (ဥပမာ `2213`) သုံးထားသော်လည်း Panel ထဲတွင် Port `22` သတ်မှတ်မိထားခြင်း။

### (ဂ) အပြီးသတ် ဖြေရှင်းနည်း:
1. **SSH Port အမှန် စစ်ဆေးခြင်း:**
   ```bash
   sudo ss -tulpn | grep ssh
   ```
2. **Web Panel တွင် Port ပြင်ဆင်ခြင်း:**
   Panel ၏ **Servers** စာမျက်နှာတွင် သက်ဆိုင်ရာ ဆာဗာကို **Edit** နှိပ်၍ **SSH Port** ကို အမှန်တကယ် ပွင့်နေသော Port (ဥပမာ `2213`) ဟု ပြောင်းလဲ Save လုပ်ပါ။
3. **Host Key ကို မှတ်သားပြီး 300s Cooldown ကို ချက်ချင်း ရှင်းလင်းခြင်း:**
   ```bash
   sudo bash -c '
   python3 -c "
   import json, subprocess, os

   path = \"/home/zinko/Amnezia-Web-Panel\"
   if not os.path.isdir(path):
       path = \"/root/Amnezia-Web-Panel\"

   data_file = os.path.join(path, \"data.json\")
   if os.path.isfile(data_file):
       with open(data_file) as f:
           data = json.load(f)
       for s in data.get(\"servers\", []):
           host = s.get(\"host\")
           port = s.get(\"port\", 22)
           print(f\"Scanning {host}:{port}...\")
           res = subprocess.run(f\"ssh-keyscan -p {port} {host}\", shell=True, capture_output=True, text=True)
           if res.stdout:
               for target in [\"/home/zinko/.ssh/known_hosts\", \"/root/.ssh/known_hosts\", os.path.join(path, \"ssh_known_hosts\")]:
                   os.makedirs(os.path.dirname(target), exist_ok=True)
                   with open(target, \"a\") as out:
                       out.write(res.stdout)
                   os.chmod(target, 0o644)
               print(f\"✓ Enrolled {host}:{port}\")
   "
   systemctl restart amnezia-panel
   '
   ```

---

## ၂။ Cloudflare-Protected IP တွင် Docker Build "TLS Handshake Timeout" ဖြစ်ပွားခြင်း

### (က) ပြဿနာ လက္ခဏာရပ်များ:
* Panel မှ AmneziaWG 3.1 သို့မဟုတ် Protocols များကို တပ်ဆင်ချိန်တွင်:
  ```text
  failed to do request: Head "https://registry-1.docker.io/v2/...": net/http: TLS handshake timeout
  WARNING: fetching https://dl-cdn.alpinelinux.org/alpine/... temporary error (try again later)
  ERROR: unable to select packages: conntrack-tools (no such package)
  ```
* Docker pull သို့မဟုတ် Container တည်ဆောက်ချိန်တွင် ဒေါင်းလုဒ် မဆွဲနိုင်ဘဲ ရပ်တန့်သွားခြင်း။

### (ခ) ဖြစ်ပွားရသည့် အကြောင်းရင်း (Root Cause):
Cloudflare Magic Transit သို့မဟုတ် DDoS-Protected GRE Tunnel အသုံးပြုသော VPS များတွင် Tunnel Header များကြောင့် အမြင့်ဆုံး Packet Size (MTU) သည် နဂို `1500` မဟုတ်ဘဲ `1476` သို့မဟုတ် ပိုမို လျော့နည်းသွားသည်။ Packet Size ပိုကြီးနေသည့်အခါ Router က Silent Drop လုပ်ပစ်သဖြင့် TLS Handshake Timeout ဖြစ်ရခြင်း ဖြစ်သည်။

### (ဂ) အပြီးသတ် ဖြေရှင်းနည်း:

#### ၁။ Interface MTU နှင့် TCP MSS Clamping သတ်မှတ်ခြင်း:
```bash
sudo ip link set dev ens17 mtu 1476
sudo iptables -t mangle -I POSTROUTING 1 -o ens17 -p tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1361:65535 -j TCPMSS --set-mss 1360
sudo iptables -t mangle -I FORWARD 1 -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
```

#### ၂။ Docker Daemon MTU နှင့် DNS သတ်မှတ်ခြင်း:
Docker Container အတွင်းပိုင်းသို့ပါ MTU 1400 သက်ရောက်စေရန်:
```bash
sudo bash -c 'cat << "EOF" > /etc/docker/daemon.json
{
  "mtu": 1400,
  "dns": ["8.8.8.8", "1.1.1.1"]
}
EOF'
sudo systemctl restart docker
```

#### ၃။ စမ်းသပ်ခြင်း:
```bash
docker run --rm alpine apk update
```
(`OK: ... distinct packages available` ဟု ထွက်လာပါက အပြည့်အဝ အောင်မြင်ပါပြီ)။

#### ၄။ Server Reboot လုပ်ပြီးတိုင်း မပျောက်စေရန် အပြီးတိုင် သိမ်းဆည်းနည်း:
```bash
sudo apt-get install -y iptables-persistent
sudo netfilter-persistent save

sudo bash -c 'cat << "EOF" > /etc/networkd-dispatcher/routable.d/50-ens17-mtu.sh
#!/bin/bash
ip link set dev ens17 mtu 1476
EOF
chmod +x /etc/networkd-dispatcher/routable.d/50-ens17-mtu.sh'
```

---

## ၃။ VPS Outbound Network Block (အပြင်သို့ အင်တာနက် လုံးဝ ထွက်မရခြင်း)

### (က) ပြဿနာ လက္ခဏာရပ်များ:
* VPS ထဲသို့ SSH ပုံမှန် ဝင်၍ရသည်၊ Local Gateway (`50.114.172.1`) ကို ping မိသည်။
* သို့သော် `ping 8.8.8.8` (100% packet loss) ဖြစ်ခြင်း၊ `Could not resolve host: github.com` ဖြစ်ပြီး Auto Update မရခြင်း။

### (ခ) စစ်ဆေးအတည်ပြုနည်း (Diagnostic):
DNS ကြောင့်လား သို့မဟုတ် IP လမ်းကြောင်းကြောင့်လား ခွဲခြားရန် Direct IP ဖြင့် စစ်ဆေးခြင်း:
```bash
curl -Iv --connect-timeout 5 https://1.1.1.1
```
* အကယ်၍ `Failed to connect to 1.1.1.1 port 443: Timeout was reached` ဟု ထွက်လာပါက VPS ၏ Router အဆင့်တွင် Egress Block (Outbound ပိတ်မိနေခြင်း) ဖြစ်သည်။

### (ဂ) ဖြေရှင်းနည်း:
Cloud Provider (QQG.NET စသည်) ထံသို့ Support Ticket တင်၍ Outbound Restriction စစ်ဆေးပေးရန် သို့မဟုတ် Clean IP ဖြင့် လဲလှယ်ပေးရန် တောင်းဆိုရမည်ဖြစ်သည်။

---

## ၄။ ဆာဗာ အလုံးစုံ စစ်ဆေးသည့် One-Click Diagnostic Script

ဆာဗာ၏ ကျန်းမာရေးအခြေအနေ (CPU, RAM, Disk, Outbound Internet, Docker Containers, Web Panel Service နှင့် Listening Ports) အားလုံးကို စက္ကန့်ပိုင်းအတွင်း ကြည့်ရှုနိုင်သည့် စစ်ဆေးရေး Script ဖြစ်ပါသည်:

```bash
sudo bash -c '
echo -e "\n========================================================"
echo -e "         🖥️  SERVER STATUS & HEALTH CHECK              "
echo -e "========================================================"

echo -e "\n📌 [1] System Information:"
echo -e "  • Hostname : $(hostname)"
echo -e "  • Public IP: $(curl -s4m 3 ifconfig.me || ip route get 1.1.1.1 | awk "{print \$7}")"
echo -e "  • Uptime   : $(uptime -p)"

echo -e "\n📊 [2] Resource Usage (CPU / RAM / Disk):"
echo -e "  • CPU Load : $(uptime | awk -F "load average:" "{print \$2}")"
echo -e "  • RAM Usage: $(free -h | awk "/^Mem:/ {print \$3 \" / \" \$2 \" (Free: \" \$4 \")\"}")"
echo -e "  • Disk Free: $(df -h / | awk "NR==2 {print \$3 \" used / \" \$2 \" (Available: \" \$4 \")\"}")"

echo -e "\n🌐 [3] Internet & Network Connectivity:"
if ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
    echo -e "  • Outbound Internet: ✅ Normal (Ping 8.8.8.8 OK)"
else
    echo -e "  • Outbound Internet: ❌ Blocked (Packet Loss)"
fi

echo -e "\n🚀 [4] Amnezia Web Panel Service:"
if systemctl is-active --quiet amnezia-panel; then
    echo -e "  • Panel Status: ✅ Active (Running)"
else
    echo -e "  • Panel Status: ❌ Inactive / Stopped"
fi

echo -e "\n🐳 [5] Active Docker Containers (VPN Services):"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "  No docker containers running."

echo -e "\n🔌 [6] Key Listening Ports:"
ss -tulpn | grep -E ":(5000|2213|22|55424|8483|3000|3001)" | awk "{print \"  • Port \" \$5 \" (\" \$1 \") -> PID: \" \$7}" || echo "  None"

echo -e "========================================================\n"
'
```
