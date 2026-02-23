import 'package:first_app/app.dart';
import 'package:first_app/core/services/notification_service.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();
  runApp(const GluCareApp());
}
