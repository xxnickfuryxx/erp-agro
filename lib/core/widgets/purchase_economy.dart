import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'common.dart';

final _money = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');

/// Fluxo curto em 3 passos (catálogo → pool → lote).
class PoolHowToBanner extends StatelessWidget {
  const PoolHowToBanner({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final steps = compact
        ? const [
            ('1', 'Catálogo', 'CADPRO → Insumos'),
            ('2', 'Pool', 'Incluir quantidade'),
          ]
        : const [
            ('1', 'Catálogo', 'Cadastrar insumo'),
            ('2', 'Pool', 'Incluir no pool'),
            ('3', 'Lote', 'Consolidar compra'),
          ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.forest.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0)
              Icon(Icons.arrow_forward, size: 14, color: AppColors.muted),
            _StepChip(
              index: steps[i].$1,
              title: steps[i].$2,
              subtitle: steps[i].$3,
            ),
          ],
        ],
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({
    required this.index,
    required this.title,
    required this.subtitle,
  });

  final String index;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: AppColors.forest,
            child: Text(
              index,
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.manrope(fontSize: 10, color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Diálogo para incluir um produto do catálogo no pool (necessidade planeada).
Future<bool> showIncludeInPoolDialog(
  BuildContext context, {
  required AppState state,
  String? initialProductId,
  String? initialProducerId,
}) async {
  if (state.products.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Cadastre um produto em CADPRO → Insumos antes de incluir no pool.',
        ),
      ),
    );
    return false;
  }
  if (state.producers.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cadastre um CADPRO (produtor) primeiro.')),
    );
    return false;
  }

  final role = state.currentUser?.role;
  final lockProducer = role == UserRole.produtor;
  var producerId = initialProducerId ??
      state.currentProducer?.id ??
      state.producers.first.id;
  if (lockProducer && state.currentProducer != null) {
    producerId = state.currentProducer!.id;
  }

  var productId = initialProductId ?? state.products.first.id;
  if (!state.products.any((p) => p.id == productId)) {
    productId = state.products.first.id;
  }
  var product = state.productById(productId)!;
  final qtyCtrl = TextEditingController(
    text: product.dosePerHa > 0 ? (product.dosePerHa * 100).toStringAsFixed(0) : '50',
  );

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setLocal) {
          return AlertDialog(
            title: Text(
              'Incluir no pool',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
            ),
            content: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Isto cria uma necessidade de compra planeada. '
                    'O produto passa a contar no pool (R\$/ha) e pode ser consolidado em lote.',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: AppColors.muted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (!lockProducer) ...[
                    DropdownButtonFormField<String>(
                      initialValue: producerId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Fazenda / produtor',
                      ),
                      items: [
                        for (final p in state.producers)
                          DropdownMenuItem(
                            value: p.id,
                            child: Text('${p.farm} (${p.cadproCode})'),
                          ),
                      ],
                      onChanged: (v) {
                        if (v != null) setLocal(() => producerId = v);
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  DropdownButtonFormField<String>(
                    initialValue: productId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Produto do catálogo',
                    ),
                    items: [
                      for (final p in state.products)
                        DropdownMenuItem(
                          value: p.id,
                          child: Text(
                            '${p.name} · ${p.purchaseGroup.shortLabel} (${p.unit})',
                          ),
                        ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setLocal(() {
                        productId = v;
                        product = state.productById(v)!;
                        qtyCtrl.text = product.dosePerHa > 0
                            ? (product.dosePerHa * 100).toStringAsFixed(0)
                            : '50';
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Grupo: ${product.purchaseGroup.label}'
                    '${product.refPriceReais > 0 ? ' · ref. R\$ ${product.refPriceReais.toStringAsFixed(2)}/${product.unit}' : ''}',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Quantidade (${product.unit})',
                      helperText:
                          'Quantidade que esta fazenda precisa — entra em negociação no pool.',
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
              FilledButton.icon(
                onPressed: () {
                  final qty =
                      double.tryParse(qtyCtrl.text.replaceAll(',', '.')) ?? 0;
                  if (qty <= 0) return;
                  state.addNeed(
                    producerId: producerId,
                    productId: product.id,
                    productName: product.name,
                    quantity: qty,
                    unit: product.unit,
                    mode: PurchaseMode.planeada,
                    phase: DealPhase.negociacao,
                  );
                  Navigator.pop(ctx, true);
                },
                icon: const Icon(Icons.add_shopping_cart_outlined),
                label: const Text('Incluir no pool'),
              ),
            ],
          );
        },
      );
    },
  );

  if (ok == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '“${product.name}” incluído no pool (em negociação). Veja em Compras.',
        ),
      ),
    );
  }
  return ok == true;
}

/// Painel do pool de compras com indicadores R$/ha por grupo (frente 1).
class PurchasePoolPanel extends StatelessWidget {
  const PurchasePoolPanel({
    super.key,
    required this.state,
    this.producerId,
    this.onIncludeInPool,
  });

  final AppState state;
  final String? producerId;
  final VoidCallback? onIncludeInPool;

