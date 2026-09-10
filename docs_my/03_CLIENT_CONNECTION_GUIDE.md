# Client ချိတ်ဆက်မှု လက်စွဲလမ်းညွှန် (Client Connection Guide)

Amnezia Web Panel မှ ထုတ်ယူထားသော VPN Keys/Configs များကို ဖုန်း (Android / iOS) နှင့် ကွန်ပျူတာ (Windows / macOS) များတွင် အောင်မြင်စွာ ချိတ်ဆက် အသုံးပြုနိုင်သည့် အဆင့်ဆင့် လမ်းညွှန် ဖြစ်ပါသည်။

---

## 📑 မာတိကာ
1. [၁။ မည်သည့် Protocol ကို ရွေးချယ်သင့်သလဲ? (AmneziaWG vs Xray)](#၁-မည်သည့်-protocol-ကို-ရွေးချယ်သင့်သလဲ)
2. [၂။ Xray (VLESS Reality) ချိတ်ဆက်နည်း (မြန်မာပြည်အတွက် အကြံပြုချက် ⭐)](#၂-xray-vless-reality-ချိတ်ဆက်နည်း)
   - [Android (v2rayNG / NekoBox)](#က-android-တွင်-v2rayng-ဖြင့်-ချိတ်ဆက်နည်း)
   - [iOS / iPhone (V2Box / FoXray / Streisand)](#ခ-ios--iphone-တွင်-v2box-ဖြင့်-ချိတ်ဆက်နည်း)
   - [Windows PC (Nekoray / v2rayN)](#ဂ-windows-pc-တွင်-nekoray-ဖြင့်-ချိတ်ဆက်နည်း)
3. [၃။ AmneziaWG (AWG 3.1) ချိတ်ဆက်နည်း](#၃-amneziawg-awg-31-ချိတ်ဆက်နည်း)
   - [အရေးကြီးသတိပြုဖွယ် (Junk Packets & Obfuscation)](#အရေးကြီးသတိပြုဖွယ်)
   - [Official AmneziaWG App ဖြင့် ချိတ်ဆက်ခြင်း](#official-amneziawg-app-ဖြင့်-ချိတ်ဆက်ခြင်း)
4. [၄။ မကြာခဏ ကြုံတွေ့ရတတ်သော ပြဿနာများနှင့် ဖြေရှင်းနည်းများ (Troubleshooting)](#၄-troubleshooting-ဖြေရှင်းနည်းများ)

---

## ၁။ မည်သည့် Protocol ကို ရွေးချယ်သင့်သလဲ?

| အချက် | Xray (VLESS Reality) | AmneziaWG (AWG 3.1) |
| :--- | :--- | :--- |
| **Port** | `443/tcp` (Standard HTTPS) | `443/udp` သို့မဟုတ် High UDP Port |
| **Bypass စွမ်းရည်** | အလွန်ကောင်းမွန် (Website အစစ်အဖြစ် ဟန်ဆောင်သည်) | အလွန်ကောင်းမွန် (Junk Packet ဖြင့် မူရင်း WG ကို ဖုံးကွယ်သည်) |
| **မြန်မာပြည် အခြေအနေ** | **အကြံပြုချက် ⭐ (၁၀၀% မပိတ်နိုင်)** | ISP အချို့တွင် UDP QoS/Drop ဖြစ်တတ်သည် |
| **အသုံးပြုသင့်သော App** | v2rayNG, V2Box, FoXray, Nekoray | Official AmneziaWG App သာ |
| **အမြန်နှုန်း (Speed)** | အလွန်မြန်ဆန် | အလွန်မြန်ဆန် (Kernel WireGuard) |

---

## ၂။ Xray (VLESS Reality) ချိတ်ဆက်နည်း

Xray သည် Port 443 TCP ပေါ်တွင် Yahoo/Microsoft စသည့် တရားဝင် Website ကြီးများအဖြစ် ဟန်ဆောင် (Camouflage) ထားသောကြောင့် မြန်မာနိုင်ငံရှိ ISP များ (MPT, ATOM, Ooredoo, MyTel) က လုံးဝ ပိတ်ဆို့၍ မရနိုင်ပါ။

### Panel ထဲမှ Key ထုတ်ယူနည်း:
1. Web Panel ရှိ **"Connections"** > **"Add connection"** ကို နှိပ်ပါ။
2. User အမည်ရွေးပါ၊ Protocol တွင် **"Xray"** ကို ရွေးပါ။
3. ထွက်လာသော `vless://...` Link ကို **Copy** ယူပါ (သို့မဟုတ် **QR Code** ဖွင့်ပါ)။

---

### (က) Android တွင် v2rayNG ဖြင့် ချိတ်ဆက်နည်း
1. Google Play Store မှ **[v2rayNG](https://play.google.com/store/apps/details?id=com.v2ray.ang)** ကို Install လုပ်ပါ။
2. App ကို ဖွင့်ပြီး ညာဘက်အပေါ်ထောင့်ရှိ **`+` (Plus icon)** ကို နှိပ်ပါ။
3. **"Import config from clipboard"** ကို နှိပ်ပါ (သို့မဟုတ် **"Scan QR Code"** ဖြင့် ဖတ်ပါ)။
4. ပေါ်လာသော Server Card လေးကို ရွေးပြီး ညာဘက်အောက်ရှိ **V (Connect ခလုတ်)** ကို နှိပ်လိုက်ပါ။
5. ချိတ်ဆက်ပြီးပါက အင်တာနက် စတင် အသုံးပြုနိုင်ပါပြီ။

---

### (ခ) iOS / iPhone တွင် V2Box ဖြင့် ချိတ်ဆက်နည်း
1. App Store မှ **[V2Box](https://apps.apple.com/app/v2box-v2ray-client/id6446814690)** (သို့မဟုတ် **FoXray** / **Streisand**) ကို Install လုပ်ပါ။
2. App အောက်ခြေရှိ **"Configs"** tab သို့ သွားပါ။
3. ညာဘက်အပေါ်ရှိ **`+`** ကို နှိပ်ပြီး **"Import v2ray url from Clipboard"** ကို ရွေးပါ။
4. Server အသစ် ပေါ်လာပါက ၎င်းကို အမှန်ခြစ် ရွေးချယ်ပြီး **Home** tab မှ **"Slide to connect"** လုပ်ပါ။

---

### (ဂ) Windows PC တွင် Nekoray ဖြင့် ချိတ်ဆက်နည်း
1. [Nekoray Release](https://github.com/MatsuriDayo/nekoray/releases) မှ ZIP ဖိုင်ကို ဒေါင်းလုဒ်ဆွဲပြီး ဖြည်ပါ။
2. `nekoray.exe` ကို ဖွင့်ပါ (Core ရွေးခိုင်းပါက `sing-box` ကို ရွေးပါ)။
3. ကီးဘုတ်မှ **`Ctrl + V`** နှိပ်လိုက်ပါက Config အလိုအလျောက် ရောက်လာပါမည်။
4. ၎င်း Server ပေါ်တွင် Right-Click နှိပ်ပြီး **"Start"** ကို ရွေးပါ။
5. အပေါ်ဘက်ရှိ **"System Proxy"** (သို့မဟုတ် **"VPN Mode"**) ကို အမှန်ခြစ်ပေးပါ။

---

## ၃။ AmneziaWG (AWG 3.1) ချိတ်ဆက်နည်း

### ⚠️ အရေးကြီး သတိပြုဖွယ်:
AmneziaWG သည် မူရင်း WireGuard ကို Obfuscation Parameters (`Jc, Jmin, S1..S4, H1..H4, I1`) ထပ်ပေါင်းထည့်ထားခြင်း ဖြစ်ပါသည်။
- **အသုံးပြုရန် App:** **Official AmneziaWG App** (အစိမ်းရောင်/အနက်ရောင် Logo) ကိုသာ သုံးရပါမည်။
- **မူရင်း WireGuard App (အဖြူအနီ Logo):** မူရင်း App သည် အဆိုပါ Parameters များကို နားမလည်သောကြောင့် ချိတ်ဆက်၍ မရနိုင်ပါ။

### ဒေါင်းလုဒ် လင့်ခ်များ:
- **Android:** [AmneziaWG on Google Play / APK](https://github.com/amnezia-vpn/amneziawg-android/releases)
- **Windows:** [AmneziaWG Windows Client](https://github.com/amnezia-vpn/amneziawg-windows/releases)
- **iOS / macOS:** [AmneziaWG on App Store](https://apps.apple.com/app/amneziawg/id6478942364)

### ချိတ်ဆက်နည်း:
1. Panel ထဲမှ `.conf` ဖိုင်ကို Download ဆွဲပါ သို့မဟုတ် QR Code ပြပါ:
2. AmneziaWG App ကို ဖွင့်ပြီး **"Add Tunnel"** > **"Import from file or archive"** (သို့မဟုတ် **"Scan from QR code"**) ကို ရွေးပါ။
3. Config ဝင်လာပါက **"Activate"** ခလုတ်ကို နှိပ်ပြီး စတင် အသုံးပြုနိုင်ပါပြီ။

---

## ၄။ Troubleshooting ဖြေရှင်းနည်းများ

### ၁။ AmneziaWG တွင် အဝိုင်းလည်နေပြီး မချိတ်ပါက:
- **အကြောင်းရင်း (၁):** ဖုန်း/PC ထဲတွင် အခြား VPN တစ်ခုခု (Throne, Outline, v2ray) ပွင့်နေခြင်း။  
  👉 **အခြား VPN အားလုံးကို အရင် Disconnect လုပ်ပြီးမှ ပြန်ချိတ်ပါ**။
- **အကြောင်းရင်း (၂):** Config ထဲရှိ `Endpoint` နေရာတွင် Domain Name (`awgpannel.duckdns.org`) ဖြစ်နေပြီး ISP က DNS ပိတ်ထားခြင်း။  
  👉 **Endpoint ကို Raw IP (`50.114.172.236:55424`) သို့ ပြောင်းလဲ ထည့်သွင်းပါ**။
- **အကြောင်းရင်း (၃):** မိုဘိုင်း အော်ပရေတာက UDP High Port (55424) ကို ယာယီ Block ထားခြင်း။  
  👉 **ဖုန်းကို Flight Mode (၅ စက္ကန့်) ပိတ်/ဖွင့် လုပ်ပါ** သို့မဟုတ် **Xray (Port 443) သို့ ပြောင်းသုံးပါ**။

### ၂။ Web Panel မပွင့်ပါက:
- Browser တွင် `https://` အစား **`http://<SERVER_IP>:5000`** ဖြင့် ဝင်ရောက်ပါ။
