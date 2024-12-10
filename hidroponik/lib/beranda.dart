import 'package:flutter/material.dart';
import 'profil.dart'; // Pastikan profil.dart tersedia
import 'package:intl/intl.dart'; // Untuk format tanggal dan waktu
import 'dart:async'; // Untuk Timer
import 'dart:convert'; // Untuk JSON decoding
import 'package:http/http.dart' as http; // Untuk permintaan HTTP
import 'config.dart'; // Import AppConfig

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(username: ''), // Layar utama
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({required this.username});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentTime = '';
  String _nutrisiStatus = '';
  String _intensitasCahaya = '';
  String _plantStatus = '';
  String _statusPompa = '';
  String _statusLampuUV = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _fetchStatusData();
    _fetchPlantStatus();
    Timer.periodic(Duration(minutes: 1), (_) => _updateTime());
    Timer.periodic(Duration(seconds: 10), (_) => _fetchStatusData());
  }

  void _updateTime() {
    final now = DateTime.now();
    final formattedTime = DateFormat('EEEE, d MMMM yyyy, HH:mm').format(now);
    setState(() {
      _currentTime = formattedTime;
    });
  }

  Future<void> _fetchStatusData() async {
    final String url = '${AppConfig.baseUrl}/getStatusPengukuran.php'; // Gunakan baseUrl dari AppConfig
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          final data = result['data'];
          setState(() {
            _intensitasCahaya = '${data['intensitas_cahaya']} cd';
            _nutrisiStatus = '${data['kadar_nutrisi']} ppm';
            _statusPompa = data['status_pompa'];
            _statusLampuUV = data['status_lampu_uv'];
          });
        } else {
          print('Error: ${result['message']}');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  Future<void> _fetchPlantStatus() async {
    final String url = '${AppConfig.baseUrl}/get_predictions.php'; // Gunakan baseUrl dari AppConfig
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          final List<dynamic> plants = result['data'];
          setState(() {
            if (plants.isNotEmpty) {
              _plantStatus = plants.first['status_tanaman'] == 'Baik' ? 'Baik' : 'Buruk';
            } else {
              _plantStatus = 'Tidak ada data tanaman';
            }
          });
        } else {
          setState(() {
            _plantStatus = 'Error: ${result['message']}';
          });
        }
      } else {
        setState(() {
          _plantStatus = 'HTTP Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _plantStatus = 'Error: $e';
      });
    }
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Beranda', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[800],
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            onPressed: () => _navigateToProfile(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(), // Mencegah scroll yang tiba-tiba
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreetingSection(),
            SizedBox(height: 20),
            _buildTextInfo('Waktu Sekarang', _currentTime),
            SizedBox(height: 20),
            _buildVideoContainer(),
            SizedBox(height: 20),
            _buildSectionTitle('Kontrol Alat'),
            SizedBox(height: 10),
            _buildControlCards(),
            SizedBox(height: 20),
            _buildSectionTitle('Pengukuran Sensor'),
            SizedBox(height: 10),
            _buildMeasurementCards(),
            SizedBox(height: 20),
            _buildSectionTitle('Keadaan Tanaman'),
            _buildStatusCard('Status', _plantStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Hai, ${widget.username}!\nSelamat Datang Di Aquagrow',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[900],
            ),
          ),
        ),
        Image.asset(
          'assets/image/logo2.png',
          fit: BoxFit.cover,
          height: 30,
          errorBuilder: (_, __, ___) => Icon(Icons.error, color: Colors.red),
        ),
      ],
    );
  }

  Widget _buildTextInfo(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildMeasurementCards() {
    return Column(
      children: [
        _buildMeasurementCard('Intensitas Cahaya', _intensitasCahaya, Icons.wb_sunny, Colors.yellow),
        _buildMeasurementCard('Kadar Nutrisi', _nutrisiStatus, Icons.eco, Colors.lightGreen),
      ],
    );
  }

  Widget _buildControlCards() {
    return Column(
      children: [
        _buildCardWithIcon('Pompa Air', _statusPompa, Icons.water, Colors.blue),
        _buildCardWithIcon('Lampu UV', _statusLampuUV, Icons.lightbulb, const Color.fromARGB(255, 217, 255, 0)),
      ],
    );
  }

  Widget _buildCardWithIcon(String title, String status, IconData icon, Color iconColor) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: iconColor),
                SizedBox(width: 10),
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            Text(status, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementCard(String title, String measurement, IconData icon, Color iconColor) {
    return _buildCardWithIcon(title, measurement, icon, iconColor);
  }

  Widget _buildStatusCard(String title, String status) {
    Color statusColor;
    if (status.toLowerCase() == 'baik') {
      statusColor = Colors.green;
    } else if (status.toLowerCase() == 'buruk') {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.grey; // Status default
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              status.isNotEmpty ? status : 'Memuat...', // Tambahkan placeholder
              style: TextStyle(fontSize: 16, color: statusColor),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchModelAccuracy() async {
    final String apiUrl = '${AppConfig.baseUrl}/get_accuracy.php'; // Gunakan baseUrl dari AppConfig
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return data['data'];
        } else {
          throw Exception('Tidak ada data yang tersedia');
        }
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  Widget _buildVideoContainer() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchModelAccuracy(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final data = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInfoCard(
                title: 'Akurasi Model',
                content: '${data['accuracy']}%',
              ),
              SizedBox(height: 10),
              _buildInfoCard(
                title: 'Klasifikasi Baik',
                content: '''
Precision: ${data['baik']['precision']}
Recall: ${data['baik']['recall']}
F1 Score: ${data['baik']['f1_score']}
Support: ${data['baik']['support']}
                ''',
              ),
              SizedBox(height: 10),
              _buildInfoCard(
                title: 'Klasifikasi Buruk',
                content: '''
Precision: ${data['buruk']['precision']}
Recall: ${data['buruk']['recall']}
F1 Score: ${data['buruk']['f1_score']}
Support: ${data['buruk']['support']}
                ''',
              ),
              SizedBox(height: 10),
              _buildInfoCard(
                title: 'Macro Average',
                content: '''
Precision: ${data['macro_avg']['precision']}
Recall: ${data['macro_avg']['recall']}
F1 Score: ${data['macro_avg']['f1_score']}
                ''',
              ),
              SizedBox(height: 10),
              _buildInfoCard(
                title: 'Weighted Average',
                content: '''
Precision: ${data['weighted_avg']['precision']}
Recall: ${data['weighted_avg']['recall']}
F1 Score: ${data['weighted_avg']['f1_score']}
                ''',
              ),
              SizedBox(height: 10),
              _buildInfoCard(
                title: 'Total Support',
                content: '${data['total_support']}',
              ),
              SizedBox(height: 10),
              _buildInfoCard(
                title: 'Diperbarui pada',
                content: '${data['created_at']}',
              ),
            ],
          );
        } else {
          return Center(child: Text('Tidak ada data untuk ditampilkan.'));
        }
      },
    );
  }

  Widget _buildInfoCard({required String title, required String content}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(content, style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
