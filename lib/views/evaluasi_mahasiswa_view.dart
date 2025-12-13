import 'package:flutter/material.dart';

class EvaluasiMahasiswaView extends StatelessWidget {
  const EvaluasiMahasiswaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluasi Mahasiswa'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Text('Halaman Evaluasi Mahasiswa sedang dalam pengembangan'),
      ),
    );
  }
}
