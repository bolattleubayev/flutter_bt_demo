import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_blue/flutter_blue.dart';

class DeviceDetailScreen extends StatefulWidget {
  final BluetoothDevice _connectedDevice;
  final Map<Guid, List<int>> readValues = new Map<Guid, List<int>>();

  DeviceDetailScreen(this._connectedDevice);

  @override
  _DeviceDetailScreenState createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  Future<List<BluetoothService>> _getService() async {
    return widget._connectedDevice.discoverServices();
  }

  List<ButtonTheme> _buildReadWriteNotifyButton(
      BluetoothCharacteristic characteristic) {
    List<ButtonTheme> buttons = new List<ButtonTheme>();

    if (characteristic.properties.read) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: RaisedButton(
              color: Theme.of(context).primaryColor,
              child: Text(
                'read',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                var sub = characteristic.value.listen((value) {
                  setState(() {
                    widget.readValues[characteristic.uuid] = value;
                  });
                });
                await characteristic.read();
                sub.cancel();
              },
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.write) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: RaisedButton(
              child: Text(
                'write',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                // Did not yet implement
              },
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.notify) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: RaisedButton(
              child: Text(
                'notify',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                characteristic.value.listen((value) {
                  widget.readValues[characteristic.uuid] = value;
                });
                await characteristic.setNotifyValue(true);
              },
            ),
          ),
        ),
      );
    }

    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Detail Screen'),
      ),
      body: FutureBuilder(
        future: _getService(),
        builder: (ctx, snapshot) {
          List<Container> containers = new List<Container>();

          for (BluetoothService service in snapshot.data) {
            List<Widget> characteristicsWidget = new List<Widget>();
            for (BluetoothCharacteristic characteristic
                in service.characteristics) {
              characteristic.value.listen((value) {
                if (value != null) {
                  String decoded = Utf8Decoder()
                      .convert(value); // value == List<int>, Uint8List, etc.
                  if (decoded != "") {
                    print("decoded: " + decoded);
                  }
                }

                if (value.isNotEmpty) {
                  print("value: " + value.toString());
                }
              });
              characteristicsWidget.add(
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(characteristic.uuid.toString(),
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          ..._buildReadWriteNotifyButton(characteristic),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text('Value: ' +
                              Utf8Decoder().convert(
                                  widget.readValues[characteristic.uuid] ??
                                      [0])),
                        ],
                      ),
                      Divider(),
                    ],
                  ),
                ),
              );
            }
            containers.add(
              Container(
                child: ExpansionTile(
                    title: Text(service.uuid.toString()),
                    children: characteristicsWidget),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(8),
            children: <Widget>[
              ...containers,
            ],
          );
        },
      ),
    );
  }
}
