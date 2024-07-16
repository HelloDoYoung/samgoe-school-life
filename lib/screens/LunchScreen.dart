import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/CustomAppBar.dart';

class LunchScreen extends StatefulWidget {
  @override
  _LunchScreenState createState() => _LunchScreenState();
}

class _LunchScreenState extends State<LunchScreen> {
  Map<String, dynamic>? lunchData;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLunchData();
  }

  Future<void> _fetchLunchData() async {
    final response = await http.get(Uri.parse('https://api.doyoung.tech/school/index.php?type=lunch'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status']['code'] == 'INFO-000') {
        setState(() {
          lunchData = data;
        });
      } else {
        setState(() {
          errorMessage = data['status']['message'];
        });
      }
    } else {
      setState(() {
        errorMessage = '급식 정보를 불러오지 못했습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: errorMessage != null
            ? Text(errorMessage!)
            : lunchData == null
            ? CircularProgressIndicator()
            : ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            Text(
              '급식 메뉴',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ...lunchData!['menu'].entries.map<Widget>((entry) {
              return ListTile(
                title: Text(entry.value),
              );
            }).toList(),
            SizedBox(height: 20),
            Text(
              '영양 정보',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ...lunchData!['ntr_info'].entries.map<Widget>((entry) {
              return ListTile(
                title: Text('${entry.value['name']}: ${entry.value['value']}'),
              );
            }).toList(),
            SizedBox(height: 20),
            Text(
              '칼로리: ${lunchData!['cal_info']}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}