import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HistoryCard extends StatefulWidget {
  @override
  _HistoryCardState createState() => _HistoryCardState();
}

class _HistoryCardState extends State<HistoryCard> {
  // Variabel untuk menyimpan data
  String kadarNutrisi = 'Loading...';
  String lampu = 'Loading...';
  String pompa = 'Loading...';
  String intensitasCahaya = 'Loading...';
  String timestamp = 'Loading...';
  List<Map<String, dynamic>> tanamanList = [];
  bool isLoading = true;

  // Fungsi untuk mengambil data dari kedua API
  Future<void> fetchData() async {
    try {
      // API 1: getStatusPengukuran.php
      final response1 = await http.get(Uri.parse('http://192.168.231.37/api/getStatusPengukuran.php'));

      if (response1.statusCode == 200) {
        var data1 = json.decode(response1.body);
        if (data1['status'] == 'success') {
          setState(() {
            kadarNutrisi = "${data1['data']['kadar_nutrisi']} ppm";
            lampu = data1['data']['status_lampu_uv'] == '1' ? 'Aktif' : 'Nonaktif';
            pompa = data1['data']['status_pompa'] == '1' ? 'Aktif' : 'Nonaktif';
            intensitasCahaya = "${data1['data']['intensitas_cahaya']} cd";
            timestamp = data1['data']['timestamp'] ?? 'Tidak ada waktu';
          });
        }
      }

      // API 2: get_predictions.php
      final response2 = await http.get(Uri.parse('http://192.168.231.37/api/get_predictions.php'));

      if (response2.statusCode == 200) {
        var data2 = json.decode(response2.body);
        if (data2['status'] == 'success') {
          setState(() {
            tanamanList = List<Map<String, dynamic>>.from(data2['data']);
          });
        }
      }
    } catch (error) {
      setState(() {
        kadarNutrisi = 'Error';
        intensitasCahaya = 'Error';
        lampu = 'Error';
        pompa = 'Error';
        timestamp = 'Error';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // Fungsi untuk mendapatkan tanggal saat ini
  String _getCurrentDate() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('d MMM yyyy');
    return formatter.format(now);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 16),
                _buildMeasurementCard(),
                SizedBox(height: 16),
                Divider(thickness: 2),
                _buildPlantList(),
              ],
            ),
          );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Riwayat Hari Ini',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          _getCurrentDate(),
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        SizedBox(height: 4),
        Text(
          'Terakhir diperbarui: $timestamp',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildMeasurementCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow(Icons.opacity, 'Kadar Nutrisi', kadarNutrisi),
            SizedBox(height: 12),
            _buildInfoRow(Icons.lightbulb, 'Lampu UV', lampu),
            SizedBox(height: 12),
            _buildInfoRow(Icons.wb_sunny, 'Intensitas Cahaya', intensitasCahaya),
            SizedBox(height: 12),
            _buildInfoRow(Icons.water, 'Status Pompa', pompa),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantList() {
    return Expanded(
      child: tanamanList.isEmpty
          ? Center(child: Text('Tidak ada data tanaman.'))
          : ListView.builder(
              itemCount: tanamanList.length,
              itemBuilder: (context, index) {
                final tanaman = tanamanList[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        tanaman['gambar'] ?? '',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image),
                      ),
                    ),
                    title: Text(
                      'Tanaman ${tanaman['id_tanaman']}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Status: ${tanaman['status_tanaman']}'),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 16, color: Colors.grey[800]),
        ),
      ],
    );
  }
}
