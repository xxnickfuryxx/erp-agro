import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class PurchasesScreen extends StatelessWidget {
  const PurchasesScreen({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final role = state.currentUser!.role;
    return ListView(
      children: [
        SectionHeader(
          title: role.canActAsSupplier && !role.canManageEcosystem
              ? 'Cotações e aprovação'
              : role.canManageEcosystem
                  ? 'Compras e lotes'
                  : 'Compras bifurcadas',
          subtitle:
              'Planeada (lote único) vs Direta (JIT) — faturação fora do ERP',
          action: role == UserRole.produtor
              ? Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _openNeedDialog(context),
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: const Text('Compra planeada'),
                    ),
                    FilledButton.icon(
                      onPressed: () => _openDirectPurchaseDialog(context),
                      icon: const Icon(Icons.flash_on),
                      label: const Text('Compra direta'),
                    ),
                  ],
                )
              : null,
        ),
        if (role == UserRole.produtor) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.goldSoft.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
            ),
            child: Text(
              'Compra direta: pedido imediato ao fornecedor, sem entrar no lote consolidado. '
              'A entrega é feita por transportadora terceirizada.',
              style: GoogleFonts.manrope(fontSize: 13, height: 1.4),
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (role == UserRole.produtor || role.canManageEcosystem) ...[
          _NeedsPanel(state: state),
          const SizedBox(height: 20),
        ],
        if (role == UserRole.produtor ||
            role.canManageEcosystem ||
            role.canActAsSupplier) ...[
          _DirectOrdersPanel(state: state),
          const SizedBox(height: 20),
        ],
        if (role.canManageEcosystem) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () {
                final lot = state.consolidatePlanned('ins-semente');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      lot == null
                          ? 'Sem necessidades planeadas de semente para consolidar.'
                          : 'Lote ${lot.code} consolidado.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.merge_type),
              label: const Text('Consolidar sementes (demo)'),
            ),
          ),
          const SizedBox(height: 16),
        ],
        _LotsPanel(state: state),
      ],
    );
  }

  Future<void> _openNeedDialog(BuildContext context) async {
    final producer = state.currentProducer;
    if (producer == null) return;

    String productId = 'ins-semente';
    String productName = 'Semente de Soja';
    String unit = 'sc';
    final qtyCtrl = TextEditingController(text: '50');

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              title: Text(
                'Compra planeada (lote único)',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
              ),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Esta necessidade entra na consolidação do ERP para cotação em volume.',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ProductDropdown(
                      products: state.products,
                      productId: productId,
                      onChanged: (id, name, u) {
                        setLocal(() {
                          productId = id;
                          productName = name;
                          unit = u;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: qtyCtrl,
                      keyboardType: TextInputType.number,
                      decoration:
                          InputDecoration(labelText: 'Quantidade ($unit)'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    final qty =
                        double.tryParse(qtyCtrl.text.replaceAll(',', '.')) ?? 0;
                    if (qty <= 0) return;
                    state.addNeed(
                      producerId: producer.id,
                      productId: productId,
                      productName: productName,
                      quantity: qty,
                      unit: unit,
                      mode: PurchaseMode.planeada,
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Enviar programação'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openDirectPurchaseDialog(BuildContext context) async {
    final producer = state.currentProducer;
    if (producer == null) return;

    String productId = 'ins-diesel';
    String productName = 'Gasóleo / Diesel';
    String unit = 'L';
    String? carrierId =
        state.activeCarriers.isNotEmpty ? state.activeCarriers.first.id : null;
    final qtyCtrl = TextEditingController(text: '2000');

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              title: Text(
                'Compra direta (Just-in-Time)',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
              ),
              content: SizedBox(
                width: 440,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ignora a consolidação. Pedido direto ao fornecedor com frete terceirizado.',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ProductDropdown(
                      products: state.products,
                      productId: productId,
                      onChanged: (id, name, u) {
                        setLocal(() {
                          productId = id;
                          productName = name;
                          unit = u;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: qtyCtrl,
                      keyboardType: TextInputType.number,
                      decoration:
                          InputDecoration(labelText: 'Quantidade ($unit)'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: carrierId,
                      decoration: const InputDecoration(
                        labelText: 'Transportadora terceirizada',
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
                FilledButton.icon(
                  onPressed: () {
                    final qty =
                        double.tryParse(qtyCtrl.text.replaceAll(',', '.')) ?? 0;
                    if (qty <= 0) return;
                    final order = state.placeDirectPurchase(
                      producerId: producer.id,
                      productId: productId,
                      productName: productName,
                      quantity: qty,
                      unit: unit,
                      carrierId: carrierId,
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Compra direta ${order.code} enviada ao fornecedor.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.flash_on),
                  label: const Text('Fazer compra direta'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ProductDropdown extends StatelessWidget {
  const _ProductDropdown({
    required this.products,
    required this.productId,
    required this.onChanged,
  });

  final List<CatalogProduct> products;
  final String productId;
  final void Function(String id, String name, String unit) onChanged;

  @override
  Widget build(BuildContext context) {
    final safeId = products.any((p) => p.id == productId)
        ? productId
        : (products.isNotEmpty ? products.first.id : null);

    return DropdownButtonFormField<String>(
      initialValue: safeId,
      decoration: const InputDecoration(labelText: 'Produto / Insumo'),
      items: [
        for (final p in products)
          DropdownMenuItem(
            value: p.id,
            child: Text('${p.name} (${p.unit})'),
          ),
      ],
      onChanged: (v) {
        if (v == null) return;
        final p = products.firstWhere((e) => e.id == v);
        onChanged(p.id, p.name, p.unit);
      },
    );
  }
}

class _NeedsPanel extends StatelessWidget {
  const _NeedsPanel({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final role = state.currentUser!.role;
    final lines = role == UserRole.produtor && state.currentProducer != null
        ? state.needsFor(state.currentProducer!.id)
        : state.needs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Necessidades enviadas',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 10),
        if (lines.isEmpty)
          const EmptyHint(message: 'Nenhuma necessidade registada.')
        else
          ...lines.map((n) {
            final farm = state.producerById(n.producerId)?.farm ?? n.producerId;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            n.productName,
                            style:
                                GoogleFonts.manrope(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '$farm · ${n.quantity.toStringAsFixed(0)} ${n.unit} · ${n.season}',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusPill(
                      label: n.mode == PurchaseMode.planeada
                          ? 'Planeada'
                          : 'Direta',
                      tone: n.mode == PurchaseMode.planeada
                          ? PillTone.info
                          : PillTone.gold,
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

class _DirectOrdersPanel extends StatelessWidget {
  const _DirectOrdersPanel({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final role = state.currentUser!.role;
    final orders = role == UserRole.produtor && state.currentProducer != null
        ? state.directPurchasesFor(state.currentProducer!.id)
        : state.directPurchases;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pedidos de compra direta',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 10),
        if (orders.isEmpty)
          const EmptyHint(
            message:
                'Nenhuma compra direta. O produtor usa o botão “Compra direta”.',
          )
        else
          ...orders.map((o) {
            final farm = state.producerById(o.producerId)?.farm ?? '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${o.code} · ${o.productName}',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        StatusPill(
                          label: o.status.name,
                          tone: PillTone.gold,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$farm · ${o.quantity.toStringAsFixed(0)} ${o.unit} · ${o.supplierName}'
                      '${o.carrierName != null ? ' · Frete: ${o.carrierName}' : ''}',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                    if (role.canActAsSupplier &&
                        o.status == DirectOrderStatus.enviado) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton(
                            onPressed: () => state.confirmDirectPurchase(o.id),
                            child: const Text('Confirmar pedido'),
                          ),
                          FilledButton(
                            onPressed: () => state.deliverDirectPurchase(o.id),
                            child: const Text('Marcar entregue'),
                          ),
                        ],
                      ),
                    ],
                    if (role.canActAsSupplier &&
                        o.status == DirectOrderStatus.confirmado) ...[
                      const SizedBox(height: 10),
                      FilledButton(
                        onPressed: () => state.deliverDirectPurchase(o.id),
                        child: const Text('Marcar entregue'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _LotsPanel extends StatelessWidget {
  const _LotsPanel({required this.state});

  final AppState state;

  PillTone _tone(LotStatus s) => switch (s) {
        LotStatus.concluido => PillTone.success,
        LotStatus.cotacao || LotStatus.consolidado => PillTone.warning,
        LotStatus.aprovado || LotStatus.faturado => PillTone.info,
        LotStatus.noArmazem || LotStatus.emDistribuicao => PillTone.gold,
        _ => PillTone.neutral,
      };

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final role = state.currentUser!.role;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lotes de compra planeada',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 10),
        if (state.lots.isEmpty)
          const EmptyHint(message: 'Sem lotes no pipeline.')
        else
          ...state.lots.map((lot) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
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
                            '${lot.code} · ${lot.productName}',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        StatusPill(
                          label: lot.status.label,
                          tone: _tone(lot.status),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Volume: ${lot.totalQuantity.toStringAsFixed(0)} ${lot.unit} · '
                      '${lot.participantIds.length} produtores · '
                      '${lot.supplierName ?? '—'}'
                      '${lot.quotedPricePerUnit != null ? ' · ${money.format(lot.quotedPricePerUnit)} / ${lot.unit}' : ''}',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (role.canManageEcosystem &&
                            (lot.status == LotStatus.consolidado ||
                                lot.status == LotStatus.programacao))
                          OutlinedButton(
                            onPressed: () => state.quoteLot(lot.id, 490),
                            child: const Text('Efetuar cotação'),
                          ),
                        if (role.canActAsSupplier &&
                            lot.status == LotStatus.cotacao)
                          FilledButton(
                            onPressed: () => state.approveLot(lot.id),
                            child: const Text('Aprovar venda'),
                          ),
                        if (role.canActAsSupplier &&
                            lot.status == LotStatus.aprovado) ...[
                          OutlinedButton(
                            onPressed: () => state.issueInvoice(lot.id),
                            child: const Text('Emitir faturação direta'),
                          ),
                          FilledButton(
                            onPressed: () => state.deliverToWarehouse(lot.id),
                            child: const Text('Entregar volume ao armazém'),
                          ),
                        ],
                        if (role.canActAsSupplier &&
                            lot.status == LotStatus.faturado)
                          FilledButton(
                            onPressed: () => state.deliverToWarehouse(lot.id),
                            child: const Text('Entregar volume ao armazém'),
                          ),
                        if (role.canManageEcosystem &&
                            lot.status == LotStatus.aprovado)
                          OutlinedButton(
                            onPressed: () => state.deliverToWarehouse(lot.id),
                            child: const Text('Rececionar no armazém'),
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
