import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';

class FeesScreen extends StatelessWidget {
  const FeesScreen({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final role = state.currentUser!.role;
    final list = role == UserRole.produtor && state.currentProducer != null
        ? [state.currentProducer!]
        : state.producers;

    final total = list.fold<double>(0, (a, p) => a + p.managementFeeKg);
    final dateFmt = DateFormat('dd/MM/yyyy');

    return ListView(
      children: [
        SectionHeader(
          title: 'Taxa de gestão',
          subtitle:
              '33 kg de soja por hectare anual · safra única ou múltipla · cobrança registada no ERP',
          action: role.canManageEcosystem
              ? FilledButton.icon(
                  onPressed: () {
                    final n = state.chargeAllManagementFees();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          n == 0
                              ? 'Todas as taxas da safra já estavam cobradas.'
                              : '$n cobrança(s) registada(s).',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.request_page_outlined),
                  label: const Text('Cobrar todas'),
                )
              : null,
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
                      'Base de cobrança',
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
                      'ha × 33 × multiplicador de safra',
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
          final last = state.latestFeeFor(p.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.farm,
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '${p.name} · ${p.focusDetail} · ${p.volumeTier}',
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
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      StatusPill(
                        label: p.harvestMode.label,
                        tone: PillTone.gold,
                      ),
                      if (last != null)
                        StatusPill(
                          label:
                              'Cobrada ${dateFmt.format(last.chargedAt ?? DateTime.now())}',
                          tone: PillTone.success,
                        ),
                      if (role.canManageEcosystem) ...[
                        OutlinedButton(
                          onPressed: () => state.setHarvestMode(
                            p.id,
                            p.harvestMode == HarvestMode.unica
                                ? HarvestMode.multipla
                                : HarvestMode.unica,
                          ),
                          child: Text(
                            p.harvestMode == HarvestMode.unica
                                ? 'Mudar para múltipla'
                                : 'Mudar para única',
                          ),
                        ),
                        FilledButton(
                          onPressed: () {
                            final c =
                                state.chargeManagementFee(producerId: p.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Cobrados ${c.kgCharged.toStringAsFixed(0)} kg soja · ${c.season}',
                                ),
                              ),
                            );
                          },
                          child: const Text('Cobrar taxa'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 20),
        Text(
          'Histórico de cobranças',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 10),
        if (state.feeCharges.isEmpty)
          const EmptyHint(message: 'Ainda não há cobranças registadas.')
        else
          ...state.feeCharges.map((f) {
            final farm = state.producerById(f.producerId)?.farm ?? f.producerId;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.line),
                ),
                title: Text(
                  farm,
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${f.season} · ${f.harvestMode.label} · ${f.hectares.toStringAsFixed(0)} ha',
                  style: GoogleFonts.manrope(fontSize: 12),
                ),
                trailing: Text(
                  '${f.kgCharged.toStringAsFixed(0)} kg',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800,
                    color: AppColors.forest,
                  ),
                ),
              ),
            );
          }),
        const SizedBox(height: 8),
        const EmptyHint(
          message:
              'Fórmula UML: hectares × 33 kg soja/ano × (1 se safra única, 2 se múltipla).',
        ),
      ],
    );
  }
}
