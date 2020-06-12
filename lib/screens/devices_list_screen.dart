import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import './device_detail_screen.dart';

class DevicesListScreen extends StatefulWidget {
  DevicesListScreen({Key key, this.title}) : super(key: key);

  final String title;
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devicesList = new List<BluetoothDevice>();

  @override
  _DevicesListScreenState createState() => _DevicesListScreenState();
}

class _DevicesListScreenState extends State<DevicesListScreen> {
  BluetoothDevice _connectedDevice;
  List<BluetoothService> _services;

  void _addDeviceToList(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);
      });
    }
  }

  void _findDevices() {
    widget.flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceToList(device);
      }
    });
    widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceToList(result.device);
      }
    });
    widget.flutterBlue.startScan();
  }

  @override
  void initState() {
    super.initState();
    _findDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Devices List'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _findDevices();
              setState(() {});
            },
          ),
        ],
      ),
      body: ListView.builder(
          itemCount: widget.devicesList.length,
          itemBuilder: (ctx, index) {
            final device = widget.devicesList[index];
            return ListTile(
              leading: Icon(Icons.devices),
              title: Column(
                children: [
                  Text(device.name == '' ? 'no name' : device.name),
                  Text(
                    device.id.toString(),
                    style: TextStyle(fontSize: 10.0),
                  ),
                  Divider(),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.arrow_forward_ios),
                onPressed: () async {
                  await widget.flutterBlue.stopScan();
                  try {
                    await device.connect();
                  } catch (e) {
                    if (e.code != 'already_connected') {
                      throw e;
                    }
                  } finally {
                    _services = await device.discoverServices();
                  }

                  setState(() {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => DeviceDetailScreen(device),
                      ),
                    );
                  });
                },
              ),
            );
          }),
    );
  }
}
