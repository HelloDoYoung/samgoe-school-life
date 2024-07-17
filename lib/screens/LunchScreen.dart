import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/CustomAppBar.dart';

class LunchScreen extends StatefulWidget {
  @override
  _LunchScreenState createState() => _LunchScreenState();
}

class _LunchScreenState extends State<LunchScreen> {
  Map<String, dynamic>? breakfastData;
  Map<String, dynamic>? lunchData;
  Map<String, dynamic>? dinnerData;
  String? errorMessage;

  bool isLoading = true; // 데이터가 로딩 중인지 여부를 나타내는 플래그

  @override
  void initState() {
    super.initState();
    _fetchAllData(); // 모든 데이터를 한 번에 가져오는 함수 호출
  }

  Future<void> _fetchAllData() async {
    setState(() {
      isLoading = true;
    });

    try {
      await Future.wait([_fetchBreakfastData(), _fetchLunchData(), _fetchDinnerData()]);
    } finally {
      setState(() {
        isLoading = false; // 모든 데이터 로딩이 끝나면 플래그 업데이트
      });
    }
  }

  Future<void> _fetchBreakfastData() async {
    final response = await http.get(Uri.parse('https://api.doyoung.tech/school/index.php?type=breakfast'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status']['code'] == 'INFO-000') {
        setState(() {
          breakfastData = data;
        });
      } else {
        setState(() {
          errorMessage = data['status']['message'];
        });
      }
    } else {
      setState(() {
        errorMessage = '조식 정보를 불러오지 못했습니다.';
      });
    }
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
        errorMessage = '중식 정보를 불러오지 못했습니다.';
      });
    }
  }

  Future<void> _fetchDinnerData() async {
    final response = await http.get(Uri.parse('https://api.doyoung.tech/school/index.php?type=dinner'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status']['code'] == 'INFO-000') {
        setState(() {
          dinnerData = data;
        });
      } else {
        setState(() {
          errorMessage = data['status']['message'];
        });
      }
    } else {
      setState(() {
        errorMessage = '석식 정보를 불러오지 못했습니다.';
      });
    }
  }

  Widget buildMealBox(Map<String, dynamic>? mealData, String mealType) {
    if (mealData == null) {
      return Center(child: CircularProgressIndicator());
    }

    final mealEntries = (mealData['menu'] as Map<String, dynamic>).entries
        .where((entry) {
      if (mealType == '조식') {
        return entry.key.startsWith('breakfast');
      } else if (mealType == '중식') {
        return entry.key.startsWith('meal');
      } else if (mealType == '석식') {
        return entry.key.startsWith('dinner');
      }
      return false;
    });

    return Container(
      margin: EdgeInsets.all(8.0),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(width: 2.0, color: Colors.black),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  Text(
                    '$mealType 상세 정보',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  if (mealData['ntr_info'] != null)
                    ...mealData['ntr_info'].entries.map<Widget>((entry) {
                      return ListTile(
                        title: Text('${entry.value['name']}: ${entry.value['value']}'),
                      );
                    }).toList(),
                  SizedBox(height: 20),
                  if (mealData['cal_info'] != null)
                    Text(
                      '칼로리: ${mealData['cal_info'].toString()}',
                      style: TextStyle(fontSize: 16),
                    ),
                ],
              );
            },
          );
        },
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mealType,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ...mealEntries.map<Widget>((entry) {
                return Text(entry.value.toString());
              }).toList(),
            ],
          ),
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
          ],
        ),
      ),
      body: Center(
        child: isLoading
            ? Text("급식을 로딩중입니다...")
            : errorMessage != null
            ? Text(errorMessage!)
            : SingleChildScrollView(
          child: Column(
            children: [
              buildMealBox(breakfastData, '조식'),
              buildMealBox(lunchData, '중식'),
              buildMealBox(dinnerData, '석식'),
            ],
          ),
        ),
      ),
    );
  }
}
