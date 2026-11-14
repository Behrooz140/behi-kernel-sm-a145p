# کرنل behi — سامسونگ Galaxy A14 4G (SM-A145P)

[English](README.md) | **فارسی**

![kernel](https://img.shields.io/badge/kernel-6.6.92-blue)
![device](https://img.shields.io/badge/device-SM--A145P-green)
![KernelSU](https://img.shields.io/badge/KernelSU-v3.3.1-orange)
![release](https://img.shields.io/github/v/release/Behrooz140/behi-kernel-a14?label=release)

یک کرنل شخصی‌سازی‌شدهٔ GKI اندروید ۱۵ (لینوکس 6.6.92) برای سامسونگ Galaxy A14 4G
(`a14m`، مدیاتک Helio G80 / MT6769V) که برای KernelSU و کارهای کانتینری مثل
Droidspaces ساخته شده است.

بستهٔ انتشار **فقط یک boot image** است. هیچ ماژول KernelSU، هیچ تغییری در
`vendor_dlkm` و هیچ نصب داخلی اندروید ندارد: `boot` را فلش می‌کنی، ریبوت، تمام.

نسخهٔ فعلی: **v1.3** —
`6.6.92-android15-8-abA145PXXSDDZH1-4k-behi-v1.3`

---

## فهرست

- [دستگاه](#دستگاه)
- [چه چیزی دریافت می‌کنید](#چه-چیزی-دریافت-می‌کنید)
- [امکانات](#امکانات)
- [پیش‌نیازها](#پیشنیازها)
- [نصب با Odin](#نصب-با-odin)
- [بررسی نصب](#بررسی-نصب)
- [بازگشت به حالت قبل](#بازگشت-به-حالت-قبل)
- [فرکانس CPU](#فرکانس-cpu)
- [سازگاری ABI با ماژول‌های استوک vendor](#سازگاری-abi-با-ماژولهای-استوک-vendor)
- [ریلیزها و نسخه‌بندی](#ریلیزها-و-نسخهبندی)
- [ساخت از سورس](#ساخت-از-سورس)
- [ساختار مخزن](#ساختار-مخزن)
- [عیب‌یابی](#عیبیابی)
- [اعتبارها](#اعتبارها)
- [سلب مسئولیت](#سلب-مسئولیت)

---

## دستگاه

| مورد | مقدار |
|---|---|
| مدل | Samsung Galaxy A14 4G (SM-A145P / `a14m`) |
| چیپست | MediaTek Helio G80 (MT6769V) |
| پردازنده | ۲ × Cortex-A75 + ۶ × Cortex-A55 |
| کرنل | 6.6.92 GKI، `android15-6.6` |
| فریمور پایه | `A145PXXSDDZH1` |
| رشتهٔ نسخهٔ کرنل | `6.6.92-android15-8-abA145PXXSDDZH1-4k-behi-v1.3` |
| boot image | ۳۲ مگابایت، هدر v4، فوتر AVB (`SHA256_RSA4096`، کلید تست AOSP) |
| نوع بیلد | KernelSU `v3.3.1` (نسخهٔ `32680`)، بیلد user |

رشتهٔ نسخهٔ کرنل، پایهٔ استوک
(`6.6.92-android15-8-abA145PXXSDDZH1-4k`) را دست‌نخورده نگه می‌دارد و برند شخصی و
نسخهٔ بسته را به انتهای آن اضافه می‌کند. نشانهٔ ABI ماژول (vermagic) عمداً روی مقدار
**استوک** پین شده تا همهٔ ماژول‌های ازپیش‌ساختهٔ `/vendor` لود شوند؛ فقط رشتهٔ
نمایشی تغییر کرده است.

## چه چیزی دریافت می‌کنید

هر ریلیز GitHub فقط شامل این فایل‌هاست:

| فایل | کاربرد |
|---|---|
| `A145P-Kernel-vX.Y-boot.img` | boot image ۳۲ مگابایتی، آمادهٔ فلش |
| `A145P-Kernel-vX.Y-Odin.tar.md5` | همان `boot.img` داخل بستهٔ AP برای Odin |
| `SHA256SUMS` | چک‌سام همهٔ فایل‌ها |
| `build-info.txt` | مشخصات دقیق ابزارها و کامیت بیلد |
| `RELEASE_NOTES.md` | یادداشت نسخه (روی صفحهٔ ریلیز هم نمایش داده می‌شود) |

هیچ فایل `.ko`، هیچ overlay روی `system` و هیچ zip ماژولی وجود ندارد. پشتیبانی
KernelSU داخل خود کرنل کامپایل شده است.

## امکانات

- **KernelSU v3.3.1** (نسخهٔ 32680) به‌صورت built-in — با مدیر رسمی KernelSU کار می‌کند.
- **namespaceها برای کانتینر**: SYSVIPC، صف پیام POSIX، namespaceهای IPC/PID/USER
  (سازگار با Droidspaces)، ACL و xattr روی TMPFS.
- **شبکه**: qdisc CAKE (برای SQM و تأخیر کم)، MACVLAN برای کانتینرها، تارگت‌های
  TTL/HL برای tethering، `xt_cpu` و `xt_CHECKSUM`، ipset و match/targetهای رایج netfilter.
- **فایل‌سیستم‌ها**: SquashFS با XZ/LZ4/ZSTD، NFSv4.2، SMB/CIFS.
- **امنیت/سخت‌سازی**: تصادفی‌سازی آفست استک کرنل.
- **گیت ABI در CI**: CRC نمادهای صادرشده در هر بیلد با نسخهٔ سالم v1.0 مقایسه می‌شود؛
  کرنلی که ماژول‌های استوک vendor را رد کند اصلاً منتشر نمی‌شود.
- **فرکانس‌های استوک CPU** — بدون اورکلاک و بدون تغییر ولتاژ (پایین‌تر توضیح داده شده).

## پیش‌نیازها

- **بوت‌لودر آنلاک‌شده** (boot image با کلید تست عمومی AOSP امضا شده، نه کلید سامسونگ؛
  روی دستگاه آنلاک پذیرفته می‌شود).
- **Odin** (ویندوز، یا Wine روی لینوکس) برای فلش بستهٔ AP.
- فریمور پایهٔ **`A145PXXSDDZH1`** توصیه می‌شود. vermagic روی همین پایه پین شده؛ روی
  نسخه‌های دیگر فریمور ممکن است ماژول‌های `/vendor` عدم‌تطابق نسخه گزارش کنند.
- مدیر KernelSU نسخهٔ **v3.3.1 یا جدیدتر** اگر روت می‌خواهی.
- `adb` و `su` برای مراحل بررسی.

## نصب با Odin

1. فایل `A145P-Kernel-vX.Y-Odin.tar.md5` را دانلود کن (و در صورت تمایل `SHA256SUMS`).
2. صحت دانلود را بررسی کن:
   ```sh
   sha256sum -c SHA256SUMS
   ```
3. گوشی را خاموش کن.
4. با نگه‌داشتن **Vol+ و Vol−** و وصل‌کردن کابل USB وارد Download mode شو.
5. با نگه‌داشتن **Vol+** هشدار Download mode را تأیید کن.
6. در Odin فایل `.tar.md5` را در خانهٔ **AP** بگذار.
7. گزینهٔ *Re-Partition* را **فعال نکن**. فلش کن و بگذار گوشی ریبوت شود.

داده‌ها حفظ می‌شوند؛ فقط پارتیشن `boot` نوشته می‌شود. اولین بوت بعد از فلش ممکن است
چند دقیقه طول بکشد.

## بررسی نصب

```sh
adb shell uname -r
# 6.6.92-android15-8-abA145PXXSDDZH1-4k-behi-v1.3
```

با روت:

```sh
su -c 'uname -r; grep . /sys/devices/system/cpu/cpufreq/policy*/cpuinfo_max_freq'
```

سقف فرکانس‌های مورد انتظار (استوک):

```
/sys/devices/system/cpu/cpufreq/policy0/cpuinfo_max_freq:1800000
/sys/devices/system/cpu/cpufreq/policy6/cpuinfo_max_freq:2000000
```

بررسی لود شدن ماژول‌های استوک vendor (Wi-Fi، GPS، FM و…):

```sh
su -c 'lsmod | wc -l; lsmod | head'
```

## بازگشت به حالت قبل

چون فقط پارتیشن `boot` عوض می‌شود، بازگشت یک فلش معمولی با Odin است:

- boot image قبلی که کار می‌کرد را فلش کن، یا
- فریمور کامل استوک `A145PXXSDDZH1` را فلش کن (AP + BL + CP + CSC؛ برای حفظ
  داده‌ها از `HOME_CSC` استفاده کن).

هیچ ماژول یا پارتیشن دیگری برای برگرداندن وجود ندارد.

## فرکانس CPU

| خوشه | حداکثر فرکانس |
|---|---|
| little (۶ × Cortex-A55) | 1.8 GHz |
| big (۲ × Cortex-A75) | 2.0 GHz |

این‌ها مقادیر استوک جدول OPP مربوط به G75 (سطح CPU 6) هستند که SM-A145P استفاده
می‌کند. اورکلاک آزمایشی که در v1.4-oc تست شد از پروژه حذف شده و در هیچ ریلیزی نیست.

## سازگاری ABI با ماژول‌های استوک vendor

گوشی صدها ماژول ازپیش‌ساخته از `/vendor` و `/vendor_dlkm` لود می‌کند. با
`CONFIG_MODVERSIONS=y` هر نماد صادرشده یک CRC دارد که از امضای آن ساخته می‌شود؛
تغییر چیدمان هر ساختار GKI صادرشده هزاران CRC را عوض می‌کند و **همهٔ** ماژول‌های
استوک با خطای `disagrees about version of symbol module_layout` رد می‌شوند (همین
موضوع v1.1 را خراب کرد).

به همین دلیل این پروژه:

- `VERMAGIC_STRING` را در `kernel-6.6/include/linux/vermagic.h` دقیقاً روی مقدار
  استوک پین می‌کند؛
- پایهٔ رشتهٔ نسخه را مثل استوک نگه می‌دارد
  (`6.6.92-android15-8-abA145PXXSDDZH1-4k`) و فقط `-behi-vX.Y` را اضافه می‌کند؛
- گزینه‌های شکنندهٔ ABI را فعال نمی‌کند (`NF_TABLES*`، `KSM`، `VXLAN`، `IPVLAN`،
  `NF_CONNTRACK_LABELS`، `LRU_GEN` و…)؛
- در هر بیلد `scripts/kmi_check.py` را با `configs/kmi-baseline-v1.0.txt` اجرا
  می‌کند و اگر هر CRC صادرشده فرق کند یا حذف شود، بیلد fail می‌شود.

`CONFIG_MODULE_SIG_PROTECT` عمداً غیرفعال است، مطابق رفتار بیلد استوک vendor.

## ریلیزها و نسخه‌بندی

ریلیزها **خودکار و عمومی** هستند: هر push به شاخهٔ `main` کرنل را بیلد و یک ریلیز
GitHub منتشر می‌کند. نسخه از `CONFIG_LOCALVERSION` خوانده می‌شود، پس برای انتشار نسخهٔ
جدید:

1. مقدار `CONFIG_LOCALVERSION="-4k-behi-vX.Y"` را در این دو فایل عوض کن:
   - `kernel-6.6/arch/arm64/configs/gki_defconfig`
   - `kernel/kernel_device_modules-6.6/arch/arm64/configs/a14m_defconfig`
2. کامیت کن و به `main` push کن.

workflow تگ (`vX.Y`) را می‌سازد، بیلد می‌کند و ریلیز را با `boot.img`، بستهٔ Odin و
چک‌سام‌ها منتشر می‌کند. اگر تگ قبلاً روی کامیت دیگری ساخته شده باشد، بیلد همان ابتدا
fail می‌شود تا دو کرنل مختلف هرگز یک نسخه نداشته باشند. از مسیر
**Actions → Build Kernel A145P → Run workflow** هم می‌توان بیلد را دستی شروع کرد.

## ساخت از سورس

### GitHub Actions (مسیر پشتیبانی‌شده)

workflow مرجع بیلد است و این کارها را انجام می‌دهد:

1. sync کردن ابزارها و prebuiltهای AOSP `common-android15-6.6`؛
2. دریافت نسخه‌های پین‌شدهٔ `mkbootimg` و `avbtool`؛
3. اعمال پچ پین‌شدهٔ SYSVIPC kABI از Droidspaces؛
4. راه‌اندازی KernelSU روی کامیت پین‌شده؛
5. فعال‌کردن گزینه‌های لازم کرنل و غیرفعال‌کردن شکننده‌های ABI؛
6. بیلد با Kleaf/Bazel (هدف `a14m`، `mgk_64_k66`، حالت user) و overlayهای
   `mt6768_overlay.config`، `o22.config`، `a145p_advanced.config`؛
7. بررسی رشتهٔ نسخه، vermagic استوک و CRC نمادهای صادرشده؛
8. ساخت boot image (هدر v4 + AVB) و بستهٔ Odin.

بیلد کامل روی `ubuntu-latest` حدود ۳۵ تا ۴۵ دقیقه طول می‌کشد.

### بیلد محلی (پیشرفته)

مراحل CI مرجع دقیق هستند. یک مسیر محلی حداقلی، با فرض اینکه مخزن کنار درخت ابزار
AOSP sync‌شده قرار دارد:

```sh
# 1. ابزارها و prebuiltها (همان manifest CI)
repo init -u https://android.googlesource.com/kernel/manifest -b common-android15-6.6 --depth=1
repo sync -c -j"$(nproc)"

# 2. کپی build/, external/, prebuilts/, tools/ به ./kernel/
#    (مرحلهٔ "Set up environment & sync AOSP toolchains" در workflow)

# 3. اعمال پچ Droidspaces و افزودن KernelSU (کامیت‌های پین‌شده در build.yml)

# 4. بیلد
cd kernel
export USE_BAZEL_VERSION=6.4.0
export DEVICE_MODULES_DIR=kernel_device_modules-6.6
export BUILD_CONFIG=../out/target/product/a14m/obj/KERNEL_OBJ/build.config
export OUT_DIR=../out/target/product/a14m/obj/KLEAF_OBJ
export DIST_DIR=../out/target/product/a14m/obj/KLEAF_OBJ/dist
export DEFCONFIG_OVERLAYS="mt6768_overlay.config o22.config a145p_advanced.config"
export PROJECT=mgk_64_k66 MODE=user
python3 kernel_device_modules-6.6/scripts/gen_build_config.py \
  --kernel-defconfig mediatek-bazel_defconfig \
  --kernel-defconfig-overlays "mt6768_overlay.config o22.config a145p_advanced.config" \
  -m user -o "$BUILD_CONFIG"
./kernel_device_modules-6.6/build.sh --nokleaf_localversion

# 5. boot image
cd ..
MBOOTIMG=<mkbootimg.py> AVBTOOL=<avbtool.py> \
AVB_KEY=<testkey_rsa4096.pem> AVB_ALGORITHM=SHA256_RSA4096 \
BOOT_PARTITION_SIZE=33554432 \
  bash scripts/build_boot_image.sh "$DIST_DIR/.../Image.gz" boot.img
```

چیدمان boot image: هدر v4 در ۴ کیلوبایت اول، کرنل gzip، سپس `SEANDROIDENFORCE` و
در انتها فوتر هش AVB به اندازهٔ پارتیشن ۳۲ مگابایتی `boot`.

## ساختار مخزن

| مسیر | محتوا |
|---|---|
| `.github/workflows/build.yml` | CI کامل: ابزارها، پچ‌ها، KernelSU، گیت‌های config، بیلد، بسته‌بندی و انتشار |
| `kernel/` | درخت ماژول‌های دستگاه (`kernel_device_modules-6.6`) و ورودی بیلد Kleaf/Bazel |
| `kernel-6.6/` | سورس کرنل GKI (Android common kernel 6.6) |
| `configs/kmi-baseline-v1.0.txt` | baseline سالم CRC نمادهای صادرشده |
| `configs/stock-a145pxxsddzh1.config` | تنظیمات مرجع استوک |
| `scripts/kmi_check.py` | گیت ABI که در CI اجرا می‌شود |
| `scripts/build_boot_image.sh` | سازندهٔ boot image ۳۲ مگابایتی + فوتر AVB |
| `build_kernel.sh` | wrapper کوچک برای بیلد درخت دستگاه |

## عیب‌یابی

**بوت‌لوپ یا صفحهٔ سیاه بعد از فلش.** فریمور استوک (یا boot image قبلی که کار
می‌کرد) را با Odin فلش کن. فقط `boot` عوض شده، پس داده‌های کاربر دست‌نخورده است.

**نبود Wi-Fi / GPS / FM یا سخت‌افزار دیگر.** این درایورها ماژول‌های ازپیش‌ساختهٔ
`/vendor` هستند؛ اگر رد شوند یعنی boot image و پایهٔ فریمور با هم نمی‌خوانند. مطمئن
شو دستگاه روی `A145PXXSDDZH1` است و boot image از ریلیز همین پروژه آمده است.

**مدیر KernelSU پیام «unsupported» می‌دهد.** از مدیر KernelSU نسخهٔ `v3.3.1` یا
جدیدتر استفاده کن. کرنل نسخهٔ KernelSU را `32680` گزارش می‌کند.

**آداپتورهای USB serial کار نمی‌کنند.** `CONFIG_USB_SERIAL` مثل استوک `=m` است و
بستهٔ ریلیز فایل `.ko` ندارد. برای این آداپتورها بیلد همراه ماژول لازم است.

## اعتبارها

- [AOSP common kernel](https://android.googlesource.com/kernel/common/) — پایهٔ GKI 6.6.
- [KernelSU](https://github.com/tiann/KernelSU) از tiann — روت در سطح کرنل.
- [Droidspaces](https://github.com/ravindu644/Droidspaces-OSS) از ravindu644 —
  پشتیبانی کانتینر و پچ SYSVIPC kABI.
- ابزارهای `mkbootimg` و `avbtool` اندروید برای ساخت image و امضای AVB.
- سامسونگ برای فریمور استوک `A145PXXSDDZH1` و مدیاتک برای ماژول‌های vendor
  MT6769V که این کرنل با آن‌ها سازگار می‌ماند.

## سلب مسئولیت

این یک پروژهٔ شخصی و غیررسمی است. فلش کرنل کاستوم گارانتی را باطل می‌کند و در صورت
بروز مشکل می‌تواند دستگاه را از کار بیندازد. boot image با کلید تست عمومی AOSP امضا
شده است، نه کلید سامسونگ. مسئولیت دستگاه و داده‌هایت با خودت است — یک بستهٔ فریمور
استوک و بکاپ همیشه آماده داشته باش.

سورس کرنل تحت GPL-2.0 است؛ بقیهٔ مخزن همان‌طور که هست و بدون هیچ ضمانتی ارائه
می‌شود.
