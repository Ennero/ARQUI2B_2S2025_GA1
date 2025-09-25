import 'package:flutter/material.dart';
import 'package:flutter_application/core/api_service.dart';
import 'package:flutter_application/core/app_colors.dart';
import 'package:flutter_application/core/moch_api_service.dart';

class TopPersonsWidget extends StatelessWidget {
  const TopPersonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personas en Lista Negra (Más Vistas)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.secondaryText,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: .35),
                offset: Offset(0, 3),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Galería horizontal
        SizedBox(
          height: 140,
          child: FutureBuilder<List<dynamic>>(
            //future: ApiService.fetchTopPersonas(),
            future: MockApiService.fetchTopPersons(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryAccent,
                  ),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: AppColors.notificationRed),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'No hay datos de personas detectadas.',
                    style: TextStyle(color: AppColors.secondaryText),
                  ),
                );
              }
              final people = snapshot.data!;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: people.length,
                itemBuilder: (context, index) {
                  final person = people[index];
                  final imageUrl = person['face_image_url'] ?? '';
                  final personId = person['person_id'] ?? 'Desconocido';
                  final count = person['detection_count'] ?? 0;

                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 10),
                    child: Card(
                      color: AppColors.cardBackground,
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: AppColors.primaryAccent
                                  .withValues(alpha: 0.2),
                              backgroundImage: imageUrl.isNotEmpty
                                  ? AssetImage(imageUrl)
                                  : null,
                              child: imageUrl.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      color: AppColors.primaryAccent,
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              personId,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryAccent,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "$count vistas",
                              style: const TextStyle(
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
