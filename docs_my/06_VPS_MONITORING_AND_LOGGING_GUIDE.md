# VPS & VPN စနစ် ချွတ်ယွင်းမှုများ စောင့်ကြည့်မှတ်တမ်းတင်ခြင်းနှင့် ပြန်လည်စစ်ဆေးနည်း လမ်းညွှန်
(Comprehensive VPS & VPN Monitoring, Logging, and Post-Incident Forensic Guide)

---

## ၁။ နိဒါန်း (Introduction)

VPS တစ်ခုကို VPN Server သို့မဟုတ် Web Panel အဖြစ် အသုံးပြုရာတွင် မမျှော်လင့်ဘဲ **SSH ပြတ်တောက်သွားခြင်း၊ VPN အင်တာနက် ရပ်သွားခြင်း၊ သို့မဟုတ် Server တစ်ခုလုံး ပုံမှန်မဟုတ်ဘဲ Restart ကျသွားခြင်း** စသည်တို့ ကြုံတွေ့ရတတ်ပါသည်။

အဆိုပါ ပြဿနာများကို ထိရောက်စွာ ဖြေရှင်းနိုင်ရန်အတွက် ဤလမ်းညွှန်တွင် -
1. **ဖြစ်ပွားပြီးပါက ဘာကြောင့်ဖြစ်ခဲ့သည်ကို ပြန်လည်စစ်ဆေးနည်း (Post-Incident Forensics)**
2. **Server ပြတ်တောက်မှုကို အပြင်ဘက်မှ ၂၄ နာရီ စောင့်ကြည့်အသိပေးမည့်စနစ် (External Uptime Monitoring)**
3. **Server အတွင်းပိုင်း ကျန်းမာရေးကို စောင့်ကြည့်ပြီး မှတ်တမ်းတင်မည့် Script (Internal Watchdog & Logging)**
4. **Log ဖိုင်များ စီမံခန့်ခွဲခြင်းနှင့် အလိုအလျောက် ပြန်လည်ကုစားခြင်း (Auto-Recovery)**
စသည်တို့ကို အသေးစိတ် ဖော်ပြထားပါသည်။

---

## ၂။ အပိုင်း (၁) - ပြဿနာဖြစ်ပြီးနောက် VPS ထဲတွင် အကြောင်းရင်း ပြန်လည်စစ်ဆေးနည်း

ဆာဗာတွင် တစ်ခုခု ပုံမှန်မဟုတ်တော့သည့်အခါ SSH (Xshell) ဖြင့် ဝင်ရောက်ပြီး အောက်ပါ Command များကို အသုံးပြု၍ စစ်ဆေးပါ:

### (က) ဆာဗာ Reboot ကျသွားခဲ့သလား စစ်ဆေးခြင်း
```bash
# လက်ရှိ Server ဘယ်လောက်ကြာကြာ ပွင့်နေလဲ ကြည့်ရန်
uptime

# ပြီးခဲ့သည့် ရက်များအတွင်း Reboot ကျခဲ့သည့် အချိန်မှတ်တမ်းများ ကြည့်ရန်
last reboot | head -n 8
```
> **မှတ်ချက်:** အကယ်၍ သင်ကိုယ်တိုင် Reboot မလုပ်ဘဲ `reboot ~ system boot` ဟု မှတ်တမ်းတွေ့ပါက VPS Provider ဘက်မှ Node ပြဿနာ သို့မဟုတ် Kernel Crash ဖြစ်ခဲ့ခြင်း ဖြစ်သည်။

---

### (ခ) RAM မလောက်၍ Linux Kernel က Process များကို သတ်ပစ်ခဲ့သလား (OOM Killer)
Server ၏ RAM ပြည့်သွားပါက Linux OS သည် ဆာဗာမသေစေရန် အရေးကြီးသော VPN/Docker Process များကို အလိုအလျောက် သတ်ပစ် (Kill) လေ့ရှိသည်။
```bash
sudo dmesg -T | grep -i -E 'killed process|oom|out of memory'
```
> **မှတ်ချက်:** အထက်ပါ command တွင် မှတ်တမ်းပေါ်လာပါက RAM မလုံလောက်သည့် ပြဿနာ (Memory Leak သို့မဟုတ် Swap Memory မရှိခြင်း) ကြောင့် ဖြစ်သည်။

---

### (ဂ) Docker Container များနှင့် VPN များ Crash ဖြစ်ခဲ့သလား စစ်ဆေးခြင်း
```bash
# Container များ၏ လက်ရှိ Status နှင့် Restart ခံရသည့် အကြိမ်ရေ ကြည့်ရန်
sudo docker inspect --format='Name: {{.Name}} | Status: {{.State.Status}} | Restarts: {{.RestartCount}} | Started: {{.State.StartedAt}} | ExitCode: {{.State.ExitCode}}' $(sudo docker ps -aq)
```
* **Restart Count:** `0` မဟုတ်ဘဲ အရေအတွက် တက်နေပါက Container သည် နောက်ကွယ်တွင် Crash ဖြစ်၍ ခဏခဏ ပြန်စနေရခြင်း ဖြစ်သည်။
* **Error Log ကြည့်ရန်:**
```bash
sudo docker logs --tail 100 amnezia-awg
sudo docker logs --tail 100 shadowbox
```

