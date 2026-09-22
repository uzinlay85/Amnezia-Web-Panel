# 3X-UI & Cloudflare CDN (VLESS-WebSocket) 1-Click အပြည့်အစုံ တပ်ဆင်အသုံးပြုနည်း လမ်းညွှန်
(Production Verified: Bypass Myanmar ISP DPI & Strict VPS BGP DDoS Null-Routes / Blacklists)

---

## ၁။ နိဒါန်းနှင့် ပြဿနာဖြေရှင်းနိုင်မှု (Overview & Architecture)

အချို့သော Budget VPS များ (ဥပမာ Fastnet Data, ColoCrossing $15/yr "No defense" Plan များ) တွင် WireGuard (AmneziaWG) သို့မဟုတ် VLESS-Reality ကို တိုက်ရိုက် run သည့်အခါ Data ပမာဏ ရာနှင့်ချီ စီးဆင်းသွားသည်နှင့် **မြန်မာပြည် ISP (ATOM/MPT) ၏ DPI ပိတ်ဆို့မှု** သို့မဟုတ် **VPS Provider ၏ BGP DDoS Null-Route (ယာယီ ကွန်ရက်ဖြတ်တောက်ခြင်း)** ကြောင့် နာရီပိုင်းအတွင်း အင်တာနက် လိုင်းကျသွားလေ့ရှိပါသည်။

ဤပြဿနာကို ၁၀၀% အပြီးတိုင် ဖြေရှင်းနိုင်ရန်အတွက် **Cloudflare CDN + VLESS-WebSocket (WS)** စနစ်ကို အသုံးပြုရပါသည်:

```
[ဖုန်း/ကွန်ပျူတာ (Client)] 
         ⬇ (ISP က Cloudflare IP ကိုသာ မြင်ရသည် - VPS IP အစစ်ကို မမြင်ရပါ)
[Cloudflare CDN (Proxied: ON)]
         ⬇ (Cloudflare မှ VPS သို့ တရားဝင် Web Traffic အဖြစ်သာ ပို့ပေးသည် - BGP Null-Route လုံးဝ မကျပါ)
[VPS Server (3X-UI: Port 2053)]
```

---

## ၂။ အခြားဆာဗာများတွင်ပါ အသုံးပြုနိုင်သော 1-Click Script

သင့် Project ထဲရှိ `scripts/install_3xui_cloudflare.sh` ကို အသုံးပြု၍ မည်သည့် Ubuntu/Debian ဆာဗာတွင်မဆို ၁ မိနစ်အတွင်း အလိုအလျောက် သွင်းယူနိုင်ပါသည်။

### ဆာဗာသစ်တွင် Run ရန် Command:
```bash
cat << 'EOF' > install_3xui_cloudflare.sh && bash install_3xui_cloudflare.sh
EOF
```
*(သို့မဟုတ် `scripts/install_3xui_cloudflare.sh` ဖိုင်ကို ဆာဗာပေါ်သို့ upload တင်၍ `bash install_3xui_cloudflare.sh` ဟု Run နိုင်ပါသည်)*

---

## ၃။ အဆင့်ဆင့် လက်တွေ့ တပ်ဆင်အသုံးပြုနည်း (Step-by-Step Guide)

