import 'package:flutter/material.dart';
import 'package:splitio/split_client.dart';
import 'package:splitio/splitio.dart';
import 'dart:async';
import 'dart:convert';

StreamController<dynamic> streamController = StreamController<dynamic>();

final SplitConfiguration configurationOptions = SplitConfiguration(
    trafficType: 'user',
    enableDebug: true,
    persistentAttributesEnabled: true,
    streamingEnabled: true,
    featuresRefreshRate: 5
);

final Splitio _split = Splitio('2d20dfejlhn8ihi1tla2e27bs4ishqa54nt5', 'key', configuration: configurationOptions);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Split Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage('Split Demo Home Page', streamController.stream),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage(this.title, this.stream);

  final String title;
  final Stream<dynamic> stream;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Future<SplitResult> getSplitTreatment() {
    Completer<SplitResult> resultCompleter = Completer();

    _split.client(onReady: (client) async {
      print("client is ready, calling getTreatment");
      resultCompleter
        .complete(client.getTreatmentWithConfig('multivariant_demo'));
    }, onReadyFromCache: (client) {
      print("onReadyFromCache!");
    }, onUpdated: (client) async {
      print("onUpdated!");
      SplitResult result = await client.getTreatmentWithConfig('multivariant_demo');
      var json = jsonDecode(result.config!);
      print(json);
      print("adding JSON to stream controller");
      streamController.add(json);
    }, onTimeout: (client) {
      print("onTimeout!");
    });

    return resultCompleter.future;
}

Future<SplitResult> _splitResult = getSplitTreatment();

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  var _image;
  var _text;

  @override
  void initState() {
    super.initState();
    widget.stream.listen((json) {
      print("LISTEN");
      mySetState(json);
    });
  }

  void mySetState(dynamic json) {
    print ("mySetState");
    setState(() {
      _image = json['image'];
      _text = json['text'];
    });
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _setImage(image) {
    setState(() {
      _image = image;
    });
  }

  void _setText(text) {
    setState(() {
      _text = text;
    });
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<SplitResult>(
      future: _splitResult,
      builder: (BuildContext context, AsyncSnapshot<SplitResult> snapshot) {
        List<Widget> children;
        
        if(snapshot.hasData) {
          if(_image == null) {
            var json = jsonDecode(snapshot.data!.config!);
            print("onReady data: " + json['image']);
            _image = json['image'];
            _text = json['text'];
          }
          print("showing: " + _image);

          children = <Widget> [
            Flexible(
              child: Scaffold(
                appBar: AppBar(
              title: Text(widget.title),
              ),
              body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.network(_image),
                  Text(
                    _text,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ],
              ),)
            )
          )];
        } else if (snapshot.hasError) {
          children = <Widget>[
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 120,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Error: ${snapshot.error}'),
            )
          ];
        } else {
          children = <Widget>[
            SizedBox(
              child: CircularProgressIndicator(),
              width: 240,
              height: 240,
            )
          ];
        }  
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          ),
        );         
      }
    );
  }
}
