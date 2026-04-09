import 'package:diakron_participant/ui/auth/logout/view_models/logout_viewmodel.dart';
import 'package:diakron_participant/ui/auth/logout/widgets/logout_button.dart';
import 'package:diakron_participant/ui/core/ui/custom_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  Widget build(BuildContext context) {


    
    return CustomScreen(
      title: 'Progreso',
      actions: [LogoutButton(viewModel: LogoutViewModel(authRepository: context.read()))],
      
      child: SafeArea(
        child: GridView.count(
          crossAxisCount: 2, // 2 columns
          crossAxisSpacing: 10, // Horizontal gap
          mainAxisSpacing: 10, // Vertical gap
          children: [
            Container(color: Colors.blue, height: 100),
            Container(color: Colors.red, height: 100),
            Container(color: Colors.green, height: 100),
            Container(color: Colors.yellow, height: 100),
          ],
        ),
      ),
    );
  }
}
