import 'package:flutter/material.dart';
import 'features/bears/presentation/pages/bears_page.dart'; 

class App extends StatelessWidget {
  const App({super.key}); 

  @override 
  Widget build(BuildContext context){
    return MaterialApp(
      title: "Bears", 
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange)), 
      home: const BearsPage(),
    ); 
  }
}