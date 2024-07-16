import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/CustomAppBar.dart';

class QRScreen extends StatefulWidget {
  @override
  _QRScreenState createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  String qrCodeUrl = '';
  String token = '';
  String studentName = '';
  String studentGrade = '';
  String studentClass = '';
  String photoUrl = '';
  Timer? _timer;
  int remainingSeconds = 30;

  @override
  void initState() {
    super.initState();
    _fetchQRCode();
  }

  Future<void> _fetchQRCode() async {
    final response = await http.get(Uri.parse('https://api.doyoung.tech/id/index.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        qrCodeUrl = data['qr_code'];
        token = data['token'];
        studentName = data['name'];
        studentGrade = data['grade'];
        studentClass = data['class'];
        photoUrl = data['photo_url'];
        remainingSeconds = 30;
      });

      _startTimer();
    } else {
      throw Exception('QR 코드 로딩 실패');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        remainingSeconds--;
      });

      if (remainingSeconds <= 0) {
        _fetchQRCode();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(imageUrl),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('닫기'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                '메뉴',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('학생증'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/');
              },
            ),
            ListTile(
              leading: Icon(Icons.restaurant),
              title: Text('급식'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/lunch');
              },
            ),
            // Add more options here for timetable, academic schedule, etc.
          ],
        ),
      ),
      body: Center(
        child: qrCodeUrl.isEmpty
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '삼괴고등학교 모바일 학생증',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _showImageDialog(photoUrl),
                  child: Image.network(photoUrl, height: 200, width: 200),
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$studentGrade학년',
                      style: TextStyle(fontSize: 30),
                    ),
                    Text(
                      '$studentClass반',
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      '$studentName',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 50),
            GestureDetector(
              onTap: () => _showImageDialog(qrCodeUrl),
              child: Image.network(qrCodeUrl, height: 250, width: 250),
            ),
            SizedBox(height: 30),
            Text('남은 시간 : $remainingSeconds초'),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: remainingSeconds / 30,
            ),
            SizedBox(height: 20),
            Text(
              '삼괴고등학교',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'COPYRIGHTⓒ 2024 DOYOUNG KIM',
              style: TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}