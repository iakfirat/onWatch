# Stacklight × onWatch — GitHub Codespaces denemesi

Bu depo [onllm-dev/onWatch](https://github.com/onllm-dev/onWatch) projesinin GPL-3.0 lisanslı fork'udur. Stacklight'ın üretim sisteminden tamamen bağımsızdır.

## GitHub'da çalıştırma

1. Bu depodaki **Code → Codespaces → Create codespace on main** yolunu aç.
2. Codespace oluşturulurken `.devcontainer/devcontainer.json` uygulanır. Kaynak sürümüne sabitlenmiş onWatch Linux ikilisi resmi GitHub sürümünden çekilir; SHA-256 özeti GitHub Release API üzerinden doğrulanır. İlgili ikili doğrulanamazsa Codespace'in Go ortamında kaynak kodundan derlenir.
3. Codespace açıldığında **Ports** panelinden `9211` portunu aç. **Visibility: Private** olarak bırak. GitHub kimlik doğrulaması arkasındaki önizleme URL'siyle web panelini gör.
4. Yönetici adı: `stacklight`. Parola Codespace terminalinde `cat ~/.config/stacklight-onwatch/admin-password` komutuyla görüntülenir; bu parolayı sohbete, git'e veya log'a koyma.
5. Sağlayıcıları onWatch'ın **Settings → Providers** bölümünden seçip gerekliyse kendi hesaplarınla bağlantılandır. Başlangıçta **hiçbir sağlayıcı bağlantısı yoktur**; gerçek kota görünmesi için ilgili sağlayıcı kimlik doğrulaması gereklidir.

## Sağlayıcı kapsamı

onWatch çok sağlayıcılıdır; Codex, Claude, Gemini, Copilot, Antigravity, OpenCode Go, MiniMax, Z.AI, Cursor ve çeşitli API sağlayıcılarını destekler. **Destek, sunucuda her kaynağın çalışacağı anlamına gelmez**: bazı okuyucular yerel CLI dosyalarına/oturumlara bağımlıdır. Hesap bilgilerini Codespaces'e aktarırken bu farkı gözet.

## Güvenlik / tüketim

- Bu çalışma **Stacklight'ın mevcut Cloudflare D1 veritabanını, OAuth gizli değişkenlerini veya görevlerini değiştirmez**.
- Pilotun Codespaces'teki kimliği ve SQLite dosyası `~/.config/stacklight-onwatch/` ile `~/.local/share/stacklight-onwatch/` altında tutulur; Git'e kaydedilmez.
- Kod deposu **public** fork'tur. Uygulama portu **private** kalmalıdır. Portu public yapma.
- onWatch komutu `--debugstdout` ile Codespace oturumunda çalışır; başlangıç polling aralığı 3600 saniye olarak ayarlıdır, bu bir ürün-üretim cron'u değildir.
- GitHub Codespaces **sürekli çalışan ücretsiz sunucu değildir**. Her açık Codespace işlem süresi ve depolama tüketir. Ücretsiz kullanım planınla sınırlıdır; ücretsiz tahsis biterse ücrete tabi olabilir. Gereksiz kredi tüketmemek için deneme sonunda Codespace'i **Stop** et ve gerekmiyorsa sil.
- GitHub **Actions sürekli kota okuyucusu olarak kullanılmaz**. GitHub Pages Go sunucusunu/SQLite'ı çalıştıramaz.
- Hiçbir abonelik veya API anahtarı projeye otomatik olarak kopyalanmaz.

## Sağlık ve yönetim

Codespace terminalinde:

```bash
curl -I http://127.0.0.1:9211/
tail -n 30 ~/.local/share/stacklight-onwatch/onwatch.log
bash .devcontainer/start-onwatch.sh
```

Kota bilgisi getirmediği halde panel açılıyorsa ilk kontrol sağlayıcının izinleri ve onWatch'ın ilgili okuyucusunun **bulut ortamında** çalışmaya uygun olup olmadığıdır. Bu fork kendi başına Stacklight ile veri senkronizasyonu yapmaz; entegrasyon ancak gerçek ölçümleri doğruladıktan sonra planlanır.
