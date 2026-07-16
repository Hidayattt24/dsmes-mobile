import 'package:flutter/material.dart';

class RoutineIconOption {
  const RoutineIconOption({
    required this.key,
    required this.label,
    required this.icon,
  });

  final String key;
  final String label;
  final IconData icon;
}

const List<RoutineIconOption> routineIconOptions = [
  RoutineIconOption(key: 'walk', label: 'Jalan', icon: Icons.directions_walk),
  RoutineIconOption(key: 'run', label: 'Lari', icon: Icons.directions_run),
  RoutineIconOption(key: 'water', label: 'Air', icon: Icons.water_drop_outlined),
  RoutineIconOption(key: 'breakfast', label: 'Sarapan', icon: Icons.free_breakfast_outlined),
  RoutineIconOption(key: 'lunch', label: 'Makan Siang', icon: Icons.lunch_dining_outlined),
  RoutineIconOption(key: 'dinner', label: 'Makan Malam', icon: Icons.dinner_dining_outlined),
  RoutineIconOption(key: 'blood', label: 'Gula Darah', icon: Icons.bloodtype_outlined),
  RoutineIconOption(key: 'medicine', label: 'Obat', icon: Icons.medication_outlined),
  RoutineIconOption(key: 'sleep', label: 'Tidur', icon: Icons.bedtime_outlined),
  RoutineIconOption(key: 'alarm', label: 'Alarm', icon: Icons.alarm),
  RoutineIconOption(key: 'exercise', label: 'Olahraga', icon: Icons.fitness_center_outlined),
  RoutineIconOption(key: 'bike', label: 'Sepeda', icon: Icons.directions_bike),
  RoutineIconOption(key: 'yoga', label: 'Yoga', icon: Icons.self_improvement),
  RoutineIconOption(key: 'heart', label: 'Jantung', icon: Icons.favorite_border),
  RoutineIconOption(key: 'hospital', label: 'Rumah Sakit', icon: Icons.local_hospital_outlined),
  RoutineIconOption(key: 'restaurant', label: 'Makan', icon: Icons.restaurant),
  RoutineIconOption(key: 'coffee', label: 'Kopi', icon: Icons.local_cafe),
  RoutineIconOption(key: 'clock', label: 'Jam', icon: Icons.schedule),
  RoutineIconOption(key: 'work', label: 'Kerja', icon: Icons.work_outline),
  RoutineIconOption(key: 'home', label: 'Rumah', icon: Icons.home_outlined),
];

IconData resolveRoutineIcon(String key) {
  return routineIconOptions.firstWhere(
    (o) => o.key == key,
    orElse: () => routineIconOptions.first,
  ).icon;
}
