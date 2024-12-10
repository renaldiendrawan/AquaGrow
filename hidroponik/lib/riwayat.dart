import 'package:flutter/material.dart';
import 'package:hidroponik/riwayat2.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'config.dart'; // Import AppConfig to access base URL

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HistoryScreen(),
    );
  }
}

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Map<String, dynamic>? _historyData;

  @override
  void initState() {
    super.initState();
    _fetchHistoryData(); // Fetch data when the screen loads
  }

  Future<void> _fetchHistoryData() async {
    final url = Uri.parse('${AppConfig.baseUrl}/getStatusPengukuran.php'); // Use base URL from AppConfig

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          setState(() {
            _historyData = responseData;
          });
        } else {
          setState(() {
            _historyData = null;
          });
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<void> _deleteLatestEntry() async {
    final url = Uri.parse('${AppConfig.baseUrl}/delete.php'); // Use base URL from AppConfig

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data deleted successfully')),
          );
          _fetchHistoryData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete data: ${responseData['message']}')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current date in dd/MM/yyyy format
    String formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Riwayat',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0), // Mengurangi padding agar lebih responsif
        child: _historyData == null
            ? Center(
                child: Text(
                  "No history available",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    color: Colors.green[50],
                    child: ListTile(
                      title: Text(
                        'Riwayat Hari Ini',
                        style: TextStyle(color: Colors.black87),
                      ),
                      subtitle: Text(
                        formattedDate,
                        style: TextStyle(color: Colors.black54),
                      ),
                      onTap: () {
                        _showHistoryDialog(context);
                      },
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[800],
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _deleteLatestEntry,
                        child: Text(
                          'Hapus',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8, // Menyesuaikan dengan lebar layar
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: HistoryCard(),
          ),
        );
      },
    );
  }
}
