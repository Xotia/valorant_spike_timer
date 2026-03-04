import 'package:flutter/material.dart';
import 'features/spike_timer/presentation/spike_timer_page.dart';

void main() {
  runApp(const SpikeApp());
}

class SpikeApp extends StatelessWidget {
  const SpikeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valorant Spike Timer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const SpikeTimerPage(),
    );
  }
}
