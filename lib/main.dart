import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:storage_path/storage_path.dart';
import 'musicInfo.dart';
import 'package:http/http.dart' as http;

var musicBank = new Map<String,MusicItem>();
var currentMusicId = 'currentPlay';
final AudioPlayer audioPlayer = AudioPlayer();

void main() {
  runApp(new MaterialApp(
    title: 'Fly bits',
    home: new HomeScreen(),
    initialRoute: '/',
    debugShowCheckedModeBanner: false,
  ));
}

class HomeScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return new Scaffold(
      body: DefaultTabController(
        length: 3,
        child: Scaffold(
          drawer: MyDrawer(),
          appBar: AppBar(
            title: Text("Home Page"),
            leading: Builder(
              builder:(BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () { Scaffold.of(context).openDrawer(); },
                  tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                );
              }
            ),
            bottom: TabBar(
              tabs: [
                Tab(text: 'Musics',),
                Tab(text: 'Artist',),
                Tab(text: 'Album',),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              FutureBuilder(
                future: fetchMusicList(http.Client()),
                builder: (context, snapshot) {
                  if (snapshot.hasError) print(snapshot.error);
                  return snapshot.hasData
                      ? MusicList(songs: snapshot.data)
                      : Center(child: CircularProgressIndicator());
                },),
              Icon(Icons.directions_transit),
              Icon(Icons.directions_bike),
            ],
          ),
        ),
      ),
      bottomNavigationBar: new BottomAppBar(
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_drop_up),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CurrentPlay()));
              },
            ),
            Text(currentMusicId)
          ],
        ),
      ),
    );
  }
}

class CurrentPlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Second Screen"),
        elevation: 0,//appbar的阴影
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class MyDrawer extends StatelessWidget {
  const MyDrawer({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: MediaQuery.removePadding(
        context: context,
        //移除抽屉菜单顶部默认留白
        removeTop: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 38.0, left: 38.0),
              child: Row(
                children: <Widget>[
                  Text(
                    "Gadore",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Add account'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Manage accounts'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<List<MusicItem>> scanMediaFile() async{
  var result = new List<MusicItem>();
  try {
      var path = await StoragePath.audioPath;
      var jsonSongs = jsonDecode(path)[0];
      var songs = jsonSongs['files'];
      for (var item in songs) {
        var musicItem = new MusicItem();
        musicItem.album = item['album'];
        musicItem.artist = item['artist'];
        musicItem.dateAdded = item['dateAdded'];
        musicItem.displayName = item['displayName'];
        musicItem.duration = item['duration'];
        result.add(musicItem);
      }
    } catch(e) {
      print('Failed to get path with error: ' + e);
  }
  return result;
}

Future<List<MusicItem>> fetchMusicList(http.Client client) async {
  var url = 'http://server.gadore.me:2333/music';
  var urlString =
      "{\"url\":\"http://music.163.com/playlist/72210253/68328243/?userid=68328243\"}";
  var response = await client
      .post(url, body: urlString, headers: {"Accept": "application/json"});
  return compute(parseMusic, response.body);
}

List<MusicItem> parseMusic(String responseBody) {
  var parsed = jsonDecode(responseBody)["data"];
  var list = new List<MusicItem>();
  for (var jObj in parsed) {
    var m = new MusicItem();
    // m.id = jObj["id"].split('_')[1];
    m.id = jObj["id"];
    m.displayName = jObj["name"];
    list.add(m);
    // musicBank[m.id] = m;
  }
  return list;
}

class MusicList extends StatelessWidget{
  final List<MusicItem> songs;
  MusicList({Key key, this.songs}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        return new ListTile(
          title: new Text('${songs[index].getdisplayName()}'),
          onTap: (){
            currentMusicId = songs[index].id;
          },
        );
      },
    );
  }
}
