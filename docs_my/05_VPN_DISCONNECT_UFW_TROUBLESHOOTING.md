# AmneziaWG & Outline VPN - ခဏသုံးပြီးနောက် Webpage ဖွင့်မရတော့သည့် ပြဿနာ ဖြေရှင်းနည်းလမ်းညွှန်
(AmneziaWG & Outline UFW Forwarding Drop Troubleshooting & Permanent Fix)

---

## ၁။ ပြဿနာ လက္ခဏာရပ်များ (Problem Symptoms)

* **VPN အစပိုင်းတွင် ပုံမှန်သုံးနိုင်ခြင်း:** VPS ပေါ်တွင် AmneziaWG (သို့မဟုတ် Outline) ကို အသစ်တပ်ဆင်ချိန်တွင် အင်တာနက် ပုံမှန် သုံး၍ရသည်။
* **နာရီပိုင်းကြာလျှင် ရပ်သွားခြင်း:** နာရီပိုင်းခန့်ကြာပြီးနောက် ဖုန်း သို့မဟုတ် ကွန်ပျူတာ Client App တွင် **"Connected" (အစိမ်းရောင် ချိတ်ဆက်ထားဆဲ)** ဟု ပြနေသော်လည်း Webpage များ၊ လူမှုကွန်ရက်များနှင့် အင်တာနက် လုံးဝ ဖွင့်မရတော့ခြင်း (No Internet Access)။
* **SSH ပုံမှန် ဝင်ရောက်နိုင်ခြင်း:** အဆိုပါပြဿနာ ဖြစ်နေစဉ် VPS ဆာဗာသို့ SSH (Xshell) ဖြင့် ပုံမှန် ဝင်ရောက်နိုင်ပြီး ဆာဗာသည် အင်တာနက် မပြတ်တောက်ခြင်း။
* **Handshake မိနေဆဲဖြစ်ခြင်း:** ဆာဗာထဲတွင် `sudo docker exec amnezia-awg awg show` စစ်ဆေးကြည့်ပါက ဖုန်းနှင့် ဆာဗာကြား Handshake အဆက်အသွယ် ရနေဆဲဖြစ်ခြင်း (`latest handshake: XX seconds ago`)။

---

## ၂။ ဖြစ်ပွားရသည့် အဓိက အကြောင်းရင်း (Root Cause Analysis)

### 🔹 UFW Firewall နှင့် Docker Forwarding ပဋိပက္ခ (Conflict)
Ubuntu Linux တွင် UFW (Uncomplicated Firewall) ကို ဖွင့်ထားပါက Default အားဖြင့် Forwarding Policy ကို ပိတ်ထားလေ့ရှိသည် (`DEFAULT_FORWARD_POLICY="DROP"`):

1. **စတင် Run ချိန်:** AmneziaWG သို့မဟုတ် Outline ကို Docker ဖြင့် စတင် Run သောအခါ Docker Daemon သည် Linux Kernel ၏ `iptables` ထဲသို့ Forwarding Rule များကို ထိပ်ဆုံးမှ ယာယီ ထည့်သွင်းပေးလိုက်သည်။ ထို့ကြောင့် အစပိုင်းတွင် VPN ပုံမှန် အလုပ်လုပ်သည်။
2. **နာရီပိုင်းကြာချိန်:** နာရီပိုင်းကြာပြီးနောက် System/Network Service များ Refresh ဖြစ်ချိန် (သို့မဟုတ် UFW service ပြန်လည် run ချိန်) တွင် UFW က ၎င်း၏ မူလသတ်မှတ်ချက်ဖြစ်သော `DROP` မူဝါဒကို ပြန်လည် အသက်သွင်းလိုက်သည်။
3. **ရလဒ်:** 
   * Handshake ပို့သည့် Port (`55424/udp`) မှာ UFW တွင် Allow ပေးထား၍ ဖုန်းနှင့် ဆာဗာ Handshake မိနေဆဲဖြစ်ပြီး App တွင် **"Connected"** ဟု ပြနေသည်။
   * သို့သော် ဖုန်းမှတဆင့် ပြင်ပအင်တာနက်ဆီသို့ Data ပို့ပေးရမည့် **Forwarding Packet (Tunnel -> WAN Interface `ens17`)** များကို UFW က အလိုအလျောက် **DROP (ပယ်ချ)** ပစ်လိုက်သဖြင့် မည်သည့် Webpage မှ ဖွင့်မရတော့ခြင်း ဖြစ်သည်။

---

