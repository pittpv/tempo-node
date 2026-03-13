# Script ile Tempo node kurulumu

`install-tempo.sh` scripti ile Tempo (moderato, mainnet) RPC veya Validator node kurulumu için adım adım rehber. Script Docker kurulumu, snapshot indirme, downgrade ve Telegram bildirimlerini otomatikleştirir.

---

## Zorunlu: Snapshot ve downgrade için screen veya tmux

**3 (Snapshot) veya 4 (Downgrade) seçeneğini çalıştırmadan önce** scripti her zaman **screen** veya **tmux** oturumunda çalıştırın.

- Snapshot indirme ve açma **uzun sürer** (onlarca dakika veya daha fazla).
- SSH oturumu koparsa işlem durur ve baştan başlamanız gerekir.
- screen/tmux oturumunda script bağlantı koptuktan sonra da çalışmaya devam eder; daha sonra tekrar bağlanabilirsiniz.

**Diğer tüm işlemler için** (snapshot olmadan kurulum, log görüntüleme, konteyner durdurma/başlatma vb.) screen veya tmux gerekmez.

Örnekler:

```bash
# Seçenek 1: screen
screen -S tempo
# ardından tek satırlık komutu veya ./install-tempo.sh çalıştırın
# 3 veya 4 seçin. Ayır: Ctrl+A, sonra D. Tekrar bağlan: screen -r tempo

# Seçenek 2: tmux
tmux new -s tempo
# ardından tek satırlık komutu veya ./install-tempo.sh çalıştırın
# 3 veya 4 seçin. Ayır: Ctrl+B, sonra D. Tekrar bağlan: tmux attach -t tempo
```

---

## Telegram bildirimleri

**3 (Snapshot)** veya **4 (Downgrade)** seçeneği **tamamlandığında** bildirim almak için **.env-tempo** dosyasına (script dizininde veya `$TEMPO_HOME` içinde) ekleyin:

