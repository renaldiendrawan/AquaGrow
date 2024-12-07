import 'package:flutter/material.dart';
import 'dart:async'; // Untuk menggunakan Timer

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ControlPage(),
      theme: ThemeData(primarySwatch: Colors.green),
    );
  }
}

class ControlPage extends StatefulWidget {
  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  bool isAuto = false;
  bool isPumpOn1 = false;
  bool isUvLightOn = false;
  bool isCameraOn = false;

  // Default times for each device
  TimeOfDay _pumpNutrisiStartTime = TimeOfDay(hour: 19, minute: 0);
  TimeOfDay _pumpNutrisiEndTime = TimeOfDay(hour: 20, minute: 0);
  TimeOfDay _uvLightStartTime = TimeOfDay(hour: 19, minute: 0);
  TimeOfDay _uvLightEndTime = TimeOfDay(hour: 20, minute: 0);
  TimeOfDay _cameraStartTime = TimeOfDay(hour: 19, minute: 0);
  TimeOfDay _cameraEndTime = TimeOfDay(hour: 20, minute: 0);

  DateTime _startDate = DateTime.now(); // Default date for start planting

  Timer? _timer; // Timer untuk menjalankan pengecekan otomatis

  @override
  void initState() {
    super.initState();
    _startAutoControl(); // Memulai pengecekan otomatis saat widget diinisialisasi
  }

  @override
  void dispose() {
    _timer?.cancel(); // Hentikan timer ketika widget dibuang
    super.dispose();
  }