### အဆင့် (၁) - Cloudflare တွင် DNS နှင့် SSL ချိန်ညှိခြင်း
1. [Cloudflare Dashboard](https://dash.cloudflare.com) သို့ ဝင်ရောက်ပါ။
2. မိမိ Domain ထဲရှိ **DNS -> Records** သို့ သွားပြီး **Add record** ကို နှိပ်ပါ:
   * **Type:** `A`
   * **Name:** `qqg` (သို့မဟုတ် မိမိနှစ်သက်ရာ Subdomain)
   * **IPv4 address:** `50.114.172.236` (သင့် VPS IP)
   * **Proxy status:** **Proxied (လိမ္မော်ရောင် တိမ်တိုက်ပုံ On ထားပါ)**
3. **Save** ကို နှိပ်ပါ။
4. ဘယ်ဘက် Menu ရှိ **SSL/TLS** သို့ သွားပြီး Encryption mode ကို **Flexible** ထားပေးပါ။

---

### အဆင့် (၂) - VPS တွင် 1-Click Script ဖြင့် 3X-UI သွင်းခြင်း
Script ကို Run လိုက်ပါက Linux BBR Optimization, UFW Forwarding Fix နှင့် 3X-UI Panel ကို အလိုအလျောက် သွင်းပေးသွားမည် ဖြစ်သည်။

* **Admin Username:** မိမိစိတ်ကြိုက် (ဥပမာ - `zinko`)
* **Admin Password:** မိမိစိတ်ကြိုက် (ဥပမာ - `Zinkoaung@159`)
* **Panel Port:** `30659` (သို့မဟုတ် မိမိနှစ်သက်ရာ Port)

---

### အဆင့် (၃) - 3X-UI Web Panel သို့ Login ဝင်ရောက်ခြင်း
Browser တွင် Secret Web Path အပါအဝင် အောက်ပါအတိုင်း ဖွင့်ပါ:
👉 **`http://50.114.172.236:30659/bbyF9EaMLerKk34RJq/`**

*(စကားဝှက်နှင့် အသုံးပြုသူအမည် ရိုက်ထည့်၍ Login ဝင်ပါ)*

---

### အဆင့် (၄) - Cloudflare VLESS-WS Inbound အသစ် ဖန်တီးခြင်း
Login ဝင်ပြီးပါက ဘယ်ဘက် Menu မှ **Inbounds** -> **+ Add Inbound** ကို နှိပ်ပြီး အောက်ပါအတိုင်း တိကျစွာ ဖြည့်ပါ:

| Tab အမည် | ဖြည့်သွင်းရမည့် အချက်အလက်များ |
| :--- | :--- |
| **`Basics`** | **Remark:** `CF-VLESS-WS`<br>**Protocol:** `vless`<br>**Port:** `2053` *(Cloudflare HTTPS Port)* |
| **`Stream`** | **Transmission:** `WebSocket`<br>**Host:** `qqg.uzinlay.cloudns.ph`<br>**Path:** `/ws` |
| **`Security`** | **Security:** `None` *(Cloudflare SSL mode: Flexible ထားထား၍ Server တွင် None သာ လိုအပ်သည်)* |
| **`Sniffing`** | **Sniffing:** `ON` *(အပြာရောင် ခလုတ် ဖွင့်ထားပါ)* |

ပြီးလျှင် ညာဘက်အောက်ထောင့်ရှိ အပြာရောင် **`Create`** ခလုတ်ကို နှိပ်ပါ။

---

### အဆင့် (၅) - Client App (ဖုန်း/ကွန်ပျူတာ) တွင် ချိတ်ဆက်အသုံးပြုခြင်း

1. 3X-UI ထဲရှိ အသစ်ဖန်တီးထားသော `CF-VLESS-WS` ဘေးက **QR Code icon (သို့မဟုတ် Copy Link)** ကို နှိပ်ပါ။
2. **Android:** **v2rayNG** App ထဲသို့ ဝင်၍ `+` နှိပ်ကာ **Import config from QR code / Clipboard** လုပ်ပါ။
3. **iOS (iPhone):** **Shadowrocket** သို့မဟုတ် **Sing-box** ဖြင့် Scan ဖတ်ပါ။
4. **Windows:** **v2rayN** သို့မဟုတ် **Nekoray** တွင် ထည့်သွင်းပါ။

---

## ၄။ အရေးကြီး ပြုပြင်ထိန်းသိမ်းမှု Command များ (Quick Reference)

```bash
# 3X-UI Service အခြေအနေ စစ်ဆေးရန်
sudo x-ui status

# 3X-UI ကို Restart ချရန်
sudo x-ui restart

# Panel ၏ လက်ရှိ Port, Password နှင့် Secret Path ပြန်လည်ကြည့်ရှုရန်
sudo x-ui
# (Menu တွင် နံပါတ် 11 ကို ရွေးချယ်ပါ)
```

---

## ၅။ ရရှိလာသော အကျိုးကျေးဇူးများ

1. **မြန်မာပြည် ISP (ATOM/MPT/Ooredoo/Mytel) ပိတ်ဆို့မှု ကင်းဝေးခြင်း:** VPS IP အစစ်ကို မည်သူမျှ မသိနိုင်တော့သဖြင့် လိုင်းဖြတ်ချခံရခြင်း မရှိတော့ပါ။
2. **VPS Provider BGP DDoS Null-Route ကင်းဝေးခြင်း:** Traffic များသည် Cloudflare မှ လာသဖြင့် Fastnet BGP Router က Attack ဟု မသတ်မှတ်တော့ဘဲ ၂၄ နာရီ မပြတ်တမ်း တည်ငြိမ်စွာ အသုံးပြုနိုင်ပါပြီ။
