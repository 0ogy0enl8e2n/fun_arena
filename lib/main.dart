import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/app_provider.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final storage = StorageService();
  await storage.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppDataProvider(storage),
      child: const FanArenaApp(),
    ),
  );
}
