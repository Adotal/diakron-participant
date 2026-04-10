import 'package:diakron_participant/ui/core/ui/custom_screen.dart';
import 'package:diakron_participant/ui/profile/view_models/profile_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RecyclingData {
  final Map<String, int> materials; // { 'Metal': 10, 'Plastic': 4, ... }
  final Map<String, String> energySavings; // { 'can': '12 kWh', ... }

  RecyclingData({required this.materials, required this.energySavings});
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.viewModel});

  final ProfileViewmodel viewModel;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// 2. Mock Data (Replace with real data later)
final RecyclingData data = RecyclingData(
  materials: {'Metal': 10, 'Plástico': 4, 'Papel/Cartón': 2, 'Vidrio': 1},
  energySavings: {
    'metal': '12 kWh',
    'paper': '1.21 GWh',
    'plastic': '1.21 kWh',
    'glass': '13 Wh',
  },
);

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScreen(
      title: 'Progreso',
      actions: [IconButton(onPressed: null, icon: Icon(Icons.person, color: Colors.white,))],
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- Header 1 ---
              const Text(
                'Cantidad de materiales',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                'reciclados',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // --- 3. The Pie Chart (fl_chart) ---
              SizedBox(
                height: 250, // Constrain height for the chart
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 0, // No space between segments
                    centerSpaceRadius: 0, // Solid pie, not a donut
                    startDegreeOffset: 270, // Start drawing from the top
                    sections: _showingSections(data.materials),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // --- Header 2 ---
              const Text(
                '¡¡¡Ahorro energético!!!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),

              const SizedBox(height: 30),

              // --- 4. The Energy Savings Grid ---
              _buildEnergySavingsGrid(data.energySavings),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper: Define Chart Colors & Layout ---
  List<PieChartSectionData> _showingSections(Map<String, int> materials) {
    // 1. Calculate total for percentage labeling if needed (not used in the specific image design, but useful)
    final total = materials.values.fold<int>(0, (sum, value) => sum + value);

    // 2. Define colors mapping the image
    final Map<String, Color> materialColors = {
      'Metal': const Color(0xFF9E9E9E), // Grey
      'Plástico': const Color(0xFFFFB74D), // Yellow-Orange
      'Papel/Cartón': const Color(0xFF2980B9), // Blue
      'Vidrio': const Color(0xFF33691E), // Dark Green
    };

    // 3. Generate Section Data
    return materials.entries.map((entry) {
      final name = entry.key;
      final value = entry.value;

      // Radius of the pie segment
      const double radius = 100;

      // Define appearance of labels
      final isTopLabel = (name == 'Vidrio' || name == 'Papel/Cartón');
      final labelStyle = const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Colors.black, // From the image
      );

      return PieChartSectionData(
        color: materialColors[name] ?? Colors.grey,
        value: value.toDouble(),
        title: '$name\n$value', // Label: Name + Value
        radius: radius,
        titleStyle: labelStyle,
        // Positioning the label outside. This is key for the "radial label" look.
        titlePositionPercentageOffset: 1.3, // Move label radially outwards
        // We ensure text is horizontally aligned, fl_chart handles radial placement
        badgeWidget: null,
      );
    }).toList();
  }

  // --- Helper: Build the Icons + Values Grid ---
  Widget _buildEnergySavingsGrid(Map<String, String> savings) {
    // Standard Material Icons (or install MdiIcons for exact matches)
    const metalIcon = Icons.construction; // Placeholder for can
    const paperIcon = Icons.note; // Placeholder for paper roll
    const plasticIcon = Icons.science; // Placeholder for plastic bottle
    const glassIcon = Icons.wine_bar_outlined; // Placeholder for wine glass

    return GridView.count(
      shrinkWrap: true, // Crucial inside a SingleChildScrollView
      physics: const NeverScrollableScrollPhysics(), // Scroll handled by parent
      crossAxisCount: 2, // Two columns
      childAspectRatio: 2.2, // Adjust item height/width ratio
      mainAxisSpacing: 15, // Vertical spacing
      crossAxisSpacing: 15, // Horizontal spacing
      padding: const EdgeInsets.symmetric(horizontal: 10),
      children: [
        _buildEnergyItem(metalIcon, savings['metal'] ?? 'N/A'),
        _buildEnergyItem(paperIcon, savings['paper'] ?? 'N/A'),
        _buildEnergyItem(plasticIcon, savings['plastic'] ?? 'N/A'),
        _buildEnergyItem(glassIcon, savings['glass'] ?? 'N/A'),
      ],
    );
  }

  // --- Helper Widget for individual grid items ---
  Widget _buildEnergyItem(IconData icon, String value) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.start, // Align to left within grid cell
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. The dark icon square
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF212121), // Near-black background
            borderRadius: BorderRadius.circular(10), // Optional slight curve
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 15), // Spacing between icon and text
        // 2. The value text
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  /*
    return CustomScreen(
      title: 'Perfil',
      actions: [
        LogoutButton(
          viewModel: LogoutViewModel(
            authRepository: context.read(),
            participantRepository: context.read()
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
  */

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
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
