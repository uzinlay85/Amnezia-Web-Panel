# ⚙️ Web Panel Settings & User Management လမ်းညွှန်အပြည့်အစုံ

ဤလမ်းညွှန်သည် **Amnezia Web Panel** ၏ **Settings (စနစ်ဆိုင်ရာ ချိန်ညှိချက်များ)** ကဏ္ဍအားလုံးနှင့် **Users (အသုံးပြုသူ စီမံခန့်ခွဲမှု & Self-Service)** တို့ကို အသေးစိတ် နားလည်သဘောပေါက်စေရန် ရေးသားထားသော လက်စွဲ ဖြစ်ပါသည်။

---

## 📑 မာတိကာ

1. [၁။ User စီမံခန့်ခွဲမှုနှင့် Role (အခန်းကဏ္ဍ) အမျိုးအစားများ](#၁-user-စီမံခန့်ခွဲမှုနှင့်-role-အမျိုးအစားများ)
2. [၂။ Self-Service စနစ်ကို Admin ဘက်မှ အဆင့်ဆင့် ဖွင့်လှစ်တပ်ဆင်နည်း](#၂-self-service-စနစ်ကို-admin-ဘက်မှ-အဆင့်ဆင့်-ဖွင့်လှစ်တပ်ဆင်နည်း)
3. [၃။ Settings (စနစ်ဆိုင်ရာ ချိန်ညှိချက်များ) အားလုံး ရှင်းလင်းချက်](#၃-settings-စနစ်ဆိုင်ရာ-ချိန်ညှိချက်များ-အားလုံး-ရှင်းလင်းချက်)
   - [၃.၁ Appearance (ပုံပန်းသဏ္ဌာန်နှင့် အမည်)](#၃၁-appearance-ပုံပန်းသဏ္ဌာန်နှင့်-အမည်)
   - [၃.၂ Captcha (Login လုံခြုံရေး စစ်ဆေးမှု)](#၃၂-captcha-login-လုံခြုံရေး-စစ်ဆေးမှု)
   - [၃.၃ Telegram Bot (တယ်လီဂရမ် ဘော့တ် ချိတ်ဆက်ခြင်း)](#၃၃-telegram-bot-တယ်လီဂရမ်-ဘော့တ်-ချိတ်ဆက်ခြင်း)
   - [၃.၄ Tunnels (Cloudflare Tunnel, ngrok, WARP)](#၃၄-tunnels-cloudflare-tunnel-ngrok-warp)
   - [၃.၅ SSL / HTTPS Settings (လုံခြုံရေး သော့ခလောက်)](#၃၅-ssl--https-settings-လုံခြုံရေး-သော့ခလောက်)
   - [၃.၆ Import Users (Remnawave Sync)](#၃၆-import-users-remnawave-sync)
   - [၃.၇ Simple Backup (Data ဖိုင် သိမ်းဆည်းခြင်းနှင့် ပြန်တင်ခြင်း)](#၃၇-simple-backup-data-ဖိုင်-သိမ်းဆည်းခြင်းနှင့်-ပြန်တင်ခြင်း)
   - [၃.၈ API Tokens (Third-Party Bot & API ချိတ်ဆက်မှု)](#၃၈-api-tokens-third-party-bot--api-ချိတ်ဆက်မှု)
   - [၃.၉ Exit Defaults (Exit Node ဆက်တင်များ)](#၃၉-exit-defaults-exit-node-ဆက်တင်များ)
   - [၃.၁၀ Self-Service (အသုံးပြုသူများ ကိုယ်တိုင် Key စီမံခွင့်)](#၃၁၀-self-service-အသုံးပြုသူများ-ကိုယ်တိုင်-key-စီမံခွင့်)
   - [၃.၁၁ About & Updates (ဗားရှင်း စစ်ဆေးခြင်းနှင့် Update ပြုလုပ်ခြင်း)](#၃၁၁-about--updates-ဗားရှင်း-စစ်ဆေးခြင်းနှင့်-update-ပြုလုပ်ခြင်း)

---

## ၁။ User စီမံခန့်ခွဲမှုနှင့် Role အမျိုးအစားများ

Web Panel ထဲတွင် User အသစ် ဆောက်သည့်အခါ အောက်ပါ **Role (အခန်းကဏ္ဍ ၄ မျိုး)** ကို ရွေးချယ်နိုင်ပါသည်:

| Role (အခန်းကဏ္ဍ) | အခွင့်အာဏာနှင့် လုပ်ဆောင်နိုင်စွမ်း | သင့်တော်သည့် နေရာ |
| :--- | :--- | :--- |
| **Admin** | Panel တစ်ခုလုံး (Settings, Servers, Users, Protocols) ကို ၁၀၀% အပြည့်အဝ စီမံခွင့်ရှိသည်။ | ဆာဗာပိုင်ရှင် / မန်နေဂျာ |
| **Support** | ဆာဗာများနှင့် User ချိတ်ဆက်မှုများကို ကြည့်ရှုကူညီနိုင်သော်လည်း System Settings များကို ပြင်ဆင်ခွင့်မရှိပါ။ | အကူဝန်ထမ်း (Customer Service) |
| **User** | **Self-Service သာ ဝင်ရောက်နိုင်သည်**။ ဆာဗာ Setting များ၊ အခြားသူများ၏ အချက်အလက်များကို မမြင်ရဘဲ မိမိပိုင်ဆိုင်သော VPN Keys များကိုသာ ထုတ်ယူ/ဖျက်ပစ်ခွင့်ရှိသည်။ | Customer / မိသားစုဝင် / အဖွဲ့ဝင် |
| **None (No access)** | Web Panel သို့ Login ဝင်ခွင့် လုံးဝမရှိပါ (စာရင်းသွင်း မှတ်တမ်းအဖြစ်သာ ထားရှိခြင်း)။ | ရိုးရိုး VPN သုံးစွဲသူ စာရင်း |

---

## ၂။ Self-Service စနစ်ကို Admin ဘက်မှ အဆင့်ဆင့် ဖွင့်လှစ်တပ်ဆင်နည်း

User များ မိမိဘာသာ Key ထုတ်ယူနိုင်စေရန် **Admin အနေဖြင့် အောက်ပါ အဆင့် (၃) ဆင့်ကို ဦးစွာ ပြုလုပ်ပေးရပါမည်**:

### အဆင့် (၁): Settings တွင် Self-Service ကို ဖွင့်ပါ
1. Web Panel ၏ **"Settings" (⚙️)** > **"Self-Service"** သို့ သွားပါ။
2. အောက်ပါအတိုင်း ချိန်ညှိပြီး ညာဘက်အောက်ရှိ **"💾 Save changes"** ကို နှိပ်ပါ:
   - **Enable self-service:** [✓] **အမှန်ခြစ်ပါ**
   - **Enable web self-service:** [✓] **အမှန်ခြစ်ပါ** (Browser မှ ထုတ်ခွင့်ပြုရန်)
   - **Max connections per user:** `5` (User တစ်ဦးလျှင် အများဆုံး Key ၅ ခု ထုတ်ခွင့်)
   - **Allowed protocols:** `Xray`, `AmneziaWG 3.1`, `WireGuard` စသည်တို့ကို အမှန်ခြစ်ပေးပါ။

### အဆင့် (၂): Server ပေါ်တွင် Self-Service ကို ခွင့်ပြုပါ
1. **"Servers"** စာမျက်နှာသို့ သွားပါ။
2. မိမိ Server ဘေးရှိ **Edit (ခဲတံပုံ - ✏️)** ကို နှိပ်ပါ။
3. **"Allow self-service on this server"** ကို [✓] **အမှန်ခြစ်ပေးပြီး Save လုပ်ပါ**။

### အဆင့် (၃): Users စာမျက်နှာတွင် User အကောင့် ဖွင့်ပေးပါ
1. **"Users" (👥)** tab သို့ သွားပြီး **"+ Add user"** ကို နှိပ်ပါ။
2. အချက်အလက်များ ဖြည့်ပါ:
   - **Username:** `user1` (ဥပမာ)
   - **Password:** `password123` (မိမိပေးလိုသော စကားဝှက်)
   - **Role:** ⚠️ **`User`** ကို ရွေးပေးပါ (Role ကို `None` မထားရပါ)
3. **"Create"** ကို နှိပ်ပါ။

*(ထိုအခါ `user1` သည် `http://<SERVER_IP>:5000` သို့ သွားရောက်၍ မိမိဘာသာ VPN Key များကို လွတ်လပ်စွာ ထုတ်ယူနိုင်သွားပါပြီ)*

---

## ၃။ Settings (စနစ်ဆိုင်ရာ ချိန်ညှိချက်များ) အားလုံး ရှင်းလင်းချက်

---

### ၃.၁ Appearance (ပုံပန်းသဏ္ဌာန်နှင့် အမည်)
Web Panel ၏ မျက်နှာစာ အပြင်အဆင်ကို စိတ်ကြိုက် ပြောင်းလဲနိုင်ပါသည်:
- **Title:** Panel ၏ ခေါင်းစဉ် (ဥပမာ `My VPN Panel`)
- **Logo:** အပေါ်ထောင့်ရှိ Logo ပုံ သို့မဟုတ် Emoji (ဥပမာ `❤️`, `⚡`)
- **Subtitle:** ခေါင်းစဉ်ငယ် (ဥပမာ `Secure VPN Portal`)

---

### ၃.၂ Captcha (Login လုံခြုံရေး စစ်ဆေးမှု)
- **Enable Captcha:** ဖွင့်ထားပါက Login ဝင်သည့်အခါ Bot များ Hacker များ Password ခန့်မှန်းဖောက်ထွင်းခြင်း (Brute-force attack) မပြုလုပ်နိုင်ရန် ဂဏန်း/စာလုံး ပုံရိပ်စစ်ဆေးမှု ကာကွယ်ပေးပါမည်။

---

### ၃.၃ Telegram Bot (တယ်လီဂရမ် ဘော့တ် ချိတ်ဆက်ခြင်း)
Telegram Bot မှတစ်ဆင့် Server ကို စီမံခန့်ခွဲရန် သို့မဟုတ် User များအား Telegram ထဲတွင် Key ထုတ်ပေးရန် အသုံးပြုပါသည်:
- **Bot Token:** `@BotFather` ထံမှ ရရှိသော HTTP API Token ကို ထည့်သွင်းပါ။
- **Start / Stop Bot:** Token ထည့်ပြီးပါက **"Start Bot"** ကို နှိပ်၍ Bot ကို ချက်ချင်း အသက်သွင်းနိုင်ပါသည်။

---

### ၃.၄ Tunnels (Cloudflare Tunnel, ngrok, WARP)
ဆာဗာ၏ Port 5000 ကို အင်တာနက်ပေါ်သို့ လုံခြုံစွာ ဖွင့်လှစ်ပေးနိုင်သော Public Tunnels များ ဖြစ်ပါသည်:
- **ngrok Tunnel:** ngrok token ထည့်ပြီး One-Click ဖြင့် အင်တာနက်လင့်ခ် ထုတ်ယူခြင်း။
- **Cloudflare WARP:** ဆာဗာ၏ ထွက်ပေါက် IP ကို Cloudflare IP ဖြင့် ဖုံးကွယ်ထားခြင်း။

---

### ၃.၅ SSL / HTTPS Settings (လုံခြုံရေး သော့ခလောက်)
Web Panel အား `https://` ဖြင့် လုံခြုံစွာ အသုံးပြုရန် Certbot မှ ရရှိသော SSL Certificate လမ်းကြောင်းများကို ထည့်သွင်းသည့် နေရာ ဖြစ်ပါသည်။

---

### ၃.၆ Import Users (Remnawave Sync)
အကယ်၍ သင်သည် Remnawave Panel ကို အသုံးပြုနေပါက အဆိုပါ Panel ပေါ်ရှိ Users စာရင်းအားလုံးကို Amnezia Panel ထဲသို့ အလိုအလျောက် Import ဆွဲယူ ပေါင်းစပ်ပေးမည့် စနစ် ဖြစ်ပါသည်။

---

### ၃.၇ Simple Backup (Data ဖိုင် သိမ်းဆည်းခြင်းနှင့် ပြန်တင်ခြင်း)
- **Download Backup:** ဆာဗာပေါ်ရှိ Users, Servers, Keys, Settings အားလုံးပါဝင်သော `data.json` ဖိုင်ကို ကွန်ပျူတာထဲသို့ Backup အဖြစ် ဒေါင်းလုဒ်ဆွဲ သိမ်းဆည်းခြင်း။
- **Restore Backup:** ဆာဗာအသစ်လဲသည့်အခါ Backup ဖိုင်ကို ပြန်တင်လိုက်ရုံဖြင့် နဂိုအချက်အလက်အားလုံး ချက်ချင်း ပြန်လည် ရရှိစေခြင်း။

---

### ၃.၈ API Tokens (Third-Party Bot & API ချိတ်ဆက်မှု)
မိမိ၏ ကိုယ်ပိုင် Bot၊ Website သို့မဟုတ် Automation စနစ်များမှတစ်ဆင့် Amnezia Web Panel ကို အလိုအလျောက် ခိုင်းစေနိုင်ရန် **Bearer API Token** ထုတ်ယူသည့် နေရာ ဖြစ်ပါသည်။

---

### ၃.၉ Exit Defaults (Exit Node ဆက်တင်များ)
ဆာဗာများစွာ ချိတ်ဆက်ပြီး Traffic လမ်းကြောင်းလွှဲ (Entry Node မှတစ်ဆင့် Exit Node သို့ သွားစေခြင်း) ပြုလုပ်သည့်အခါ အသုံးပြုသော Advanced Routing ဆက်တင်များ ဖြစ်ပါသည်။

---

### ၃.၁၀ Self-Service (အသုံးပြုသူများ ကိုယ်တိုင် Key စီမံခွင့်)
- **Enable web self-service:** Web Browser မှ Key ထုတ်ခွင့်ပြုခြင်း။
- **Enable Telegram self-service:** Telegram Bot မှ Key ထုတ်ခွင့်ပြုခြင်း။
- **Max connections per user:** User တစ်ဦးလျှင် အများဆုံး Device အရေအတွက် (ဥပမာ ၅ ခု)။
- **Rate Limit:** စက္ကန့်ပိုင်းအတွင်း Key တွေ အများကြီး မဆောက်နိုင်အောင် ကာကွယ်ခြင်း။
- **Allowed protocols:** User များကို မည်သည့် Protocol ပေးသုံးမည်နည်းကို ရွေးချယ်ခြင်း။

---

### ၃.၁၁ About & Updates (ဗားရှင်း စစ်ဆေးခြင်းနှင့် Update ပြုလုပ်ခြင်း)
- **Current version:** လက်ရှိ အသုံးပြုနေသော Panel Version (ဥပမာ `v1.6.6`) ကို ပြသပေးခြင်း။
- **Check for updates:** GitHub ပေါ်တွင် Version အသစ်များ ထွက်ရှိခြင်း ရှိမရှိ စစ်ဆေးပေးခြင်း။

---
*Created with ❤️ for Amnezia & Myanmar Internet Freedom.*
