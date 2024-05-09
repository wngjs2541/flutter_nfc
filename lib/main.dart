import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 및 시간 형식을 위한 패키지 추가
import 'package:webview_flutter/webview_flutter.dart'; // 웹뷰 패키지 추가

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

  // 임시로 지어낸 학번과 비밀번호
  final Map<String, String> testCredentials = {
    '20183743': '2541', // 하주헌
    '20173995': '1234', // 이상윤
    '20191118': '0000', // 고동욱
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

                // 입력된 학번과 비밀번호가 테스트용 계정 중 하나와 일치하는지 확인
                for (final entry in credentialsList) {
                  if (entry.key == studentID && entry.value == password) {
                    // 로그인 성공 처리
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MainPage(studentID: studentID)),
                    );
                    return;
                  }
                }

                // 일치하는 학번과 비밀번호가 없을 경우 로그인 실패 처리
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
  late String _currentTime; // 현재 시간을 저장할 변수 선언

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _updateTime(); // 현재 시간을 업데이트하는 함수 호출
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
                SizedBox(height: 20), // 추가된 코드
                Text(
                  '현재 시간: $_currentTime', // 추가된 코드
                  style: TextStyle(fontSize: 20), // 추가된 코드
                ), // 추가된 코드
              ],
            ),
          ),
          SchoolNoticePage(), // 학교 게시판 탭에 웹뷰 추가
          Center(child: Text('마이 페이지')),
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
    // 초까지 포함된 현재 시간을 가져오는 함수
    setState(() {
      _currentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    });
    Future.delayed(Duration(seconds: 1), _updateTime); // 1초마다 시간을 업데이트하는 함수 호출
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// 학교 게시판 웹뷰 페이지
class SchoolNoticePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: 'https://www.bu.ac.kr/web/index.do',
      javascriptMode: JavascriptMode.unrestricted,
    );
  }
}
