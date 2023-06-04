import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mera_ai/secret.dart';

class OpenAIService{

  final List<Map<String,String>> messages=[];

  Future<String> chatGptApi(String prompt) async{
    messages.add({
      'role':'user',
      'content':prompt,
    });
    try{
      final res= await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPI',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": messages,
        }),
      );
      
      if (res.statusCode==200){
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'];
        messages.add({
          'role': 'assistant',
          'content': content,
        });
        return content;
      }
      return 'An internal error occured';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> dallEApi(String prompt)async{
    messages.add(({
      'role':'user',
      'content':prompt,
    }));
    try{
      final res= await http.post(Uri.parse("https://api.openai.com/v1/images/generations"),
      headers:  {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openAIAPI',
      },
        body: jsonEncode({
          'prompt': prompt,
          'n': 1,
        }),
      );
      if (res.statusCode == 200) {
        String imageUrl = jsonDecode(res.body)['data'][0]['url'];
        imageUrl = imageUrl.trim();

        messages.add({
          'role': 'assistant',
          'content': imageUrl,
        });
        return imageUrl;
      }
      return 'An internal error occurred';
    }catch (e) {
      return e.toString();
    }

  }
}