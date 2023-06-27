import 'dart:convert';
import 'package:get/get.dart';
import 'package:chatgptbing/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

List<Widget> chats1 = <Widget>[Text(' ')];
String lastText = '';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Future<Album>? _futureAlbum;

class _MyHomePageState extends State<MyHomePage> {
 
  int _counter = 0;
  TextEditingController controller = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    viewController ctrl = Get.put(viewController());
     double size=MediaQuery.of(context).size.height - 150;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 73, 202, 202),
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(' Chat'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              //height: size,
              child: SingleChildScrollView(
                child: Obx(
                  () => Column(
                    children: [
                      for (int i = 0; i < ctrl.chats.length; i++) ctrl.chats[i],
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, left: 20),
                  child: Container(
                   width: MediaQuery.of(context).size.width - 70,
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: const Color.fromARGB(255, 207, 207, 207)),
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 5),
                      child: TextField(
                        controller: controller,
                        
                        decoration: const InputDecoration(
                          
                            floatingLabelStyle: TextStyle(color: Colors.black),
                            hintText: 'Ask Anything here...',
                            border: InputBorder.none,
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 15)),
                      ),
                    )),
                  ),
                ),
                // getResult(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      size: 30,
                    ),
                    onPressed: () {
                      _futureAlbum = fetchAnswer(controller.text);

                      print(_futureAlbum);
                      ctrl.chats.add(chatNow(controller: controller));

                      ctrl.chats.add(getResult());
                      Future.delayed(Duration(milliseconds: 100), () {
                         controller.clear();
                      });
                     

                      // controller.clear();
                    },
                  ),
                )
              ],
            ),
          ],
        ));
  }

  FutureBuilder<Album> getResult() {
    viewController ctrl = Get.put(viewController());

    return FutureBuilder(
        future: _futureAlbum,
        builder: (context, snapshot) {
          print(snapshot.hasData);

          if (snapshot.hasData) {
            print(snapshot.data!.textResponse);

            return Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    width: MediaQuery.of(context).size.width - 50,
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 118, 146, 146),
                        borderRadius: BorderRadius.circular(13)),
                    child: Padding(
                      padding: const EdgeInsets.all(9.0),
                      child: Text(
                        snapshot.data!.textResponse,
                        style: TextStyle(color: Colors.black, fontSize: 15),
                      ),
                    ),
                  )),
            );
          } else {
            return Align(
              alignment: Alignment.centerLeft,
              child: Container(
                  width: 50,
                  height: 50,
                  child: Image.asset('assets/images/three_dots.gif')),
            );
          }
        });
  }
}

class chatNow extends StatelessWidget {
  const chatNow({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, top: 10, bottom: 10),
      child: Align(
          alignment: Alignment.topRight,
          child: Container(
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 73, 202, 202),
                borderRadius: BorderRadius.circular(13)),
            child: Padding(
              padding: const EdgeInsets.all(9.0),
              child: Text(
                controller.text,
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          )),
    );
  }
}

Future<Album> fetchAnswer(String question) async {
  final response = await http.post(
      Uri.parse('https://chatgpt-bing-ai-chat-api.p.rapidapi.com/ask'),
      headers: {
        'content-type': 'application/json',
        'X-RapidAPI-Key': '0dcb321547msh484cbceafdeeb3bp1c42d4jsn274cf93cdb84',
        'X-RapidAPI-Host': 'chatgpt-bing-ai-chat-api.p.rapidapi.com'
      },
      body: jsonEncode(<String, String>{
        "question": question,
        "bing_u_cookie":
            "Please replace this string with a string representing your Bing _U cookie. You can obtain your _U cookie by accessing the Developer Console and searching for the _U cookie name. Please follow this link for guidance: https://i.ibb.co/94YWpQD/1676391128.png"
      }));
  print(response.body);

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.

    return Album.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class Album {
  //List<SourceUrl> sourceUrls;
  String textResponse;

  Album({
    required this.textResponse,
  });

  factory Album.fromRawJson(String str) => Album.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Album.fromJson(Map<String, dynamic> json) => Album(
        textResponse: json["text_response"],
      );

  Map<String, dynamic> toJson() => {
        "text_response": textResponse,
      };
}

class viewController extends GetxController {
  List<Widget> chats = <Widget>[Text('Welcome to chat gpt ')].obs;
  RxString last = ''.obs;
}
