import 'package:diakron_participant/ui/auth/logout/view_models/logout_viewmodel.dart';
import 'package:diakron_participant/ui/auth/logout/widgets/logout_button.dart';
import 'package:diakron_participant/ui/core/ui/custom_screen.dart';
import 'package:diakron_participant/ui/profile/view_models/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.viewModel});

  final ProfileViewmodel viewModel;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScreen(
      title: 'Perfil',
      actions: [
        LogoutButton(
          viewModel: LogoutViewModel(
            authRepository: context.read(),
          ),
        ),
      ],
      child: SingleChildScrollView(
        child: ListenableBuilder(
          listenable: widget.viewModel.load,
          builder: (context, child) {
            if (widget.viewModel.load.running) {
              return Center(child: const CircularProgressIndicator());
            }

            if (widget.viewModel.load.error) {
              return const Center(child: Text('Error al cargar información'));
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Header con Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.viewModel.participant!.userName,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),

                  // Lista de opciones
                  _buildMenuItem(
                    dataType: 'Nombre',
                    data: widget.viewModel.participant!.userName,
                  ),
                  _buildMenuItem(
                    dataType: 'Apellidos',
                    data: widget.viewModel.participant!.surnames,
                  ),
                  _buildMenuItem(
                    dataType: 'Número telefónico',
                    data: widget.viewModel.participant!.phoneNumber,
                  ),
                  _buildMenuItem(
                    dataType: 'E-Mail',
                    data: widget.viewModel.participant!.email,
                  ),

                  _buildMenuItem(
                    dataType: 'Puntos Diakron',
                    data: '${widget.viewModel.participant!.points}',
                  ),
                  
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuItem({required String dataType, required String data}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
         
        children: [
          Text(
            '$dataType:',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 20),
          Text(
            data,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
           overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
