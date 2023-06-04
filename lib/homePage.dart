import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mera_ai/openai_service.dart';
import 'package:mera_ai/pallete.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'feature_bubble.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  String lastWords = "";
  String? generatedContent;
  String? generatedImageUrl;
  late Uint8List _bytes;
  var awaitingResponse = false;
  TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //initSpeechToText();
  }

  Future<void> responseCheck() async {
    lastWords=_messageController.text;
    print(lastWords);
    generatedContent= await OpenAIService().chatGptApi(lastWords);
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mera AI",style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
        leading: Icon(Icons.menu),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(top: 10, left: 22),
              child: const Text(
                'Here are a few features',
                style: TextStyle(
                  fontFamily: 'Cera Pro',
                  color: Pallete.mainFontColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Column(
              children:  [
                GestureDetector(
                  onTap: () async{
                    generatedContent= await OpenAIService().chatGptApi(lastWords);
                    setState(() {});
                  },
                  child: FeatureBox(
                    color: Pallete.firstSuggestionBoxColor,
                    headerText: 'ChatGpt',
                    descriptionText:
                    'A smarter way to organised and informed with chatgpt',
                  ),
                ),
                GestureDetector(
                  onTap: () async{
                    generatedImageUrl=await OpenAIService().dallEApi(lastWords);
                    final response = await http.get(Uri.parse(generatedImageUrl!));

                    if (response.statusCode == 200) {
                      setState(() {
                        _bytes = response.bodyBytes;
                      });
                    } else {
                      throw Exception('Failed to load image: ${response.statusCode}');
                    }
                    setState(() {});
                  },
                  child: FeatureBox(
                    color: Pallete.secondSuggestionBoxColor,
                    headerText: 'Dall-E',
                    descriptionText:
                    'Get inspired and stay creative with power of Dall-E',
                  ),
                ),
              ],
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              margin: EdgeInsets.symmetric(horizontal: 30).copyWith(
                top: 20,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Pallete.borderColor,
                ),
                borderRadius: BorderRadius.circular(20).copyWith(
                  topLeft: Radius.zero,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: SelectableText(
                  generatedContent==null
                      ? 'Hello, How can I help you?'
                      : generatedContent!,
                  style: TextStyle(
                    fontFamily: 'Cera Pro',
                    color: Pallete.mainFontColor,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            if (generatedImageUrl != null)
              Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                margin: EdgeInsets.symmetric(horizontal: 30).copyWith(
                  top: 20,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.memory(
                    _bytes,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

          ],
        ),
      ),
      bottomNavigationBar: Container(
          padding: const EdgeInsets.all(12),
          child: SafeArea(
              child: Row(
            children: [
              Expanded(
                  child: TextField(
                controller: _messageController,
                onSubmitted: null,
                decoration: const InputDecoration(
                  hintText: 'Write your message here...',
                  border: InputBorder.none,
                ),
              )),
              IconButton(
                onPressed: responseCheck,
                icon: const Icon(Icons.send),
              ),
            ],
          ))),

    );
  }
}
