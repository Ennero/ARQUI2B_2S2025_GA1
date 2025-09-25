import 'package:flutter/material.dart';
import 'package:flutter_application/widgets/top_persons.dart';

class AnalyticalDashboardView extends StatelessWidget {
  const AnalyticalDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // ListView para organizar todos los compoenntes analíticos verticalmente.
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        // Componente para el Top de Personas
        TopPersonsWidget(),
        SizedBox(height: 24),

        // Espacio para el top de Armas
        Placeholder(
          fallbackHeight: 200,
          child: Center(child: Text('Aquí irá el top de Armas')),
        ),
        SizedBox(height: 24),

        // Espacio para las infracciones
        Placeholder(
          fallbackHeight: 200,
          child: Center(child: Text('Aquí irán las infracciones del día')),
        ),
      ],
    );
  }
}
