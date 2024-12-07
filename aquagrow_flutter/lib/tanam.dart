import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Tanam extends StatefulWidget {
  @override
  _TanamState createState() => _TanamState();
}

class _TanamState extends State<Tanam> {
  // Controllers untuk Mulai Tanam
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController jamController = TextEditingController();

  // Controllers untuk 1-4 Minggu
  final List<TextEditingController> kadarNutrisiControllers = List.generate(4, (_) => TextEditingController());
  final List<TextEditingController> waktuControllers = List.generate(4, (_) => TextEditingController());

  // Fungsi untuk memilih tanggal
  Future<void> _pilihTanggal(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      String formattedDate = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      setState(() {
        tanggalController.text = formattedDate;
      });
    }
  }

  // Fungsi untuk memilih jam
  Future<void> _pilihJam(BuildContext context, TextEditingController controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      String formattedTime = "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
      setState(() {
        controller.text = formattedTime;
      });
    }
  }

  // Fungsi untuk mengirim data "Mulai Tanam"
  Future<void> kirimDataTanam() async {
    final String apiUrl = 'http://192.168.1.18/api/save_tanam.php'; // Ganti URL API

    try {
      if (tanggalController.text.isEmpty || jamController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Harap pilih tanggal dan jam terlebih dahulu!")),
        );
        return;
      }

      String formattedDatetime = "${tanggalController.text} ${jamController.text}:00";

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'id_tanam': 1, // ID dummy, ganti sesuai kebutuhan
          'set_waktu': formattedDatetime,
        }),
      );

      final responseData = jsonDecode(response.body);
      if (responseData['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Data Mulai Tanam berhasil disimpan!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan data: ${responseData['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }

  // Fungsi untuk mengirim data "1-4 Minggu"
  Future<void> kirimDataPengukuran() async {
  final String apiUrl = 'http://192.168.1.18/api/save_kadar_nutrisi.php'; // Ganti URL API

  try {
    for (int i = 0; i < 4; i++) {
      String kadarNutrisi = kadarNutrisiControllers[i].text;
      String waktu = waktuControllers[i].text;
      int idPengukuran = i + 1; // Assign ID sesuai urutan (1, 2, 3, 4)

      if (kadarNutrisi.isEmpty || waktu.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Pastikan semua data diisi untuk minggu ${i + 1}!")),
        );
        return;
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'id_pengukuran': idPengukuran,
          'kadar_nutrisi': int.parse(kadarNutrisi),
          'timestamp': waktu,
        }),
      );

      final responseData = jsonDecode(response.body);
      if (!responseData['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan data untuk minggu ${i + 1}: ${responseData['message']}")),
        );
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Data pengukuran berhasil disimpan!")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Terjadi kesalahan: $e")),
    );
  }
}


  // Fungsi untuk menghapus data "Mulai Tanam"
  Future<void> hapusDataTanam() async {
    final String apiUrl = 'http://192.168.1.18/api/delete_tanam.php'; // Ganti URL API

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'id_tanam': 1, // ID yang sesuai untuk data yang ingin dihapus
        }),
      );

      final responseData = jsonDecode(response.body);
      if (responseData['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Data Mulai Tanam berhasil dihapus!")),
        );
        setState(() {
          tanggalController.clear();
          jamController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menghapus data: ${responseData['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }

  // Fungsi untuk menghapus data "1-4 Minggu"
  Future<void> hapusDataPengukuran() async {
    final String apiUrl = 'http://192.168.1.18/api/hapus_pengukuran.php'; // Ganti URL API

    try {
      for (int i = 0; i < 4; i++) {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'kadar_nutrisi': int.parse(kadarNutrisiControllers[i].text),
            'timestamp': waktuControllers[i].text,
          }),
        );

        final responseData = jsonDecode(response.body);
        if (!responseData['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal menghapus data minggu ${i + 1}: ${responseData['message']}")),
          );
          return;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data pengukuran berhasil dihapus!")),
      );
      setState(() {
        // Clear semua field setelah berhasil menghapus data
        for (var controller in kadarNutrisiControllers) {
          controller.clear();
        }
        for (var controller in waktuControllers) {
          controller.clear();
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Tanam', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Mulai Tanam
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mulai Tanam', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: tanggalController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Pilih Tanggal',
                              border: OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.calendar_today),
                                onPressed: () => _pilihTanggal(context),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: jamController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Pilih Jam',
                              border: OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.access_time),
                                onPressed: () => _pilihJam(context, jamController),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: kirimDataTanam,
                          child: Text('Konfirmasi'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: hapusDataTanam,
                          child: Text('Hapus Data Tanam'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // 1-4 Minggu
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('1-4 Minggu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Column(
                      children: List.generate(4, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: kadarNutrisiControllers[index],
                                  decoration: InputDecoration(
                                    labelText: 'Ambang Kadar Nutrisi ${index + 1}',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: waktuControllers[index],
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: 'Waktu',
                                    border: OutlineInputBorder(),
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.access_time),
                                      onPressed: () => _pilihJam(context, waktuControllers[index]),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: kirimDataPengukuran,
                          child: Text('Konfirmasi'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: hapusDataPengukuran,
                          child: Text('Hapus Data Pengukuran'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: Tanam()));
}
