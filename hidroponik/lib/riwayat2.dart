import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'config.dart'; // Import the config.dart file to use AppConfig

class HistoryCard extends StatefulWidget {
  @override
  _HistoryCardState createState() => _HistoryCardState();
}

class _HistoryCardState extends State<HistoryCard> {
  String kadarNutrisi = 'Loading...';
  String lampu = 'Loading...';
  String pompa = 'Loading...';
  String intensitasCahaya = 'Loading...';
  String timestamp = 'Loading...';
  String tanggalTanam = 'Loading...';
  String jamTanam = 'Loading...';
  String gambarTanaman = 'Loading...';
  String statusTanaman = 'Loading...';
  List<dynamic> controlData = [];
  bool isLoading = true;

  // Mengambil data dari API
  Future<void> fetchData() async {
    try {
      // Use the base URL from AppConfig in API requests
      final response1 = await http.get(Uri.parse('${AppConfig.baseUrl}/getStatusPengukuran.php'));
      final response2 = await http.get(Uri.parse('${AppConfig.baseUrl}/get_Tanam.php'));
      final response3 = await http.get(Uri.parse('${AppConfig.baseUrl}/get_predictions.php'));
      final response4 = await http.get(Uri.parse('${AppConfig.baseUrl}/get_tds.php'));

      if (response1.statusCode == 200) {
        var data1 = json.decode(response1.body);
        if (data1['status'] == 'success') {
          setState(() {
            kadarNutrisi = "${data1['data']['kadar_nutrisi']} ppm";
            lampu = data1['data']['status_lampu_uv'] ?? 'Tidak diketahui';
            pompa = data1['data']['status_pompa'] ?? 'Tidak diketahui';
            intensitasCahaya = "${data1['data']['intensitas_cahaya']} cd";
            timestamp = data1['data']['timestamp'] ?? 'Tidak ada waktu';
          });
        }
      }

      if (response2.statusCode == 200) {
        var data2 = json.decode(response2.body);
        if (data2.isNotEmpty) {
          setState(() {
            tanggalTanam = data2[0]['tanggal'] ?? 'Tidak ada tanggal';
            jamTanam = data2[0]['jam'] ?? 'Tidak ada jam';
          });
        } else {
          setState(() {
            tanggalTanam = 'Tidak ada tanggal';
            jamTanam = 'Tidak ada jam';
          });
        }
      }

      if (response3.statusCode == 200) {
        var data3 = json.decode(response3.body);
        if (data3['status'] == 'success' && data3['data'].isNotEmpty) {
          setState(() {
            gambarTanaman = data3['data'][0]['gambar'] ?? 'Tidak ada gambar';
            statusTanaman = data3['data'][0]['status_tanaman'] ?? 'Tidak ada status';
          });
        }
      }

      if (response4.statusCode == 200) {
        var data4 = json.decode(response4.body);
        if (data4['status'] == 'success') {
          setState(() {
            controlData = data4['data'];
          });
        }
      }
    } catch (error) {
      print('Error occurred: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Format tanggal saat ini
  String _getCurrentDate() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('d MMM yyyy');
    return formatter.format(now);
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Riwayat Pengukuran',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 16),
                  _buildMeasurementCard(),
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Data Control',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildControlTable(),
                ],
              ),
            ),
    );
  }

  // Header bagian atas
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Riwayat Hari Ini',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(height: 4),
          Text(
            _getCurrentDate(),
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
          SizedBox(height: 4),
          Text(
            'Terakhir diperbarui: $timestamp',
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }

  // Card untuk informasi pengukuran
  Widget _buildMeasurementCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (gambarTanaman != 'Loading...' && gambarTanaman != 'Error')
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  gambarTanaman,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 16),
            _buildInfoRow(Icons.opacity, 'Kadar Nutrisi', kadarNutrisi, color: Colors.blue),
            Divider(),
            _buildInfoRow(Icons.lightbulb, 'Lampu UV', lampu, color: const Color.fromARGB(255, 206, 135, 77)),
            Divider(),
            _buildInfoRow(Icons.wb_sunny, 'Intensitas Cahaya', intensitasCahaya, color: Colors.orange),
            Divider(),
            _buildInfoRow(Icons.water, 'Status Pompa', pompa, color: Colors.green),
            Divider(),
            _buildInfoRow(Icons.calendar_today, 'Tanggal Tanam', tanggalTanam, color: Colors.brown),
            Divider(),
            _buildInfoRow(Icons.access_time, 'Jam Tanam', jamTanam, color: Colors.purple),
            Divider(),
            _buildInfoRow(
              Icons.flag,
              'Status Tanaman',
              statusTanaman,
              color: statusTanaman.toLowerCase() == 'buruk' ? Colors.red : Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  // Menampilkan informasi dalam baris
  Widget _buildInfoRow(IconData icon, String label, String value, {Color color = Colors.black}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, size: 20, color: color),
            ),
            SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
        ),
      ],
    );
  }

  // Menampilkan tabel data control
  Widget _buildControlTable() {
    return controlData.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                'Tidak ada data untuk ditampilkan',
                style: TextStyle(fontSize: 18, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
          )
        : Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor:
                          MaterialStateColor.resolveWith((states) => Colors.green[100]!),
                      columns: [
                        DataColumn(
                          label: Text(
                            'Minggu Ke',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Ambang TDS',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'UV Start Hour',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'UV End Hour',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ],
                      rows: controlData.map<DataRow>((item) {
                        return DataRow(cells: [
                          DataCell(
                            Text(
                              item['minggu_ke'].toString(),
                              style: TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ),
                          DataCell(
                            Text(
                              item['ambang_tds'].toString(),
                              style: TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ),
                          DataCell(
                            Text(
                              item['uv_start_hour'].toString(),
                              style: TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ),
                          DataCell(
                            Text(
                              item['uv_end_hour'].toString(),
                              style: TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
