import 'package:flutter/material.dart';
import 'package:velloza/pages/pizzariapage.dart';

void main() {
  runApp(const Pizzaria());
}

class Pizzaria extends StatelessWidget {
  const Pizzaria({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: PizzariaPage());
  }
}
