import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  AppState() {
    _producers = MockData.initialProducers();
    _groups = MockData.initialGroups();
    _productionTypes = MockData.initialProductionTypes();
    _products = MockData.initialProducts();
    _stock = MockData.initialStock();
    _needs = MockData.initialNeeds();
    _lots = MockData.initialLots();
    _warehouse = MockData.initialWarehouse();
    _shipments = MockData.initialShipments();
    _carriers = MockData.initialCarriers();
    _directPurchases = MockData.initialDirectPurchases();
    _transfers = MockData.initialTransfers();
    _replenishments = MockData.initialReplenishments();
    _settlements = MockData.initialSettlements();
    _feeCharges = MockData.initialFeeCharges();
  }

  DemoUser? currentUser;
  String? authError;

  late List<Producer> _producers;
  late List<FarmerGroup> _groups;
  late List<ProductionTypeDef> _productionTypes;
  late List<CatalogProduct> _products;
  late List<StockItem> _stock;
  late List<NeedLine> _needs;
  late List<PurchaseLot> _lots;
  late List<WarehouseBatch> _warehouse;
  late List<CarrierShipment> _shipments;
  late List<CarrierCompany> _carriers;
  late List<DirectPurchase> _directPurchases;
  late List<TransferLoan> _transfers;
  late List<ReplenishmentOrder> _replenishments;
  late List<FinancialSettlement> _settlements;
  late List<FeeCharge> _feeCharges;
  final List<ConsumptionLog> _consumptions = [];
  final List<String> _activity = [
    'Sistema iniciado — ambiente de demonstração mock.',
    'Lote LOTE-2026-014 em cotação junto à AgroSupply.',
    'Alerta: stock de diesel do Sítio Boa Vista abaixo do mínimo.',
    'Regra ativa: trocas só entre produtores do mesmo grupo; frete pago por quem pede.',
    'Cadastros: módulo CADPRO — produtores, tipos de produção, produtos e grupos.',
    'Demo: OC-REP-1000 pendente (Juliana → repor diesel de Carlos).',
    'Demo: LOTE-2026-011 liquidado; LOTE-2026-009 aguarda liquidação.',
  ];

  List<DemoUser> get users => MockData.users;
  List<Producer> get producers => List.unmodifiable(_producers);
  List<FarmerGroup> get groups => List.unmodifiable(_groups);
  List<ProductionTypeDef> get productionTypes =>
      List.unmodifiable(_productionTypes);
  List<ProductionTypeDef> get activeProductionTypes =>
      _productionTypes.where((t) => t.active).toList();
  List<CatalogProduct> get products => List.unmodifiable(_products);
  List<ExchangeableProduct> get exchangeableProducts => products;
  List<StockItem> get stock => List.unmodifiable(_stock);
  List<NeedLine> get needs => List.unmodifiable(_needs);
  List<PurchaseLot> get lots => List.unmodifiable(_lots);
  List<WarehouseBatch> get warehouse => List.unmodifiable(_warehouse);
  List<CarrierShipment> get shipments => List.unmodifiable(_shipments);
  List<CarrierCompany> get carriers => List.unmodifiable(_carriers);
  List<DirectPurchase> get directPurchases =>
      List.unmodifiable(_directPurchases);
  List<TransferLoan> get transfers => List.unmodifiable(_transfers);
  List<ReplenishmentOrder> get replenishments =>
      List.unmodifiable(_replenishments);
  List<FinancialSettlement> get settlements =>
      List.unmodifiable(_settlements);
  List<FeeCharge> get feeCharges => List.unmodifiable(_feeCharges);
  List<ConsumptionLog> get consumptions => List.unmodifiable(_consumptions);
  List<String> get activity => List.unmodifiable(_activity);

  bool get isLoggedIn => currentUser != null;

  List<CarrierCompany> get activeCarriers =>
      _carriers.where((c) => c.active).toList();

  Producer? producerById(String id) {
    for (final p in _producers) {
      if (p.id == id) return p;
    }
    return null;
  }

  FarmerGroup? groupById(String id) {
    for (final g in _groups) {
      if (g.id == id) return g;
    }
    return null;
  }

  ProductionTypeDef? productionTypeById(String id) {
    for (final t in _productionTypes) {
      if (t.id == id) return t;
    }
    return null;
  }

  CatalogProduct? productById(String id) {
    for (final p in _products) {
      if (p.id == id) return p;
    }
    return null;
  }

  CarrierCompany? carrierById(String id) {
    for (final c in _carriers) {
      if (c.id == id) return c;
    }
    return null;
  }

  Producer? get currentProducer {
    final id = currentUser?.producerId;
    if (id == null) return null;
    return producerById(id);
  }

  List<Producer> producersInGroup(String groupId) =>
      _producers.where((p) => p.groupId == groupId).toList();

  List<StockItem> stockFor(String producerId) =>
      _stock.where((s) => s.producerId == producerId).toList();

  List<StockItem> get ruptures => _stock.where((s) => s.isRupture).toList();

  List<NeedLine> needsFor(String producerId) =>
      _needs.where((n) => n.producerId == producerId).toList();

  List<DirectPurchase> directPurchasesFor(String producerId) =>
      _directPurchases.where((d) => d.producerId == producerId).toList();

  bool sameFarmerGroup(String aId, String bId) {
    final a = producerById(aId);
    final b = producerById(bId);
    if (a == null || b == null) return false;
    return a.groupId == b.groupId;
  }

  double managementFeeFor(Producer p) => p.managementFeeKg;

  List<ReplenishmentOrder> get openReplenishments => _replenishments
      .where((r) => r.status != ReplenishmentStatus.entregueAoDoador)
      .toList();

  List<PurchaseLot> get lotsAwaitingSettlement => _lots
      .where((l) =>
          (l.status == LotStatus.faturado || l.status == LotStatus.aprovado) &&
          !l.settled)
      .toList();

  FeeCharge? latestFeeFor(String producerId) {
    final list = _feeCharges.where((f) => f.producerId == producerId).toList();
    if (list.isEmpty) return null;
    return list.first;
  }

  void setHarvestMode(String producerId, HarvestMode mode) {
    final p = producerById(producerId);
    if (p == null) return;
    p.harvestMode = mode;
    _pushActivity(
      '${p.farm}: modo de safra → ${mode.label} (taxa ${p.managementFeeKg.toStringAsFixed(0)} kg).',
    );
    notifyListeners();
  }

  // ─── Cadastros (clientes, produtos, grupos) ─────────────────────────

  FarmerGroup createGroup({
    required String name,
    required String region,
    String description = '',
  }) {
    final group = FarmerGroup(
      id: 'g-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      region: region.trim(),
      description: description.trim(),
    );
    _groups.insert(0, group);
    _pushActivity('Novo grupo criado: ${group.name} (${group.region}).');
    notifyListeners();
    return group;
  }

  ProductionTypeDef registerProductionType({
    required String name,
    required String shortLabel,
  }) {
    final short = shortLabel.trim().isEmpty
        ? name.trim().split(' ').last
        : shortLabel.trim();
    final type = ProductionTypeDef(
      id: 'pt-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'Produção de $short' : name.trim(),
      shortLabel: short,
    );
    _productionTypes.insert(0, type);
    _pushActivity(
      'Tipo de produção cadastrado: ${type.shortLabel} (${type.name}).',
    );
    notifyListeners();
    return type;
  }

  void toggleProductionTypeActive(String typeId) {
    final type = productionTypeById(typeId);
    if (type == null) return;
    type.active = !type.active;
    _pushActivity(
      'Tipo ${type.shortLabel} marcado como ${type.active ? 'ativo' : 'inativo'}.',
    );
    notifyListeners();
  }

  CatalogProduct registerProduct({
    required String name,
    required String unit,
    String category = 'Insumo',
  }) {
    final product = CatalogProduct(
      id: 'ins-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      unit: unit.trim(),
      category: category.trim().isEmpty ? 'Insumo' : category.trim(),
    );
    _products.insert(0, product);
    _pushActivity(
      'Produto cadastrado: ${product.name} (${product.unit}). Disponível em compras e trocas.',
    );
    notifyListeners();
    return product;
  }

  Producer registerClient({
    required String name,
    required String farm,
    required double hectares,
    required List<ProductionArea> productionAreas,
    required String groupId,
    String? cadproCode,
    ProductionSize? productionSize,
    String document = '',
    String car = '',
    String municipality = '',
    String stateUf = '',
    String phone = '',
    String email = '',
    HarvestMode harvestMode = HarvestMode.unica,
  }) {
    final group = groupById(groupId);
    if (group == null) {
      throw StateError('Grupo não encontrado. Crie um grupo antes do CADPRO.');
    }
    if (hectares <= 0) {
      throw StateError('Área total da fazenda deve ser maior que zero.');
    }
    final areas = productionAreas
        .where((a) => a.hectares > 0 && a.typeId.isNotEmpty)
        .map(
          (a) => ProductionArea(
            typeId: a.typeId,
            typeName: a.typeName,
            hectares: a.hectares,
            harvestMode: a.harvestMode,
          ),
        )
        .toList();
    if (areas.isEmpty) {
      throw StateError('Adicione pelo menos um tipo de produção com hectares.');
    }
    final allocated = areas.fold<double>(0, (s, a) => s + a.hectares);
    if (allocated > hectares + 0.001) {
      throw StateError(
        'Hectares alocados (${allocated.toStringAsFixed(0)}) excedem a área total (${hectares.toStringAsFixed(0)} ha).',
      );
    }

    final rawCode = (cadproCode ?? '').trim();
    final code = rawCode.isEmpty
        ? 'CADPRO-${DateTime.now().year}-${(1000 + _producers.length).toString().padLeft(4, '0')}'
        : rawCode;
    if (_producers.any((p) => p.cadproCode.toLowerCase() == code.toLowerCase())) {
      throw StateError('Nº Identificador CADPRO já existe: $code');
    }

    final size =
        productionSize ?? ProductionSizeX.fromHectares(hectares);

    final producer = Producer(
      id: 'p-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      farm: farm.trim(),
      hectares: hectares,
      productionAreas: areas,
      productionSize: size,
      groupId: group.id,
      groupName: group.name,
      cadproCode: code,
      document: document.trim(),
      car: car.trim(),
      municipality: municipality.trim(),
      stateUf: stateUf.trim().toUpperCase(),
      phone: phone.trim(),
      email: email.trim(),
      cadproStatus: CadproStatus.ativo,
      harvestMode: harvestMode,
    );
    _producers.insert(0, producer);

    for (final product in _products) {
      _stock.add(
        StockItem(
          producerId: producer.id,
          productId: product.id,
          productName: product.name,
          unit: product.unit,
          quantity: 0,
          minThreshold: 1,
        ),
      );
    }

    _pushActivity(
      'CADPRO ${producer.cadproCode}: ${producer.name} (${producer.farm}) · '
      '${producer.focusDetail} · ${producer.hectares.toStringAsFixed(0)} ha · '
      'Grupo ${group.name}.',
    );
    notifyListeners();
    return producer;
  }

  /// Atualiza as reservas de hectares por tipo de produção na fazenda.
  void updateProductionAreas({
    required String producerId,
    required List<ProductionArea> productionAreas,
    double? totalHectares,
  }) {
    final producer = producerById(producerId);
    if (producer == null) return;

    final areas = productionAreas.where((a) => a.hectares > 0).toList();
    final total = totalHectares ?? producer.hectares;
    final allocated = areas.fold<double>(0, (s, a) => s + a.hectares);
    if (areas.isEmpty || allocated > total + 0.001) {
      _pushActivity(
        'CADPRO ${producer.cadproCode}: alocação inválida '
        '(${allocated.toStringAsFixed(0)} / ${total.toStringAsFixed(0)} ha).',
      );
      notifyListeners();
      return;
    }

    producer.hectares = total;
    producer.productionAreas
      ..clear()
      ..addAll(areas);
    producer.productionSize = ProductionSizeX.fromHectares(total);
    _pushActivity(
      'CADPRO ${producer.cadproCode}: produção atualizada → ${producer.focusDetail}.',
    );
    notifyListeners();
  }

  void updateCadproStatus(String producerId, CadproStatus status) {
    final producer = producerById(producerId);
    if (producer == null) return;
    producer.cadproStatus = status;
    _pushActivity(
      'CADPRO ${producer.cadproCode}: status → ${status.label}.',
    );
    notifyListeners();
  }

  void moveClientToGroup({
    required String producerId,
    required String groupId,
  }) {
    final producer = producerById(producerId);
    final group = groupById(groupId);
    if (producer == null || group == null) return;
    producer.groupId = group.id;
    producer.groupName = group.name;
    _pushActivity(
      'CADPRO ${producer.cadproCode}: ${producer.farm} movido para ${group.name}.',
    );
    notifyListeners();
  }

  bool loginWithCredentials(String email, String password) {
    DemoUser? match;
    for (final u in users) {
      if (u.email.toLowerCase() == email.trim().toLowerCase() &&
          u.password == password) {
        match = u;
        break;
      }
    }
    if (match == null) {
      authError = 'Credenciais inválidas. Use um perfil demo.';
      notifyListeners();
      return false;
    }
    return loginAs(match);
  }

  bool loginAs(DemoUser user) {
    currentUser = user;
    authError = null;
    _pushActivity('${user.name} autenticou-se como ${user.role.label}.');
    notifyListeners();
    return true;
  }

  void logout() {
    final name = currentUser?.name;
    currentUser = null;
    if (name != null) _pushActivity('$name encerrou a sessão.');
    notifyListeners();
  }

  void addNeed({
    required String producerId,
    required String productId,
    required String productName,
    required double quantity,
    required String unit,
    required PurchaseMode mode,
  }) {
    _needs.add(
      NeedLine(
        id: 'n-${DateTime.now().millisecondsSinceEpoch}',
        producerId: producerId,
        productId: productId,
        productName: productName,
        quantity: quantity,
        unit: unit,
        mode: mode,
      ),
    );
    _pushActivity(
      'Nova necessidade: $quantity $unit de $productName (${mode == PurchaseMode.planeada ? 'Planeada' : 'Direta'}).',
    );
    notifyListeners();
  }

  /// Compra direta JIT: ignora consolidação e vai ao fornecedor.
  DirectPurchase placeDirectPurchase({
    required String producerId,
    required String productId,
    required String productName,
    required double quantity,
    required String unit,
    String? carrierId,
  }) {
    final producer = producerById(producerId)!;
    final carrier = carrierId != null
        ? carrierById(carrierId)
        : (activeCarriers.isNotEmpty ? activeCarriers.first : null);

    final order = DirectPurchase(
      id: 'dp-${DateTime.now().millisecondsSinceEpoch}',
      code: 'DIR-2026-${100 + _directPurchases.length}',
      producerId: producerId,
      productId: productId,
      productName: productName,
      quantity: quantity,
      unit: unit,
      supplierName: 'AgroSupply Multinacional',
      status: DirectOrderStatus.enviado,
      carrierId: carrier?.id,
      carrierName: carrier?.name,
    );
    _directPurchases.insert(0, order);

    addNeed(
      producerId: producerId,
      productId: productId,
      productName: productName,
      quantity: quantity,
      unit: unit,
      mode: PurchaseMode.direta,
    );

    if (carrier != null) {
      _shipments.insert(
        0,
        CarrierShipment(
          id: 'sh-${DateTime.now().millisecondsSinceEpoch}',
          type: 'compra_direta',
          origin: 'Fornecedor AgroSupply',
          destination: producer.farm,
          productName: productName,
          quantity: quantity,
          unit: unit,
          status: 'Aguardando coleta',
          carrierId: carrier.id,
          carrierName: carrier.name,
          freightPayerName: producer.name,
        ),
      );
    }

    _pushActivity(
      'Compra direta ${order.code}: $quantity $unit de $productName por ${producer.farm} (sem consolidação). Frete via ${carrier?.name ?? 'a definir'}.',
    );
    notifyListeners();
    return order;
  }

  void confirmDirectPurchase(String orderId) {
    final order = _directPurchases.firstWhere((o) => o.id == orderId);
    order.status = DirectOrderStatus.confirmado;
    _pushActivity('Fornecedor confirmou compra direta ${order.code}.');
    notifyListeners();
  }

  void deliverDirectPurchase(String orderId) {
    final order = _directPurchases.firstWhere((o) => o.id == orderId);
    order.status = DirectOrderStatus.entregue;

    final destinationId =
        order.stockDestinationProducerId ?? order.producerId;
    final stockItem = _ensureStock(
      producerId: destinationId,
      productId: order.productId,
      productName: order.productName,
      unit: order.unit,
    );
    stockItem.quantity += order.quantity;

    if (order.isReplenishment && order.replenishmentOrderId != null) {
      _completeReplenishment(order.replenishmentOrderId!);
      _pushActivity(
        'Reposição ${order.replenishmentOrderId}: '
        '${order.quantity.toStringAsFixed(0)} ${order.unit} de ${order.productName} '
        'entregue ao doador ${producerById(destinationId)?.farm}.',
      );
    } else {
      _pushActivity(
        'Compra direta ${order.code} entregue em ${producerById(order.producerId)?.farm}.',
      );
    }
    notifyListeners();
  }

  StockItem _ensureStock({
    required String producerId,
    required String productId,
    required String productName,
    required String unit,
  }) {
    return _stock.firstWhere(
      (s) => s.producerId == producerId && s.productId == productId,
      orElse: () {
        final created = StockItem(
          producerId: producerId,
          productId: productId,
          productName: productName,
          unit: unit,
          quantity: 0,
          minThreshold: 1,
        );
        _stock.add(created);
        return created;
      },
    );
  }

  void _completeReplenishment(String replenishmentCodeOrId) {
    ReplenishmentOrder? order;
    for (final r in _replenishments) {
      if (r.id == replenishmentCodeOrId || r.code == replenishmentCodeOrId) {
        order = r;
        break;
      }
    }
    if (order == null) return;
    order.status = ReplenishmentStatus.entregueAoDoador;

    for (final t in _transfers) {
      if (t.replenishmentOrderId == order.code || t.id == order.transferId) {
        t.status = TransferStatus.reposicaoConcluida;
      }
    }
  }

  /// Consolida necessidades planeadas de um produto e remove-as do pool.
  PurchaseLot? consolidatePlanned(String productId) {
    final lines = _needs
        .where((n) =>
            n.productId == productId && n.mode == PurchaseMode.planeada)
        .toList();
    if (lines.isEmpty) return null;

    final total = lines.fold<double>(0, (a, b) => a + b.quantity);
    final participants = lines.map((e) => e.producerId).toSet().toList();
    final productName = lines.first.productName;
    final unit = lines.first.unit;
    final lot = PurchaseLot(
      id: 'lot-${DateTime.now().millisecondsSinceEpoch}',
      code: 'LOTE-2026-${100 + _lots.length}',
      productId: productId,
      productName: productName,
      totalQuantity: total,
      unit: unit,
      participantIds: participants,
      status: LotStatus.consolidado,
      supplierName: 'AgroSupply Multinacional',
    );
    _lots.insert(0, lot);
    _needs.removeWhere(
      (n) => n.productId == productId && n.mode == PurchaseMode.planeada,
    );
    _pushActivity(
      'ERP consolidou ${lot.code}: $total $unit de $productName (${participants.length} produtores).',
    );
    notifyListeners();
    return lot;
  }

  /// Consolida o primeiro produto com necessidades planeadas pendentes.
  PurchaseLot? consolidateNextPlanned() {
    final pending = _needs.where((n) => n.mode == PurchaseMode.planeada);
    if (pending.isEmpty) return null;
    return consolidatePlanned(pending.first.productId);
  }

  List<String> plannedProductIdsWithNeeds() {
    return _needs
        .where((n) => n.mode == PurchaseMode.planeada)
        .map((n) => n.productId)
        .toSet()
        .toList();
  }

  void quoteLot(String lotId, double price) {
    final lot = _lots.firstWhere((l) => l.id == lotId);
    lot.quotedPricePerUnit = price;
    lot.status = LotStatus.cotacao;
    _pushActivity(
      'Cotação registada em ${lot.code}: R\$ ${price.toStringAsFixed(2)} / ${lot.unit}.',
    );
    notifyListeners();
  }

  void approveLot(String lotId) {
    final lot = _lots.firstWhere((l) => l.id == lotId);
    lot.status = LotStatus.aprovado;
    _pushActivity('Fornecedor aprovou venda e fechou ${lot.code}.');
    notifyListeners();
  }

  void issueInvoice(String lotId) {
    final lot = _lots.firstWhere((l) => l.id == lotId);
    lot.status = LotStatus.faturado;
    _pushActivity(
      'Faturação direta emitida aos produtores de ${lot.code} (pagamento fora do ERP).',
    );
    notifyListeners();
  }

  /// Passo 6 UML: regista liquidação financeira fornecedor ↔ produtores.
  FinancialSettlement? settleLotFinancial(String lotId) {
    final lot = _lots.firstWhere((l) => l.id == lotId);
    if (lot.quotedPricePerUnit == null) {
      _pushActivity('Liquidação bloqueada: ${lot.code} sem preço cotado.');
      notifyListeners();
      return null;
    }
    if (lot.settled) {
      _pushActivity('${lot.code} já está liquidado.');
      notifyListeners();
      return null;
    }

    final settlement = FinancialSettlement(
      id: 'fs-${DateTime.now().millisecondsSinceEpoch}',
      lotId: lot.id,
      lotCode: lot.code,
      totalAmount: lot.estimatedTotal,
      participantIds: List.of(lot.participantIds),
      settledAt: DateTime.now(),
    );
    _settlements.insert(0, settlement);
    lot.settled = true;
    lot.settledAt = settlement.settledAt;
    lot.status = LotStatus.liquidado;

    _pushActivity(
      'Liquidação financeira ${lot.code}: R\$ ${settlement.totalAmount.toStringAsFixed(0)} '
      '(${lot.participantIds.length} produtores ↔ ${lot.supplierName}).',
    );
    notifyListeners();
    return settlement;
  }

  /// Despacha volume físico do fornecedor → armazém (em trânsito).
  void dispatchLotToWarehouse(String lotId) {
    final lot = _lots.firstWhere((l) => l.id == lotId);
    if (lot.status != LotStatus.faturado &&
        lot.status != LotStatus.liquidado &&
        lot.status != LotStatus.aprovado) {
      return;
    }
    lot.status = LotStatus.emTransito;
    _pushActivity(
      'Volume físico de ${lot.code} despachado pelo fornecedor (em trânsito para armazém).',
    );
    notifyListeners();
  }

  /// Receciona carga no armazém de retaguarda.
  void receiveLotAtWarehouse(String lotId) {
    final lot = _lots.firstWhere((l) => l.id == lotId);
    if (lot.status != LotStatus.emTransito &&
        lot.status != LotStatus.faturado &&
        lot.status != LotStatus.liquidado &&
        lot.status != LotStatus.aprovado) {
      return;
    }

    final already = _warehouse.any((w) => w.lotId == lot.id);
    if (!already) {
      _warehouse.insert(
        0,
        WarehouseBatch(
          id: 'w-${DateTime.now().millisecondsSinceEpoch}',
          lotId: lot.id,
          productName: lot.productName,
          receivedQty: lot.totalQuantity,
          distributedQty: 0,
          unit: lot.unit,
        ),
      );
    }
    lot.status = LotStatus.noArmazem;
    _pushActivity(
      'Armazém de retaguarda rececionou carga total de ${lot.code}.',
    );
    notifyListeners();
  }

  /// Compat: atalho demo (despacho + receção).
  void deliverToWarehouse(String lotId) {
    final lot = _lots.firstWhere((l) => l.id == lotId);
    if (lot.status != LotStatus.emTransito) {
      dispatchLotToWarehouse(lotId);
    }
    receiveLotAtWarehouse(lotId);
  }

  CarrierCompany registerCarrier({
    required String name,
    required String cnpj,
    required String contact,
    required String region,
    required int fleetSize,
  }) {
    final company = CarrierCompany(
      id: 'c-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      cnpj: cnpj,
      contact: contact,
      region: region,
      fleetSize: fleetSize,
    );
    _carriers.insert(0, company);
    _pushActivity('Transportadora cadastrada: ${company.name} ($region).');
    notifyListeners();
    return company;
  }

  void toggleCarrierActive(String carrierId) {
    final c = carrierById(carrierId);
    if (c == null) return;
    c.active = !c.active;
    _pushActivity(
      '${c.name} marcada como ${c.active ? 'ativa' : 'inativa'}.',
    );
    notifyListeners();
  }

  /// Distribuição JIT obrigatoriamente via transportadora terceirizada.
  void distributeFraction({
    required String warehouseId,
    required String producerId,
    required double qty,
    required String carrierId,
  }) {
    final batch = _warehouse.firstWhere((w) => w.id == warehouseId);
    if (qty <= 0 || qty > batch.remaining) return;
    final carrier = carrierById(carrierId);
    if (carrier == null || !carrier.active) {
      _pushActivity('Distribuição bloqueada: selecione uma transportadora ativa.');
      notifyListeners();
      return;
    }

    batch.distributedQty += qty;
    final producer = producerById(producerId)!;
    final stockItem = _stock.firstWhere(
      (s) =>
          s.producerId == producerId && s.productName == batch.productName,
      orElse: () {
        final created = StockItem(
          producerId: producerId,
          productId: 'ins-dyn',
          productName: batch.productName,
          unit: batch.unit,
          quantity: 0,
          minThreshold: 1,
        );
        _stock.add(created);
        return created;
      },
    );
    stockItem.quantity += qty;

    _shipments.insert(
      0,
      CarrierShipment(
        id: 'sh-${DateTime.now().millisecondsSinceEpoch}',
        type: 'entrega',
        origin: 'Armazém Retaguarda — Polo MT',
        destination: producer.farm,
        productName: batch.productName,
        quantity: qty,
        unit: batch.unit,
        status: 'Em rota',
        carrierId: carrier.id,
        carrierName: carrier.name,
      ),
    );

    final lot = _lots.firstWhere((l) => l.id == batch.lotId);
    lot.status =
        batch.remaining <= 0 ? LotStatus.concluido : LotStatus.emDistribuicao;

    _pushActivity(
      'Distribuição terceirizada (${carrier.name}): $qty ${batch.unit} de ${batch.productName} → ${producer.farm}.',
    );
    notifyListeners();
  }

  void registerConsumption({
    required String producerId,
    required String productId,
    required double quantity,
  }) {
    final item = _stock.firstWhere(
      (s) => s.producerId == producerId && s.productId == productId,
    );
    if (quantity <= 0 || quantity > item.quantity) return;

    item.quantity -= quantity;
    _consumptions.insert(
      0,
      ConsumptionLog(
        id: 'c-${DateTime.now().millisecondsSinceEpoch}',
        producerId: producerId,
        productName: item.productName,
        quantity: quantity,
        unit: item.unit,
        date: DateTime.now(),
      ),
    );
    _pushActivity(
      'Consumo diário: -$quantity ${item.unit} de ${item.productName} (${producerById(producerId)?.farm}).',
    );

    if (item.isRupture) {
      _pushActivity(
        '⚠ Rutura detetada: ${item.productName} em ${producerById(producerId)?.farm}.',
      );
    }
    notifyListeners();
  }

  /// Troca/empréstimo só no mesmo grupo. Quem pediu paga o frete.
  /// Gera OC-REP + compra direta vinculativa para B repor stock de A.
  TransferLoan? attemptSmartLoan({
    required String deficitProducerId,
    required String productId,
    required double quantity,
    String? preferredDonorId,
    String? carrierId,
  }) {
    final deficit = producerById(deficitProducerId);
    if (deficit == null) return null;

    final donors = _stock.where((s) {
      if (s.productId != productId) return false;
      if (s.producerId == deficitProducerId) return false;
      if (preferredDonorId != null && s.producerId != preferredDonorId) {
        return false;
      }
      final donor = producerById(s.producerId);
      if (donor == null) return false;
      if (donor.groupId != deficit.groupId) return false;
      return s.quantity - s.minThreshold >= quantity;
    }).toList()
      ..sort((a, b) => b.quantity.compareTo(a.quantity));

    if (donors.isEmpty) {
      if (preferredDonorId != null &&
          !sameFarmerGroup(deficitProducerId, preferredDonorId)) {
        final other = producerById(preferredDonorId);
        _pushActivity(
          'Troca BLOQUEADA: ${deficit.farm} e ${other?.farm} estão em grupos diferentes (${deficit.groupName} ≠ ${other?.groupName}).',
        );
        notifyListeners();
        return TransferLoan(
          id: 'tr-block-${DateTime.now().millisecondsSinceEpoch}',
          fromProducerId: preferredDonorId,
          toProducerId: deficitProducerId,
          productId: productId,
          productName: exchangeableProducts
              .firstWhere(
                (p) => p.id == productId,
                orElse: () => exchangeableProducts.first,
              )
              .name,
          quantity: quantity,
          unit: '—',
          freightCost: 0,
          freightPayerId: deficitProducerId,
          sameGroup: false,
          status: TransferStatus.bloqueado,
          blockReason:
              'Produtores em grupos diferentes. Troca permitida apenas no mesmo grupo de fazendeiros.',
        );
      }

      _pushActivity(
        'Matching falhou: sem excedente de $productId no grupo ${deficit.groupName}.',
      );
      notifyListeners();
      return null;
    }

    final donorStock = donors.first;
    final donor = producerById(donorStock.producerId)!;
    donorStock.quantity -= quantity;

    final receiver = _ensureStock(
      producerId: deficitProducerId,
      productId: productId,
      productName: donorStock.productName,
      unit: donorStock.unit,
    );
    receiver.quantity += quantity;

    final freight = _estimateFreight(quantity, donorStock.unit);
    final carrier = carrierId != null
        ? carrierById(carrierId)
        : (activeCarriers.isNotEmpty ? activeCarriers.first : null);

    final repCode = 'OC-REP-${1000 + _replenishments.length}';
    final purchaseId = 'dp-rep-${DateTime.now().millisecondsSinceEpoch}';
    final transferId = 'tr-${DateTime.now().millisecondsSinceEpoch}';

    final purchase = DirectPurchase(
      id: purchaseId,
      code: 'DIR-REP-${1000 + _directPurchases.length}',
      producerId: deficit.id,
      productId: productId,
      productName: donorStock.productName,
      quantity: quantity,
      unit: donorStock.unit,
      supplierName: 'AgroSupply Multinacional',
      status: DirectOrderStatus.enviado,
      carrierId: carrier?.id,
      carrierName: carrier?.name,
      isReplenishment: true,
      replenishmentOrderId: repCode,
      stockDestinationProducerId: donor.id,
    );
    _directPurchases.insert(0, purchase);

    final replenishment = ReplenishmentOrder(
      id: 'rep-${DateTime.now().millisecondsSinceEpoch}',
      code: repCode,
      transferId: transferId,
      borrowerId: deficit.id,
      donorId: donor.id,
      productId: productId,
      productName: donorStock.productName,
      quantity: quantity,
      unit: donorStock.unit,
      status: ReplenishmentStatus.compraEmitida,
      linkedDirectPurchaseId: purchaseId,
    );
    _replenishments.insert(0, replenishment);

    final transfer = TransferLoan(
      id: transferId,
      fromProducerId: donor.id,
      toProducerId: deficit.id,
      productId: productId,
      productName: donorStock.productName,
      quantity: quantity,
      unit: donorStock.unit,
      freightCost: freight,
      freightPayerId: deficit.id,
      sameGroup: true,
      status: TransferStatus.reposicaoGerada,
      carrierId: carrier?.id,
      carrierName: carrier?.name,
      replenishmentOrderId: repCode,
      replenishmentPurchaseId: purchaseId,
    );
    _transfers.insert(0, transfer);

    if (carrier != null) {
      _shipments.insert(
        0,
        CarrierShipment(
          id: 'sh-${DateTime.now().millisecondsSinceEpoch}',
          type: 'transferencia',
          origin: donor.farm,
          destination: deficit.farm,
          productName: donorStock.productName,
          quantity: quantity,
          unit: donorStock.unit,
          status: 'Concluído',
          carrierId: carrier.id,
          carrierName: carrier.name,
          freightPayerName: deficit.name,
        ),
      );
    }

    _pushActivity(
      'Troca autorizada (mesmo grupo ${deficit.groupName}): ${donor.farm} → ${deficit.farm} ($quantity ${donorStock.unit} ${donorStock.productName}).',
    );
    _pushActivity(
      'Frete R\$ ${freight.toStringAsFixed(0)} pago por ${deficit.name} (solicitante) via ${carrier?.name ?? 'transportadora'}.',
    );
    _pushActivity(
      'Ordem $repCode + compra ${purchase.code}: ${deficit.name} deve repor stock de ${donor.name}.',
    );
    notifyListeners();
    return transfer;
  }

  double _estimateFreight(double qty, String unit) {
    final base = unit == 'L'
        ? 0.18
        : unit == 't'
            ? 95.0
            : 12.0;
    return (qty * base).clamp(350, 12000);
  }

  /// Cobrança efetiva da taxa de gestão (passo 17 UML).
  FeeCharge chargeManagementFee({
    required String producerId,
    String season = 'Safra 2026/27',
    HarvestMode? harvestMode,
  }) {
    final producer = producerById(producerId)!;
    if (harvestMode != null) {
      producer.harvestMode = harvestMode;
    }
    final kg = producer.managementFeeKg;
    final charge = FeeCharge(
      id: 'fee-${DateTime.now().millisecondsSinceEpoch}',
      producerId: producerId,
      season: season,
      harvestMode: producer.harvestMode,
      hectares: producer.hectares,
      kgCharged: kg,
      status: FeeChargeStatus.cobrada,
      chargedAt: DateTime.now(),
    );
    _feeCharges.insert(0, charge);
    _pushActivity(
      'Taxa cobrada: ${producer.farm} · ${kg.toStringAsFixed(0)} kg soja '
      '(${producer.hectares.toStringAsFixed(0)} ha × 33 × ${producer.harvestMode.feeMultiplier.toStringAsFixed(0)}) · $season.',
    );
    notifyListeners();
    return charge;
  }

  int chargeAllManagementFees({String season = 'Safra 2026/27'}) {
    var count = 0;
    for (final p in _producers) {
      final already = _feeCharges.any(
        (f) =>
            f.producerId == p.id &&
            f.season == season &&
            f.status == FeeChargeStatus.cobrada,
      );
      if (already) continue;
      chargeManagementFee(producerId: p.id, season: season);
      count++;
    }
    return count;
  }

  void simulateRuptureDemo() {
    final dieselB = _stock.firstWhere(
      (s) => s.producerId == 'p-b' && s.productId == 'ins-diesel',
    );
    dieselB.quantity = 200;
    _pushActivity('Demo: forcei rutura de diesel no Sítio Boa Vista.');
    notifyListeners();
  }

  /// Executa cenários mock alinhados às fases do UML.
  String runDemoScenario(DemoScenarioId id) {
    switch (id) {
      case DemoScenarioId.compraPlaneadaCompleta:
        return _scenarioCompraPlaneada();
      case DemoScenarioId.ruturaEmprestimoReposicao:
        return _scenarioRuturaReposicao();
      case DemoScenarioId.liquidacaoFinanceira:
        return _scenarioLiquidacao();
      case DemoScenarioId.taxaGestao:
        return _scenarioTaxa();
    }
  }

  String _scenarioCompraPlaneada() {
    // Garante necessidade de fertilizante se não houver.
    final hasFertNeed = _needs.any(
      (n) => n.productId == 'ins-fert' && n.mode == PurchaseMode.planeada,
    );
    if (!hasFertNeed) {
      addNeed(
        producerId: 'p-b',
        productId: 'ins-fert',
        productName: 'Fertilizante NPK',
        quantity: 15,
        unit: 't',
        mode: PurchaseMode.planeada,
      );
      addNeed(
        producerId: 'p-d',
        productId: 'ins-fert',
        productName: 'Fertilizante NPK',
        quantity: 8,
        unit: 't',
        mode: PurchaseMode.planeada,
      );
    }

    final lot = consolidatePlanned('ins-fert');
    if (lot == null) {
      return 'Sem necessidades de fertilizante para consolidar.';
    }
    quoteLot(lot.id, 3180);
    approveLot(lot.id);
    issueInvoice(lot.id);
    settleLotFinancial(lot.id);
    dispatchLotToWarehouse(lot.id);
    receiveLotAtWarehouse(lot.id);
    return 'Cenário OK: ${lot.code} consolidado → cotado → aprovado → faturado → liquidado → no armazém.';
  }

  String _scenarioRuturaReposicao() {
    simulateRuptureDemo();
    final result = attemptSmartLoan(
      deficitProducerId: 'p-b',
      productId: 'ins-diesel',
      quantity: 2500,
    );
    if (result == null) {
      return 'Matching falhou — sem excedente no grupo.';
    }
    if (result.status == TransferStatus.bloqueado) {
      return result.blockReason ?? 'Troca bloqueada.';
    }
    final purchaseId = result.replenishmentPurchaseId;
    if (purchaseId != null) {
      confirmDirectPurchase(purchaseId);
      deliverDirectPurchase(purchaseId);
    }
    return 'Cenário OK: rutura B → empréstimo A→B → ${result.replenishmentOrderId} entregue ao doador.';
  }

  String _scenarioLiquidacao() {
    PurchaseLot? target;
    for (final lot in _lots) {
      if (!lot.settled && lot.quotedPricePerUnit != null) {
        target = lot;
        break;
      }
    }
    if (target == null) {
      return 'Nenhum lote pendente de liquidação.';
    }
    if (target.status == LotStatus.cotacao) {
      approveLot(target.id);
      issueInvoice(target.id);
    } else if (target.status == LotStatus.aprovado) {
      issueInvoice(target.id);
    }
    final s = settleLotFinancial(target.id);
    if (s == null) return 'Não foi possível liquidar ${target.code}.';
    return 'Cenário OK: ${target.code} liquidado — R\$ ${s.totalAmount.toStringAsFixed(0)}.';
  }

  String _scenarioTaxa() {
    setHarvestMode('p-a', HarvestMode.multipla);
    final a = chargeManagementFee(producerId: 'p-a');
    final b = chargeManagementFee(producerId: 'p-b');
    return 'Cenário OK: taxas cobradas — Horizonte ${a.kgCharged.toStringAsFixed(0)} kg · Boa Vista ${b.kgCharged.toStringAsFixed(0)} kg.';
  }

  void _pushActivity(String message) {
    _activity.insert(0, message);
    if (_activity.length > 60) {
      _activity.removeRange(60, _activity.length);
    }
  }
}