  // Function to start auto control
  void _startAutoControl() {
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (isAuto) {
        _checkAndUpdateDeviceStatus(); // Update perangkat berdasarkan waktu
      }
    });
  }

  // Function to check and update device status automatically based on the time
  void _checkAndUpdateDeviceStatus() {
    final now = TimeOfDay.now();

    setState(() {
      // Check Pompa Nutrisi
      isPumpOn1 = _isCurrentTimeInRange(
          now, _pumpNutrisiStartTime, _pumpNutrisiEndTime);

      // Check Lampu UV
      isUvLightOn =
          _isCurrentTimeInRange(now, _uvLightStartTime, _uvLightEndTime);

      // Check Kamera
      isCameraOn = _isCurrentTimeInRange(now, _cameraStartTime, _cameraEndTime);
    });
  }

  // Helper function to check if the current time is within a specific range
  bool _isCurrentTimeInRange(
      TimeOfDay now, TimeOfDay startTime, TimeOfDay endTime) {
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    if (startMinutes <= endMinutes) {
      // Case where start and end time are on the same day
      return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
    } else {
      // Case where end time is on the next day (crosses midnight)
      return nowMinutes >= startMinutes || nowMinutes <= endMinutes;
    }
  }

  // Function to show the Date Picker dialog
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  // Function to show the Time Picker dialog
  Future<void> _selectTime(BuildContext context,
      Function(TimeOfDay) onTimeSelected, TimeOfDay initialTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      onTimeSelected(picked);
    }
  }

  // Function to update the status of all devices
  void _updateDevices(bool isEnabled) {
    setState(() {
      isPumpOn1 = isEnabled;
      isUvLightOn = isEnabled;
      isCameraOn = isEnabled;
      isAuto = isEnabled; // Jika semua perangkat dinyalakan, auto aktif
    });
  }

  // Function to format the time as a readable string
  String _formatTime(TimeOfDay time) {
    return time.format(context);
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Kendali',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[900],
      ),
      body: SingleChildScrollView(
        // Membungkus konten agar bisa di-scroll
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              constraints: BoxConstraints(
                  minWidth: double.infinity), // Mengisi lebar penuh
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bagian Tanggal dan Jam Mulai Tanam
                  Text(
                    "Tanggal dan Jam Mulai Tanam",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Text(
                      "Tanggal Mulai: ${_formatDate(_startDate)}",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      // Disable time selection if auto mode is active
                      if (!isAuto) {
                        _selectTime(context, (newTime) {
                          setState(() {
                            _pumpNutrisiStartTime = newTime;
                          });
                        }, _pumpNutrisiStartTime);
                      }
                    },
                    child: Text(
                      "Jam Mulai: ${_formatTime(_pumpNutrisiStartTime)}",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Bagian List Konfigurasi Perangkat
                  Text("List konfigurasi",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  _buildDeviceCard(
                    title: "Pompa Nutrisi",
                    icon: Icons.local_drink,
                    iconColor: Colors.orange, // Sama seperti di beranda
                    isOn: isPumpOn1,
                    startTime: _pumpNutrisiStartTime,
                    endTime: _pumpNutrisiEndTime,
                    statusText:
                        isPumpOn1 ? "Aktif" : "Nonaktif", // Status label
                    onChanged: (value) {
                      setState(() {
                        isPumpOn1 = value;
                        _checkAutoStatus();
                      });
                    },
                    onStartTimeTap: () {
                      // Disable time selection if auto mode is active
                      if (!isAuto) {
                        _selectTime(context, (newTime) {
                          setState(() {
                            _pumpNutrisiStartTime = newTime;
                          });
                        }, _pumpNutrisiStartTime);
                      }
                    },
                    onEndTimeTap: () {
                      // Disable time selection if auto mode is active
                      if (!isAuto) {
                        _selectTime(context, (newTime) {
                          setState(() {
                            _pumpNutrisiEndTime = newTime;
                          });
                        }, _pumpNutrisiEndTime);
                      }
                    },
                  ),
                  _buildDeviceCard(
                    title: "Lampu UV",
                    icon: Icons.lightbulb,
                    iconColor: Colors.yellow,
                    isOn: isUvLightOn,
                    startTime: _uvLightStartTime,
                    endTime: _uvLightEndTime,
                    statusText: isUvLightOn ? "Aktif" : "Nonaktif",
                    onChanged: (value) {
                      setState(() {
                        isUvLightOn = value;
                        _checkAutoStatus();
                      });
                    },
                    onStartTimeTap: () {
                      // Disable time selection if auto mode is active
                      if (!isAuto) {
                        _selectTime(context, (newTime) {
                          setState(() {
                            _uvLightStartTime = newTime;
                          });
                        }, _uvLightStartTime);
                      }
                    },
                    onEndTimeTap: () {
                      // Disable time selection if auto mode is active
                      if (!isAuto) {
                        _selectTime(context, (newTime) {
                          setState(() {
                            _uvLightEndTime = newTime;
                          });
                        }, _uvLightEndTime);
                      }
                    },
                  ),
                  _buildDeviceCard(
                    title: "Kamera",
                    icon: Icons.camera_alt,
                    iconColor: Colors.blue,
                    isOn: isCameraOn,
                    startTime: _cameraStartTime,
                    endTime: _cameraEndTime,
                    statusText: isCameraOn ? "Aktif" : "Nonaktif",
                    onChanged: (value) {
                      setState(() {
                        isCameraOn = value;
                        _checkAutoStatus();
                      });
                    },
                    onStartTimeTap: () {
                      // Disable time selection if auto mode is active
                      if (!isAuto) {
                        _selectTime(context, (newTime) {
                          setState(() {
                            _cameraStartTime = newTime;
                          });
                        }, _cameraStartTime);
                      }
                    },
                    onEndTimeTap: () {
                      // Disable time selection if auto mode is active
                      if (!isAuto) {
                        _selectTime(context, (newTime) {
                          setState(() {
                            _cameraEndTime = newTime;
                          });
                        }, _cameraEndTime);
                      }
                    },
                  ),

                  // Switch for Auto
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Otomatis",
                        style: TextStyle(fontSize: 18),
                      ),
                      Switch(
                        value: isAuto,
                        onChanged: (value) {
                          setState(() {
                            isAuto = value;
                            if (isAuto) {
                              _updateDevices(true); // Turn on all devices
                            } else {
                              _updateDevices(false); // Turn off all devices
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required bool isOn,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required String statusText,
    required ValueChanged<bool> onChanged,
    required VoidCallback onStartTimeTap,
    required VoidCallback onEndTimeTap,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 32),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Switch(
                  value: isOn,
                  onChanged: onChanged,
                ),
              ],
            ),
            SizedBox(height: 10),
            Text("Status: $statusText"),
            GestureDetector(
              onTap: onStartTimeTap,
              child: Text(
                "Jam Mulai: ${_formatTime(startTime)}",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            GestureDetector(
              onTap: onEndTimeTap,
              child: Text(
                "Jam Selesai: ${_formatTime(endTime)}",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _checkAutoStatus() {
    // Check if all devices are on, and update isAuto accordingly
    isAuto = isPumpOn1 && isUvLightOn && isCameraOn;
  }
}
