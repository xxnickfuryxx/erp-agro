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

    final total =
        list.fold<double>(0, (a, p) => a + state.managementFeeFor(p));
    final dateFmt = DateFormat('dd/MM/yyyy');
    final cfg = state.feeConfig;

    return ListView(
      children: [
        SectionHeader(
          title: 'Taxa de gestão',
          subtitle:
              '${cfg.formulaLabel} · na cobrança o valor vem preenchido e pode ser ajustado',
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
        if (role.canManageEcosystem) ...[
          const SizedBox(height: 12),
          _FeeConfigCard(state: state),
        ],
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
                      '${total.toStringAsFixed(0)} kg ${cfg.commodityLabel}',
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      cfg.formulaLabel,
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
          final kg = state.managementFeeFor(p);
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
                            '${kg.toStringAsFixed(0)} kg',
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
                          onPressed: () => _confirmCharge(context, state, p),
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
                  '${f.season} · ${f.harvestMode.label} · ${f.hectares.toStringAsFixed(0)} ha'
                  '${f.isPersonalized ? ' · personalizada (padrão ${f.standardKg!.toStringAsFixed(0)} kg)' : ''}'
                  '${f.adjustmentNote != null ? ' · ${f.adjustmentNote}' : ''}',
                  style: GoogleFonts.manrope(fontSize: 12),
                ),
                trailing: Text(
                  '${f.kgCharged.toStringAsFixed(0)} kg',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800,
                    color: f.isPersonalized ? AppColors.gold : AppColors.forest,
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}

Future<void> _confirmCharge(
  BuildContext context,
  AppState state,
  Producer p,
) async {
  final standard = state.managementFeeFor(p);
  final kgCtrl = TextEditingController(text: standard.toStringAsFixed(0));
  final noteCtrl = TextEditingController();

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text(
          'Cobrar taxa · ${p.farm}',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Valor da regra geral já preenchido '
                '(${p.hectares.toStringAsFixed(0)} ha × ${state.feeConfig.kgPerHa.toStringAsFixed(0)} kg '
                '× ${p.harvestMode.feeMultiplier.toStringAsFixed(0)}). '
                'Confirme ou altere para uma taxa pré-acordada '
                '(desconto, indicação, produtor novo).',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  height: 1.4,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: kgCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText:
                      'Kg de ${state.feeConfig.commodityLabel} a cobrar',
                  helperText:
                      'Padrão: ${standard.toStringAsFixed(0)} kg. Pode reduzir.',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Motivo do ajuste (opcional)',
                  hintText: 'Ex.: indicação, desconto de entrada',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar cobrança'),
          ),
        ],
      );
    },
  );

  if (ok != true || !context.mounted) {
    kgCtrl.dispose();
    noteCtrl.dispose();
    return;
  }

  final kg = double.tryParse(kgCtrl.text.replaceAll(',', '.')) ?? standard;
  final charge = state.chargeManagementFee(
    producerId: p.id,
    kgOverride: kg < 0 ? standard : kg,
    adjustmentNote: noteCtrl.text,
  );
  kgCtrl.dispose();
  noteCtrl.dispose();
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        charge.isPersonalized
            ? 'Taxa personalizada: ${charge.kgCharged.toStringAsFixed(0)} kg '
                '(padrão ${charge.standardKg!.toStringAsFixed(0)}).'
            : 'Cobrados ${charge.kgCharged.toStringAsFixed(0)} kg · ${charge.season}',
      ),
    ),
  );
}

class _FeeConfigCard extends StatefulWidget {
  const _FeeConfigCard({required this.state});

  final AppState state;

  @override
  State<_FeeConfigCard> createState() => _FeeConfigCardState();
}

class _FeeConfigCardState extends State<_FeeConfigCard> {
  late final TextEditingController _kg;
  late final TextEditingController _season;
  late final TextEditingController _commodity;

  @override
  void initState() {
    super.initState();
    final c = widget.state.feeConfig;
    _kg = TextEditingController(text: c.kgPerHa.toStringAsFixed(0));
    _season = TextEditingController(text: c.defaultSeason);
    _commodity = TextEditingController(text: c.commodityLabel);
  }

  @override
  void dispose() {
    _kg.dispose();
    _season.dispose();
    _commodity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cadastro de parâmetros da taxa',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _kg,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'kg / hectare',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _commodity,
                  decoration: const InputDecoration(
                    labelText: 'Commodity (ex.: soja)',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _season,
            decoration: const InputDecoration(
              labelText: 'Safra padrão',
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () {
                final kg =
                    double.tryParse(_kg.text.replaceAll(',', '.')) ?? 33;
                widget.state.updateFeeConfig(
                  kgPerHa: kg,
                  defaultSeason: _season.text,
                  commodityLabel: _commodity.text,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Parâmetros de taxa salvos.')),
                );
              },
              child: const Text('Salvar parâmetros'),
            ),
          ),
        ],
      ),
    );
  }
}
