# VPS Pre-Flight Checker & Auto-Optimizer Guide (မြန်မာဘာသာ)

ဤ Script သည် **Amnezia Web Panel** နှင့် VPN Protocols (AmneziaWG, Xray, WireGuard) များ စတင်မထည့်သွင်းမီ Linux VPS (Ubuntu / Debian) တွင် လိုအပ်သော **System Pre-requisites များကို စစ်ဆေးပေးပြီး လိုအပ်သည်များကို အလိုအလျောက် ၁၀၀% အပြည့်အစုံ ပြင်ဆင်/ဖြည့်စွက်ပေးမည့် One-Click Optimizer Script** ဖြစ်ပါသည်။

ယခင်က ကြုံတွေ့ခဲ့ရသော RAM ပြည့်ပြီး စနစ်ပျက်ကျခြင်း (OOM Crash)၊ Packet loss များ၍ လိုင်းလေးခြင်း၊ Docker Permission Error တက်ခြင်းနှင့် Firewall ပိတ်မိခြင်းများကို ဤ Script တစ်ခုတည်းဖြင့် အပြီးတိုင် ကြိုတင်ကာကွယ် ဖြေရှင်းပေးပါသည်။

---

## ⚡ One-Click ဖြင့် အသုံးပြုနည်း

Server အသစ် (Fresh VPS) ပေါ်တွင် အောက်ပါ command တစ်ကြောင်းတည်းကို Run လိုက်ရုံဖြင့် စနစ်တစ်ခုလုံး အလိုအလျောက် စစ်ဆေးပြီး အကောင်းဆုံး အခြေအနေသို့ ပြင်ဆင်ပေးသွားပါမည်:

```bash
curl -sSL https://raw.githubusercontent.com/uzinlay85/Amnezia-Web-Panel/main/scripts/vps_optimizer.sh | sudo bash
```

*(သို့မဟုတ် Repository ကို Clone လုပ်ထားပြီးဖြစ်ပါက အောက်ပါအတိုင်း run နိုင်ပါသည်):*
```bash
cd ~/Amnezia-Web-Panel
sudo bash scripts/vps_optimizer.sh
```

---

## 🛠️ ဤ Script က အလိုအလျောက် ပြင်ဆင်ပေးမည့် အချက် (၇) ချက်

### ၁။ Google BBR & Fair Queueing (FQ) ဖွင့်လှစ်ခြင်း
* **ဘာကြောင့် လိုအပ်သလဲ:** မြန်မာနိုင်ငံရှိ ISP များ (MPT, Atom, Ooredoo, MyTel, Fiber) သည် နိုင်ငံတကာ gateway နှင့် ချိတ်ဆက်ရာတွင် Packet loss အလွန်များတတ်ပါသည်။ Google ၏ BBR algorithm သည် packet loss ဖြစ်သော်လည်း လိုင်းမကျစေဘဲ အမြန်ဆုံး bandwidth ဖြင့် ဆွဲတင်ပေးပါသည်။
* **အလိုအလျောက် ပြုလုပ်ပေးချက်:** `net.ipv4.tcp_congestion_control = bbr` နှင့် `net.core.default_qdisc = fq` ကို အမြဲတမ်း active ဖြစ်အောင် system-level တွင် ထည့်သွင်းပေးပါသည်။

### ၂။ IPv4 & IPv6 Packet Forwarding
* **ဘာကြောင့် လိုအပ်သလဲ:** VPN Client ဖုန်း/ကွန်ပျူတာများဆီမှ လာသော အင်တာနက် traffic များကို VPS မှတစ်ဆင့် ပြင်ပအင်တာနက်သို့ လမ်းကြောင်းလွှဲ (forward) ပေးရန် လိုအပ်ပါသည်။
* **အလိုအလျောက် ပြုလုပ်ပေးချက်:** `net.ipv4.ip_forward = 1` နှင့် `net.ipv6.conf.all.forwarding = 1` ကို ဖွင့်ပေးပါသည်။

