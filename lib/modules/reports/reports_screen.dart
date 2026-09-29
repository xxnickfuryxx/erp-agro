import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';

/// Relatórios operacionais para demo com investidores.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final feeTotal = state.producers.fold<double>(
      0,
      (a, p) => a + state.managementFeeFor(p),
    );
    final charged = state.feeCharges.fold<double>(
      0,
      (a, f) => a + f.kgCharged,
    );
    final openRep = state.openReplenishments.length;
    final warehouseFill = state.warehouse.isEmpty
        ? 0.0
        : state.warehouse.fold<double>(0, (a, w) => a + w.distributedQty) /
            state.warehouse.fold<double>(0, (a, w) => a + w.receivedQty) *
            100;

    return ListView(
      children: [
        const SectionHeader(
          title: 'Relatórios',
          subtitle:
              'Visão consolidada — taxas, compras, rede de empréstimos e armazém',
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, c) {
            final cards = [
              MetricCard(
                label: 'Taxa prevista',
                value: '${feeTotal.toStringAsFixed(0)} kg',
                icon: Icons.grass,
                subtitle: state.feeConfig.formulaLabel,
                accent: AppColors.gold,
              ),
              MetricCard(
                label: 'Taxa já cobrada',
                value: '${charged.toStringAsFixed(0)} kg',
                icon: Icons.request_page_outlined,
                subtitle: '${state.feeCharges.length} lançamento(s)',
              ),
              MetricCard(
                label: 'OC-REP abertas',
                value: '$openRep',
                icon: Icons.swap_horiz,
                subtitle: 'Reposições pendentes',
                accent: openRep > 0 ? AppColors.warning : AppColors.success,
              ),
              MetricCard(
                label: 'Armazém distribuído',
                value:
                    '${warehouseFill.isNaN ? 0 : warehouseFill.toStringAsFixed(0)}%',
                icon: Icons.warehouse_outlined,
                subtitle: '${state.warehouse.length} lote(s)',
              ),
            ];

            if (c.maxWidth < 600) {
              return Column(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    cards[i],
                  ],
                ],
              );
            }

            final cols = c.maxWidth > 900 ? 4 : 2;
            return GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: cols == 4 ? 1.45 : 1.55,
              children: cards,
            );
          },
        ),
        const SizedBox(height: 24),
        Text(
          'Lotes por status',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final status in LotStatus.values)
              Builder(
                builder: (_) {
                  final n =
                      state.lots.where((l) => l.status == status).length;
                  if (n == 0) return const SizedBox.shrink();
                  return StatusPill(
                    label: '${status.label}: $n',
                    tone: PillTone.info,
                  );
                },
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Taxa por fazenda',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 10),
        ...state.producers.map((p) {
          final kg = state.managementFeeFor(p);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.line),
              ),
              title: Text(
                p.farm,
                style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                '${p.cadproCode} · ${p.hectares.toStringAsFixed(0)} ha · ${p.harvestMode.label} · ${p.focus}',
                style: GoogleFonts.manrope(fontSize: 12),
              ),
              trailing: Text(
                '${kg.toStringAsFixed(0)} kg',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w800,
                  color: AppColors.forest,
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
        Text(
          'Empréstimos / rede',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 10),
        if (state.transfers.isEmpty)
          const EmptyHint(message: 'Sem transferências registadas.')
        else
          ...state.transfers.take(8).map((t) {
            final from = state.producerById(t.fromProducerId)?.farm ?? '—';
            final to = state.producerById(t.toProducerId)?.farm ?? '—';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.line),
                ),
                title: Text(
                  '$from → $to',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${t.quantity.toStringAsFixed(0)} ${t.unit} ${t.productName} · ${t.status.label}',
                  style: GoogleFonts.manrope(fontSize: 12),
                ),
                trailing: StatusPill(
                  label: t.replenishmentOrderId ?? '—',
                  tone: PillTone.gold,
                ),
              ),
            );
          }),
      ],
    );
  }
}
