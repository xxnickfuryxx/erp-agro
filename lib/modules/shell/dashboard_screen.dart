import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';

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
            'Fluxo operacional (UML)',
            style: GoogleFonts.manrope(
              color: AppColors.goldSoft,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Programação → Lote → Cotação → Aprovação → Faturação → Liquidação → Trânsito → Armazém → JIT → Consumo → Rutura → Empréstimo → OC-REP → Taxa',
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FlowStepChip(index: 1, label: 'Necessidades', active: true),
              FlowStepChip(index: 2, label: 'Consolidação'),
              FlowStepChip(index: 3, label: 'Fornecedor'),
              FlowStepChip(index: 4, label: 'Liquidação'),
              FlowStepChip(index: 5, label: 'Armazém JIT'),
              FlowStepChip(index: 6, label: 'Empréstimo'),
              FlowStepChip(index: 7, label: 'Taxa'),
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
              '${p.farm} · ${p.groupName} · ${p.focus} · Porte ${p.productionSize.label} · ${p.hectares.toStringAsFixed(0)} ha · ${p.cadproCode}',
        ),
        const SizedBox(height: 16),
        _FlowBanner(),
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
            label: 'Necessidades',
            value: '$needs',
            icon: Icons.playlist_add_check_circle_outlined,
            subtitle: 'Planeadas e diretas',
          ),
          MetricCard(
            label: 'Taxa de gestão',
            value: '${p.managementFeeKg.toStringAsFixed(0)} kg',
            icon: Icons.grass,
            subtitle: 'Soja / ano (33 kg/ha)',
            accent: AppColors.gold,
          ),
          MetricCard(
            label: 'Empréstimos',
            value: '${state.transfers.where((t) => t.toProducerId == p.id || t.fromProducerId == p.id).length}',
            icon: Icons.swap_horiz,
            subtitle: 'Rede lateral',
          ),
        ]),
        const SizedBox(height: 24),
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
        state.producers.fold<double>(0, (a, p) => a + p.managementFeeKg);

    return ListView(
      children: [
        const SectionHeader(
          title: 'Painel do administrador',
          subtitle:
              'Acesso total: clientes, compras, logística, rede de trocas, stock e taxas',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.goldSoft.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
          ),
          child: Text(
            'Perfil com permissão completa sobre o ecossistema ERP Agro. '
            'Pode operar fluxos de gestora, fornecedor e monitorizar todos os produtores.',
            style: GoogleFonts.manrope(fontSize: 13, height: 1.4),
          ),
        ),
        const SizedBox(height: 16),
        _FlowBanner(),
        const SizedBox(height: 16),
        _DemoScenariosPanel(state: state),
        const SizedBox(height: 16),
        _metricsRow([
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
        state.producers.fold<double>(0, (a, p) => a + p.managementFeeKg);

    return ListView(
      children: [
        const SectionHeader(
          title: 'Central da gestora',
          subtitle: 'Orquestração de lotes, armazém de retaguarda e rede de empréstimos',
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
            label: 'Transportadoras',
            value: '${state.activeCarriers.length}',
            icon: Icons.local_shipping_outlined,
            subtitle: 'Logística terceirizada ativa',
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
            'Executa sequências prontas para demonstrar as fases: liquidação, reposição e taxa.',
            style: GoogleFonts.manrope(fontSize: 12, color: AppColors.muted),
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