---

### (ဃ) SSH ပြတ်တောက်မှုနှင့် Unauthorized Login တိုက်ခိုက်မှုများ စစ်ဆေးခြင်း
SSH သို့ မကြာခဏ ဝင်မရဖြစ်ခြင်းသည် Brute-force Attack (Password ခန့်မှန်းတိုက်ခိုက်မှု) များလွန်း၍ Server Connection များ ပြည့်သွားခြင်းကြောင့် ဖြစ်တတ်သည်။
```bash
# SSH Service ၏ မကြာသေးမီက Log မှတ်တမ်း ကြည့်ရန်
sudo journalctl -u ssh -n 50 --no-pager

# ကျရှုံးခဲ့သော Login အကြိမ်ရေများ ကြည့်ရန်
sudo grep "Failed password" /var/log/auth.log | tail -n 20
```

---

### (င) Hard Disk ပြည့်သွားခဲ့သလား စစ်ဆေးခြင်း
Disk ပြည့်သွားပါက Service အားလုံး ရပ်တန့်သွားတတ်သည်။
```bash
df -h /
```
*(Use% သည် 90% အထက် ဖြစ်မနေစေရပါ)*

---

## ၃။ အပိုင်း (၂) - Server ပြတ်တောက်မှုကို ၂၄ နာရီ အပြင်ဘက်မှ စောင့်ကြည့်ခြင်း (External Uptime Monitor)

ဆာဗာတစ်ခုလုံး Down သွားချိန်တွင် ဆာဗာအတွင်းရှိ Script များပါ အလုပ်မလုပ်နိုင်တော့ပါ။ ထို့ကြောင့် **ဆာဗာအပြင်ဘက်မှနေ၍ Ping သို့မဟုတ် Port ကို စောင့်ကြည့်ပေးမည့် စနစ် (Cloud Monitoring)** ထားရှိရန် လိုအပ်သည်။

### အကြံပြု Free Monitoring ဝန်ဆောင်မှု: [UptimeRobot](https://uptimerobot.com)

#### တပ်ဆင်ပုံ အဆင့်ဆင့်:
1. **UptimeRobot** တွင် အခမဲ့ အကောင့်ဖွင့်ပါ (Monitor ၅၀ အထိ အခမဲ့ ရရှိသည်)။
2. **Add New Monitor** ကို နှိပ်ပါ:
   * **Monitor Type:** `Port` ကို ရွေးပါ (သို့မဟုတ် `Ping`)
   * **Friendly Name:** `My VPN Server SSH`
   * **IP or Host:** `50.114.172.236` (သင့် VPS IP)
   * **Port:** `2213` (သင့် SSH Port)
   * **Monitoring Interval:** `5 minutes`
3. **Alert Contacts (အသိပေးစနစ် ချိတ်ဆက်ခြင်း):**
   * မိမိ၏ **Telegram Bot** သို့မဟုတ် **Email** ကို ရွေးချယ်ချိတ်ဆက်ပါ။
4. **ရလဒ်:** 
   * Server အင်တာနက်ပြတ်တောက်သွားခြင်း၊ VPS Reboot ကျခြင်း သို့မဟုတ် Provider Network ပြဿနာဖြစ်လျှင်ဖြစ်ချင်း **၁ မိနစ်အတွင်း သင့်ဖုန်း Telegram သို့ "Monitor is DOWN" ဟူသော Message ချက်ချင်း ရောက်ရှိလာမည်** ဖြစ်သည်။

---

## ၄။ အပိုင်း (၃) - VPS အတွင်းပိုင်း ကျန်းမာရေး စောင့်ကြည့် မှတ်တမ်းတင် Script

ဆာဗာ၏ အင်တာနက် အခြေအနေ၊ VPN Container များ၊ RAM နှင့် Disk အခြေအနေတို့ကို (၅) မိနစ်တစ်ကြိမ် အလိုအလျောက် စစ်ဆေးပြီး ပုံမှန်မဟုတ်ပါက `/var/log/vps_health.log` တွင် အသေးစိတ် မှတ်တမ်းတင်ပေးမည့် Script ဖြစ်ပါသည်။

### အဆင့် (၁) - စောင့်ကြည့် Script ဖန်တီးခြင်း
Xshell တွင် အောက်ပါ Command တစ်ခုလုံးကို Copy ကူး၍ Run လိုက်ပါ:

