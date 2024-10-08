Установка Xray на macOS похожа на процесс установки на другие UNIX-подобные системы, такие как Linux. Она включает загрузку Xray, настройку конфигурационного файла и запуск программы через терминал.

### Шаги по установке Xray на macOS:

### 1. **Установка Homebrew (если он не установлен)**

Для начала установите **Homebrew** — менеджер пакетов для macOS, если он ещё не установлен. Откройте терминал и выполните команду:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. **Установка Xray через Homebrew**

Существует удобный способ установки Xray через Homebrew:

1. Добавьте репозиторий с Xray (если ошибка, то попробуйте с `sudo`):

```bash
brew tap xtls/tap
```

2. Установите Xray:

```bash
brew install xray
```

### 3. **Создание конфигурационного файла**
#### Шаг 0. Запросите у админа вашу ссылку для подключения:
```
vless://ID@SERVER_IP:SERVER_PORT?type=tcp&security=reality&pbk=PUBLIC_KEY=chrome&sni=yahoo.com&sid=SHORT_ID&spx=%2F&flow=xtls-rprx-vision#vvv-boris-sony
```

Xray требует файла конфигурации в формате JSON. В macOS конфигурационные файлы обычно находятся в `/usr/local/etc/xray/`. Вам нужно создать файл `config.json`.

#### Шаг 1: Создайте папку для конфигурации (если её нет)

```bash
sudo mkdir -p /usr/local/etc/xray
```

#### Шаг 2: Создайте или отредактируйте файл конфигурации

Используйте текстовый редактор (например, `nano` или `vi`), чтобы создать или отредактировать конфигурационный файл:

```bash
sudo nano /usr/local/etc/xray/config.json
```

Пример конфигурационного файла для использования VLESS:

```json
{
   "log":{
     "loglevel":"debug"
   },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 1080,
      "protocol": "socks",
      "settings": {
        "udp": true
      },
      "sniffing": {
                "enabled": true,
                "destOverride": [
                    "http",
                    "tls",
                    "quic"
                ],
                "routeOnly": true
            }
    }
  ],
  "outbounds": [
    {
      "protocol": "vless",
      "settings": {
        "vnext": [
          {
            "address": "SERVER_IP из ссылки",
            "port": SERVER_PORT из ссылки,
            "users": [
              {
                "id": "ID из ссылки",
                "flow": "xtls-rprx-vision",
                "encryption": "none"
              }
            ]
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "show": false,
          "fingerprint": "chrome",
          "serverName": "yahoo.com",
          "publicKey": "PUBLIC_KEY из ссылки",
          "shortId": "SHORT_ID из ссылки",
          "spiderX": "/"
        }
      },
     "tag":"proxy"
    }
  ]
}
```

#### Шаг 3: Сохраните изменения

После внесения изменений сохраните файл и выйдите из редактора (если используете `nano`, нажмите **Ctrl + o**, затем **Enter** и нажмите **Ctrl + X**).

### 4. **Запуск Xray**

После того как конфигурационный файл настроен, запустите Xray:

```bash
sudo xray -config /usr/local/etc/xray/config.json
```

Если конфигурация правильная, Xray начнет работать, используя указанные параметры.

### 5. **Настройка браузера для использования прокси**

Теперь, когда Xray запущен и работает как SOCKS-прокси, вам нужно настроить браузер (или систему), чтобы использовать этот прокси.

#### Настройка Firefox:

1. Откройте **Настройки** -> **Сеть** -> **Настроить прокси**.
2. Выберите **Ручная настройка прокси**.
3. В поле **SOCKS Host** введите `127.0.0.1`, в поле **Port** — `1080`.
4. Выберите вариант **SOCKS5**.
5. Сохраните изменения.

#### Настройка Chrome:

Для Chrome можно использовать параметр командной строки для запуска через прокси:

1. Закройте Chrome.
2. Откройте терминал и выполните:

```bash
open -a "Google Chrome" --args --proxy-server="socks5://127.0.0.1:1080"
```

### 6. **Проверка работы**

