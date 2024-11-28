import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart'; // 3D model için gerekli paket

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3D Model Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Sayfa'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Butona basıldığında 3D model sayfasına yönlendirme
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ModelViewerScreen()),
            );
          },
          child: const Text('3D Modeli Görüntüle'),
        ),
      ),
    );
  }
}

class ModelViewerScreen extends StatelessWidget {
  const ModelViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Model Viewer'),
      ),
      body: const Center(
        child: ModelViewer(
          src: 'assets/2020_ferrari_roma.glb',
          alt: "3D model of an astronaut",
          ar: true,
          autoRotate: true,
          cameraControls: true,
        ),
      ),
    );
  }
}
