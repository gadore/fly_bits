import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/rendering.dart';
import 'events.dart';
import 'package:storage_path/storage_path.dart';
import 'musicInfo.dart';
import 'package:http/http.dart' as http;

final AudioPlayer audioPlayer = AudioPlayer();
MusicItem currentMusicItem;

void main() {
  runApp(new MaterialApp(
    title: 'Fly bits',
    home: new HomeScreen(),
    initialRoute: '/',
    debugShowCheckedModeBanner: false,
  ));
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: DefaultTabController(
          length: 3,
          child: Scaffold(
            drawer: MyDrawer(),
            appBar: AppBar(
              title: Text("Home Page"),
              leading: Builder(builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  tooltip:
                      MaterialLocalizations.of(context).openAppDrawerTooltip,
                );
              }),
              bottom: TabBar(
                tabs: [
                  Tab(
                    text: 'Musics',
                  ),
                  Tab(
                    text: 'Artist',
                  ),
                  Tab(
                    text: 'Album',
                  ),
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
                  },
                ),
                Icon(Icons.directions_transit),
                Icon(Icons.directions_bike),
              ],
            ),
          ),
        ),
        bottomNavigationBar: HomeBottomAppBar());
  }
}

class HomeBottomAppBar extends BottomAppBar {
  @override
  State<StatefulWidget> createState() {
    return _BottomAppBar();
  }
}

class _BottomAppBar extends State<HomeBottomAppBar> {
  MusicItem _currentMusic;
  @override
  void initState() {
    super.initState();
    bus.on('musicChange', (args) {
      MusicItem music = args as MusicItem;
      setState(() {
        _currentMusic = music;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.arrow_drop_up),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => CurrentPlay()));
          },
        ),
        Text(_currentMusic == null ?'Enjoy from tap one':_currentMusic.getDisplayName())
      ],
    );
  }
}

class CurrentPlay extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CurrentPlay();
  }
}

class _CurrentPlay extends State<CurrentPlay> {
  MusicItem _currentMusic;
  @override
  void initState() {
    super.initState();
    print('currentMusicItem: '+currentMusicItem?.getDisplayName());
    bus.on('musicChange', (args) {
      setState(() {
        _currentMusic = args as MusicItem;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(_currentMusic.getDisplayName()),
        elevation: 0, //appbar的阴影
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder(
        future: _currentMusic?.getCoverUrl(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);
          return snapshot.hasData
              ? Image.network(
                  snapshot.data,
                  cacheWidth: 40,
                  cacheHeight: 40,
                )
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  // @override
  // bool get wantKeepAlive => true;
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
      elevation: 99,
    );
  }
}

Future<List<MusicItem>> scanMediaFile() async {
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
  } catch (e) {
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
  var musicBank = new List<MusicItem>();
  var index = 0;
  for (var jObj in parsed) {
    var m = new MusicItem();
    m.id = jObj["id"];
    m.index = index++;
    m.displayName = jObj["name"];
    musicBank.add(m);
  }
  currentMusicItem = musicBank[0];
  bus.emit('musicChange',musicBank[0]);
  return musicBank;
}

class MusicList extends StatefulWidget {
  final List<MusicItem> songs;
  MusicList({Key key, this.songs}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MusicList();
  }
}

class _MusicList extends State<MusicList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: this.widget.songs.length,
      itemBuilder: (context, index) {
        return new ListTile(
          title: new Text('${this.widget.songs[index].getdisplayName()}'),
          onTap: () {
            MusicItem currentMusic = this.widget.songs[index];
            currentMusicItem = this.widget.songs[index];
            bus.emit('musicChange', currentMusic);
          },
        );
      },
    );
  }
}
