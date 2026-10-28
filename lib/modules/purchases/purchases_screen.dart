import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/purchase_economy.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key, required this.state});

  final AppState state;

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  AppState get state => widget.state;

  bool get _isSupplierOnly {
    final role = state.currentUser!.role;
    return role.canActAsSupplier && !role.canManageEcosystem;
  }

  @override
  void initState() {
    super.initState();
    final role = state.currentUser!.role;
    final len = _isSupplierOnly
        ? 1
        : role == UserRole.produtor
            ? 2
            : 2;
    _tabs = TabController(length: len, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role = state.currentUser!.role;
    final producerId =
        role == UserRole.produtor ? state.currentProducer?.id : null;

    if (_isSupplierOnly) {
      return ListView(
        children: [
          const SectionHeader(
            title: 'Cotações',
            subtitle: 'Lotes em cotação e aprovação',
          ),
          const SizedBox(height: 16),
          _LotsPanel(state: state),
          const SizedBox(height: 20),
          _SettlementsPanel(state: state),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Compras',
          subtitle: 'Pool de insumos → lote consolidado',
          action: FilledButton.icon(
            onPressed: () => showIncludeInPoolDialog(
              context,
              state: state,
              initialProducerId: producerId,
            ),
            icon: const Icon(Icons.add_shopping_cart_outlined),
            label: const Text('Incluir no pool'),
          ),
        ),
        const SizedBox(height: 10),
        const PoolHowToBanner(),
        const SizedBox(height: 8),
        TabBar(
          controller: _tabs,
          isScrollable: true,
          labelColor: AppColors.forest,
          unselectedLabelColor: AppColors.muted,
          indicatorColor: AppColors.forest,
          labelStyle: GoogleFonts.manrope(fontWeight: FontWeight.w800),
          tabs: [
            const Tab(text: 'Pool'),
            Tab(
              text: role == UserRole.produtor ? 'Urgente' : 'Lotes',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _PoolTab(state: state, producerId: producerId),
              if (role == UserRole.produtor)
                _UrgentTab(
                  state: state,
                  onDirect: () => _openDirectPurchaseDialog(context),
                )
              else
                _LotsTab(state: state),
            ],
          ),
        ),
      ],
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

class _PoolTab extends StatelessWidget {
  const _PoolTab({required this.state, this.producerId});

  final AppState state;
  final String? producerId;

  @override
  Widget build(BuildContext context) {
    final role = state.currentUser!.role;
    final ecoId = producerId ??
        (state.producers.isNotEmpty ? state.producers.first.id : null);

    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 24),
      children: [
        PurchasePoolPanel(
          state: state,
          producerId: producerId,
          onIncludeInPool: () => showIncludeInPoolDialog(
            context,
            state: state,
            initialProducerId: producerId,
          ),
        ),
        if (role.canManageEcosystem) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              onPressed: () {
                final lot = state.consolidateNextPlanned();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      lot == null
                          ? 'Nada para consolidar. Inclua itens no pool primeiro.'
                          : 'Lote ${lot.code} criado (${lot.productName}). Veja na aba Lotes.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.merge_type),
              label: const Text('Consolidar pool em lote'),
            ),
          ),
        ],
        const SizedBox(height: 16),
        _NeedsPanel(state: state),
        if (ecoId != null) ...[
          const SizedBox(height: 12),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(
              'Economia da safra (opcional)',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
            ),
            children: [
              CropEconomicsPanel(state: state, producerId: ecoId),
            ],
          ),
        ],
      ],
    );
  }
}

class _LotsTab extends StatelessWidget {
  const _LotsTab({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 24),
      children: [
        Text(
          'Lotes consolidados do pool — cotação, aprovação e liquidação.',
          style: GoogleFonts.manrope(fontSize: 12, color: AppColors.muted),
        ),
        const SizedBox(height: 12),
        _LotsPanel(state: state),
        const SizedBox(height: 20),
        _SettlementsPanel(state: state),
      ],
    );
  }
}

class _UrgentTab extends StatelessWidget {
  const _UrgentTab({required this.state, required this.onDirect});

