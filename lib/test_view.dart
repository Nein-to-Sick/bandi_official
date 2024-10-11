import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

class TestViewPage extends StatefulWidget {
  const TestViewPage({super.key});

  @override
  State<TestViewPage> createState() => _TestViewPageState();
}

class _TestViewPageState extends State<TestViewPage> {
  String resp = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cloud Functions HelloWorld")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(resp.isEmpty ? "No response yet" : resp), // 응답이 없는 경우 메시지 표시
            const SizedBox(height: 25),
            ElevatedButton(
              child: const Text("Call Cloud Function"),
              onPressed: () async {
                setState(() {
                  resp = "Loading..."; // 로딩 상태를 표시
                });

                try {
                  String url = "https://helloworld-25xhwjbd5q-uc.a.run.app";
                  var response = await http.get(Uri.parse(url));

                  if (response.statusCode == 200) {
                    // 성공적으로 응답을 받은 경우
                    setState(() {
                      resp = response.body;
                    });
                  } else {
                    // 응답이 실패한 경우
                    setState(() {
                      resp = "Error: ${response.statusCode}";
                    });
                  }
                } catch (e) {
                  // 요청이 실패한 경우
                  setState(() {
                    resp = "Exception: $e";
                  });
                }

                dev.log('HTTP call finished');
              },
            )
          ],
        ),
      ),
    );
  }
}
