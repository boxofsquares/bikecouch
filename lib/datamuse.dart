import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
class DataMuseWord {
  final String word;
  final List<String> tags;

  DataMuseWord({this.word, this.tags});

  factory DataMuseWord.fromJSON(Map<String, dynamic> json) {
    return DataMuseWord(
      word: json['word'],
      /*
        NOTE: The following defies my understanding of casting:
        json['tags'] shows as List<dynamic> in the debugger,
        yet casting to a List<String> DOES NOT work ->
        it must be cast to a String ??? Why? Explanation needed.
        Hint found here:
        https://github.com/flutter/flutter/issues/18979
        Possible Solution:
        https://docs.flutter.io/flutter/da(contrt-core/List/cast.html
        This suggests that cast is performed on ALL INSTANCES in list,
        so only casting the elements of the list, not the list object itself.
      */
      tags: json['tags'].cast<String>().toList(), 
    );
  }
}

class DataMuseResponse {
  final List<DataMuseWord> words;

  DataMuseResponse({this.words});

  factory DataMuseResponse.fromJSON(List<dynamic> json) {
    return DataMuseResponse(words: json.map((wordJson) {
      return DataMuseWord.fromJSON(wordJson);
    }).toList());
  }
}

Future<DataMuseResponse> datamuseFetchData() async {
  // hard coded to look for kitchen related words for now
  final response = await http.get('https://api.datamuse.com/words?topics=car&md=pd&max=300');

  if (response.statusCode == 200) {
    return DataMuseResponse.fromJSON(json.decode(response.body));
  } else {
    throw Exception('Failed fetching DataMuse data.');
  }

}
