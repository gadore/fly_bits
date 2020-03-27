import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:id3/id3.dart';

class MusicItem {
  String id;
  String album;
  String artist;
  String path;
  String dateAdded;
  String displayName;
  String duration;
  String size;
  int index;

  String getdisplayName() {
    return this.displayName.split('.')[0];
  }

  Future<String> getCoverUrl(http.Client client) async {
    var url = 'http://server.gadore.me/cover?id=' + this.getActualID();
    var response = await client
        .post(url, body: null, headers: {"Accept": "application/json"});
    return compute(fetchCoverUrlFromResponse, response.body);
  }

  String fetchCoverUrlFromResponse(String responseBody) {
    String url = jsonDecode(responseBody)["data"];
    return url;
  }

  String getDisplayName() {
    return this.displayName;
  }

  String getActualTimeLength() {
    var totalSeconds = int.parse(this.duration) / 1000;
    var hours = totalSeconds / (60 * 60);
    var minutes = (totalSeconds - hours * 60 * 60) / 60;
    var seconds = (totalSeconds - hours * 60 * 60 - minutes * 60);
    return hours.toString() + ':' + minutes.toString() + ':' + seconds.toString();
  }

  String getStorageSize() {
    var totalByte = int.parse(this.size);
    var mb = totalByte / (1024 * 1024);
    var kb = (totalByte - mb * 1024 * 1024);
    return mb == 0 ? kb.toString() + 'KB' : mb.toString() + 'M';
  }

  String getActualID() {
    return this.id.split('=')[1];
  }

  String getNetUrl() {
    return 'http://music.163.com/song/media/outer/url?id=' + this.getActualID();
  }

  dynamic getMusicTag() {
    MP3Instance mp3instance = new MP3Instance(this.path);
    if (mp3instance.parseTagsSync()) {
      print(mp3instance.getMetaTags());
    }
  }

  Uint8List getAlbumImage() {
    MP3Instance mp3instance = new MP3Instance(this.path);
    if (mp3instance.parseTagsSync()) {
      print(mp3instance.getMetaTags()['APIC']['base64']);
      return base64.decode(mp3instance.getMetaTags()['APIC']['base64']);
    } else {
      return new Uint8List(0);
    }
  }
}
