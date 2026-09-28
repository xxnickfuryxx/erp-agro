import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';

/// Módulo CADPRO — Cadastro do Produtor Rural, tipos de produção, produtos e grupos.
class ProducerScreen extends StatefulWidget {
  const ProducerScreen({super.key, required this.state});

  final AppState state;

  @override
  State<ProducerScreen> createState() => _ProducerScreenState();
}

class _ProducerScreenState extends State<ProducerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
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
          title: 'Módulo CADPRO',
          subtitle:
              'Cadastro do produtor rural · tipos de produção dinâmicos · produtos · grupos',
          action: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  _tabs.animateTo(3);
                  _openGroupDialog(context);
                },
                icon: const Icon(Icons.groups_outlined),
                label: const Text('Novo grupo'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  _tabs.animateTo(1);
                  _openProductionTypeDialog(context);
                },
                icon: const Icon(Icons.category_outlined),
                label: const Text('Novo tipo'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  _tabs.animateTo(2);
                  _openProductDialog(context);
                },
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('Novo produto'),
              ),
              FilledButton.icon(
                onPressed: () {
                  _tabs.animateTo(0);
                  _openCadproDialog(context);
                },
                icon: const Icon(Icons.badge_outlined),
                label: const Text('Novo CADPRO'),
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
            '1) Cadastre tipos de produção (Soja, Leite, Carne…). '
            '2) No CADPRO, escolha tipos e reserve hectares dinamicamente. '
            '3) Informe o Nº Identificador CADPRO. A soma das reservas ≤ área total.',
            style: GoogleFonts.manrope(fontSize: 13, height: 1.4),
          ),
        ),
        const SizedBox(height: 12),
        TabBar(
          controller: _tabs,
          isScrollable: true,
          labelColor: AppColors.forest,
          unselectedLabelColor: AppColors.muted,
          indicatorColor: AppColors.forest,
          labelStyle: GoogleFonts.manrope(fontWeight: FontWeight.w800),
          tabs: [
            Tab(text: 'Produtores (${state.producers.length})'),
            Tab(text: 'Tipos (${state.productionTypes.length})'),
            Tab(text: 'Produtos (${state.products.length})'),
            Tab(text: 'Grupos (${state.groups.length})'),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _ProducersTab(
                state: state,
                onAdd: () => _openCadproDialog(context),
                onMoveGroup: (p) => _openMoveGroupDialog(context, p),
                onEditAreas: (p) => _openEditAreasDialog(context, p),
              ),
              _ProductionTypesTab(
                state: state,
                onAdd: () => _openProductionTypeDialog(context),
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

  Future<void> _openProductionTypeDialog(BuildContext context) async {
    final name = TextEditingController();
    final short = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Cadastrar tipo de produção',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tipos ficam disponíveis para reservar hectares no CADPRO.',
                style: GoogleFonts.manrope(fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: name,
                decoration: const InputDecoration(
                  labelText: 'Nome completo *',
                  hintText: 'Ex.: Produção de Algodão',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: short,
                decoration: const InputDecoration(
                  labelText: 'Rótulo curto *',
                  hintText: 'Ex.: Algodão',
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
              if (short.text.trim().isEmpty && name.text.trim().isEmpty) return;
              final t = state.registerProductionType(
                name: name.text,
                shortLabel: short.text.isEmpty ? name.text : short.text,
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tipo “${t.shortLabel}” cadastrado.')),
              );
            },
            child: const Text('Salvar tipo'),
          ),
        ],
      ),
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
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Nome do grupo *'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: region,
                decoration: const InputDecoration(labelText: 'Região'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: desc,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Descrição'),
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
                SnackBar(
                  content: Text('Grupo “${g.name}” criado.'),
                ),
              );
            },
            child: const Text('Salvar grupo'),
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
          'Cadastrar produto',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Nome *'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: unit,
                decoration: const InputDecoration(labelText: 'Unidade *'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: category,
                decoration: const InputDecoration(labelText: 'Categoria'),
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

  Future<void> _openCadproDialog(BuildContext context) async {
    if (state.groups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Crie um grupo primeiro.')),
      );
      _tabs.animateTo(3);
      return;
    }
    if (state.activeProductionTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastre pelo menos um tipo de produção.')),
      );
      _tabs.animateTo(1);
      return;
    }

    final name = TextEditingController();
    final farm = TextEditingController();
    final cadproId = TextEditingController(
      text:
          'CADPRO-${DateTime.now().year}-${(1000 + state.producers.length).toString().padLeft(4, '0')}',
    );
    final ha = TextEditingController(text: '300');
    final document = TextEditingController();
    final car = TextEditingController();
    final municipality = TextEditingController();
    final uf = TextEditingController(text: 'MT');
    final phone = TextEditingController();
    final email = TextEditingController();
    String groupId = state.groups.first.id;
    HarvestMode harvestMode = HarvestMode.unica;

    // Linhas dinâmicas: tipo escolhido + hectares
    final rows = <_AreaRow>[
      _AreaRow(
        typeId: state.activeProductionTypes.first.id,
        haCtrl: TextEditingController(text: '200'),
      ),
    ];

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            double parseHa(String raw) =>
                double.tryParse(raw.replaceAll(',', '.')) ?? 0;
            final totalHa = parseHa(ha.text);
            final allocated = rows.fold<double>(
              0,
              (s, r) => s + parseHa(r.haCtrl.text),
            );
            final remaining = totalHa - allocated;
            final usedTypeIds = rows.map((r) => r.typeId).toSet();
            final availableToAdd = state.activeProductionTypes
                .where((t) => !usedTypeIds.contains(t.id))
                .toList();

            return AlertDialog(
              title: Text(
                'CADPRO — Cadastro do Produtor Rural',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
              ),
              content: SizedBox(
                width: 540,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: cadproId,
                        decoration: const InputDecoration(
                          labelText: 'Nº Identificador CADPRO *',
                          hintText: 'Ex.: CADPRO-2026-1005',
                        ),
                      ),
                      const SizedBox(height: 10),
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
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: document,
                              decoration: const InputDecoration(
                                labelText: 'CPF / CNPJ',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: car,
                              decoration: const InputDecoration(
                                labelText: 'CAR',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: municipality,
                              decoration: const InputDecoration(
                                labelText: 'Município',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: uf,
                              decoration: const InputDecoration(labelText: 'UF'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: phone,
                              decoration: const InputDecoration(
                                labelText: 'Telefone',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: email,
                              decoration: const InputDecoration(
                                labelText: 'E-mail',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: ha,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setLocal(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Área total da fazenda (ha) *',
                        ),
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
                      const SizedBox(height: 10),
                      DropdownButtonFormField<HarvestMode>(
                        initialValue: harvestMode,
                        decoration: const InputDecoration(
                          labelText: 'Modo de safra',
                        ),
                        items: [
                          for (final m in HarvestMode.values)
                            DropdownMenuItem(value: m, child: Text(m.label)),
                        ],
                        onChanged: (v) => setLocal(() => harvestMode = v!),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Reservas de hectares por produção',
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (availableToAdd.isNotEmpty)
                            TextButton.icon(
                              onPressed: () {
                                setLocal(() {
                                  rows.add(
                                    _AreaRow(
                                      typeId: availableToAdd.first.id,
                                      haCtrl: TextEditingController(text: '0'),
                                    ),
                                  );
                                });
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Adicionar tipo'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Alocado: ${allocated.toStringAsFixed(0)} ha · '
                        'Restante: ${remaining.toStringAsFixed(0)} ha'
                        '${remaining < 0 ? ' (excede área total)' : ''}',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: remaining < 0
                              ? AppColors.danger
                              : AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (var i = 0; i < rows.length; i++) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<String>(
                                initialValue: rows[i].typeId,
                                decoration: const InputDecoration(
                                  labelText: 'Tipo de produção',
                                ),
                                items: [
                                  for (final t in state.activeProductionTypes)
                                    if (t.id == rows[i].typeId ||
                                        !usedTypeIds.contains(t.id) ||
                                        t.id == rows[i].typeId)
                                      DropdownMenuItem(
                                        value: t.id,
                                        child: Text(t.shortLabel),
                                      ),
                                ],
                                onChanged: (v) =>
                                    setLocal(() => rows[i].typeId = v!),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: rows[i].haCtrl,
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setLocal(() {}),
                                decoration: const InputDecoration(
                                  labelText: 'Hectares',
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: rows.length <= 1
                                  ? null
                                  : () => setLocal(() {
                                        rows[i].haCtrl.dispose();
                                        rows.removeAt(i);
                                      }),
                              icon: const Icon(Icons.remove_circle_outline),
                              color: AppColors.danger,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
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
                    final hectares = parseHa(ha.text);
                    if (name.text.trim().isEmpty ||
                        farm.text.trim().isEmpty ||
                        cadproId.text.trim().isEmpty ||
                        hectares <= 0) {
                      return;
                    }
                    final areas = <ProductionArea>[];
                    for (final r in rows) {
                      final qty = parseHa(r.haCtrl.text);
                      if (qty <= 0) continue;
                      final type = state.productionTypeById(r.typeId);
                      if (type == null) continue;
                      areas.add(
                        ProductionArea(
                          typeId: type.id,
                          typeName: type.shortLabel,
                          hectares: qty,
                        ),
                      );
                    }
                    try {
                      final client = state.registerClient(
                        name: name.text,
                        farm: farm.text,
                        hectares: hectares,
                        productionAreas: areas,
                        groupId: groupId,
                        cadproCode: cadproId.text,
                        document: document.text,
                        car: car.text,
                        municipality: municipality.text,
                        stateUf: uf.text,
                        phone: phone.text,
                        email: email.text,
                        harvestMode: harvestMode,
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${client.cadproCode} criado · ${client.focusDetail}',
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$e')),
                      );
                    }
                  },
                  child: const Text('Salvar CADPRO'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openEditAreasDialog(BuildContext context, Producer p) async {
    if (state.activeProductionTypes.isEmpty) return;

    final ha = TextEditingController(text: p.hectares.toStringAsFixed(0));
    final rows = <_AreaRow>[
      for (final a in p.productionAreas)
        _AreaRow(
          typeId: a.typeId,
          haCtrl: TextEditingController(text: a.hectares.toStringAsFixed(0)),
        ),
    ];
    if (rows.isEmpty) {
      rows.add(
        _AreaRow(
          typeId: state.activeProductionTypes.first.id,
          haCtrl: TextEditingController(text: '0'),
        ),
      );
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            double parseHa(String raw) =>
                double.tryParse(raw.replaceAll(',', '.')) ?? 0;
            final totalHa = parseHa(ha.text);
            final allocated = rows.fold<double>(
              0,
              (s, r) => s + parseHa(r.haCtrl.text),
            );
            final remaining = totalHa - allocated;
            final usedTypeIds = rows.map((r) => r.typeId).toSet();
            final availableToAdd = state.activeProductionTypes
                .where((t) => !usedTypeIds.contains(t.id))
                .toList();

            return AlertDialog(
              title: Text(
                'Produção — ${p.farm}',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${p.cadproCode} · adicione/remova tipos dinamicamente',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: ha,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setLocal(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Área total (ha)',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Alocado ${allocated.toStringAsFixed(0)} · restante ${remaining.toStringAsFixed(0)}',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: remaining < 0
                              ? AppColors.danger
                              : AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (availableToAdd.isNotEmpty)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              setLocal(() {
                                rows.add(
                                  _AreaRow(
                                    typeId: availableToAdd.first.id,
                                    haCtrl: TextEditingController(text: '0'),
                                  ),
                                );
                              });
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Adicionar tipo'),
                          ),
                        ),
                      for (var i = 0; i < rows.length; i++) ...[
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<String>(
                                initialValue: rows[i].typeId,
                                decoration: const InputDecoration(
                                  labelText: 'Tipo',
                                ),
                                items: [
                                  for (final t in state.activeProductionTypes)
                                    if (t.id == rows[i].typeId ||
                                        !usedTypeIds.contains(t.id))
                                      DropdownMenuItem(
                                        value: t.id,
                                        child: Text(t.shortLabel),
                                      ),
                                ],
                                onChanged: (v) =>
                                    setLocal(() => rows[i].typeId = v!),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: rows[i].haCtrl,
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setLocal(() {}),
                                decoration: const InputDecoration(
                                  labelText: 'ha',
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: rows.length <= 1
                                  ? null
                                  : () => setLocal(() {
                                        rows[i].haCtrl.dispose();
                                        rows.removeAt(i);
                                      }),
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
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
                    final areas = <ProductionArea>[];
                    for (final r in rows) {
                      final qty = parseHa(r.haCtrl.text);
                      if (qty <= 0) continue;
                      final type = state.productionTypeById(r.typeId);
                      if (type == null) continue;
                      areas.add(
                        ProductionArea(
                          typeId: type.id,
                          typeName: type.shortLabel,
                          hectares: qty,
                        ),
                      );
                    }
                    state.updateProductionAreas(
                      producerId: p.id,
                      productionAreas: areas,
                      totalHectares: parseHa(ha.text),
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

class _AreaRow {
  _AreaRow({required this.typeId, required this.haCtrl});

  String typeId;
  final TextEditingController haCtrl;
}

class _ProducersTab extends StatelessWidget {
  const _ProducersTab({
    required this.state,
    required this.onAdd,
    required this.onMoveGroup,
    required this.onEditAreas,
  });

  final AppState state;
  final VoidCallback onAdd;
  final void Function(Producer p) onMoveGroup;
  final void Function(Producer p) onEditAreas;

  @override
  Widget build(BuildContext context) {
    final byType = <String, int>{};
    for (final t in state.productionTypes) {
      byType[t.id] = 0;
    }
    for (final p in state.producers) {
      for (final id in p.productionTypeIds) {
        byType[id] = (byType[id] ?? 0) + 1;
      }
    }

    return ListView(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.badge_outlined),
            label: const Text('Novo CADPRO'),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final type in state.productionTypes)
              StatusPill(
                label: '${type.shortLabel}: ${byType[type.id] ?? 0} fazenda(s)',
                tone: type.active ? PillTone.gold : PillTone.neutral,
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (state.producers.isEmpty)
          const EmptyHint(message: 'Nenhum CADPRO. Clique em “Novo CADPRO”.')
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              AppColors.forest.withValues(alpha: 0.1),
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
                                '${p.farm} · Nº ${p.cadproCode} · Grupo: ${p.groupName}',
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        StatusPill(
                          label: p.cadproStatus.label,
                          tone: p.cadproStatus == CadproStatus.ativo
                              ? PillTone.success
                              : PillTone.warning,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        StatusPill(
                          label: 'Total ${p.hectares.toStringAsFixed(0)} ha',
                          tone: PillTone.neutral,
                        ),
                        for (final area in p.productionAreas)
                          StatusPill(label: area.label, tone: PillTone.gold),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        TextButton(
                          onPressed: () => onEditAreas(p),
                          child: const Text('Editar produção'),
                        ),
                        TextButton(
                          onPressed: () => onMoveGroup(p),
                          child: const Text('Mudar grupo'),
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

class _ProductionTypesTab extends StatelessWidget {
  const _ProductionTypesTab({required this.state, required this.onAdd});

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
            icon: const Icon(Icons.category_outlined),
            label: const Text('Cadastrar tipo de produção'),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Lista dinâmica usada nas reservas de hectares do CADPRO.',
          style: GoogleFonts.manrope(fontSize: 12, color: AppColors.muted),
        ),
        const SizedBox(height: 14),
        if (state.productionTypes.isEmpty)
          const EmptyHint(message: 'Nenhum tipo. Cadastre Soja, Leite, Carne…')
        else
          ...state.productionTypes.map((t) {
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.shortLabel,
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            t.name,
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusPill(
                      label: t.active ? 'Ativo' : 'Inativo',
                      tone: t.active ? PillTone.success : PillTone.neutral,
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => state.toggleProductionTypeActive(t.id),
                      child: Text(t.active ? 'Desativar' : 'Ativar'),
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
            icon: const Icon(Icons.inventory_2_outlined),
            label: const Text('Cadastrar produto'),
          ),
        ),
        const SizedBox(height: 14),
        if (state.products.isEmpty)
          const EmptyHint(message: 'Nenhum produto cadastrado.')
        else
          ...state.products.map((p) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.line),
                ),
                title: Text(
                  p.name,
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
                ),
                subtitle: Text('${p.category} · ${p.unit}'),
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
        if (state.groups.isEmpty)
          const EmptyHint(message: 'Nenhum grupo.')
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
                    Text(
                      g.name,
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      '${g.region} · ${members.length} produtor(es)',
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
                        for (final m in members)
                          StatusPill(
                            label: '${m.farm} · ${m.focus}',
                            tone: PillTone.info,
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