  final AppState state;
  final VoidCallback onDirect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 24),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.goldSoft.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
          ),
          child: Text(
            'Compra urgente (JIT): fora do pool. Use só quando não puder esperar o lote.',
            style: GoogleFonts.manrope(fontSize: 13, height: 1.4),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: onDirect,
            icon: const Icon(Icons.flash_on),
            label: const Text('Nova compra urgente'),
          ),
        ),
        const SizedBox(height: 16),
        _DirectOrdersPanel(state: state),
      ],
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
          'Itens no pool',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 10),
        if (lines.isEmpty)
          const EmptyHint(
            message: 'Vazio. Toque em “Incluir no pool” no topo.',
          )
        else
          ...lines.map((n) {
            final farm = state.producerById(n.producerId)?.farm ?? n.producerId;
            final group =
                state.productById(n.productId)?.purchaseGroup.shortLabel ??
                    'Insumo';
            final rsHa = n.rsPerHa;
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
                            '$farm · $group · ${n.quantity.toStringAsFixed(0)} ${n.unit}'
                            '${n.unitPrice > 0 ? ' · R\$ ${n.unitPrice.toStringAsFixed(2)}/${n.unit}' : ''}'
                            '${rsHa != null ? ' · R\$ ${rsHa.toStringAsFixed(0)}/ha' : ''}'
                            ' · ${n.season}',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        StatusPill(
                          label: n.mode == PurchaseMode.planeada
                              ? 'Planeada'
                              : 'Direta',
                          tone: n.mode == PurchaseMode.planeada
                              ? PillTone.info
                              : PillTone.gold,
                        ),
                        StatusPill(
                          label: n.phase.label,
                          tone: n.phase == DealPhase.realizada
                              ? PillTone.success
                              : PillTone.warning,
                        ),
                        if (n.phase == DealPhase.negociacao &&
                            role.canManageEcosystem)
                          TextButton(
                            onPressed: () => state.markNeedRealized(n.id),
                            child: const Text('Marcar realizada'),
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
                      '${o.carrierName != null ? ' · Frete: ${o.carrierName}' : ''}'
                      '${o.isReplenishment ? ' · REPOSIÇÃO → ${state.producerById(o.stockDestinationProducerId ?? '')?.farm ?? 'doador'}' : ''}',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                    if (o.isReplenishment) ...[
                      const SizedBox(height: 6),
                      StatusPill(
                        label: 'OC ${o.replenishmentOrderId ?? '—'}',
                        tone: PillTone.gold,
                      ),
                    ],
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
                            child: Text(
                              o.isReplenishment
                                  ? 'Entregar ao doador'
                                  : 'Marcar entregue',
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (role.canActAsSupplier &&
                        o.status == DirectOrderStatus.confirmado) ...[
                      const SizedBox(height: 10),
                      FilledButton(
                        onPressed: () => state.deliverDirectPurchase(o.id),
                        child: Text(
                          o.isReplenishment
                              ? 'Entregar ao doador'
                              : 'Marcar entregue',
                        ),
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
        LotStatus.concluido || LotStatus.liquidado => PillTone.success,
        LotStatus.cotacao || LotStatus.consolidado => PillTone.warning,
        LotStatus.aprovado || LotStatus.faturado => PillTone.info,
        LotStatus.emTransito => PillTone.warning,
        LotStatus.noArmazem || LotStatus.emDistribuicao => PillTone.gold,
        _ => PillTone.neutral,
      };

  Future<void> _quoteDialog(BuildContext context, PurchaseLot lot) async {
    final ctrl = TextEditingController(
      text: (lot.quotedPricePerUnit ?? 490).toStringAsFixed(2),
    );
    final price = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Cotação — ${lot.code}',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Preço por ${lot.unit} (R\$)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final v = double.tryParse(ctrl.text.replaceAll(',', '.'));
              Navigator.pop(ctx, v);
            },
            child: const Text('Registar'),
          ),
        ],
      ),
    );
    if (price != null && price > 0) {
      state.quoteLot(lot.id, price);
    }
  }

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
                      '${lot.quotedPricePerUnit != null ? ' · ${money.format(lot.quotedPricePerUnit)} / ${lot.unit}' : ''}'
                      '${lot.settled ? ' · Liquidado' : ''}',
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
                            onPressed: () => _quoteDialog(context, lot),
                            child: const Text('Efetuar cotação'),
                          ),
                        if (role.canActAsSupplier &&
                            lot.status == LotStatus.cotacao)
                          FilledButton(
                            onPressed: () => state.approveLot(lot.id),
                            child: const Text('Aprovar venda'),
                          ),
                        if ((role.canActAsSupplier || role.canManageEcosystem) &&
                            lot.status == LotStatus.aprovado)
                          OutlinedButton(
                            onPressed: () => state.issueInvoice(lot.id),
                            child: const Text('Emitir faturação direta'),
                          ),
                        if ((role.canActAsSupplier || role.canManageEcosystem) &&
                            (lot.status == LotStatus.faturado ||
                                lot.status == LotStatus.aprovado) &&
                            !lot.settled)
                          FilledButton(
                            onPressed: () {
                              final s = state.settleLotFinancial(lot.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    s == null
                                        ? 'Não foi possível liquidar.'
                                        : 'Liquidado: ${money.format(s.totalAmount)}',
                                  ),
                                ),
                              );
                            },
                            child: const Text('Liquidar financeiramente'),
                          ),
                        if ((role.canActAsSupplier || role.canManageEcosystem) &&
                            (lot.status == LotStatus.faturado ||
                                lot.status == LotStatus.liquidado))
                          OutlinedButton(
                            onPressed: () =>
                                state.dispatchLotToWarehouse(lot.id),
                            child: const Text('Despachar (em trânsito)'),
                          ),
                        if (role.canManageEcosystem &&
                            lot.status == LotStatus.emTransito)
                          FilledButton(
                            onPressed: () =>
                                state.receiveLotAtWarehouse(lot.id),
                            child: const Text('Rececionar no armazém'),
                          ),
                        if (role.canManageEcosystem &&
                            (lot.status == LotStatus.aprovado ||
                                lot.status == LotStatus.faturado ||
                                lot.status == LotStatus.liquidado))
                          OutlinedButton(
                            onPressed: () => state.deliverToWarehouse(lot.id),
                            child: const Text('Atalho: receber no armazém'),
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

class _SettlementsPanel extends StatelessWidget {
  const _SettlementsPanel({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Liquidações financeiras (fornecedor ↔ produtores)',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          'O ERP apenas regista a liquidação — o pagamento ocorre fora da plataforma.',
          style: GoogleFonts.manrope(fontSize: 12, color: AppColors.muted),
        ),
        const SizedBox(height: 10),
        if (state.settlements.isEmpty)
          const EmptyHint(message: 'Nenhuma liquidação registada.')
        else
          ...state.settlements.map((s) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.line),
                ),
                leading: const Icon(Icons.account_balance_wallet_outlined,
                    color: AppColors.forest),
                title: Text(
                  s.lotCode,
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${s.participantIds.length} produtores · ${s.notes}',
                  style: GoogleFonts.manrope(fontSize: 12),
                ),
                trailing: Text(
                  money.format(s.totalAmount),
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800,
                    color: AppColors.forest,
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