Зайдите на сайт для проверки вашего IP-адреса (например, [whatismyip.com](https://whatismyip.com)), чтобы убедиться, что трафик проходит через прокси, и ваш IP-адрес изменен.

### 7. **Остановка Xray**

Чтобы остановить Xray, вы можете нажать **Ctrl + C** в терминале, если Xray был запущен напрямую. Если хотите остановить его позже, найдите процесс Xray и завершите его:

```bash
ps aux | grep xray
sudo kill -9 <номер процесса>
```

### 8. **Автоматизация запуска (опционально)**

Если вы хотите, чтобы Xray запускался автоматически при старте системы, можно добавить команду запуска в файл `~/.bash_profile` или создать скрипт автозагрузки.

Теперь Xray установлен и настроен на вашем Mac, и вы можете использовать его для проксирования интернет-трафика.

## Перенаправление трафика
Чтобы перенаправить весь системный трафик через SOCKS-прокси в macOS, вы можете воспользоваться встроенными инструментами и командами, такими как `networksetup`, либо использовать дополнительные утилиты для более гибкой настройки. 

Ниже приведены несколько способов настроить прокси на уровне системы.

### Способ 1: Использование команды `networksetup`

macOS предоставляет встроенную утилиту для настройки сетевых параметров — `networksetup`. С её помощью вы можете указать для конкретного сетевого интерфейса использование SOCKS-прокси.

#### Шаги:

1. **Откройте терминал** на вашем Mac.

2. **Получите список доступных сетевых сервисов** (например, Wi-Fi, Ethernet):

   Выполните команду, чтобы увидеть доступные интерфейсы:

   ```bash
   networksetup -listallnetworkservices
   ```

   Вы увидите список сетевых сервисов, например:

   ```
   An asterisk (*) denotes that a network service is disabled.
   Wi-Fi
   Ethernet
   ```

3. **Включите SOCKS-прокси для нужного интерфейса**. Например, для Wi-Fi выполните команду:

   ```bash
   sudo networksetup -setsocksfirewallproxy "Wi-Fi" 127.0.0.1 1080
   ```

   Здесь:
   - `"Wi-Fi"` — это название сетевого интерфейса (замените на нужный, если используете другой, например, Ethernet).
   - `127.0.0.1` — это IP-адрес прокси-сервера (в данном случае локальный адрес, где запущен Xray).
   - `1080` — порт вашего SOCKS-прокси.

4. **Включите прокси для всех протоколов**:

   Для того чтобы включить прокси для всех протоколов и перенаправить весь трафик через SOCKS-прокси, выполните следующую команду:

   ```bash
   sudo networksetup -setsocksfirewallproxystate "Wi-Fi" on
   ```

5. **Проверка настроек**:

   Чтобы проверить, что прокси настроен, выполните:

   ```bash
   networksetup -getsocksfirewallproxy "Wi-Fi"
   ```

   Вы должны увидеть что-то вроде:

   ```
   Enabled: Yes
   Server: 127.0.0.1
   Port: 1080
   ```

6. **Отключение прокси (при необходимости)**:

   Если вам нужно отключить прокси, выполните:

   ```bash
   sudo networksetup -setsocksfirewallproxystate "Wi-Fi" off
   ```

### Способ 2: Использование приложения ProxyCap (графический интерфейс)

Если вы хотите использовать более удобный графический интерфейс для перенаправления всего трафика через прокси, вы можете установить стороннее приложение, такое как **ProxyCap**.

#### Шаги:

1. Перейдите на официальный сайт ProxyCap: [https://www.proxycap.com/download.html](https://www.proxycap.com/download.html).
2. Скачайте и установите версию для macOS.
3. Откройте ProxyCap и добавьте правило для перенаправления всего трафика через ваш SOCKS-прокси (например, `127.0.0.1:1080`).
4. Примените настройки.

ProxyCap предоставляет гибкие настройки для выбора приложений и протоколов, которые должны использовать прокси.

### Способ 3: Использование утилиты `pf` (файрвол) для перенаправления трафика

Для более продвинутой настройки можно использовать утилиту **`pf`** (Packet Filter), встроенную в macOS, для перенаправления трафика на уровне ядра системы.

#### Шаги:

1. **Откройте терминал** и отредактируйте конфигурационный файл `pf`:

   ```bash
   sudo nano /etc/pf.conf
   ```

2. Добавьте правила для перенаправления всего трафика на SOCKS-прокси. Например, для перенаправления всех TCP-запросов через локальный прокси-сервер на `127.0.0.1:1080`, добавьте следующие строки:

   ```bash
   rdr pass on en0 inet proto tcp to any port 80 -> 127.0.0.1 port 1080
   rdr pass on en0 inet proto tcp to any port 443 -> 127.0.0.1 port 1080
   ```

   Здесь `en0` — это интерфейс вашего сетевого адаптера (может быть другим, например, `en1` для Wi-Fi).

3. Сохраните файл и выйдите из редактора (`Ctrl + X`, затем **Y** и **Enter**).

4. **Примените настройки**:

   Примените правила файрвола с помощью команды:

   ```bash
   sudo pfctl -f /etc/pf.conf
   sudo pfctl -e
   ```

Теперь весь HTTP(S)-трафик будет перенаправляться через указанный SOCKS-прокси.

### Проверка работы прокси

Чтобы убедиться, что трафик действительно проходит через прокси, вы можете использовать веб-сайт для проверки IP-адреса, например:

- [whatismyip.com](https://www.whatismyip.com)
- [ipleak.net](https://ipleak.net)

Если всё настроено правильно, ваш IP-адрес должен измениться на тот, который вы ожидаете от прокси-сервера.

Теперь весь трафик вашей системы перенаправляется через SOCKS-прокси на macOS.
