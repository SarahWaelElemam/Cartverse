import 'package:flutter/material.dart';

class ContactScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contact')),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: support@cartverse.com', style: TextStyle(fontSize: 16)),
            SizedBox(height: 12),
            Text('Phone: +123‑456‑7890', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