```bash
sudo tee /usr/local/bin/vps-monitor.sh << 'EOF'
#!/bin/bash
# ==========================================
# VPS & VPN Health Monitor Watchdog Script
# ==========================================

LOGFILE="/var/log/vps_health.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

write_log() {
    local LEVEL="$1"
    local MSG="$2"
    echo "[$TIMESTAMP] [$LEVEL] $MSG" >> "$LOGFILE"
}

# ၁။ ပြင်ပ အင်တာနက် ထွက်/မထွက် စစ်ဆေးခြင်း (Google DNS ဖြင့် စစ်သည်)
if ! ping -c 2 -W 3 8.8.8.8 > /dev/null 2>&1; then
    write_log "CRITICAL" "Internet connectivity check FAILED (Outgoing ping failed)!"
fi

# ၂။ AmneziaWG Container စစ်ဆေးခြင်း
AWG_STATE=$(docker inspect -f '{{.State.Running}}' amnezia-awg 2>/dev/null)
if [ "$AWG_STATE" != "true" ]; then
    write_log "ERROR" "Docker container [amnezia-awg] is NOT running! Attempting auto-restart..."
    docker restart amnezia-awg >/dev/null 2>&1
    write_log "INFO" "Triggered auto-restart for amnezia-awg."
fi

# ၃။ Outline (Shadowbox) Container စစ်ဆေးခြင်း
OUTLINE_STATE=$(docker inspect -f '{{.State.Running}}' shadowbox 2>/dev/null)
if [ "$OUTLINE_STATE" != "true" ]; then
    write_log "WARNING" "Docker container [shadowbox] is NOT running!"
fi

# ၄။ ရရှိနိုင်သော RAM ပမာဏ စစ်ဆေးခြင်း (Available RAM < 150MB ဆိုလျှင် သတိပေးမည်)
AVAIL_RAM=$(free -m | awk '/^Mem:/{print $7}')
if [ -n "$AVAIL_RAM" ] && [ "$AVAIL_RAM" -lt 150 ]; then
    write_log "WARNING" "Low Available Memory alert: Only ${AVAIL_RAM}MB RAM remaining!"
fi

# ၅။ Disk နေရာလွတ် စစ်ဆေးခြင်း (Root partition > 90% ဆိုလျှင် သတိပေးမည်)
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
if [ "$DISK_USAGE" -gt 90 ]; then
    write_log "WARNING" "High Disk Usage alert: Root partition is at ${DISK_USAGE}% capacity!"
fi
EOF

sudo chmod +x /usr/local/bin/vps-monitor.sh
```

---

### အဆင့် (၂) - (၅) မိနစ်တစ်ကြိမ် အလိုအလျောက် စစ်ဆေးရန် Crontab ထည့်ခြင်း
```bash
(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/local/bin/vps-monitor.sh") | crontab -
```

---

### အဆင့် (၃) - Log ဖိုင် အဆမတန် မကြီးသွားစေရန် Logrotate သတ်မှတ်ခြင်း
အချိန်ကြာလာပါက Log ဖိုင် အရွယ်အစား ကြီးမားမသွားစေရန် အလိုအလျောက် ရှင်းလင်းပေးမည့် configuration ထည့်သွင်းပါ:

```bash
sudo tee /etc/logrotate.d/vps-health << 'EOF'
/var/log/vps_health.log {
    weekly
    rotate 4
    compress
    missingok
    notifempty
}
EOF
```

---

## ၅။ အပိုင်း (၄) - ချွတ်ယွင်းမှုမှတ်တမ်း ပြန်လည်ဖတ်ရှုနည်း

နောက်ပိုင်းတွင် VPS ချွတ်ယွင်းခဲ့သလား၊ ဘာတွေဖြစ်ပျက်ခဲ့သလဲ စစ်ဆေးလိုပါက အောက်ပါအတိုင်း ကြည့်ရှုနိုင်ပါသည်:

```bash
# မကြာသေးမီက ထူးခြားမှု မှတ်တမ်းများကို ဖတ်ရှုရန်
cat /var/log/vps_health.log

# အချိန်နှင့်တပြေးညီ မှတ်တမ်းတက်လာသည်ကို စောင့်ကြည့်ရန်
tail -f /var/log/vps_health.log
```

---

## ၆။ အမြန်စစ်ဆေးမှု Command ဇယား (Quick Cheat Sheet)

| စစ်ဆေးလိုသည့် အချက်အလက် | အသုံးပြုရမည့် Command |
| :--- | :--- |
| **Server Uptime & Reboot မှတ်တမ်း** | `uptime` နှင့် `last reboot \| head -n 5` |
| **Memory ပြည့်၍ Process အသတ်ခံရမှု** | `sudo dmesg -T \| grep -i oom` |
| **VPN Docker Restart အကြိမ်ရေ** | `sudo docker inspect --format='{{.RestartCount}}' amnezia-awg` |
| **Amnezia Handshake အခြေအနေ** | `sudo docker exec amnezia-awg awg show` |
| **SSH ချိတ်ဆက်မှု မှတ်တမ်း** | `sudo journalctl -u ssh -n 30 --no-pager` |
| **ကျန်းမာရေးစောင့်ကြည့် မှတ်တမ်းဖိုင်** | `cat /var/log/vps_health.log` |
| **Disk နှင့် RAM လက်ကျန်** | `df -h /` နှင့် `free -h` |
