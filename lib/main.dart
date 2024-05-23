import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController studentIDController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('로그인 결과'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  final Map<String, String> testCredentials = {
    '20183743': '2541',
    '20173995': '1234',
    '20191118': '0000',
  };

  late final List<MapEntry<String, String>> credentialsList;

  @override
  void initState() {
    super.initState();
    credentialsList = testCredentials.entries.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BU NFC check-in'),
        backgroundColor: Colors.blue[700],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/bu.jpg',
              width: 150,
              height: 150,
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: studentIDController,
              decoration: InputDecoration(
                labelText: '학번',
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: '비밀번호',
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                String studentID = studentIDController.text;
                String password = passwordController.text;

                for (final entry in credentialsList) {
                  if (entry.key == studentID && entry.value == password) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MainPage(studentID: studentID)),
                    );
                    return;
                  }
                }

                _showMessage('학번 또는 비밀번호가 올바르지 않습니다.');
              },
              child: Text('로그인'),
            ),
          ],
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  final String studentID;

  MainPage({required this.studentID});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _currentTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _updateTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BU NFC Check-in'),
        backgroundColor: Colors.blue[700],
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '메인 화면'),
            Tab(text: '학교 게시판'),
            Tab(text: '마이 페이지'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.account_circle, size: 150),
                Text(
                  '${widget.studentID} ${getStudentName(widget.studentID)}님 안녕하세요!',
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  '좌석번호: E 137',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 20),
                Text(
                  '현재 시간: $_currentTime',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
          SchoolNoticePage(),
          MyPage(studentID: widget.studentID),
        ],
      ),
    );
  }

  String getStudentName(String studentID) {
    switch (studentID) {
      case '20183743':
        return '하주헌';
      case '20173995':
        return '이상윤';
      case '20191118':
        return '고동욱';
      default:
        return 'Unknown';
    }
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    });
    Future.delayed(Duration(seconds: 1), _updateTime);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class SchoolNoticePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: 'https://www.bu.ac.kr/web/index.do',
      javascriptMode: JavascriptMode.unrestricted,
    );
  }
}

class MyPage extends StatefulWidget {
  final String studentID;

  MyPage({required this.studentID});

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  File? _profileImage;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  List<bool> _attendance = List.generate(3, (index) => Random().nextBool());
  List<String> _attendanceTimes = List.generate(3, (index) => _generateRandomTime(10, 50, 11));

  @override
  void initState() {
    super.initState();
    _nameController.text = getStudentName(widget.studentID);
    _emailController.text = '${widget.studentID}@bu.ac.kr';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.all(
            16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _profileImage != null
                  ? FileImage(_profileImage!)
                  : AssetImage('assets/default_profile.png') as ImageProvider,
              child: _profileImage == null
                  ? Icon(Icons.account_circle, size: 50)
                  : null,
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: '이름'),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: '이메일'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('정보 수정'),
                    content: Text('이름: ${_nameController.text}\n이메일: ${_emailController.text}'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('확인'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text('정보 수정'),
          ),
          SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            itemCount: 3,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('출석 여부: ${_attendance[index] ? '출석' : '미출석'}'),
                subtitle: Text('출석 시간: ${_attendanceTimes[index]}'),
              );
            },
          ),
        ],
      ),
    );
  }

  String getStudentName(String studentID) {
    switch (studentID) {
      case '20183743':
        return '하주헌';
      case '20173995':
        return '이상윤';
      case '20191118':
        return '고동욱';
      default:
        return 'Unknown';
    }
  }

  static String _generateRandomTime(int minHour, int minMinute, int maxHour) {
    final hour = minHour + Random().nextInt(maxHour - minHour);
    final minute = minMinute + Random().nextInt(60 - minMinute);
    return '$hour:${minute.toString().padLeft(2, '0')}';
  }
}
