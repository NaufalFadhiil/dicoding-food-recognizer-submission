import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:submission/controller/home_controller.dart';
import 'package:submission/firebase_options.dart';
import 'package:submission/service/image_classification_service.dart';
import 'package:submission/ui/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final imageClassificationService = ImageClassificationService();
  await imageClassificationService.initHelper();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HomeController()),
        Provider<ImageClassificationService>(
          create: (_) => imageClassificationService,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
