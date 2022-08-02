import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

/// Displays detailed information about a SampleItem.
class SampleItemDetailsView extends StatelessWidget {
  const SampleItemDetailsView({Key? key}) : super(key: key);

  static const routeName = '/sample_item';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
      ),
      body: Center(
        child: Column(
          children: [
            const Text('More Information Here'),
            SizedBox(
              height: 200,
              width: 200,
              child: MoveWindow(
                child: Container(
                  color: Colors.amber,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
