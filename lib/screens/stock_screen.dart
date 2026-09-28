import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final role = state.currentUser!.role;
    final producers = role == UserRole.produtor && state.currentProducer != null
        ? [state.currentProducer!]
        : state.producers;

    return ListView(
      children: [
        SectionHeader(
          title: 'Stock local (fazenda)',
          subtitle: 'Registo de consumo diário e monitorização de ruturas',
          action: role.canManageEcosystem
              ? OutlinedButton.icon(
                  onPressed: state.simulateRuptureDemo,
                  icon: const Icon(Icons.science_outlined),
                  label: const Text('Simular rutura (B)'),
                )
              : null,
        ),
        const SizedBox(height: 16),
        for (final p in producers) ...[
          _ProducerStockCard(state: state, producer: p),
          const SizedBox(height: 14),
        ],
        if (state.consumptions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Consumos recentes',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 10),
          ...state.consumptions.take(8).map((c) {
            final farm = state.producerById(c.producerId)?.farm ?? '';
            return ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.line),
              ),
              title: Text(
                '${c.productName} · -${c.quantity.toStringAsFixed(0)} ${c.unit}',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              subtitle: Text(
                '$farm · ${DateFormat('dd/MM HH:mm').format(c.date)}',
                style: GoogleFonts.manrope(fontSize: 12, color: AppColors.muted),
              ),
            );
          }),
        ],
      ],
    );
  }
}

class _ProducerStockCard extends StatelessWidget {
  const _ProducerStockCard({required this.state, required this.producer});

  final AppState state;
  final Producer producer;

  @override
  Widget build(BuildContext context) {
    final items = state.stockFor(producer.id);
    final canConsume =
        (state.currentUser!.role == UserRole.produtor &&
            state.currentUser!.producerId == producer.id) ||
        state.currentUser!.role.canManageEcosystem;

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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producer.farm,
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      '${producer.name} · ${producer.groupName}',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) {
            final tone = item.isRupture
                ? PillTone.danger
                : item.isLow
                    ? PillTone.warning
                    : PillTone.success;
            final label = item.isRupture
                ? 'Rutura'
                : item.isLow
                    ? 'Baixo'
                    : 'OK';

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (item.quantity /
                                    (item.minThreshold * 4).clamp(1, 999999))
                                .clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: AppColors.surface,
                            color: item.isRupture
                                ? AppColors.danger
                                : item.isLow
                                    ? AppColors.warning
                                    : AppColors.moss,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.quantity.toStringAsFixed(0)} ${item.unit} · mín. ${item.minThreshold.toStringAsFixed(0)}',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  StatusPill(label: label, tone: tone),
                  if (canConsume) ...[
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      tooltip: 'Registar consumo',
                      onPressed: () => _consume(context, item),
                      icon: const Icon(Icons.remove_circle_outline, size: 18),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _consume(BuildContext context, StockItem item) async {
    final ctrl = TextEditingController(
      text: item.productId == 'ins-diesel' ? '800' : '10',
    );
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Consumo diário — ${item.productName}',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Quantidade (${item.unit})'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final qty =
                  double.tryParse(ctrl.text.replaceAll(',', '.')) ?? 0;
              state.registerConsumption(
                producerId: item.producerId,
                productId: item.productId,
                quantity: qty,
              );
              Navigator.pop(ctx);
            },
            child: const Text('Registar'),
          ),
        ],
      ),
    );
  }
}
