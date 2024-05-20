# Rathole Tunnel

A secure, stable and high-performance reverse proxy for NAT traversal, written in Rust

## Installation


To use Rathole Tunnel, simply download and run the script from the following link:


```
wget -Nq https://github.com/Musixal/rathole-tunnel/raw/main/rathole.sh && bash rathole.sh
```


1) First of all run the script using the link.
2) Download and install the main rathole core through option 4.
3) Run the script on the your iran server. Specify the tunnel port and enter as many ports as you need for your configurations.
4) Finally, add a reset timer through option 6.
5) In the main (Kharej) server, the steps are similar to the Iran server. You only need to enter the IP address of the your Iran server.
6) Don't forget to add a timer to reset the service in the main server.
Good luck
_____________________________________________________________________________________



ترنسپورت UDP اضافه شد و می تونید برای مثلا وایرگارد استفاده کنید.

برای افزودن ریست تایمر از گزینه ۶ یعنی cron-job استفاد کنید.

برای استفاده Ubuntu 22.04 و Debian 12 رو فقط پیشنهاد میکنم.



🟢 **نحوه ی تانل چند سرور خارج به یک سرور ایران:**

دقت کنید برای این کار باید پورت تانل بین همه سرورها یکسان باشد. 
 مثلا ۳ سرور خارج دارید. 

0️⃣ در سرور ایران ۳ کانفیگ با مشخصات زیر می سازید. 
شماره پورت ها رو میتونید به دلخواه تغییر بدید:

پورت تانل: ۸۰۸۰ 
پورت کانفیگ ۱:‌ ۲۰۵۳
پورت کانفیگ ۲:‌ ۲۰۵۷
پورت کانفیگ ۳:‌ ۲۰۸۳

1️⃣ برای سرور خارج ۱ فقط یک کانفیگ میزنید:
پورت تانل: ۸۰۸۰ 
پورت کانفیگ:‌ ۲۰۵۳

2️⃣ برای سرور خارج ۲ فقط یک کانفیگ میزنید:
پورت تانل: ۸۰۸۰ 
پورت کانفیگ:‌ ۲۰۵۷

3️⃣ برای سرور خارج ۳ فقط یک کانفیگ میزنید:
پورت تانل: ۸۰۸۰ 
پورت کانفیگ:‌ ۲۰۸۳


به این ترتیب هر پورت به یک سرور خارج تونل میشه. هر چقد سرور خارج داشته باشید میتونید متصل کنید و محدودیتی  نداره. ‌پورت عجیب غریب هم نزنید.


# Menu
![Menu](https://github.com/Musixal/rathole-tunnel/blob/main/rathole-menu.png)

# My Channel
Check my Telegram channel for more information:
https://t.me/Gozar_Xray


# Source

https://github.com/rapiz1/rathole
