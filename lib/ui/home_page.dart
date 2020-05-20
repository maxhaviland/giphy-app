import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

import './gif_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offSet = 0;

  Future<Map> _getGifs() async {
    final trending =
        'https://api.giphy.com/v1/gifs/trending?api_key=XEHUckLz4F0XftxE9DlrHLoJF3AdHN0G&limit=10&rating=G';
    final search =
        'https://api.giphy.com/v1/gifs/search?api_key=XEHUckLz4F0XftxE9DlrHLoJF3AdHN0G&q=$_search&limit=9&offset=$_offSet&rating=G&lang=en';
    http.Response response;
    if (_search == null || _search == '')
      response = await http.get(trending);
    else
      response = await http.get(search);

    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.network(
            'https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(20.0),
            child: TextField(
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText: 'Search a gif!',
                  fillColor: Colors.deepPurple,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.deepPurple
                    )
                  ),
                  labelStyle: TextStyle(color: Colors.white, fontSize: 15.0)),
              style: TextStyle(color: Colors.white, fontSize: 15.0),
              textAlign: TextAlign.justify,
              onSubmitted: (text) {
                setState(() {
                  _search = text;
                  _offSet = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
                future: _getGifs(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        width: 200.0,
                        height: 200.0,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5.0,
                        ),
                      );
                    default:
                      if (snapshot.hasError ||
                          snapshot.data['data'].length <= 0)
                        return Container(
                          child: Text('Not found'),
                        );
                      else
                        return _createGifTable(context, snapshot);
                  }
                }),
          )
        ],
      ),
    );
  }

  int _getCount(List data) {
    if (_search == null || _search == '') return data.length;
    return data.length + 1;
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(20.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
        itemCount: _getCount(snapshot.data['data']),
        itemBuilder: (context, index) {
          if (_search == null ||
              _search == '' ||
              index < snapshot.data['data'].length) {
            return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              GifPage(snapshot.data['data'][index])));
                },
                onLongPress: () {
                  Share.share(snapshot.data['data'][index]['images']
                      ['fixed_height']['url']);
                },
                child: FadeInImage.memoryNetwork(
                    placeholder: kTransparentImage,
                    image: snapshot.data['data'][index]['images']
                        ['fixed_height']['url'],
                    height: 300.0,
                    fit: BoxFit.cover));
          }
          return Container(
            child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.add, color: Colors.white, size: 70.0),
                  Text(
                    'Show more...',
                    style: TextStyle(color: Colors.white, fontSize: 22.0),
                  )
                ],
              ),
              onTap: () {
                setState(() {
                  _offSet += 10;
                });
              },
            ),
          );
        });
  }
}
