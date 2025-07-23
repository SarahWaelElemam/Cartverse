import 'package:flutter/material.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1C1C1C),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/');
                },
                child: const Text(
                  'CARTVERSE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Our mission is to offer you the best selection of stylish and high-quality clothing, whether from well-known brands or emerging designers.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.facebook, color: Colors.white70, size: 20),
                  SizedBox(width: 12),
                  Icon(Icons.camera_alt, color: Colors.white70, size: 20),
                  SizedBox(width: 12),
                  Icon(Icons.mail_outline, color: Colors.white70, size: 20),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'CONTACT INFO',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 12),
              Text('ADDRESS:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
              SizedBox(height: 4),
              Text('105 New Cairo, Cairo, Egypt', style: TextStyle(color: Colors.white70, fontSize: 12)),
              SizedBox(height: 12),
              Text('PHONE:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
              SizedBox(height: 4),
              Text('+ (20) 060-472-388', style: TextStyle(color: Colors.white70, fontSize: 12)),
              SizedBox(height: 12),
              Text('EMAIL:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
              SizedBox(height: 4),
              Text('gizasystems@cartverse.com', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('CATEGORIES', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    SizedBox(height: 12),
                    Text('Men\'s Clothing', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    SizedBox(height: 8),
                    Text('Women\'s Clothing', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    SizedBox(height: 8),
                    Text('Kid\'s Clothing', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    SizedBox(height: 8),
                    Text('Sports Clothing', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('NAVIGATE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    SizedBox(height: 12),
                    Text('Home', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    SizedBox(height: 8),
                    Text('About', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    SizedBox(height: 8),
                    Text('Blog', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    SizedBox(height: 8),
                    Text('Categories', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Divider(color: Colors.white24),
          const SizedBox(height: 15),
          const Center(
            child: Text(
              'Copyright © 2025 Cartverse By Hisham Rabea. All Rights Reserved',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
