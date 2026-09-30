# Android APK (test sürümü)

Proje mobil için hazır: dikey (portrait) yönelim, 540×960 taban çözünürlük (`canvas_items` + `expand`), Android geri tuşu, çentik/hareket çubuğu payı, ikon (`icon.svg`) ve `export_presets.cfg` (Android, arm64). Anahtar/şifre dosyalara **yazılmaz**; Godot bunları `.godot/export_credentials.cfg` içinde tutar ve Git'e girmez.

## Bir kez yapılacaklar (kendi bilgisayarında)

1. Godot 4.7 → **Editor → Manage Export Templates → Download and Install** (editörle aynı sürüm).
2. **OpenJDK 17** kur.
3. **Android SDK** kur (Android Studio veya yalnız command-line tools): `platform-tools`, `build-tools`, bir `platform`. Sürümleri Godot'un "Exporting for Android" dokümanındaki güncel tablodan al.
4. **Editor → Editor Settings → Export → Android**: *Java SDK Path*, *Android SDK Path*, *Debug Keystore* (yoksa `keytool` ile üret).
5. **Project → Export**: "Android (test APK)" hazır gelir. Sarı uyarı çıkarsa Godot ne eksik olduğunu yazar.

## APK alma

- Dosya: **Export Project** (Debug) → `godot/build/the-path-boss.apk` (klasör Git'e girmez).
- Telefona doğrudan: telefonda geliştirici modu + USB hata ayıklama, sonra editörün sağ üstündeki Android simgesi (**One-click deploy**).

## Telefonda dikkat

- Yazı ve düğme boyutları 540 genişlikte tasarlandı; telefonda yaklaşık 2× büyür.
- Ana sekme çubuğu sabit; Geri tuşu önce onay penceresini, sonra detay ekranını kapatır, sonra Özet'e döner.
- Oyun her adımda otomatik kaydedilir (`user://savegame.dat`) ve açılışta yüklenir. **Profil → Kayıt → "Kaydı sil ve yeni oyun"** ile silinir (onay ister). Kayıt uygulama verisidir; uygulamayı kaldırmak da siler. Kayıt sürümü uyuşmazsa yok sayılır.
- Görseller `res://art/factories/<id>.png` ve `res://art/machines/<tür>_<seviye>.png` yollarına konursa APK'ya girer.
- Release/Play Store için AAB, gradle build ve release keystore gerekir; bu dosya yalnız test APK'sını kapsar.
