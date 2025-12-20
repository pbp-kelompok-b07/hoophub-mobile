import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onRegularItemTapped;
  // [TAMBAHAN]: Callback spesifik untuk ikon Profile (untuk memicu Pop-up)
  final VoidCallback onProfileTapped; 

  const CustomBottomNavBar({
    super.key, 
    required this.selectedIndex, 
    required this.onRegularItemTapped,
    required this.onProfileTapped, 
  });

  @override
  Widget build(BuildContext context) {
    // [PERUBAHAN]: Bungkus dengan Container dan Padding internal.
    // Kita menggunakan Container di sini untuk memastikan latar belakang putih
    // mencakup area padding tambahan.
    return Container(
      // [PERUBAHAN]: Tambahkan padding internal di sini untuk memperlebar kotak ke bawah
      padding: const EdgeInsets.only(bottom: 5.0), 
      decoration: const BoxDecoration(
        color: Colors.white, // Atur latar belakang Container agar padding ikut berwarna
        boxShadow: [
          BoxShadow(
            color: Colors.black12, 
            blurRadius: 4, 
            offset: Offset(0, -2) // Bayangan tipis ke atas
          )
        ]
      ),
      // [PERBAIKAN]: Gunakan SafeArea untuk otomatis menangani area bawah (gesture bar)
      child: SafeArea(
        // Hanya aktifkan SafeArea di bagian bawah
        top: false, 
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index){
            if (index == 3) { // Index 3 adalah 'Profile'
              onProfileTapped(); // Panggil fungsi pop-up menu
            } else {
              onRegularItemTapped(index); // Panggil fungsi ganti tab standar
            }
          },
          type: BottomNavigationBarType.fixed, // Memastikan semua item terlihat
          
          // Pengaturan Warna
          selectedItemColor: Theme.of(context).colorScheme.primary, // Warna item aktif
          unselectedItemColor: Colors.grey, // Warna item non-aktif
          backgroundColor: Colors.white, // Latar belakang putih (sama dengan Container)
          elevation: 0, // Elevation dipindahkan ke Box Shadow Container
          
          // Daftar Item
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home), 
              label: "Home"
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.store), 
              label: "Shop"
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite), 
              label: "Wishlist"
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person), 
              label: "Profile"
            ),
          ],
        ),
      ),
    );
  }
}