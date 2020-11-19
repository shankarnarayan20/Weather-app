import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'apikey.dart';

void main() => runApp(MyApp());
var width;
bool old = true;
var weather;
var city = 'Thanjavur';

Future<Weather> fetchWeather() async {
  final response = await http.get(
      'https://api.openweathermap.org/data/2.5/find?q=' +
          city +
          '&appid=' +
          apikey);
  if (response.statusCode == 200) {
    weather = Weather.fromJson(json.decode(response.body));
    return Weather.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load weather');
  }
}

class Weather {
  final dynamic temp;
  final dynamic desc;

  Weather({this.temp, this.desc});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
        temp: json['list'][0]['main']['temp'],
        desc: json['list'][0]['weather'][0]['main']);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Weather App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  void changeState() {
    setState(() {});
  }

  refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData query = MediaQuery.of(context);

    width = query.size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: GestureDetector(
            onTap: () {
              changeState();
            },
            child: Text(
              widget.title,
              style: TextStyle(color: Colors.black, fontSize: width * 0.08),
            )),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.all(0.035 * width),
              child: IconButton(
                icon: Icon(
                  Icons.settings,
                  size: 0.07 * width,
                  color: Colors.black,
                ),
                onPressed: () {},
              )),
        ],
      ),
      body: Center(
          child: FutureBuilder<Weather>(
              future: fetchWeather(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return CircularProgressIndicator();
                  default:
                    if (snapshot.hasError)
                      return new Text('Error: ${snapshot.error}');
                    else
                      return buildHome(snapshot);
                }
              })),
    );
  }

  Widget buildHome(AsyncSnapshot snapshot) {
    return Stack(
      children: <Widget>[
        DispWeather(snapshot: snapshot, notifyParent: refresh),
        _buildState()
      ],
    );
  }

  Widget _buildState() {
    return Positioned(
      Widget: [
        Align(
          alignment: FractionalOffset.bottomCenter,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Icon(
              Icons.location_on,
              size: width * 0.09,
            ),
            Text(
              city,
              style: TextStyle(fontSize: width * 0.09),
            )
          ]),
        ),
      ],
    );
  }

  Widget buildStack(AsyncSnapshot snapshot) {
    return Text(snapshot.data.temp.toString());
  }
}

class DispWeather extends StatefulWidget {
  AsyncSnapshot snapshot;
  final TextEditingController controller = new TextEditingController();
  final Function() notifyParent;

  DispWeather({Key key, this.snapshot, @required this.notifyParent})
      : super(key: key);

  @override
  _DispWeatherState createState() => _DispWeatherState();
}

class _DispWeatherState extends State<DispWeather> {
  @override
  Widget build(BuildContext context) {
    var val = widget.snapshot.data.temp;
    var temp = (double.parse(val.toString()) - 273).toStringAsFixed(0);
    return Container(
      child: new Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 0),
            child: Center(child: WeatherImage(desc: widget.snapshot.data.desc)),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0),
            child: Center(
              child: Text(
                temp.toString() + '°C',
                style:
                    TextStyle(fontFamily: 'Quicksand', fontSize: 0.25 * width),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0),
            child: Center(
              child: Text(
                widget.snapshot.data.desc,
                style:
                    TextStyle(fontFamily: 'Quicksand', fontSize: 0.08 * width),
              ),
            ),
          ),
          Container(
            width: width * 0.75,
            margin: EdgeInsets.only(top: width * 0.19),
            child: Center(
              child: TextField(
                showCursor: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Enter the city '),
                controller: widget.controller,
                onSubmitted: (String str) {
                  setState(() {
                    city = city.toLowerCase();
                    city = city.substring(0, 1).toUpperCase() +
                        city.substring(1, city.length);
                    city = str;
                    widget.controller.text = "";
                    widget.notifyParent();
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WeatherImage extends StatelessWidget {
  var desc;
  WeatherImage({this.desc});

  @override
  Widget build(BuildContext context) {
    var link = 'assets/' + desc.toString() + '.png';
    AssetImage assetImage = AssetImage(link);
    Image image = Image(
      image: assetImage,
      height: 0.5 * width,
      width: 0.5 * width,
    );
    return Container(
      child: image,
    );
  }
}
