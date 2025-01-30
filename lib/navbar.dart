import 'package:flutter/material.dart';

class CustomNavbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black.withOpacity(0.8),
      title: const Text("Excelsize", style: TextStyle(color: Colors.white)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
          child: const Text("Anasayfa", style: TextStyle(color: Colors.white)),
        ),
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () {},
        ),
        TextButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/profil'),
          child: const Text("Profil", style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          child: const Text("Çıkış Yap", style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}
