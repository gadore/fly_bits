import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

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
              Icon(Icons.directions_car),
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

