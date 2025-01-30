import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'anasayfa.dart';
import 'profil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  runApp(MyApp(initialRoute: token == null ? '/' : '/home'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Excelsize',
      theme: ThemeData.dark(),
      initialRoute: initialRoute,
      routes: {
        '/': (context) => const LoginRegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/profil': (context) => const ProfileScreen(),
      },
    );
  }
}

// 📌 **Giriş & Kayıt Ekranı**
class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 📌 **Text Controllers**
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  final TextEditingController registerEmailController = TextEditingController();
  final TextEditingController registerPasswordController = TextEditingController();
  final TextEditingController registerAgeController = TextEditingController();
  final TextEditingController registerHeightController = TextEditingController();
  final TextEditingController registerWeightController = TextEditingController();
  final TextEditingController registerStepGoalController = TextEditingController();
  final TextEditingController registerCalorieGoalController = TextEditingController();

  bool isLoginLoading = false;
  bool isRegisterLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // 📌 **Giriş Yap Butonu**
  void handleLogin() async {
    setState(() {
      isLoginLoading = true;
    });

    if (loginEmailController.text == "esra@gmail.com" && loginPasswordController.text == "1234567") {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', "fakeToken123");

      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçersiz giriş bilgileri!')),
      );
    }

    setState(() {
      isLoginLoading = false;
    });
  }

  // 📌 **Kayıt Ol Butonu**
  void handleRegister() async {
    setState(() {
      isRegisterLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', "fakeToken123");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kayıt başarılı, giriş yapabilirsiniz!')),
    );

    _tabController.animateTo(0);

    setState(() {
      isRegisterLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 📌 **ARKAPLAN**
          Positioned.fill(
            child: Image.network(
              'https://theironoffice.com/cdn/shop/files/Gym_12.23-19.jpg?v=1701994187&width=3840',
              fit: BoxFit.cover,
            ),
          ),
          // 📌 **BLUR EFEKTİ**
          Container(color: Colors.black.withOpacity(0.7)),

          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Excelsize",
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 20),
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Giriş Yap'),
                      Tab(text: 'Kayıt Ol'),
                    ],
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // 📌 **GİRİŞ YAP FORMU**
                        Column(
                          children: [
                            TextField(
                              controller: loginEmailController,
                              decoration: const InputDecoration(labelText: 'Email'),
                            ),
                            TextField(
                              controller: loginPasswordController,
                              decoration: const InputDecoration(labelText: 'Şifre'),
                              obscureText: true,
                            ),
                            const SizedBox(height: 20),
                            isLoginLoading
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
                              onPressed: handleLogin,
                              child: const Text('Giriş Yap'),
                            ),
                          ],
                        ),

                        // 📌 **KAYIT OL FORMU**
                        Column(
                          children: [
                            TextField(
                              controller: registerEmailController,
                              decoration: const InputDecoration(labelText: 'Email'),
                            ),
                            TextField(
                              controller: registerPasswordController,
                              decoration: const InputDecoration(labelText: 'Şifre'),
                              obscureText: true,
                            ),
                            TextField(
                              controller: registerAgeController,
                              decoration: const InputDecoration(labelText: 'Yaş'),
                              keyboardType: TextInputType.number,
                            ),
                            TextField(
                              controller: registerHeightController,
                              decoration: const InputDecoration(labelText: 'Boy (cm)'),
                              keyboardType: TextInputType.number,
                            ),
                            TextField(
                              controller: registerWeightController,
                              decoration: const InputDecoration(labelText: 'Kilo (kg)'),
                              keyboardType: TextInputType.number,
                            ),
                            TextField(
                              controller: registerStepGoalController,
                              decoration: const InputDecoration(labelText: 'Adım Hedefi'),
                              keyboardType: TextInputType.number,
                            ),
                            TextField(
                              controller: registerCalorieGoalController,
                              decoration: const InputDecoration(labelText: 'Kalori Hedefi'),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 20),
                            isRegisterLoading
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
                              onPressed: handleRegister,
                              child: const Text('Kayıt Ol'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
