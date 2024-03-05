import 'package:app_control/button.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Mqtt test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MqttServerClient client = MqttServerClient('broker.mqtt-dashboard.com', '');
  bool isOpen = false;
  senMsg(String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);

    final MqttConnectMessage connectMessage = MqttConnectMessage()
        .withClientIdentifier('Mqtt_MyClientUniqueId')
        .startClean()
        .authenticateAs('username', 'password')
        .withWillTopic('willtopic')
        .withWillMessage('Will message')
        .withWillQos(MqttQos.atLeastOnce);

    client.keepAlivePeriod = 60;
    client.connectionMessage = connectMessage;
    client.connect();

    client.onConnected = () {
      client.publishMessage(
        'intellipark/servo',
        MqttQos.exactlyOnce,
        builder.payload!,
      );
      client.disconnect();
    };

    client.logging(on: true);
    if (client.connectionStatus?.state == MqttConnectionState.connecting && message == 'servo_on') {
      setState(() {
        isOpen = true;
      });
    } else {
      setState(() {
        isOpen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Button(
                color: Colors.purple,
                onPressed: () {
                  senMsg('servo_on');
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Open gate')));
                  setState(() {});
                },
                child: const Center(
                  child: Text(
                    'Open',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Button(
                color: Colors.purple,
                onPressed: () {
                  senMsg('servo_off');
                  setState(() {});
                },
                child: const Center(
                  child: Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      /* floatingActionButton: FloatingActionButton(
        onPressed: () => senMsg('servo_on'),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), */
    );
  }
}
