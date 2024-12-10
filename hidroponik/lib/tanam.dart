import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';  // Pastikan untuk menambahkan intl package ke pubspec.yaml
import 'config.dart'; // Pastikan mengimpor file config yang sesuai

class Tanam extends StatefulWidget {
  @override
  _TanamState createState() => _TanamState();
}

class _TanamState extends State<Tanam> {
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController jamController = TextEditingController();

  final List<TextEditingController> ambangTdsControllers =
      List.generate(4, (_) => TextEditingController());
  final List<TextEditingController> waktuMulaiControllers =
      List.generate(4, (_) => TextEditingController());
  final List<TextEditingController> waktuBerakhirControllers =
      List.generate(4, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchTdsData();
  }

  Future<void> fetchData() async {
    final String apiUrl = '${AppConfig.baseUrl}/get_tanam2.php'; // Menggunakan base URL dari AppConfig

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          if (mounted) {
            setState(() {
              tanggalController.text = responseData['data'][0]['tanggal'] ?? '';
              jamController.text = responseData['data'][0]['jam'] ?? '';
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal mengambil data tanggal tanam!")),
          );
        }
      } else {
        throw Exception("Respons server tidak valid!");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }

  Future<void> fetchTdsData() async {
    final String apiUrl = '${AppConfig.baseUrl}/get_tds_tanam.php'; // Menggunakan base URL dari AppConfig

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          if (mounted) {
            setState(() {
              for (int i = 0; i < responseData['data'].length; i++) {
                ambangTdsControllers[i].text =
                    responseData['data'][i]['ambang_tds']?.toString() ?? '';
                waktuMulaiControllers[i].text =
                    responseData['data'][i]['uv_start_hour']?.toString() ?? '';
                waktuBerakhirControllers[i].text =
                    responseData['data'][i]['uv_end_hour']?.toString() ?? '';
              }
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? "Gagal mengambil data TDS!")),
          );
        }
      } else {
        throw Exception("Respons server tidak valid!");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }

  Future<void> updateDataTanam() async {
    final String apiUrl = '${AppConfig.baseUrl}/update_tanam.php'; // Menggunakan base URL dari AppConfig

    try {
      String formattedDatetime = "${tanggalController.text} ${jamController.text}:00";

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'id_tanam': 1,
          'set_waktu': formattedDatetime,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Data Mulai Tanam berhasil diperbarui!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal memperbarui data: ${responseData['message']}")),
          );
        }
      } else {
        throw Exception("Respons server tidak valid!");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }

  Future<void> updateTdsData(int index) async {
    final String apiUrl = '${AppConfig.baseUrl}/update_tds.php'; // Menggunakan base URL dari AppConfig

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'minggu_ke': index + 1,
          'ambang_tds': ambangTdsControllers[index].text,
          'uv_start_hour': waktuMulaiControllers[index].text,
          'uv_end_hour': waktuBerakhirControllers[index].text,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Data TDS berhasil diperbarui!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal memperbarui data TDS: ${responseData['message']}")),
          );
        }
      } else {
        throw Exception("Respons server tidak valid!");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }

  Widget _buildCardTanggalJam() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mulai Tanam', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: tanggalController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Pilih Tanggal',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _pilihTanggal(context),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: jamController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Pilih Jam',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.access_time),
                        onPressed: () => _pilihJam(context, jamController),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: updateDataTanam,
              child: Text("Update Data Tanam"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardMinggu(int index) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Minggu ${index + 1}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ambangTdsControllers[index],
                    decoration: InputDecoration(labelText: 'Ambang TDS'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: waktuMulaiControllers[index],
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Waktu Mulai',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.access_time),
                        onPressed: () => _pilihJam(context, waktuMulaiControllers[index], isMinggu: true),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: waktuBerakhirControllers[index],
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Waktu Berakhir',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.access_time),
                        onPressed: () => _pilihJam(context, waktuBerakhirControllers[index], isMinggu: true),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => updateTdsData(index),
              child: Text("Update Data Minggu ${index + 1}"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pilihTanggal(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      if (mounted) {
        setState(() {
          tanggalController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        });
      }
    }
  }

  Future<void> _pilihJam(BuildContext context, TextEditingController controller, {bool isMinggu = false}) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      if (mounted) {
        setState(() {
          controller.text = formatTimeOfDay(pickedTime);
        });
      }
    }
  }

  String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final parsedTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(parsedTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tanam', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCardTanggalJam(),
            for (int i = 0; i < 4; i++) _buildCardMinggu(i),
          ],
        ),
      ),
    );
  }
}
