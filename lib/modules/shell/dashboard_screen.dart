import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/purchase_economy.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final user = state.currentUser!;
    return switch (user.role) {
      UserRole.admin => _AdminDashboard(state: state),
      UserRole.produtor => _ProducerDashboard(state: state),
      UserRole.gestora => _ManagerDashboard(state: state),
      UserRole.fornecedor => _SupplierDashboard(state: state),
      UserRole.transportadora => _CarrierDashboard(state: state),
    };
  }
}

class _FlowBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.forest, Color(0xFF2A5C4E)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Como usar (simples)',
            style: GoogleFonts.manrope(
              color: AppColors.goldSoft,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '1. CADPRO — cadastre fazenda e insumos\n'
            '2. Compras → Incluir no pool — diga o que precisa comprar\n'
            '3. Compras → Lotes — consolide e acompanhe a negociação',
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FlowStepChip(index: 1, label: 'CADPRO', active: true),
              FlowStepChip(index: 2, label: 'Pool'),
              FlowStepChip(index: 3, label: 'Lote'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityList extends StatelessWidget {
  const _ActivityList({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          for (var i = 0; i < state.activity.take(8).length; i++) ...[
            if (i > 0) const Divider(height: 1),
            ListTile(
              dense: true,
              leading: const Icon(Icons.bolt_outlined, color: AppColors.moss, size: 18),
              title: Text(
                state.activity[i],
                style: GoogleFonts.manrope(fontSize: 13, height: 1.35),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Widget _metricsRow(List<MetricCard> cards) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final cols = constraints.maxWidth > 900
          ? 4
          : constraints.maxWidth > 600
              ? 2
              : 1;
      return GridView.count(
        crossAxisCount: cols,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: cols == 1 ? 2.4 : 1.55,
        children: cards,
      );
    },
  );
}

class _ProducerDashboard extends StatelessWidget {
  const _ProducerDashboard({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final p = state.currentProducer!;
    final stock = state.stockFor(p.id);
    final ruptures = stock.where((s) => s.isRupture).length;
    final needs = state.needsFor(p.id).length;

    return ListView(
      children: [
        SectionHeader(
          title: 'Painel do produtor',
          subtitle:
              '${p.farm} · ${p.hectares.toStringAsFixed(0)} ha · ${p.cadproCode}',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.forest.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
          ),
          child: Text(
            'Para comprar insumos: abra Compras → Incluir no pool. '
            'Compra urgente só se não puder esperar o lote.',
            style: GoogleFonts.manrope(fontSize: 13, height: 1.4),
          ),
        ),
        const SizedBox(height: 16),
        _metricsRow([
          MetricCard(
            label: 'Itens em stock',
            value: '${stock.length}',
            icon: Icons.inventory_2_outlined,
            subtitle: ruptures > 0 ? '$ruptures em rutura' : 'Sem ruturas',
            accent: ruptures > 0 ? AppColors.danger : AppColors.success,
          ),
          MetricCard(
            label: 'No pool',
            value: '$needs',
            icon: Icons.playlist_add_check_circle_outlined,
            subtitle: 'Necessidades programadas',
          ),
          MetricCard(
            label: 'Pool R\$/ha',
            value:
                'R\$ ${state.poolAverageRsPerHa(producerId: p.id).toStringAsFixed(0)}',
            icon: Icons.analytics_outlined,
            subtitle:
                'Total R\$ ${state.poolTotalSpend(producerId: p.id).toStringAsFixed(0)}',
            accent: AppColors.gold,
          ),
          MetricCard(
            label: 'Taxa de gestão',
            value: '${state.managementFeeFor(p).toStringAsFixed(0)} kg',
            icon: Icons.grass,
            subtitle: state.feeConfig.formulaLabel,
            accent: AppColors.gold,
          ),
        ]),
        const SizedBox(height: 12),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(
            'Economia da safra',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
          ),
          children: [
            CropEconomicsPanel(state: state, producerId: p.id),
          ],
        ),
        const SizedBox(height: 16),
        const SectionHeader(title: 'Atividade recente'),
        const SizedBox(height: 12),
        _ActivityList(state: state),
      ],
    );
  }
}

class _AdminDashboard extends StatelessWidget {
  const _AdminDashboard({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final feeTotal =
        state.producers.fold<double>(0, (a, p) => a + state.managementFeeFor(p));

    return ListView(
      children: [
        const SectionHeader(
          title: 'Painel do administrador',
          subtitle: 'Comece pelo guia abaixo · depois use Compras → Pool',
        ),
        const SizedBox(height: 16),
        _FlowBanner(),
        const SizedBox(height: 16),
        _DemoScenariosPanel(state: state),
        const SizedBox(height: 16),
        _metricsRow([
          MetricCard(
            label: 'Pool (total)',
            value:
                'R\$ ${state.poolTotalSpend().toStringAsFixed(0)}',
            icon: Icons.shopping_bag_outlined,
            subtitle:
                'Média R\$ ${state.poolAverageRsPerHa().toStringAsFixed(0)}/ha',
            accent: AppColors.gold,
          ),
          MetricCard(
            label: 'Utilizadores demo',
            value: '${state.users.length}',
            icon: Icons.admin_panel_settings_outlined,
            subtitle: 'Perfis no sistema',
            accent: AppColors.gold,
          ),
          MetricCard(
            label: 'Clientes',
            value: '${state.producers.length}',
            icon: Icons.people_outline,
            subtitle: 'Multi-produção por fazenda',
            accent: AppColors.info,
          ),
          MetricCard(
            label: 'Transportadoras',
            value: '${state.activeCarriers.length}',
            icon: Icons.local_shipping_outlined,
            subtitle: 'Ativas',
          ),
          MetricCard(
            label: 'Taxa consolidada',
            value: '${feeTotal.toStringAsFixed(0)} kg',
            icon: Icons.payments_outlined,
            subtitle: 'Soja / ano',
            accent: AppColors.gold,
          ),
        ]),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Atividade do sistema'),
        const SizedBox(height: 12),
        _ActivityList(state: state),
      ],
    );
  }
}

class _ManagerDashboard extends StatelessWidget {
  const _ManagerDashboard({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final feeTotal =
        state.producers.fold<double>(0, (a, p) => a + state.managementFeeFor(p));

    return ListView(
      children: [
        const SectionHeader(
          title: 'Central da gestora',
          subtitle: 'CADPRO → Compras (pool) → Lotes → Logística',
        ),
        const SizedBox(height: 16),
        _FlowBanner(),
        const SizedBox(height: 16),
        _DemoScenariosPanel(state: state),
        const SizedBox(height: 16),
        _metricsRow([
          MetricCard(
            label: 'Clientes',
            value: '${state.producers.length}',
            icon: Icons.people_outline,
            subtitle:
                'CADPRO · multi-foco (ha por tipo)',
            accent: AppColors.info,
          ),
          MetricCard(
            label: 'Pool R\$/ha',
            value: 'R\$ ${state.poolAverageRsPerHa().toStringAsFixed(0)}',
            icon: Icons.analytics_outlined,
            subtitle: 'Total R\$ ${state.poolTotalSpend().toStringAsFixed(0)}',
            accent: AppColors.gold,
          ),
          MetricCard(
            label: 'Ruturas monitorizadas',
            value: '${state.ruptures.length}',
            icon: Icons.warning_amber_rounded,
            accent: state.ruptures.isEmpty ? AppColors.success : AppColors.danger,
          ),
          MetricCard(
            label: 'Taxa consolidada',
            value: '${feeTotal.toStringAsFixed(0)} kg',
            icon: Icons.payments_outlined,
            subtitle: 'Soja equivalente / ano',
            accent: AppColors.gold,
          ),
        ]),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Feed do ecossistema'),
        const SizedBox(height: 12),
        _ActivityList(state: state),
      ],
    );
  }
}

class _SupplierDashboard extends StatelessWidget {
  const _SupplierDashboard({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final pending = state.lots
        .where((l) =>
            l.status == LotStatus.cotacao || l.status == LotStatus.consolidado)
        .length;

    return ListView(
      children: [
        const SectionHeader(
          title: 'Portal do fornecedor',
          subtitle: 'Aprovar vendas, emitir faturação direta e despachar volume físico',
        ),
        const SizedBox(height: 16),
        _metricsRow([
          MetricCard(
            label: 'Cotações pendentes',
            value: '$pending',
            icon: Icons.request_quote_outlined,
            accent: AppColors.warning,
          ),
          MetricCard(
            label: 'Lotes no pipeline',
            value: '${state.lots.length}',
            icon: Icons.handshake_outlined,
          ),
          MetricCard(
            label: 'Modelo financeiro',
            value: 'Direto',
            icon: Icons.receipt_long_outlined,
            subtitle: 'Fornecedor ↔ Produtor',
            accent: AppColors.info,
          ),
          MetricCard(
            label: 'ERP',
            value: 'Lógico',
            icon: Icons.hub_outlined,
            subtitle: 'Sem intermediação financeira',
          ),
        ]),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Atividade'),
        const SizedBox(height: 12),
        _ActivityList(state: state),
      ],
    );
  }
}

class _CarrierDashboard extends StatelessWidget {
  const _CarrierDashboard({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final deliveries =
        state.shipments.where((s) => s.type == 'entrega').length;
    final transfers =
        state.shipments.where((s) => s.type == 'transferencia').length;

    return ListView(
      children: [
        const SectionHeader(
          title: 'Operações logísticas',
          subtitle: 'Fretes de distribuição JIT e transferências de empréstimo',
        ),
        const SizedBox(height: 16),
        _metricsRow([
          MetricCard(
            label: 'Entregas',
            value: '$deliveries',
            icon: Icons.local_shipping_outlined,
          ),
          MetricCard(
            label: 'Transferências',
            value: '$transfers',
            icon: Icons.swap_horiz,
            accent: AppColors.gold,
          ),
          MetricCard(
            label: 'Em curso',
            value: '${state.shipments.where((s) => s.status == 'Em rota' || s.status == 'Agendado').length}',
            icon: Icons.route_outlined,
          ),
          MetricCard(
            label: 'Parceiro',
            value: 'Ativo',
            icon: Icons.verified_outlined,
            subtitle: 'TransCampo Logística',
            accent: AppColors.success,
          ),
        ]),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Atividade'),
        const SizedBox(height: 12),
        _ActivityList(state: state),
      ],
    );
  }
}

class _DemoScenariosPanel extends StatelessWidget {
  const _DemoScenariosPanel({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
            'Cenários mock (UML)',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            'Executa sequências prontas. Use “Reset demo” para restaurar os dados seed.',
            style: GoogleFonts.manrope(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () {
                state.resetDemo();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Demo reiniciada.')),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reset demo'),
            ),
          ),
          const SizedBox(height: 14),
          ...DemoScenarioId.values.map((id) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          id.title,
                          style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          id.description,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: AppColors.muted,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () {
                      final msg = state.runDemoScenario(id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(msg)),
                      );
                    },
                    child: const Text('Correr'),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