  @override
  Widget build(BuildContext context) {
    final all = state.purchasePoolIndicators(producerId: producerId);
    final nego = state.purchasePoolIndicators(
      producerId: producerId,
      phase: DealPhase.negociacao,
    );
    final real = state.purchasePoolIndicators(
      producerId: producerId,
      phase: DealPhase.realizada,
    );
    final total = state.poolTotalSpend(producerId: producerId);
    final avgHa = state.poolAverageRsPerHa(producerId: producerId);
    final negoSpend = state.poolTotalSpend(
      producerId: producerId,
      phase: DealPhase.negociacao,
    );
    final realSpend = state.poolTotalSpend(
      producerId: producerId,
      phase: DealPhase.realizada,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Resumo do pool',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
            if (onIncludeInPool != null)
              TextButton.icon(
                onPressed: onIncludeInPool,
                icon: const Icon(Icons.add_shopping_cart_outlined, size: 18),
                label: const Text('Incluir'),
              ),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, c) {
            final cards = [
              MetricCard(
                label: 'Investimento no pool',
                value: _money.format(total),
                icon: Icons.shopping_bag_outlined,
                subtitle: '${all.length} grupo(s) com movimento',
                accent: AppColors.forest,
              ),
              MetricCard(
                label: 'Média R\$/ha',
                value: _money.format(avgHa),
                icon: Icons.straighten,
                subtitle: 'Custo de insumos por hectare',
                accent: AppColors.gold,
              ),
              MetricCard(
                label: 'Em negociação',
                value: _money.format(negoSpend),
                icon: Icons.handshake_outlined,
                subtitle: '${nego.fold<int>(0, (s, g) => s + g.linesInNegotiation)} linha(s)',
                accent: AppColors.info,
              ),
              MetricCard(
                label: 'Compras realizadas',
                value: _money.format(realSpend),
                icon: Icons.verified_outlined,
                subtitle: '${real.fold<int>(0, (s, g) => s + g.linesRealized)} linha(s)',
                accent: AppColors.success,
              ),
            ];
            if (c.maxWidth < 600) {
              return Column(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    cards[i],
                  ],
                ],
              );
            }
            return GridView.count(
              crossAxisCount: c.maxWidth > 900 ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.55,
              children: cards,
            );
          },
        ),
        const SizedBox(height: 14),
        if (all.isEmpty)
          const EmptyHint(
            message: 'Sem necessidades no pool. Programe uma compra planeada.',
          )
        else
          ...all.map((g) => _GroupRow(stat: g)),
      ],
    );
  }
}

class _GroupRow extends StatelessWidget {
  const _GroupRow({required this.stat});

  final PurchaseGroupStat stat;

  @override
  Widget build(BuildContext context) {
    final ton = stat.rsPerTon;
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
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat.group.label,
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${stat.group.primaryKpi} · '
                    '${stat.linesInNegotiation} neg. · ${stat.linesRealized} realiz.',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Text(
                _money.format(stat.totalSpend),
                textAlign: TextAlign.right,
                style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_money.format(stat.rsPerHa)}/ha',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w800,
                      color: AppColors.forest,
                      fontSize: 13,
                    ),
                  ),
                  if (ton != null)
                    Text(
                      '${_money.format(ton)}/t',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Prévia frentes 2–3: custo da safra vs cotação e margem projetada.
class CropEconomicsPanel extends StatelessWidget {
  const CropEconomicsPanel({
    super.key,
    required this.state,
    required this.producerId,
  });

  final AppState state;
  final String producerId;

  @override
  Widget build(BuildContext context) {
    final snap = state.cropEconomicsFor(producerId);
    if (snap == null) {
      return const EmptyHint(message: 'Sem dados económicos para esta fazenda.');
    }

    final good = snap.projectedMarginPerHa > 0;

    return Container(
      width: double.infinity,
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
            'Gestão económica · ${snap.culture}',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Prévia das frentes 2 e 3 — custo de insumos, ponto de equilíbrio e margem '
            'vs cotação de mercado (${snap.hectares.toStringAsFixed(0)} ha).',
            style: GoogleFonts.manrope(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _EcoChip(
                label: 'Custo insumos',
                value: '${_money.format(snap.inputCostPerHa)}/ha',
              ),
              _EcoChip(
                label: 'Custo / saca',
                value: _money.format(snap.costPerSc),
              ),
              _EcoChip(
                label: 'Equilíbrio',
                value: '${snap.breakEvenScHa.toStringAsFixed(1)} sc/ha',
              ),
              _EcoChip(
                label: 'Cotação',
                value: '${_money.format(snap.marketPricePerSc)}/sc',
              ),
              _EcoChip(
                label: 'Margem proj.',
                value: '${_money.format(snap.projectedMarginPerHa)}/ha',
                highlight: good,
              ),
              _EcoChip(
                label: 'Retorno / custo',
                value: '${snap.returnOnCostPct.toStringAsFixed(0)}%',
                highlight: good,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            good
                ? 'Com produtividade assumida de ${snap.assumedYieldScHa.toStringAsFixed(0)} sc/ha '
                    'e preço de hoje, sobram ~${snap.surplusScHa.toStringAsFixed(1)} sc/ha acima do equilíbrio.'
                : 'No cenário atual o preço de mercado não cobre o custo de insumos — renegocie o pool ou revise a dose.',
            style: GoogleFonts.manrope(
              fontSize: 13,
              height: 1.4,
              color: good ? AppColors.forest : AppColors.danger,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EcoChip extends StatelessWidget {
  const _EcoChip({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.success.withValues(alpha: 0.08)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight
              ? AppColors.success.withValues(alpha: 0.35)
              : AppColors.line,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(fontSize: 11, color: AppColors.muted),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: highlight ? AppColors.success : AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
