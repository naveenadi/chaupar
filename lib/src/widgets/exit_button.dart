import 'package:flutter/material.dart';

class ExitButton extends StatelessWidget {
  const ExitButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      label: const Text('Exit'),
      icon: const Icon(Icons.exit_to_app),
    );
  }
}
