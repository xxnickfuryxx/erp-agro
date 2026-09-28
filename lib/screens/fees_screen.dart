import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class FeesScreen extends StatelessWidget {
  const FeesScreen({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final list = state.currentUser!.role == UserRole.produtor &&
            state.currentProducer != null
        ? [state.currentProducer!]
        : state.producers;

    final total = list.fold<double>(0, (a, p) => a + p.managementFeeKg);

    return ListView(
      children: [
        const SectionHeader(
          title: 'Taxa de gestão',
          subtitle:
              '33 kg de soja por hectare anual administrado (safra única ou múltipla)',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.forest, Color(0xFF2A5C4E)],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cobrança consolidada',
                      style: GoogleFonts.manrope(
                        color: AppColors.goldSoft,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${total.toStringAsFixed(0)} kg soja',
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Equivalente anual · regra UML final',
                      style: GoogleFonts.manrope(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.grass, color: AppColors.goldSoft, size: 48),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ...list.map((p) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.farm,
                          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '${p.name} · ${p.focus} · ${p.volumeTier}',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${p.hectares.toStringAsFixed(0)} ha',
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted,
                        ),
                      ),
                      Text(
                        '${p.managementFeeKg.toStringAsFixed(0)} kg',
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w800,
                          color: AppColors.forest,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        const EmptyHint(
          message:
              'Fórmula: hectares × 33 kg soja/ano. Configurável para áreas de safra única ou múltipla na versão completa.',
        ),
      ],
    );
  }
}
