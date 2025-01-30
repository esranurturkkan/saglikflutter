import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';

import 'navbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Profil Bilgisi Controller'ları
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController stepGoalController = TextEditingController();
  final TextEditingController calorieGoalController = TextEditingController();

  // Diğer veriler
  final TextEditingController stepsController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController activeMinutesController = TextEditingController();
  final TextEditingController proteinController = TextEditingController();
  final TextEditingController carbsController = TextEditingController();
  final TextEditingController fatController = TextEditingController();
  final TextEditingController waterIntakeController = TextEditingController();
  final TextEditingController heartRateController = TextEditingController();
  final TextEditingController bloodPressureController = TextEditingController();
  final TextEditingController sleepController = TextEditingController();

  bool isLoading = true;

  // Egzersiz Takvimi -> 6 Seviye Kodlaması
  Map<String, Map<String, String>> exerciseCalendar = {};
  List<Map<String, dynamic>> performanceAnalysis = [];

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      _logout();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/user/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final user = json.decode(response.body);
        setState(() {
          emailController.text = user['email'] ?? 'esra@gmail.com';
          ageController.text = user['age']?.toString() ?? '25';
          heightController.text = user['height']?.toString() ?? '175';
          weightController.text = user['weight']?.toString() ?? '75';
          stepGoalController.text = user['stepGoal']?.toString() ?? '6000323';
          calorieGoalController.text = user['calorieGoal']?.toString() ?? '40002325';

          stepsController.text = user['steps']?.toString() ?? '23454';
          caloriesController.text = user['calories']?.toString() ?? '1000334';
          activeMinutesController.text = user['activeMinutes']?.toString() ?? '80223';
          proteinController.text = user['protein']?.toString() ?? '402323';
          carbsController.text = user['carbs']?.toString() ?? '13024';
          fatController.text = user['fat']?.toString() ?? '60234';
          waterIntakeController.text = user['waterIntake']?.toString() ?? '200023';
          heartRateController.text = user['heartRate']?.toString() ?? '7023';
          bloodPressureController.text = user['bloodPressure']?.toString() ?? '120/80';
          sleepController.text = user['sleep']?.toString() ?? '10 saat';

          isLoading = false;
        });
      } else {
        _setDefaultValues();
      }
    } catch (e) {
      _setDefaultValues();
    }
  }

  

  void updateProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final updatedData = {
      "email": emailController.text,
      "password": passwordController.text.trim().isEmpty
          ? null
          : passwordController.text.trim(),
      "age": int.tryParse(ageController.text) ?? 25,
      "height": int.tryParse(heightController.text) ?? 175,
      "weight": int.tryParse(weightController.text) ?? 75,
      "stepGoal": int.tryParse(stepGoalController.text) ?? 6000323,
      "calorieGoal": int.tryParse(calorieGoalController.text) ?? 40002325,
      "steps": int.tryParse(stepsController.text) ?? 23454,
      "calories": int.tryParse(caloriesController.text) ?? 1000334,
      "activeMinutes": int.tryParse(activeMinutesController.text) ?? 80223,
      "protein": int.tryParse(proteinController.text) ?? 402323,
      "carbs": int.tryParse(carbsController.text) ?? 13024,
      "fat": int.tryParse(fatController.text) ?? 60234,
      "waterIntake": int.tryParse(waterIntakeController.text) ?? 200023,
      "heartRate": int.tryParse(heartRateController.text) ?? 7023,
      "bloodPressure": bloodPressureController.text,
      "sleep": sleepController.text,
    };

    updatedData.removeWhere((key, value) => value == null);

    try {
      final response = await http.put(
        Uri.parse('http://localhost:5000/api/user/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil başarıyla güncellendi.')),
        );
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Profil güncellenemedi.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  /// 6 Seviye: Kolay1-2, Orta1-2, Zor1-2
  void showExerciseDialog(DateTime day) {
    final dateKey = "${day.year}-${day.month}-${day.day}";
    TextEditingController exerciseController = TextEditingController();
    String selectedLevel = '1'; // Varsayılan Kolay 1

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Egzersiz Ekle", style: TextStyle(color: Colors.black)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style: const TextStyle(color: Colors.black),
                controller: exerciseController,
                decoration: const InputDecoration(
                  labelText: "Egzersiz Adı",
                  labelStyle: TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedLevel,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedLevel = newValue!;
                  });
                },
                dropdownColor: Colors.white, // Açılır liste arkaplanı
                items: [
                  DropdownMenuItem(
                    value: '1',
                    child: Text('Kolay 1', style: TextStyle(color: Colors.black)),
                  ),
                  DropdownMenuItem(
                    value: '2',
                    child: Text('Kolay 2', style: TextStyle(color: Colors.black)),
                  ),
                  DropdownMenuItem(
                    value: '3',
                    child: Text('Orta 1', style: TextStyle(color: Colors.black)),
                  ),
                  DropdownMenuItem(
                    value: '4',
                    child: Text('Orta 2', style: TextStyle(color: Colors.black)),
                  ),
                  DropdownMenuItem(
                    value: '5',
                    child: Text('Zor 1', style: TextStyle(color: Colors.black)),
                  ),
                  DropdownMenuItem(
                    value: '6',
                    child: Text('Zor 2', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final exerciseName = exerciseController.text.trim();
                if (exerciseName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Egzersiz adını girin.")),
                  );
                  return;
                }
                setState(() {
                  exerciseCalendar[dateKey] = {
                    'exercise': exerciseName,
                    'level': selectedLevel,
                  };
                });
                Navigator.of(context).pop();
              },
              child: const Text("Kaydet", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  /// Seviye-Kalori Hesap
  void calculatePerformance() {
    int totalCalories = 0;
    performanceAnalysis.clear();

    exerciseCalendar.forEach((date, details) {
      final levelString = details['level'] ?? '1';
      final level = int.tryParse(levelString) ?? 1;

      int caloriesBurned = 0;
      switch (level) {
        case 1: // Kolay 1
          caloriesBurned = 100;
          break;
        case 2: // Kolay 2
          caloriesBurned = 150;
          break;
        case 3: // Orta 1
          caloriesBurned = 200;
          break;
        case 4: // Orta 2
          caloriesBurned = 300;
          break;
        case 5: // Zor 1
          caloriesBurned = 400;
          break;
        case 6: // Zor 2
          caloriesBurned = 500;
          break;
      }

      totalCalories += caloriesBurned;
      performanceAnalysis.add({
        'date': date,
        'exercise': details['exercise'],
        'calories': caloriesBurned,
      });
    });

    String message;
    if (totalCalories > 4000) {
      message = "Tebrikler! Çok aktif bir ay geçirdiniz. Harika gidiyorsunuz! 🔥";
    } else if (totalCalories < 1500) {
      message = "Daha aktif olmalısınız. Haftada en az 3 gün egzersiz yapmayı deneyin. 💪";
    } else {
      message = "İyi gidiyorsunuz! Sağlıklı yaşamınızı bu şekilde devam ettirin. 😊";
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Performans Analizi", style: TextStyle(color: Colors.black)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Toplam Kalori Yakımı: $totalCalories kcal",
                  style: const TextStyle(color: Colors.black)),
              const SizedBox(height: 10),
              ...performanceAnalysis.map((e) => Text(
                  "${e['date']}: ${e['exercise']} - ${e['calories']} kcal",
                  style: const TextStyle(color: Colors.black))),
              const SizedBox(height: 10),
              Text(message,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tamam", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomNavbar(),
      body: Stack(
        children: [
          // Arkaplan Resmi
          Positioned.fill(
            child: Image.network(
              'https://theironoffice.com/cdn/shop/files/Gym_12.23-19.jpg?v=1701994187&width=3840',
              fit: BoxFit.cover,
            ),
          ),
          // Karanlık Katman
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          // İçerik
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              children: [
                // ÜST KISIM: Profil + Kalori Hesaplama
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PROFİL FORMU
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _buildProfileForm(),
                      ),
                    ),
                    // KALORİ HESAPLAMA VE TABLO
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _buildCaloriesSection(),
                      ),
                    ),
                  ],
                ),
                // ALT KISIM: Takvim + Performans Analizi
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TAKVİM
                    Expanded(
                      flex: 2,
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _buildCalendar(),
                      ),
                    ),
                    // PERFORMANS ANALİZİ
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Performans Analizi",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: calculatePerformance,
                              child: const Text("Performans Analizini Gör"),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _logout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text("Çıkış Yap"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// FORM
  Widget _buildProfileForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Profil Bilgileri",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 10),
        _profileInputField("Email", emailController, isDisabled: true),
        _profileInputField("Yeni Şifre", passwordController,
            hint: "En az 8 karakter", obscure: true),
        _profileInputField("Yaş", ageController),
        _profileInputField("Boy (cm)", heightController),
        _profileInputField("Kilo (kg)", weightController),
        const SizedBox(height: 10),
        const Text("Aktivite Hedefleri",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        _profileInputField("Adım Hedefi", stepGoalController),
        _profileInputField("Kalori Hedefi", calorieGoalController),
        const SizedBox(height: 10),
        const Text("Aktivite Takibi",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        _profileInputField("Adım Sayısı", stepsController),
        _profileInputField("Bugün Harcanan Kalori", caloriesController),
        _profileInputField("Aktif Dakikalar", activeMinutesController),
        const SizedBox(height: 10),
        const Text("Beslenme Takibi",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        _profileInputField("Protein (gram)", proteinController),
        _profileInputField("Karbonhidrat (gram)", carbsController),
        _profileInputField("Yağ (gram)", fatController),
        _profileInputField("Su (ml)", waterIntakeController),
        const SizedBox(height: 10),
        const Text("Sağlık Verileri",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        _profileInputField("Kalp Atış Hızı (bpm)", heartRateController),
        _profileInputField("Tansiyon (120/80)", bloodPressureController),
        _profileInputField("Uyku Süresi (saat)", sleepController),
        const SizedBox(height: 10),
        Center(
          child: ElevatedButton(
            onPressed: updateProfile,
            child: const Text("Bilgileri Güncelle"),
          ),
        ),
      ],
    );
  }

  /// KALORİ HESAPLAMA VE TABLO
  Widget _buildCaloriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Kalori Hesaplama",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _showCalorieResult,
          child: const Text("Hesapla"),
        ),
        const SizedBox(height: 10),
        const Text(
          "Egzersiz Tablosu (Kolay / Orta / Zor)",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 8),
        _buildExerciseTable(),
      ],
    );
  }

  Widget _buildExerciseTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey[200]!),
        dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white),
        headingTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        columns: const [
          DataColumn(label: Text("Egzersiz Adı", style: TextStyle(color: Colors.black))),
          DataColumn(label: Text("Seviye", style: TextStyle(color: Colors.black))),
          DataColumn(label: Text("Kalori", style: TextStyle(color: Colors.black))),
        ],
        rows: [
          // Kolay Seviye
          DataRow(cells: [
            DataCell(Text("Yürüyüş", style: TextStyle(color: Colors.black))),
            DataCell(Text("Kolay", style: TextStyle(color: Colors.black))),
            DataCell(Text("150 kcal", style: TextStyle(color: Colors.black))),
          ]),
          DataRow(cells: [
            DataCell(Text("Yoga", style: TextStyle(color: Colors.black))),
            DataCell(Text("Kolay", style: TextStyle(color: Colors.black))),
            DataCell(Text("100 kcal", style: TextStyle(color: Colors.black))),
          ]),
          DataRow(cells: [
            DataCell(Text("Hafif Dans", style: TextStyle(color: Colors.black))),
            DataCell(Text("Kolay", style: TextStyle(color: Colors.black))),
            DataCell(Text("200 kcal", style: TextStyle(color: Colors.black))),
          ]),
          DataRow(cells: [
            DataCell(Text("Bisiklet (Düşük hız)", style: TextStyle(color: Colors.black))),
            DataCell(Text("Kolay", style: TextStyle(color: Colors.black))),
            DataCell(Text("250 kcal", style: TextStyle(color: Colors.black))),
          ]),
          DataRow(cells: [
            DataCell(Text("Kaykay", style: TextStyle(color: Colors.black))),
            DataCell(Text("Kolay", style: TextStyle(color: Colors.black))),
            DataCell(Text("200 kcal", style: TextStyle(color: Colors.black))),
          ]),
          DataRow(cells: [
            DataCell(Text("Yüzme (Hafif)", style: TextStyle(color: Colors.black))),
            DataCell(Text("Kolay", style: TextStyle(color: Colors.black))),
            DataCell(Text("200 kcal", style: TextStyle(color: Colors.black))),
          ]),
          DataRow(cells: [
            DataCell(Text("Pilates", style: TextStyle(color: Colors.black))),
            DataCell(Text("Kolay", style: TextStyle(color: Colors.black))),
            DataCell(Text("180 kcal", style: TextStyle(color: Colors.black))),
          ]),
          DataRow(cells: [
            DataCell(Text("Hafif Aerobik", style: TextStyle(color: Colors.black))),
            DataCell(Text("Kolay", style: TextStyle(color: Colors.black))),
            DataCell(Text("230 kcal", style: TextStyle(color: Colors.black))),
          ]),
          DataRow(cells: [
            DataCell(Text("Yavaş Tempolu Koşu", style: TextStyle(color: Colors.black))),
            DataCell(Text("Kolay", style: TextStyle(color: Colors.black))),
            DataCell(Text("300 kcal", style: TextStyle(color: Colors.black))),
          ]),
          DataRow(cells: [
            DataCell(Text("Zumba", style: TextStyle(color: Colors.black))),
            DataCell(Text("Kolay", style: TextStyle(color: Colors.black))),
            DataCell(Text("250 kcal", style: TextStyle(color: Colors.black))),
          ]),
          // Orta Seviye
          DataRow(cells: [
            DataCell(Text("Buz Pateni", style: TextStyle(color: Colors.black))),
            DataCell(Text("Orta", style: TextStyle(color: Colors.black))),
            DataCell(Text("300 kcal", style: TextStyle(color: Colors.black))),
          ]),
          DataRow(cells: [
            DataCell(Text("Trambolin", style: TextStyle(color: Colors.black))),
            DataCell(Text("Orta", style: TextStyle(color: Colors.black))),
            DataCell(Text("300 kcal", style: TextStyle(color: Colors.black))),
          ]),
          DataRow(cells: [
            DataCell(Text("Kürek Çekme", style: TextStyle(color: Colors.black))),
            DataCell(Text("Orta", style: TextStyle(color: Colors.black))),
            DataCell(Text("400 kcal", style: TextStyle(color: Colors.black))),
          ]),
          DataRow(cells: [
            DataCell(Text("Koşu", style: TextStyle(color: Colors.black))),
            DataCell(Text("Orta", style: TextStyle(color: Colors.black))),
            DataCell(Text("350 kcal", style: TextStyle(color: Colors.black))),
          ]),
          DataRow(cells: [
            DataCell(Text("Hızlı Dans", style: TextStyle(color: Colors.black))),
            DataCell(Text("Orta", style: TextStyle(color: Colors.black))),
            DataCell(Text("300 kcal", style: TextStyle(color: Colors.black))),
          ]),
          DataRow(cells: [
            DataCell(Text("Squat", style: TextStyle(color: Colors.black))),
            DataCell(Text("Orta", style: TextStyle(color: Colors.black))),
            DataCell(Text("250 kcal", style: TextStyle(color: Colors.black))),
          ]),
          DataRow(cells: [
            DataCell(Text("Plank", style: TextStyle(color: Colors.black))),
            DataCell(Text("Orta", style: TextStyle(color: Colors.black))),
            DataCell(Text("300 kcal", style: TextStyle(color: Colors.black))),
          ]),
          DataRow(cells: [
            DataCell(Text("Dağ Tırmanışı Hareketi", style: TextStyle(color: Colors.black))),
            DataCell(Text("Orta", style: TextStyle(color: Colors.black))),
            DataCell(Text("350 kcal", style: TextStyle(color: Colors.black))),
          ]),
          DataRow(cells: [
            DataCell(Text("Elliptik Bisiklet", style: TextStyle(color: Colors.black))),
            DataCell(Text("Orta", style: TextStyle(color: Colors.black))),
            DataCell(Text("280 kcal", style: TextStyle(color: Colors.black))),
          ]),
          DataRow(cells: [
            DataCell(Text("Kickboks", style: TextStyle(color: Colors.black))),
            DataCell(Text("Orta", style: TextStyle(color: Colors.black))),
            DataCell(Text("400 kcal", style: TextStyle(color: Colors.black))),
          ]),
          // Zor Seviye
          DataRow(cells: [
            DataCell(Text("Tırmanma", style: TextStyle(color: Colors.black))),
            DataCell(Text("Zor", style: TextStyle(color: Colors.black))),
            DataCell(Text("650 kcal", style: TextStyle(color: Colors.black))),
          ]),
          DataRow(cells: [
            DataCell(Text("CrossFit", style: TextStyle(color: Colors.black))),
            DataCell(Text("Zor", style: TextStyle(color: Colors.black))),
            DataCell(Text("800 kcal", style: TextStyle(color: Colors.black))),
          ]),
          DataRow(cells: [
            DataCell(Text("Burpee", style: TextStyle(color: Colors.black))),
            DataCell(Text("Zor", style: TextStyle(color: Colors.black))),
            DataCell(Text("500 kcal", style: TextStyle(color: Colors.black))),
          ]),
          DataRow(cells: [
            DataCell(Text("Deadlift", style: TextStyle(color: Colors.black))),
            DataCell(Text("Zor", style: TextStyle(color: Colors.black))),
            DataCell(Text("600 kcal", style: TextStyle(color: Colors.black))),
          ]),
          DataRow(cells: [
            DataCell(Text("Barfiks", style: TextStyle(color: Colors.black))),
            DataCell(Text("Zor", style: TextStyle(color: Colors.black))),
            DataCell(Text("450 kcal", style: TextStyle(color: Colors.black))),
          ]),
          DataRow(cells: [
            DataCell(Text("HIIT (Yüksek Yoğunluk)", style: TextStyle(color: Colors.black))),
            DataCell(Text("Zor", style: TextStyle(color: Colors.black))),
            DataCell(Text("700 kcal", style: TextStyle(color: Colors.black))),
          ]),
          DataRow(cells: [
            DataCell(Text("Boks", style: TextStyle(color: Colors.black))),
            DataCell(Text("Zor", style: TextStyle(color: Colors.black))),
            DataCell(Text("650 kcal", style: TextStyle(color: Colors.black))),
          ]),
          DataRow(cells: [
            DataCell(Text("Sprint (Hızlı Koşu)", style: TextStyle(color: Colors.black))),
            DataCell(Text("Zor", style: TextStyle(color: Colors.black))),
            DataCell(Text("800 kcal", style: TextStyle(color: Colors.black))),
          ]),
          DataRow(cells: [
            DataCell(Text("Ağırlık Kaldırma", style: TextStyle(color: Colors.black))),
            DataCell(Text("Zor", style: TextStyle(color: Colors.black))),
            DataCell(Text("500 kcal", style: TextStyle(color: Colors.black))),
          ]),
        ],
      ),
    );
  }



  void _showCalorieResult() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Kalori Hesaplanıyor... (Örnek)",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  /// TAKVİM
  Widget _buildCalendar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Egzersiz Takvimi",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        TableCalendar(
          focusedDay: _focusedDay,
          firstDay: DateTime(2020),
          lastDay: DateTime(2030),
          calendarStyle: const CalendarStyle(
            // Gün rakamları siyah
            defaultTextStyle: TextStyle(color: Colors.black),
            weekendTextStyle: TextStyle(color: Colors.black),
            // Seçili gün
            selectedTextStyle: TextStyle(color: Colors.white),
            selectedDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
            // Bugün
            todayTextStyle: TextStyle(color: Colors.white),
            todayDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: Colors.black),
            weekendStyle: TextStyle(color: Colors.black),
          ),
          headerStyle: const HeaderStyle(
            titleTextStyle: TextStyle(color: Colors.black),
            formatButtonTextStyle: TextStyle(color: Colors.black),
            leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
            rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
          ),
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            showExerciseDialog(selectedDay);
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
        ),
      ],
    );
  }

  /// ORTAK TEXTFIELD -> Beyaz arka plan, siyah yazı
  Widget _profileInputField(
      String label,
      TextEditingController controller, {
        bool isDisabled = false,
        bool obscure = false,
        String? hint,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        enabled: !isDisabled,
        obscureText: obscure,
        style: const TextStyle(color: Colors.black), // Kullanıcı metni siyah
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black54),
          border: const OutlineInputBorder(),
          fillColor: Colors.white,  // *** Beyaz arkaplan
          filled: true,
        ),
      ),
    );
  }
}
