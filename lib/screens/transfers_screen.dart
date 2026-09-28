import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class TransfersScreen extends StatelessWidget {
  const TransfersScreen({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final ruptures = state.ruptures;
    final role = state.currentUser!.role;

    return ListView(
      children: [
        SectionHeader(
          title: 'Trocas e empréstimos entre produtores',
          subtitle:
              'Só no mesmo grupo de fazendeiros · produtos como soja e diesel · frete pago por quem pediu',
          action: role.canManageEcosystem || role == UserRole.produtor
              ? Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _openExchangeDialog(context),
                      icon: const Icon(Icons.swap_horiz),
                      label: const Text('Pedir troca'),
                    ),
                    FilledButton.icon(
                      onPressed: () => _runMatching(context),
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Matching'),
                    ),
                  ],
                )
              : null,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Regra da reunião',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                '• Troca de produto (soja, diesel, etc.) só é permitida se os dois produtores '
                'estiverem no mesmo grupo de fazendeiros.\n'
                '• Quem pediu emprestado paga o frete da transferência.\n'
                '• O transporte é feito por empresa terceirizada cadastrada.',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _GroupsOverview(state: state),
        const SizedBox(height: 20),
        Text(
          'Ruturas ativas',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 10),
        if (ruptures.isEmpty)
          const EmptyHint(
            message:
                'Nenhuma rutura no momento. Simule consumo no Stock ou use matching.',
          )
        else
          ...ruptures.map((r) {
            final farm = state.producerById(r.producerId)?.farm ?? '';
            final group = state.producerById(r.producerId)?.groupName ?? '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                tileColor: AppColors.danger.withValues(alpha: 0.06),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: AppColors.danger.withValues(alpha: 0.2),
                  ),
                ),
                leading: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.danger,
                ),
                title: Text(
                  '${r.productName} · $farm',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '$group · Disponível: ${r.quantity.toStringAsFixed(0)} ${r.unit}',
                  style: GoogleFonts.manrope(fontSize: 12),
                ),
                trailing: role == UserRole.transportadora && !role.isAdmin
                    ? null
                    : FilledButton(
                        onPressed: () {
                          final needed = (r.minThreshold * 2 - r.quantity)
                              .clamp(100, 5000);
                          final result = state.attemptSmartLoan(
                            deficitProducerId: r.producerId,
                            productId: r.productId,
                            quantity: needed.toDouble(),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result == null
                                    ? 'Sem doador elegível no mesmo grupo.'
                                    : result.status == TransferStatus.bloqueado
                                        ? result.blockReason!
                                        : 'Troca ok. Frete ${money.format(result.freightCost)} pago pelo solicitante.',
                              ),
                            ),
                          );
                        },
                        child: const Text('Resolver'),
                      ),
              ),
            );
          }),
        const SizedBox(height: 24),
        Text(
          'Histórico de trocas',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 10),
        if (state.transfers.isEmpty)
          const EmptyHint(message: 'Ainda não há trocas / empréstimos.')
        else
          ...state.transfers.map((t) {
            final from = state.producerById(t.fromProducerId);
            final to = state.producerById(t.toProducerId);
            final payer = state.producerById(t.freightPayerId);
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
                          child: Text(
                            '${from?.farm ?? '—'} → ${to?.farm ?? '—'}',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        StatusPill(
                          label: t.sameGroup ? 'Mesmo grupo' : 'Bloqueado',
                          tone: t.sameGroup ? PillTone.success : PillTone.danger,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${t.quantity.toStringAsFixed(0)} ${t.unit} de ${t.productName}',
                      style: GoogleFonts.manrope(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.sameGroup
                          ? 'Frete ${money.format(t.freightCost)} pago por ${payer?.name} (quem pediu)\n'
                              'Transportadora: ${t.carrierName ?? '—'} · Reposição: ${t.replenishmentOrderId}'
                          : (t.blockReason ?? 'Grupos diferentes'),
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.muted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Future<void> _openExchangeDialog(BuildContext context) async {
    final money = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final me = state.currentProducer;
    final requesterId = me?.id ?? state.producers.first.id;
    final myGroup = state.producerById(requesterId)!.groupId;

    String productId = 'ins-diesel';
    String? donorId;
    String? carrierId =
        state.activeCarriers.isNotEmpty ? state.activeCarriers.first.id : null;
    final qtyCtrl = TextEditingController(text: '500');

    final sameGroupPeers = state.producers
        .where((p) => p.groupId == myGroup && p.id != requesterId)
        .toList();
    final otherGroupPeers = state.producers
        .where((p) => p.groupId != myGroup)
        .toList();

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              title: Text(
                'Pedir troca / empréstimo',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
              ),
              content: SizedBox(
                width: 460,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Solicitante: ${state.producerById(requesterId)?.farm} '
                      '(${state.producerById(requesterId)?.groupName})',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: productId,
                      decoration: const InputDecoration(labelText: 'Produto'),
                      items: [
                        for (final p in state.exchangeableProducts)
                          DropdownMenuItem(
                            value: p.id,
                            child: Text('${p.name} (${p.unit})'),
                          ),
                      ],
                      onChanged: (v) => setLocal(() => productId = v!),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: qtyCtrl,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Quantidade'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: donorId,
                      decoration: const InputDecoration(
                        labelText: 'Doador (mesmo grupo)',
                      ),
                      items: [
                        for (final p in sameGroupPeers)
                          DropdownMenuItem(
                            value: p.id,
                            child: Text('${p.farm} · ${p.productionType.shortLabel}'),
                          ),
                      ],
                      onChanged: (v) => setLocal(() => donorId = v),
                    ),
                    if (otherGroupPeers.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Fora do grupo (bloqueados): ${otherGroupPeers.map((p) => p.farm).join(', ')}',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: carrierId,
                      decoration: const InputDecoration(
                        labelText: 'Transportadora (frete do solicitante)',
                      ),
                      items: [
                        for (final c in state.activeCarriers)
                          DropdownMenuItem(value: c.id, child: Text(c.name)),
                      ],
                      onChanged: (v) => setLocal(() => carrierId = v),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                if (otherGroupPeers.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      final blocked = otherGroupPeers.first;
                      final qty = double.tryParse(
                            qtyCtrl.text.replaceAll(',', '.'),
                          ) ??
                          0;
                      final result = state.attemptSmartLoan(
                        deficitProducerId: requesterId,
                        productId: productId,
                        quantity: qty <= 0 ? 100 : qty,
                        preferredDonorId: blocked.id,
                        carrierId: carrierId,
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result?.blockReason ??
                                'Troca bloqueada entre grupos diferentes.',
                          ),
                          backgroundColor: AppColors.danger,
                        ),
                      );
                    },
                    child: const Text('Testar grupo diferente'),
                  ),
                FilledButton(
                  onPressed: () {
                    if (donorId == null) return;
                    final qty = double.tryParse(
                          qtyCtrl.text.replaceAll(',', '.'),
                        ) ??
                        0;
                    if (qty <= 0) return;
                    final result = state.attemptSmartLoan(
                      deficitProducerId: requesterId,
                      productId: productId,
                      quantity: qty,
                      preferredDonorId: donorId,
                      carrierId: carrierId,
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          result == null
                              ? 'Sem stock suficiente no doador.'
                              : result.status == TransferStatus.bloqueado
                                  ? result.blockReason!
                                  : 'Troca concluída. Frete ${money.format(result.freightCost)} a cargo do solicitante.',
                        ),
                      ),
                    );
                  },
                  child: const Text('Solicitar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _runMatching(BuildContext context) {
    final money = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    StockItem? dieselB;
    for (final s in state.stock) {
      if (s.producerId == 'p-b' && s.productId == 'ins-diesel') {
        dieselB = s;
        break;
      }
    }
    if (dieselB == null) return;

    if (!dieselB.isRupture) {
      state.simulateRuptureDemo();
    }

    final needed =
        (dieselB.minThreshold * 2 - dieselB.quantity).clamp(1500, 5000);
    final result = state.attemptSmartLoan(
      deficitProducerId: 'p-b',
      productId: 'ins-diesel',
      quantity: needed.toDouble(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result == null
              ? 'Matching sem resultado no mesmo grupo.'
              : 'Demo: ${result.quantity.toStringAsFixed(0)} L. Frete ${money.format(result.freightCost)} pago por Ana (solicitante).',
        ),
      ),
    );
  }
}

class _GroupsOverview extends StatelessWidget {
  const _GroupsOverview({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Grupos de fazendeiros',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 10),
        if (state.groups.isEmpty)
          const EmptyHint(
            message: 'Nenhum grupo. Crie em Cadastros → aba Grupos.',
          )
        else
          ...state.groups.map((g) {
            final members = state.producersInGroup(g.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      g.name,
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        for (final p in members)
                          StatusPill(
                            label:
                                '${p.farm} · ${p.productionType.shortLabel} · ${p.hectares.toStringAsFixed(0)} ha',
                            tone: PillTone.info,
                          ),
                        if (members.isEmpty)
                          const StatusPill(
                            label: 'Sem membros ainda',
                            tone: PillTone.neutral,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
