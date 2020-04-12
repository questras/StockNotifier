import 'package:shared_preferences/shared_preferences.dart';

const _SETTINGS_PREFERENCES = ['notificationThreshold'];

Future<double> preferencesRead(String key) async {
  final prefs = await SharedPreferences.getInstance();
  final value = prefs.getDouble(key) ?? 0;
  print('read: $key : $value');

  return value;
}

preferencesSave(String key, double value) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setDouble(key, value);
  print('saved $key');
}

preferencesRemove(String key) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove(key);
  print('removed $key');
}

Future<Set<String>> getPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  final result = new Set<String>.from(prefs.getKeys());

  // Exclude settings preferences.
  for (var setting in _SETTINGS_PREFERENCES) {
    result.remove(setting);
  }

  return result;
}

Future<int> notificationThresholdRead() async {
  final prefs = await SharedPreferences.getInstance();
  final value = prefs.getInt('notificationThreshold');

  if (value == null) {
    final defaultThreshold = 60;
    prefs.setInt('notificationThreshold', defaultThreshold);

    return defaultThreshold;
  }

  return value;
}

void notificationThresholdSave(int value) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setInt('notificationThreshold', value);
  print('saved $value');
}