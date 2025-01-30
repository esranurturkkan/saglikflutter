import 'package:flutter/material.dart';
import 'dart:async';
import 'navbar.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String displayedMessage = "";
  int currentChar = 0;
  String fullMessage = "Take a breath. The journey to a healthier you isn't about perfection, it's about progress. Trust yourself.";

  @override
  void initState() {
    super.initState();
    typeWriterEffect();
  }

  void typeWriterEffect() {
    Timer.periodic(const Duration(milliseconds: 90), (timer) {
      if (currentChar < fullMessage.length) {
        setState(() {
          displayedMessage += fullMessage[currentChar];
          currentChar++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomNavbar(),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://theironoffice.com/cdn/shop/files/Gym_12.23-19.jpg?v=1701994187&width=3840',
              fit: BoxFit.cover,
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(color: Colors.black.withOpacity(0.7)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  displayedMessage,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFF8DC),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  featureCard("Aktivite Takibi", "Günlük adım sayınızı ölçün!", Icons.directions_walk),
                  featureCard("Sağlık Verisi", "Kalp atış hızınızı ve uyku düzeninizi takip edin.", Icons.favorite),
                  featureCard("Egzersiz Planlama", "Kişiselleştirilmiş antrenmanlar oluşturun.", Icons.fitness_center),
                ],
              ),
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.5), blurRadius: 15)],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(
                      "https://i.pinimg.com/originals/49/54/9e/49549eec926184fcb69f345b0119084e.gif",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    Text(
                      "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
                    ),
                    const SizedBox(height: 5),
                    const Text("Bugün de sağlıkla kalın ^◡^", style: TextStyle(fontSize: 14, color: Colors.pink)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget featureCard(String title, String description, IconData icon) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [const BoxShadow(color: Colors.white24, blurRadius: 5)],
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.lightBlueAccent),
          const SizedBox(height: 10),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 5),
          Text(description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }
}