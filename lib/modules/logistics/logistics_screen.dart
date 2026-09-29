import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';

class LogisticsScreen extends StatelessWidget {
  const LogisticsScreen({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final role = state.currentUser!.role;

    return ListView(
      children: [
        SectionHeader(
          title: role == UserRole.transportadora
              ? 'Gestão de fretes'
              : 'Distribuição e logística terceirizada',
          subtitle:
              'Cadastro de transportadoras · fretes de entrega e de empréstimo',
          action: role.canManageEcosystem
              ? FilledButton.icon(
                  onPressed: () => _openCarrierDialog(context),
                  icon: const Icon(Icons.add_business_outlined),
                  label: const Text('Cadastrar transportadora'),
                )
              : null,
        ),
        const SizedBox(height: 16),
        _CarriersPanel(state: state),
        const SizedBox(height: 24),
        if (role != UserRole.transportadora) ...[
          Text(
            'Armazém de retaguarda',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 10),
          if (state.warehouse.isEmpty)
            const EmptyHint(
              message:
                  'Sem carga no armazém. Aprove um lote e entregue o volume físico.',
            )
          else
            ...state.warehouse
                .map((batch) => _WarehouseCard(state: state, batch: batch)),
          const SizedBox(height: 24),
        ],
        Text(
          'Fretes terceirizados',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 10),
        if (state.shipments.isEmpty)
          const EmptyHint(message: 'Nenhum frete registado.')
        else
          ...state.shipments.map((s) {
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
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.forest.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        s.type == 'transferencia'
                            ? Icons.swap_horiz
                            : Icons.local_shipping_outlined,
                        color: AppColors.forest,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${s.productName} · ${s.quantity.toStringAsFixed(0)} ${s.unit}',
                            style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${s.origin} → ${s.destination}\n${s.carrierName}'
                            '${s.freightPayerName != null ? ' · Frete: ${s.freightPayerName}' : ''}',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: AppColors.muted,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        StatusPill(
                          label: s.status,
                          tone: s.type == 'transferencia'
                              ? PillTone.gold
                              : PillTone.info,
                        ),
                        if (s.status != 'Concluído' &&
                            (role.canManageEcosystem ||
                                role == UserRole.transportadora ||
                                role.isAdmin))
                          TextButton(
                            onPressed: () =>
                                state.advanceShipmentStatus(s.id),
                            child: const Text('Avançar status'),
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

  Future<void> _openCarrierDialog(BuildContext context) async {
    final name = TextEditingController();
    final cnpj = TextEditingController();
    final contact = TextEditingController();
    final region = TextEditingController(text: 'MT');
    final fleet = TextEditingController(text: '10');

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Cadastrar empresa de transporte',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Razão social'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cnpj,
                decoration: const InputDecoration(labelText: 'CNPJ'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contact,
                decoration: const InputDecoration(labelText: 'Contacto'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: region,
                decoration: const InputDecoration(labelText: 'Região de atuação'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: fleet,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Frota (veículos)'),
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
              if (name.text.trim().isEmpty) return;
              state.registerCarrier(
                name: name.text.trim(),
                cnpj: cnpj.text.trim().isEmpty ? '—' : cnpj.text.trim(),
                contact:
                    contact.text.trim().isEmpty ? '—' : contact.text.trim(),
                region: region.text.trim().isEmpty ? '—' : region.text.trim(),
                fleetSize: int.tryParse(fleet.text) ?? 1,
              );
              Navigator.pop(ctx);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

class _CarriersPanel extends StatelessWidget {
  const _CarriersPanel({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final role = state.currentUser!.role;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Empresas de transporte',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 10),
        if (state.carriers.isEmpty)
          const EmptyHint(message: 'Nenhuma transportadora cadastrada.')
        else
          ...state.carriers.map((c) {
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
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.forest.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_shipping_outlined,
                        color: AppColors.forest,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.name,
                            style:
                                GoogleFonts.manrope(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            '${c.cnpj} · ${c.region} · Frota ${c.fleetSize} · ${c.contact}',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusPill(
                      label: c.active ? 'Ativa' : 'Inativa',
                      tone: c.active ? PillTone.success : PillTone.neutral,
                    ),
                    if (role.canManageEcosystem) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: c.active ? 'Desativar' : 'Ativar',
                        onPressed: () => state.toggleCarrierActive(c.id),
                        icon: Icon(
                          c.active
                              ? Icons.toggle_on
                              : Icons.toggle_off_outlined,
                          color: c.active ? AppColors.success : AppColors.muted,
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

class _WarehouseCard extends StatelessWidget {
  const _WarehouseCard({required this.state, required this.batch});

  final AppState state;
  final WarehouseBatch batch;

  @override
  Widget build(BuildContext context) {
    final progress =
        batch.receivedQty == 0 ? 0.0 : batch.distributedQty / batch.receivedQty;
    final carriers = state.activeCarriers;

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
                    batch.productName,
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
                  ),
                ),
                StatusPill(
                  label:
                      '${batch.remaining.toStringAsFixed(0)} ${batch.unit} residual',
                  tone: PillTone.gold,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Recebido: ${batch.receivedQty.toStringAsFixed(0)} · Distribuído: ${batch.distributedQty.toStringAsFixed(0)} ${batch.unit}',
              style: GoogleFonts.manrope(fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 8,
                backgroundColor: AppColors.surface,
                color: AppColors.moss,
              ),
            ),
            if (state.currentUser!.role.canManageEcosystem &&
                batch.remaining > 0) ...[
              const SizedBox(height: 12),
              Text(
                'Distribuir via transportadora terceirizada',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 8),
              if (carriers.isEmpty)
                Text(
                  'Cadastre uma transportadora antes de distribuir.',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: AppColors.danger,
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final p in state.producers)
                      for (final carrier in carriers.take(1))
                        OutlinedButton.icon(
                          onPressed: () {
                            final qty =
                                (batch.remaining / 2).clamp(1, batch.remaining);
                            state.distributeFraction(
                              warehouseId: batch.id,
                              producerId: p.id,
                              qty: qty.toDouble(),
                              carrierId: carrier.id,
                            );
                          },
                          icon: const Icon(Icons.local_shipping_outlined, size: 16),
                          label: Text(
                            'JIT → ${p.farm.split(' ').last} (${carrier.name.split(' ').first})',
                          ),
                        ),
                    TextButton(
                      onPressed: () => _pickCarrierAndFarm(context),
                      child: const Text('Escolher transportadora…'),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickCarrierAndFarm(BuildContext context) async {
    String? carrierId =
        state.activeCarriers.isNotEmpty ? state.activeCarriers.first.id : null;
    String? producerId = state.producers.first.id;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              title: Text(
                'Distribuição terceirizada',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
              ),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: producerId,
                      decoration:
                          const InputDecoration(labelText: 'Fazenda destino'),
                      items: [
                        for (final p in state.producers)
                          DropdownMenuItem(
                            value: p.id,
                            child: Text(p.farm),
                          ),
                      ],
                      onChanged: (v) => setLocal(() => producerId = v),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: carrierId,
                      decoration: const InputDecoration(
                        labelText: 'Empresa de transporte',
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
                FilledButton(
                  onPressed: () {
                    if (carrierId == null || producerId == null) return;
                    final qty =
                        (batch.remaining / 2).clamp(1, batch.remaining);
                    state.distributeFraction(
                      warehouseId: batch.id,
                      producerId: producerId!,
                      qty: qty.toDouble(),
                      carrierId: carrierId!,
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Despachar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