- **TG_BOT_TOKEN** — [@BotFather](https://t.me/BotFather) ile oluşturduğunuz botun token'ı.
- **TG_CHAT_ID** — Chat ID (örn. [@myidbot](https://t.me/myidbot).

Script, node kurduğunuzda (1 veya 2 numaralı seçenek) `$TEMPO_HOME` içinde **.env-tempo** dosyasını **kendisi oluşturur**. **Kurulumdan sonra** bu dosyayı düzenleyerek `TG_BOT_TOKEN` ve `TG_CHAT_ID` ekleyebilir veya portları / `TEMPO_HOME` değiştirebilirsiniz.

.env-tempo örneği:

```env
TG_BOT_TOKEN=123456789:ABCdefGHI...
TG_CHAT_ID=123456789
```

Snapshot indirme/açma veya downgrade bittiğinde script bu sohbere başarı mesajı gönderir. Bu değişkenler yoksa bildirim gönderilmez.

---

## Scripti çalıştırma

**Tek satırlık komut** (GitHub'dan indir, çalıştırılabilir yap, başlat):

```bash
curl -o install-tempo.sh https://raw.githubusercontent.com/pittpv/tempo-node/main/install-tempo.sh && chmod +x install-tempo.sh && ./install-tempo.sh
```

Sonraki çalıştırmalarda:

```bash
cd $HOME && ./install-tempo.sh
```

(veya scripti kaydettiğiniz dizinden)

---

## .env-tempo dosyası ve değişkenler

Node kurduğunuzda (1 veya 2 numaralı seçenek) script, yoksa `$TEMPO_HOME` içinde **.env-tempo** **oluşturur** (.env.example'dan). **Kurulumdan sonra** gerekirse bu dosyayı düzenleyin.

**Ortak değişkenler** (her iki node için):
- `CHAIN` — ağ: `moderato` (testnet) veya `mainnet`
- `TEMPO_HOME` — node kök dizini (varsayılan `$HOME/tempo`)
- `TEMPO_IMAGE` — Docker imajı (örn. `ghcr.io/tempoxyz/tempo:1.1.4`)
- `TG_BOT_TOKEN`, `TG_CHAT_ID` — 3 ve 4 numaralı seçenekler tamamlandığında Telegram bildirimleri
- `SCRIPT_URL` — güncelleme kontrolü için kurulum scripti URL’si (seçenek 8)
- `SNAPSHOTS_API` — snapshot API URL’si (varsayılan resmî adres)

**Yalnızca RPC node** (seçenek 1): tek node çalışırken varsayılan portlar yeterli.
- `RPC_HTTP_PORT`, `RPC_WS_PORT`, `RPC_P2P_PORT`, `RPC_DISCOVERY_PORT`, `RPC_METRICS_PORT` (varsayılan 8545, 8546, 30303, 30303, 9000)

**Yalnızca Validator node** (seçenek 2):
- `VALIDATOR_HTTP_PORT`, `VALIDATOR_WS_PORT`, `VALIDATOR_P2P_PORT`, `VALIDATOR_CONSENSUS_PORT`, `VALIDATOR_DISCOVERY_PORT`, `VALIDATOR_METRICS_PORT` (varsayılan 8545, 8546, 30303, 8000, 30303, 9000)

**Aynı sunucuda hem RPC hem Validator** çalışıyorsa `.env-tempo` içinde Validator için **farklı portlar** tanımlayın (örn. `VALIDATOR_HTTP_PORT=8547`, `VALIDATOR_P2P_PORT=30304`). Aşağıdaki “Aynı sunucuda RPC ve Validator” bölümüne bakın.

---

## Aynı sunucuda RPC ve Validator

**RPC ve Validator’ı aynı sunucuda çalıştırmak önerilmez**: iki node CPU, disk ve bellek yükünü artırır. Script, kaynaklar yeterliyse **aynı makinede ikisini de kurmanıza izin verir**.

**İkisi de kurulduğunda:**
- RPC `$TEMPO_HOME/rpc`, Validator `$TEMPO_HOME/validator` içindedir; konteynerler `tempo-rpc` ve `tempo-validator` adlıdır.
- `.env-tempo` içinde Validator için mutlaka farklı portlar tanımlayın (yukarıya bakın), yoksa ikinci node bağlanamaz.
- **4** (Downgrade), **6** (Loglar), **7** (Kaldır), **9** (Durdur), **10** (Başlat), **11** (Senkron kontrolü), **12** (Disk kullanımı) seçenekleri **“Which node?”** menüsünü gösterir: **1) RPC** veya **2) Validator** seçin. Her seçenekte konteyner durumu (çalışıyor / durduruldu) gösterilir. Her node’u ayrı yönetebilirsiniz: durdurma, başlatma, snapshot, downgrade, log görüntüleme vb.
- Bu menüde **0) Return to main menu** ana menüye döner, işlem yapılmaz.

---

## Başlangıç ayarları

1. Script Docker ve Docker Compose kontrol eder; eksikse yükleme önerir. Gerekirse `y` ile kabul edin.

2. Ana menüde dil seçimi istenirse seçin.

3. Node kurmak için:
   - **1** — **RPC Node**: yalnızca zincir senkronu ve API; validator anahtarı ve whitelist gerekmez. `--follow` modunda çalışır.
   - **2** — **Validator Node**: konsensüs ve blok üretimi; konsensüs imza anahtarı ve whitelist gerekir. Script **FEE_RECIPIENT** (ödüller için EVM adresi) sorar ve ilk kurulumda imza anahtarı yoksa onu **üretir**.

---

## RPC Node kurulumu (seçenek 1)

1. Menüde **1** (Install Tempo RPC Node) seçin.
2. Script RPC portlarını kontrol eder: HTTP (8545), WebSocket (8546), P2P (30303), metrics (9000). Port meşgulse `.env-tempo` içinde `RPC_HTTP_PORT`, `RPC_WS_PORT`, `RPC_P2P_PORT`, `RPC_METRICS_PORT` ayarlayıp tekrar çalıştırın.
3. `$TEMPO_HOME/rpc` (varsayılan `$HOME/tempo/rpc`) oluşturulur; içinde `data`, `keys`, `docker-compose.yml` ve node tipi işareti vardır. RPC için konsensüs anahtarı **oluşturulmaz** (`--follow` ile çalışır, blok imzalamaz).
4. Script gerekirse `$TEMPO_HOME` içinde `.env-tempo` oluşturur, imajı çeker ve `tempo-rpc` konteynerini başlatır.
5. Node’u olduğu gibi kullanabilir (genesis’ten senkron) veya **screen/tmux** içinde **3** (Snapshot) çalıştırıp senkronu hızlandırabilirsiniz.

Kurulumdan sonra RPC örneğin `http://0.0.0.0:8545` (veya .env-tempo’daki portlar) üzerinden erişilebilir.

---

## Validator Node kurulumu (seçenek 2)

1. Menüde **2** (Install Tempo Validator Node) seçin.
2. Script **FEE_RECIPIENT** ister — ödüller için EVM adresi (0x ile). Ardından validator portlarını kontrol eder: HTTP, WebSocket, P2P, Consensus (8000), metrics. Port meşgulse `.env-tempo` içinde `VALIDATOR_HTTP_PORT`, `VALIDATOR_P2P_PORT`, `VALIDATOR_CONSENSUS_PORT` vb. ayarlayıp tekrar çalıştırın.
3. `$TEMPO_HOME/validator` oluşturulur; içinde `data` ve `keys` vardır. `keys/signing.key` yoksa script konsensüs imza anahtarını **üretir** (`consensus generate-private-key`) ve buna göre genel anahtarı `keys/signing.pub` oluşturur (`consensus calculate-public-key`). Özel anahtar varsa ama `signing.pub` yoksa script genel anahtarı ayrıca oluşturur.
4. `tempo-validator` konteyneri için `docker-compose.yml` yazılır, data ve keys mount edilir; gerekirse `$TEMPO_HOME` içinde `.env-tempo` oluşturulur.
5. İlk tam çalıştırmadan önce **screen/tmux** içinde **3** (Snapshot) çalıştırmanız önerilir.

---

## Snapshot (seçenek 3) — screen veya tmux içinde

1. **Scripti screen veya tmux içinde başlatın** (yukarıdaki bölüme bakın).
2. Ana menüde **3** (Snapshot) seçin.
3. Her iki node kuruluysa RPC veya Validator seçin.
4. Snapshot kaynağını seçin:
   - **0** veya Enter — API'den son sürüm;
   - **u** — snapshot URL'sini elle girin;
   - **e** — yerel `.tar.lz4` dosya yolu;
   - Listeden numara — sıra numarasıyla seçim.
5. Script konteyneri durdurur, snapshot indirir ve açar, node'u yeniden başlatır.
6. .env-tempo'da **TG_BOT_TOKEN** ve **TG_CHAT_ID** ayarlıysa tamamlandığında Telegram bildirimi gelir.

---

## Downgrade (seçenek 4) — screen/tmux önerilir

1. Scripti **screen** veya **tmux** içinde çalıştırmanız önerilir.
2. Ana menüde **4** (Downgrade) seçin.
3. RPC veya Validator seçin.
4. Listeden sürüm seçin veya özel etiket girin (örn. `1.1.0`).
5. İmaj çekildikten sonra script, seçilen sürüm için **zincir snapshot’ı indirilsin mi** diye sorar. **Evet** derseniz ilgili zincir için mevcut snapshot sürümleri listelenir ve birini seçebilirsiniz (veya en son olanı kullanabilirsiniz). **Hayır** derseniz node yalnızca yeni imajla, mevcut zincir verisi korunarak yeniden başlatılır.
6. Snapshot sürüm menüsünde ayrıca **b (geri)** seçeneği vardır — snapshot seçiminden geri dönüp yalnızca indirilen imajla node’u yeniden başlatmanıza (snapshot indirmeyi atlamanıza) izin verir.
7. Telegram yapılandırılmışsa downgrade (ve varsa snapshot) tamamlandığında bildirim alırsınız.

---

## Diğer seçenekler

- **5** — seçilen RPC veya Validator için node/imaj sürümü.
- **6** — seçilen node’un logları (çıkış: Ctrl+C).
- **7** — node kaldırma: sadece konteyner (veri ve anahtarlar kalır) veya veri ve anahtarlarla tam kaldırma.
- **8** — **Güncellemeleri kontrol et**: kurulum scripti sürümünü gösterir; `.env-tempo` içinde **SCRIPT_URL** (GitHub veya başka bir adresteki script URL’si) ayarlıysa daha yeni kurulum scripti olup olmadığını kontrol eder. Ayrıca GitHub’daki son Tempo node sürümünü gösterir ve kurulu node ile karşılaştırır (daha yeni sürüm varsa node’u güncellemek için 4 numaralı Downgrade seçeneğini önerir). Kurulum scriptinin kendisini güncellemek ayrı yapılır (örn. SCRIPT_URL ayarlıyken `./install-tempo.sh -U`).
- **9 / 10** — seçilen node’un konteynerini durdurur/başlatır; “Which node?” menüsünde her konteynerin durumu (çalışıyor / durduruldu) gösterilir.
- **11** — seçilen node’un RPC’si üzerinden senkron ve blok kontrolü (peers, blok yüksekliği, eth_syncing vb.).
- **12** — seçilen node’un disk kullanımı (veri ve anahtarlar).

---

## Özet

| İşlem | Screen/tmux | .env-tempo'da Telegram |
|--------|-------------|------------------------|
| RPC/Validator kur (1, 2) | Zorunlu değil | İsteğe bağlı (kurulumdan sonra dosyayı düzenleyin) |
| Snapshot (3) | **Zorunlu** | Önerilir (tamamlanma bildirimi) |
| Downgrade (4) | **Önerilir** | Önerilir (tamamlanma bildirimi) |
| Diğer seçenekler | Zorunlu değil | Gerekmez |

Node'unuz sorunsuz çalışsın.

> **Script hakkında sorularınız varsa** Telegram destek sohbetinde sorun: [https://t.me/+DLsyG6ol3SFjM2Vk](https://t.me/+DLsyG6ol3SFjM2Vk)
