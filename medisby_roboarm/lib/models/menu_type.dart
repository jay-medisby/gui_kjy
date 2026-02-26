import 'package:flutter/material.dart';

enum MenuType {
  start(label: '시작', icon: Icons.play_arrow),
  patient(label: '환자 불러오기', icon: Icons.person_outline),
  treatmentLog(label: '치료 기록 보기', icon: Icons.description_outlined),
  settings(label: '설정', icon: Icons.settings_outlined),
  exit(label: '종료', icon: Icons.logout);

  const MenuType({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