## ၃။ အခြေအနေ စစ်ဆေးအတည်ပြုနည်း (Verification Commands)

သင့် VPS တွင် အဆိုပါ ပြဿနာ ဟုတ်/မဟုတ် စစ်ဆေးရန် အောက်ပါ Command များကို သုံးနိုင်သည်-

### (က) Client နှင့် ဆာဗာ Handshake မိမမိ စစ်ဆေးခြင်း
```bash
sudo docker exec amnezia-awg awg show
```
* `latest handshake: 48 seconds ago` ဟု ပြနေပါက ဖုန်းနှင့် ဆာဗာကြား အဆက်အသွယ် လုံးဝရနေပြီး ISP က ပိတ်ထားခြင်း မဟုတ်ကြောင်း အတည်ပြုနိုင်သည်။

### (ခ) UFW Forward Policy စစ်ဆေးခြင်း
```bash
grep -i "default_forward_policy" /etc/default/ufw
```
* အကယ်၍ `DEFAULT_FORWARD_POLICY="DROP"` ဖြစ်နေပါက အဆိုပါ Bug ကြောင့် အင်တာနက် မထွက်ခြင်း ဖြစ်သည်။

### (ဂ) Linux Kernel IP Forwarding စစ်ဆေးခြင်း
```bash
cat /proc/sys/net/ipv4/ip_forward
```
* `1` ဖြစ်ရမည် (`0` ဖြစ်နေပါက အင်တာနက် forward မလုပ်နိုင်ပါ)။

---

## ၄။ အပြီးတိုင် ပြင်ဆင်နည်းအဆင့်ဆင့် (Permanent Step-by-Step Fix)

Xshell (သို့မဟုတ် SSH Terminal) ထဲတွင် အောက်ပါ Command များကို အစဉ်လိုက် ရိုက်ထည့်ပါ:

### အဆင့် (၁) - UFW Forward Policy ကို "ACCEPT" ပြောင်းလဲခြင်း
```bash
sudo sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw
```

### အဆင့် (၂) - UFW sysctl configuration တွင် IP Forwarding အမြဲတမ်း ဖွင့်ထားခြင်း
```bash
sudo sed -i 's/#net\/ipv4\/ip_forward=1/net\/ipv4\/ip_forward=1/' /etc/ufw/sysctl.conf
```

### အဆင့် (၃) - System-wide IP Forwarding ကို အသက်သွင်းခြင်း
```bash
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-ip-forward.conf
sudo sysctl -p /etc/sysctl.d/99-ip-forward.conf
```

### အဆင့် (၄) - UFW ကို Reload ပြုလုပ်ပြီး Docker ကို Restart ချခြင်း
```bash
sudo ufw reload
sudo systemctl restart docker
```

---

## ၅။ တစ်ကြောင်းတည်း အမြန်ပြင်ဆင်နိုင်သော Command (One-Liner Command)

နောက်နောင် VPS အသစ်များတွင်ဖြစ်စေ၊ အမြန်ပြင်ဆင်လိုပါကဖြစ်စေ အောက်ပါ One-Liner ကို ကူးယူ၍ Run နိုင်ပါသည်:

```bash
sudo sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw && sudo sed -i 's/#net\/ipv4\/ip_forward=1/net\/ipv4\/ip_forward=1/' /etc/ufw/sysctl.conf && echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-ip-forward.conf && sudo sysctl -p /etc/sysctl.d/99-ip-forward.conf && sudo ufw reload && sudo systemctl restart docker
```

---

## ၆။ အောင်မြင်စွာ ပြင်ဆင်ပြီးစီးကြောင်း ပြန်လည်စစ်ဆေးခြင်း

ပြင်ဆင်ပြီးပါက အောက်ပါ Command ဖြင့် ပြန်လည်စစ်ဆေးပါ:

```bash
grep -i "default_forward_policy" /etc/default/ufw
```
**မျှော်လင့်ထားသည့် အဖြေ:**
```text
DEFAULT_FORWARD_POLICY="ACCEPT"
```

ယခုအခါ UFW Firewall သည် AmneziaWG နှင့် Outline VPN များ၏ အင်တာနက် Traffic Forwarding ကို ပိတ်ချတော့မည်မဟုတ်ဘဲ အချိန်မည်မျှကြာကြာ ချိတ်ဆက်ထားစေကာမူ အင်တာနက် မပြတ်ဘဲ အမြဲတမ်း ပုံမှန် အသုံးပြုနိုင်မည် ဖြစ်ပါသည်။
