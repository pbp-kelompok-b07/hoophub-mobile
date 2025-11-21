# hoophub

## Nama Anggota Kelompok
- Rivaldy Putra Rivly (2406351453)
- Rafalah Izak (2406417790)
- Bisma Zharfan Satryo Wibowo (2406355136)
- Akhtar Eijaz Putranto (2406495571)
- Rochelle Marchia Arisandi (2406429014)
- Roselia Evanny Sucipto (2406410235)

## Deskripsi Aplikasi
Pecinta basket, pasti tahu rasanya susah payah cari sepatu yang cocok, nyari jersey tim idola, atau bingung cari ring portable buat main bareng teman. Di tengah euforia olahraga yang makin naik daun, terutama basket, rasanya penting banget punya satu tempat khusus buat cari segala perlengkapan tanpa ribet. Dari lapangan sekolah sampai turnamen komunitas, perlengkapan yang tepat bisa jadi game changer.

Dari keresahan itulah, hoophub hadir sebagai one-stop platform buat pecinta dunia basket. Kami nggak cuma jual sepatu dan bola, tapi juga jersey kece, pelindung, ring basket portable, sampai aksesori lengkap yang bisa bikin gaya mainmu makin maksimal. Dengan katalog awal berisi ratusan produk, kamu bisa jelajahi berbagai merek.

hoophub bukan sekadar toko, ini komunitas. Tempat di mana semangat main basket bertemu dengan kemudahan teknologi. Yuk, bikin permainannya makin seru, bareng hoophub.

## Daftar Modul
Wishlist
- Dikerjakan oleh: Rochelle
- Pada modul ini, akan berisi list produk yang telah “ditandai” dan “disimpan” oleh pengguna untuk kemudahan pembelian dan melihat produk.

Keranjang dan checkout
- Dikerjakan oleh: Rafalah
- Pada modul ini, pengguna dapat menambahkan produk ke keranjang dan melakukan checkout untuk pembelian produk.

Laporan
- Dikerjakan oleh: Bisma
- Pada modul ini, pengguna dapat melaporkan kendala yang dialami kepada admin, kemudian admin dapat melihat laporan tersebut dan menyelesaikan kendalanya.

Ulasan dan Rating
- Dikerjakan oleh: Roselia
- Pada modul ini, pengguna dapat memberikan review serta rating mengenai produk yang dijual. Pengguna dapat mengedit serta menghapus review yang telah diberikan.

Katalog dan Pencarian
- Dikerjakan oleh: Rivaldy
- Pada modul ini, akan berisi list produk dan pengguna dapat melakukan filtering atau pencarian berdasarkan kategori, merek, atau harga yang sesuai. Admin dapat menambah, mengubah, serta menghapus produk.

Invoice
- Dikerjakan oleh: Akhtar
- Pada modul ini, setelah pengguna membeli suatu produk, akan otomatis membuat suatu invoice yang memuat nama produk, jumlah produk, harga produk, dan alamat (opsional).

## Sumber Initial Dataset
- https://docs.google.com/spreadsheets/d/116yGaRjewufSu_6dCSuxHHOd2ouape10tNWU2QdtcAU/edit?usp=drivesdk 
- Dataset diperoleh dengan metode scraping dari website Nike, adidas, Spalding, Wilson, dan TARMAK.

## Peran Pengguna
Guest (tidak login):
- Guest dapat browsing katalog, melihat detail produk, menggunakan filter, serta melihat review yang ada.

User:
- User dapat menambahkan produk ke keranjang, melakukan checkout, serta menulis ulasan dan rating.

Admin:
- Admin dapat menambahkan, mengubah, serta menghapus produk, serta mengelola stok.

## Alur pengintegrasian dengan web service untuk terhubung dengan aplikasi web yang sudah dibuat
-  Alur pengintegrasian web service untuk terhubung dengan aplikasi web yang sudah dibuat, kami akan melakukan beberapa hal berikut:
1. Menambahkan package atau library `http` pada proyek agar aplikasi mobile dapat berinteraksi dengan aplikasi web.
2. Menggunakan fitur autentikasi seperti login, register, dan logout yang telah dibuat sebelumnya agar bisa memberikan otorisasi sesuai peran pengguna, yaitu sebagai admin, user, atau guest (tidak login).
3. Menggunakan package `pbp_django_auth` untuk mengelola cookie sehingga request yang dikirimkan ke server merupakan request yang terautentikasi dan terotorisasi.
4. Mengimplementasikan class Catalog pada Flutter dengan memanfaatkan API dataset yang telah dibuat dan dapat diakses di `https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/`, serta memanfaatkan `https://app.quicktype.io/` untuk mengubah data JSON menjadi objek Dart yang akan digunakan untuk membentuk class Catalog di Flutter.

## Link Design
- https://www.figma.com/design/wwBBdlglDQBOCo9OM1RAQe/Untitled?node-id=0-1&t=M3sb6RFJ55DRoEJ1-1 

