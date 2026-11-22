# Panduan Submission Akhir: GameVault

Ikuti urutan ini, karena modul **GameVaultCore harus dipublish lebih dulu**. Modul lain mengunduhnya dari GitHub.
Di semua perintah, ganti `USERNAME` dengan username GitHub Anda.

---

## A. Publish modul GameVaultCore

1. Di github.com, buat repo baru bernama **`GameVaultCore`** dengan visibilitas **Public**.
   Jangan centang README, .gitignore, atau license karena file-file itu sudah ada.
2. Di Terminal:
   ```bash
   cd ~/Developer/GameVaultCore
   sed -i '' 's/fandiaspraja/USERNAME/g' README.md
   git init
   git add .
   git commit -m "GameVaultCore 1.0.0: generic protocol Clean Architecture"
   git branch -M main
   git remote add origin https://github.com/USERNAME/GameVaultCore.git
   git push -u origin main
   git tag 1.0.0
   git push origin 1.0.0
   ```
   **Tag `1.0.0` wajib dibuat.** Swift Package Manager mencari versi lewat tag.
3. Buka tab **Actions** di repo tersebut dan pastikan workflow CI berwarna hijau ✅.

## B. Siapkan proyek aplikasi

1. Isi username di seluruh proyek:
   ```bash
   cd ~/Developer/GameVault
   ./scripts/set-github-username.sh USERNAME
   ```
2. Periksa API key. Buka `Config/Secrets.xcconfig`, isinya harus API key RAWG Anda. Kalau file ini
   tidak ada, salin dari `Secrets.example.xcconfig` lalu isi key-nya.
3. Buat proyek Xcode, lalu buka:
   ```bash
   xcodegen generate
   open GameVault.xcodeproj
   ```
   Tunggu sampai Xcode selesai mengunduh package (GameVaultCore, Swinject, Alamofire, Kingfisher).
4. Pilih simulator iPhone, lalu:
   - **⌘B** untuk build, lalu **⌘R** untuk run. Cek Beranda (termasuk tombol Urutkan), Detail (termasuk Screenshot), Favorit, dan Tentang.
   - **⌘U** untuk test aplikasi.
   - Pilih scheme **Common / Game / Detail / Favorite / About** satu per satu, lalu tekan **⌘U**.
     Semua test harus hijau.
5. Untuk mencoba bahasa Inggris: buka Pengaturan iOS di simulator ▸ GameVault ▸ Language ▸ English.
   Bisa juga lewat baris **Bahasa** di halaman Tentang.

## C. Push aplikasi ke GitHub dan cek CI

1. Buat repo baru **`GameVault`** dengan visibilitas **Public**, tanpa README.
2. Di Terminal:
   ```bash
   cd ~/Developer/GameVault
   git init
   git add .
   git status        # pastikan Config/Secrets.xcconfig TIDAK ada di daftar
   git commit -m "GameVault: modularization, CI, localization"
   git branch -M main
   git remote add origin https://github.com/USERNAME/GameVault.git
   git push -u origin main
   ```
   Pastikan `GameVault.xcodeproj` (termasuk folder `xcshareddata`) dan `Package.resolved` ikut ter-push.
   CI memakai keduanya.
3. Buka tab **Actions**. Ketiga job (**Build & Test**, **Code Style**, **Vulnerability Scan**) harus hijau ✅.
   Run pertama biasanya butuh 10–20 menit.
4. Kalau ada job yang merah, buka job itu, salin bagian error-nya, lalu kirimkan ke Claude.

## D. Zip untuk Dicoding

```bash
cd ~/Developer
zip -r GameVault-Submission.zip GameVault -x "*/.git/*" "*.DS_Store" "*/xcuserdata/*" "*/.build/*" "*/DerivedData/*" "*/TestResults/*"
```
Zip ini **berisi** `Config/Secrets.xcconfig` supaya reviewer bisa langsung menjalankan aplikasi.
Isinya juga mencakup `GameVault.xcodeproj` dan folder `Wireframe/`.

---

## E. Catatan untuk reviewer (salin ke kolom *Catatan*)

```
GameVault – Submission Akhir "Menjadi iOS Developer Expert"

TAUTAN
- Repo aplikasi        : https://github.com/USERNAME/GameVault
- CI (GitHub Actions)  : https://github.com/USERNAME/GameVault/actions
- Modul dipublish (SPM): https://github.com/USERNAME/GameVaultCore  (tag 1.0.0)

KRITERIA WAJIB
1. Continuous Integration: GitHub Actions (.github/workflows/ci.yml) dengan 3 job
   (Build & Test, Code Style, Vulnerability Scan). Run terakhir sukses.
2. Modularization:
   - Modul fitur (Swift Package lokal): Game, Detail, Favorite, About, ditambah modul bersama Common.
   - Modul Core (GameVaultCore) dipublish ke GitHub via Swift Package Manager dan dipakai lewat URL
     (tidak ada salinan lokal).
3. Syarat sebelumnya tetap ada: Beranda, Detail, Favorit, Tentang (nama + foto asli).
   Clean Architecture di setiap modul (Data → Domain ← Presentation).
   Dependency Injection dengan Swinject (App/Sources/DI/Injection.swift, Assembly per modul).
   Reactive Programming dengan Combine (Alamofire publisher & Core Data dibungkus Future).
4. Wireframe: Wireframe/GameVault-Wireframe-v2.png (perubahan ditandai hijau, v1 tetap dilampirkan).

SARAN YANG DITERAPKAN
1. UI sesuai HIG: skeleton shimmer, error state + "Coba Lagi", empty state, toast, Dark Mode,
   Dynamic Type, SF Symbols, label aksesibilitas, komponen sesuai fungsinya.
2. Fitur tambahan baru:
   a. Urutkan daftar gim (Relevan, Terpopuler, Rating tertinggi, Rilis terbaru, Nama A–Z).
      Tujuan: memudahkan pengguna menemukan gim terbaik atau terbaru.
   b. Galeri screenshot di Detail + tampilan layar penuh yang bisa digeser.
      Tujuan: memberi gambaran visual gameplay sebelum memfavoritkan gim.
   c. Pilihan bahasa di halaman Tentang (membuka Pengaturan iOS).
      Tujuan: pengguna bisa memakai aplikasi dalam Bahasa Indonesia atau Inggris.
3. Generic protocol dalam modularization: UseCase, Repository, DataSource, LocalDataSource, Mapper,
   Interactor<Request, Response, R>, RemoteRepository<Remote, Mapper>, AnyUseCase,
   ListPresenter<Request, Item>, ItemPresenter<Request, Item> (di GameVaultCore).
4. Localization di modul Common: Bahasa Indonesia & English (L10n + Localizable.strings),
   termasuk format tanggal dan angka yang mengikuti bahasa.
5. Pengujian business logic dengan XCTest (pendekatan TDD): GamesRequest (normalisasi query,
   batas halaman, halaman berikutnya), ToggleFavorite, Metascore, mapper, presenter, DI.
   Tersedia di GameVaultCore dan setiap modul.
6. CI dengan analisis tambahan: code coverage (ringkasan di setiap run), code style (SwiftLint),
   dan vulnerability (OSV-Scanner untuk Package.resolved + Dependabot).
7. Linter: SwiftLint (.swiftlint.yml + build phase + job CI).
8. Gambar hubungan antar-modul: Wireframe/GameVault-Module-Diagram.png.

CARA MENJALANKAN
Buka GameVault.xcodeproj lalu jalankan scheme GameVault. API key sudah ada di Config/Secrets.xcconfig.
```
