import 'package:flutter/material.dart';
import 'package:splitio/split_client.dart';
import 'package:splitio/splitio.dart';
import 'dart:async';
import 'dart:convert';

final Splitio _split = Splitio('<your split client-side api token>', 'key');

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
      home: const MyHomePage(title: 'Split Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Future<SplitResult> getSplitTreatment() {
    Completer<SplitResult> resultCompleter = Completer();

    _split.client(onReady: (client) async {
      print("client is ready, calling getTreatment");
      resultCompleter
          .complete(client.getTreatmentWithConfig('multivariant_demo'));
    });

    return resultCompleter.future;
}

Future<SplitResult> _splitResult = getSplitTreatment();

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<SplitResult>(
      future: _splitResult,
      builder: (BuildContext context, AsyncSnapshot<SplitResult> snapshot) {
        List<Widget> children;
        
        if(snapshot.hasData) {
          var json = jsonDecode(snapshot.data!.config!);
          print("data: " + json['image']);

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
                  Image.network(json['image']),
                  Text(
                    json['text'],
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