### ၃။ 4GB Swap Memory အလိုအလျောက် ဆောက်ပေးခြင်း (Anti-Crash OOM Protection)
* **ဘာကြောင့် လိုအပ်သလဲ:** RAM 1GB / 2GB သာရှိသော VPS များတွင် VPN user များပြားလာပါက RAM ပြည့်လျှံပြီး Linux OS က Docker daemon သို့မဟုတ် Web Panel ကို အလိုအလျောက် သတ်ပစ် (kill) သဖြင့် စနစ်တစ်ခုလုံး ပျက်ကျတတ်ပါသည်။
* **အလိုအလျောက် ပြုလုပ်ပေးချက်:** VPS တွင် Swap memory နည်းနေပါက 4GB Swapfile ကို စနစ်တကျ ဖန်တီးပေးပြီး reboot ကျပြီးတိုင်းလည်း အမြဲအလုပ်လုပ်နေစေရန် `/etc/fstab` တွင် ထည့်သွင်းပေးပါသည်။

### ၄။ Docker Engine စစ်ဆေးခြင်းနှင့် User Permission ပြင်ဆင်ပေးခြင်း
* **ဘာကြောင့် လိုအပ်သလဲ:** Docker မရှိသေးပါက သွင်းပေးခြင်း၊ containerd version conflict ဖြစ်နေပါက ရှင်းလင်းပေးခြင်းနှင့် `permission denied while trying to connect to the docker API` error မတက်စေရန် လက်ရှိ user အား `docker` group ထဲသို့ အလိုအလျောက် ထည့်သွင်းပေးပါသည်။
* **ရလဒ်:** နောင်တွင် `docker ps` စသည့် command များကို `sudo` ခံစရာမလိုဘဲ တိုက်ရိုက် run နိုင်ပါမည်။

### ၅။ Safe UFW Firewall ချိန်ညှိခြင်း (SSH Port မပိတ်မိစေရန် ကာကွယ်မှုအပြည့်)
* **ဘာကြောင့် လိုအပ်သလဲ:** Firewall ဖွင့်လိုက်စဉ် SSH Port ပါ ပိတ်မိသွားပြီး Server ထဲ ဝင်မရတော့သည့် အန္တရာယ်ကို လုံးဝ ကာကွယ်ပေးပါသည်။
* **အလိုအလျောက် ပြုလုပ်ပေးချက်:**
  - လက်ရှိ သုံးစွဲနေသော SSH Port (ဥပမာ Default `22` သို့မဟုတ် Custom Port `2213`) ကို အလိုအလျောက် detect လုပ်ပြီး အရင်ဆုံး ဖွင့်ပေးပါသည်။
  - VPN အတွက် မရှိမဖြစ်လိုအပ်သော Ports များ:
    - **`80/tcp` & `443/tcp`**: HTTP/HTTPS Web Server & Xray (VLESS Reality)
    - **`443/udp`**: AmneziaWG (ဖုန်းလိုင်းများ မပိတ်နိုင်သော UDP Port)
    - **`5000/tcp`**: Amnezia Web Panel Dashboard
    - **`55424/udp`**: AmneziaWG Default Port
  - အထက်ပါ Ports များကို စနစ်တကျ ဖွင့်ပြီးမှ UFW ကို active လုပ်ပေးပါသည်။

### ၆။ System Limits (ulimit / File Descriptors) တိုးမြှင့်ပေးခြင်း
* VPN ချိတ်ဆက်မှု ထောင်ပေါင်းများစွာ တစ်ပြိုင်နက် လက်ခံနိုင်စေရန် Max open files limit ကို `65535` အထိ မြှင့်တင်ပေးပါသည်။

### ၇။ မရှိမဖြစ် Software များ အလိုအလျောက် သွင်းပေးခြင်း
* Web Panel အတွက် လိုအပ်သော `python3`, `python3-pip`, `python3-venv`, `git`, `curl`, `jq`, `ufw`, `iptables` တို့ကို တစ်ပါတည်း သွင်းယူပေးပါသည်။

---

## 📋 စစ်ဆေးပြီးစီးပါက နောက်တစ်ဆင့် ဆက်လက်ဆောင်ရွက်ရန်

Script run ပြီးပါက သင်၏ VPS သည် အပြည့်အဝ အသင့်ဖြစ်သွားပြီဖြစ်၍ Amnezia Web Panel ကို စတင် Run နိုင်ပါပြီ:

```bash
# Docker group permission ချက်ချင်း အာနိသင်သက်ရောက်စေရန်:
newgrp docker

# Web Panel ကို စတင် Run ခြင်း:
cd ~/Amnezia-Web-Panel
source venv/bin/activate
pip install -r requirements.txt
sudo systemctl restart amnezia-panel
```

---
*Created with ❤️ for Amnezia & Myanmar Internet Freedom.*
