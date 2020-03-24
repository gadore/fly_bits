import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:simple_permissions/simple_permissions.dart';
import 'package:storage_path/storage_path.dart';
import 'musicInfo.dart';

// final musicBank = null;

// final AudioPlayer audioPlayer = AudioPlayer();

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
                future: scanMediaFile(),
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
            )
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

class MusicList extends StatelessWidget{
  final List<MusicItem> songs;
  MusicList({Key key, this.songs}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        return new ListTile(title: new Text('${songs[index].getdisplayName()}'));
      },
    );
  }
}

