import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Cadastros explícitos: Clientes, Produtos e Grupos.
class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key, required this.state});

  final AppState state;

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  AppState get state => widget.state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Cadastros',
          subtitle:
              'Aqui você cria grupos, cadastra produtos e adiciona novos clientes (produtores)',
          action: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  _tabs.animateTo(2);
                  _openGroupDialog(context);
                },
                icon: const Icon(Icons.groups_outlined),
                label: const Text('Novo grupo'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  _tabs.animateTo(1);
                  _openProductDialog(context);
                },
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('Novo produto'),
              ),
              FilledButton.icon(
                onPressed: () {
                  _tabs.animateTo(0);
                  _openClientDialog(context);
                },
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Novo cliente'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.forest.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
          ),
          child: Text(
            'Ordem sugerida: 1) crie um Grupo de fazendeiros → 2) cadastre Produtos (diesel, soja…) → '
            '3) cadastre o Cliente e associe-o ao grupo. Trocas só funcionam entre membros do mesmo grupo.',
            style: GoogleFonts.manrope(fontSize: 13, height: 1.4),
          ),
        ),
        const SizedBox(height: 12),
        TabBar(
          controller: _tabs,
          labelColor: AppColors.forest,
          unselectedLabelColor: AppColors.muted,
          indicatorColor: AppColors.forest,
          labelStyle: GoogleFonts.manrope(fontWeight: FontWeight.w800),
          tabs: [
            Tab(text: 'Clientes (${state.producers.length})'),
            Tab(text: 'Produtos (${state.products.length})'),
            Tab(text: 'Grupos (${state.groups.length})'),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _ClientsTab(
                state: state,
                onAdd: () => _openClientDialog(context),
                onMoveGroup: (p) => _openMoveGroupDialog(context, p),
              ),
              _ProductsTab(
                state: state,
                onAdd: () => _openProductDialog(context),
              ),
              _GroupsTab(
                state: state,
                onAdd: () => _openGroupDialog(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openGroupDialog(BuildContext context) async {
    final name = TextEditingController();
    final region = TextEditingController(text: 'MT');
    final desc = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Criar novo grupo de fazendeiros',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Só produtores do mesmo grupo podem trocar produtos entre si.',
                style: GoogleFonts.manrope(fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: name,
                decoration: const InputDecoration(
                  labelText: 'Nome do grupo *',
                  hintText: 'Ex.: Grupo Cerrado Sul',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: region,
                decoration: const InputDecoration(
                  labelText: 'Região',
                  hintText: 'Ex.: MT / GO',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: desc,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                ),
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
              final g = state.createGroup(
                name: name.text,
                region: region.text,
                description: desc.text,
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Grupo “${g.name}” criado. Agora pode cadastrar clientes nele.')),
              );
            },
            child: const Text('Criar grupo'),
          ),
        ],
      ),
    );
  }

  Future<void> _openProductDialog(BuildContext context) async {
    final name = TextEditingController();
    final unit = TextEditingController(text: 'sc');
    final category = TextEditingController(text: 'Insumo');

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Cadastrar novo produto',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'O produto entra no catálogo de compras e de trocas entre produtores.',
                style: GoogleFonts.manrope(fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: name,
                decoration: const InputDecoration(
                  labelText: 'Nome do produto *',
                  hintText: 'Ex.: Herbicida Glifosato',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: unit,
                decoration: const InputDecoration(
                  labelText: 'Unidade *',
                  hintText: 'L, sc, t, un…',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: category,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  hintText: 'Insumo, Combustível, Grão…',
                ),
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
              if (name.text.trim().isEmpty || unit.text.trim().isEmpty) return;
              final p = state.registerProduct(
                name: name.text,
                unit: unit.text,
                category: category.text,
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Produto “${p.name}” cadastrado.')),
              );
            },
            child: const Text('Salvar produto'),
          ),
        ],
      ),
    );
  }

  Future<void> _openClientDialog(BuildContext context) async {
    if (state.groups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Crie um grupo primeiro (aba Grupos → Novo grupo).'),
        ),
      );
      _tabs.animateTo(2);
      return;
    }

    final name = TextEditingController();
    final farm = TextEditingController();
    final ha = TextEditingController(text: '300');
    ProductionType type = ProductionType.soja;
    ProductionSize size = ProductionSize.medio;
    String groupId = state.groups.first.id;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              title: Text(
                'Cadastrar novo cliente (produtor)',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
              ),
              content: SizedBox(
                width: 460,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Classifique por tipo, porte e hectares, e associe a um grupo.',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: name,
                        decoration: const InputDecoration(
                          labelText: 'Nome do produtor *',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: farm,
                        decoration: const InputDecoration(
                          labelText: 'Nome da fazenda *',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: ha,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Área (hectares) *',
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<ProductionType>(
                        initialValue: type,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de produção *',
                        ),
                        items: [
                          for (final t in ProductionType.values)
                            DropdownMenuItem(
                              value: t,
                              child: Text(t.label),
                            ),
                        ],
                        onChanged: (v) => setLocal(() => type = v!),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<ProductionSize>(
                        initialValue: size,
                        decoration: const InputDecoration(
                          labelText: 'Tamanho da produção *',
                        ),
                        items: [
                          for (final s in ProductionSize.values)
                            DropdownMenuItem(
                              value: s,
                              child: Text(s.label),
                            ),
                        ],
                        onChanged: (v) => setLocal(() => size = v!),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: groupId,
                        decoration: const InputDecoration(
                          labelText: 'Grupo de fazendeiros *',
                        ),
                        items: [
                          for (final g in state.groups)
                            DropdownMenuItem(
                              value: g.id,
                              child: Text('${g.name} (${g.region})'),
                            ),
                        ],
                        onChanged: (v) => setLocal(() => groupId = v!),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    final hectares =
                        double.tryParse(ha.text.replaceAll(',', '.')) ?? 0;
                    if (name.text.trim().isEmpty ||
                        farm.text.trim().isEmpty ||
                        hectares <= 0) {
                      return;
                    }
                    final client = state.registerClient(
                      name: name.text,
                      farm: farm.text,
                      hectares: hectares,
                      productionType: type,
                      productionSize: size,
                      groupId: groupId,
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Cliente “${client.name}” cadastrado no grupo ${client.groupName}.',
                        ),
                      ),
                    );
                  },
                  child: const Text('Salvar cliente'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openMoveGroupDialog(BuildContext context, Producer p) async {
    String groupId = p.groupId;
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              title: Text(
                'Mover ${p.farm} de grupo',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
              ),
              content: DropdownButtonFormField<String>(
                initialValue: groupId,
                decoration: const InputDecoration(labelText: 'Novo grupo'),
                items: [
                  for (final g in state.groups)
                    DropdownMenuItem(value: g.id, child: Text(g.name)),
                ],
                onChanged: (v) => setLocal(() => groupId = v!),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    state.moveClientToGroup(
                      producerId: p.id,
                      groupId: groupId,
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Atualizar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ClientsTab extends StatelessWidget {
  const _ClientsTab({
    required this.state,
    required this.onAdd,
    required this.onMoveGroup,
  });

  final AppState state;
  final VoidCallback onAdd;
  final void Function(Producer p) onMoveGroup;

  @override
  Widget build(BuildContext context) {
    final byType = <ProductionType, List<Producer>>{};
    for (final p in state.producers) {
      byType.putIfAbsent(p.productionType, () => []).add(p);
    }

    return ListView(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Cadastrar cliente'),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final type in ProductionType.values)
              StatusPill(
                label: '${type.shortLabel}: ${byType[type]?.length ?? 0}',
                tone: PillTone.gold,
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (state.producers.isEmpty)
          const EmptyHint(message: 'Nenhum cliente. Clique em “Cadastrar cliente”.')
        else
          ...state.producers.map((p) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.forest.withValues(alpha: 0.1),
                      child: Text(
                        p.name.substring(0, 1),
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w800,
                          color: AppColors.forest,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${p.farm} · Grupo: ${p.groupName}',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              StatusPill(
                                label: p.productionType.label,
                                tone: PillTone.gold,
                              ),
                              StatusPill(
                                label: 'Porte ${p.productionSize.label}',
                                tone: PillTone.info,
                              ),
                              StatusPill(
                                label: '${p.hectares.toStringAsFixed(0)} ha',
                                tone: PillTone.neutral,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => onMoveGroup(p),
                      child: const Text('Mudar grupo'),
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

class _ProductsTab extends StatelessWidget {
  const _ProductsTab({required this.state, required this.onAdd});

  final AppState state;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Cadastrar produto'),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Produtos disponíveis em compra planeada, compra direta e trocas.',
          style: GoogleFonts.manrope(fontSize: 12, color: AppColors.muted),
        ),
        const SizedBox(height: 12),
        if (state.products.isEmpty)
          const EmptyHint(message: 'Nenhum produto. Clique em “Cadastrar produto”.')
        else
          ...state.products.map((p) {
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
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.forest.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.forest,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Unidade: ${p.unit} · ${p.category}',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusPill(label: p.unit, tone: PillTone.info),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _GroupsTab extends StatelessWidget {
  const _GroupsTab({required this.state, required this.onAdd});

  final AppState state;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.groups_outlined),
            label: const Text('Criar grupo'),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Grupos definem quem pode trocar produtos (mesmo grupo = troca permitida).',
          style: GoogleFonts.manrope(fontSize: 12, color: AppColors.muted),
        ),
        const SizedBox(height: 12),
        if (state.groups.isEmpty)
          const EmptyHint(message: 'Nenhum grupo. Clique em “Criar grupo”.')
        else
          ...state.groups.map((g) {
            final members = state.producersInGroup(g.id);
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
                            g.name,
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        StatusPill(
                          label: '${members.length} membros',
                          tone: PillTone.success,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${g.region}${g.description.isEmpty ? '' : ' · ${g.description}'}',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                    if (members.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          for (final m in members)
                            StatusPill(
                              label:
                                  '${m.farm} · ${m.productionType.shortLabel}',
                              tone: PillTone.info,
                            ),
                        ],
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
