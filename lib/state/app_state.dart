import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  AppState() {
    _producers = MockData.initialProducers();
    _groups = MockData.initialGroups();
    _products = MockData.initialProducts();
    _stock = MockData.initialStock();
    _needs = MockData.initialNeeds();
    _lots = MockData.initialLots();
    _warehouse = MockData.initialWarehouse();
    _shipments = MockData.initialShipments();
    _carriers = MockData.initialCarriers();
  }

  DemoUser? currentUser;
  String? authError;

  late List<Producer> _producers;
  late List<FarmerGroup> _groups;
  late List<CatalogProduct> _products;
  late List<StockItem> _stock;
  late List<NeedLine> _needs;
  late List<PurchaseLot> _lots;
  late List<WarehouseBatch> _warehouse;
  late List<CarrierShipment> _shipments;
  late List<CarrierCompany> _carriers;
  final List<DirectPurchase> _directPurchases = [];
  final List<TransferLoan> _transfers = [];
  final List<ConsumptionLog> _consumptions = [];
  final List<String> _activity = [
    'Sistema iniciado — ambiente de demonstração mock.',
    'Lote LOTE-2026-014 em cotação junto à AgroSupply.',
    'Alerta: stock de diesel do Sítio Boa Vista abaixo do mínimo.',
    'Regra ativa: trocas só entre produtores do mesmo grupo; frete pago por quem pede.',
    'Cadastros: use o menu Clientes para criar grupos, produtos e novos produtores.',
  ];

  List<DemoUser> get users => MockData.users;
  List<Producer> get producers => List.unmodifiable(_producers);
  List<FarmerGroup> get groups => List.unmodifiable(_groups);
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
    required ProductionType productionType,
    required ProductionSize productionSize,
    required String groupId,
  }) {
    final group = groupById(groupId);
    if (group == null) {
      throw StateError('Grupo não encontrado. Crie um grupo antes do cliente.');
    }

    final producer = Producer(
      id: 'p-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      farm: farm.trim(),
      hectares: hectares,
      productionType: productionType,
      productionSize: productionSize,
      groupId: group.id,
      groupName: group.name,
    );
    _producers.insert(0, producer);

    // Stock inicial zerado para cada produto do catálogo (demo).
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
      'Cliente cadastrado: ${producer.name} (${producer.farm}) · '
      '${producer.productionType.shortLabel} · ${producer.hectares.toStringAsFixed(0)} ha · '
      'Grupo ${group.name}.',
    );
    notifyListeners();
    return producer;
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
      '${producer.farm} movido para o grupo ${group.name}.',
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

    final stockItem = _stock.firstWhere(
      (s) => s.producerId == order.producerId && s.productId == order.productId,
      orElse: () {
        final created = StockItem(
          producerId: order.producerId,
          productId: order.productId,
          productName: order.productName,
          unit: order.unit,
          quantity: 0,
          minThreshold: 1,
        );
        _stock.add(created);
        return created;
      },
    );
    stockItem.quantity += order.quantity;
    _pushActivity(
      'Compra direta ${order.code} entregue em ${producerById(order.producerId)?.farm}.',
    );
    notifyListeners();
  }

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
    _pushActivity(
      'ERP consolidou ${lot.code}: $total $unit de $productName (${participants.length} produtores).',
    );
    notifyListeners();
    return lot;
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
      'Faturação direta emitida aos produtores de ${lot.code} (fora do fluxo financeiro do ERP).',
    );
    notifyListeners();
  }

  void deliverToWarehouse(String lotId) {
    final lot = _lots.firstWhere((l) => l.id == lotId);
    lot.status = LotStatus.noArmazem;
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
    _pushActivity(
      'Armazém de retaguarda rececionou carga total de ${lot.code}.',
    );
    notifyListeners();
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
      // Regra de negócio: mesmo grupo de fazendeiros.
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

    final receiver = _stock.firstWhere(
      (s) => s.producerId == deficitProducerId && s.productId == productId,
      orElse: () {
        final created = StockItem(
          producerId: deficitProducerId,
          productId: productId,
          productName: donorStock.productName,
          unit: donorStock.unit,
          quantity: 0,
          minThreshold: 1,
        );
        _stock.add(created);
        return created;
      },
    );
    receiver.quantity += quantity;

    final freight = _estimateFreight(quantity, donorStock.unit);
    final carrier = carrierId != null
        ? carrierById(carrierId)
        : (activeCarriers.isNotEmpty ? activeCarriers.first : null);

    final transfer = TransferLoan(
      id: 'tr-${DateTime.now().millisecondsSinceEpoch}',
      fromProducerId: donor.id,
      toProducerId: deficit.id,
      productId: productId,
      productName: donorStock.productName,
      quantity: quantity,
      unit: donorStock.unit,
      freightCost: freight,
      freightPayerId: deficit.id, // quem pediu emprestado paga o frete
      sameGroup: true,
      status: TransferStatus.entregue,
      carrierId: carrier?.id,
      carrierName: carrier?.name,
      replenishmentOrderId: 'OC-REP-${1000 + _transfers.length}',
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
      'Ordem de reposição ${transfer.replenishmentOrderId} para ${deficit.name} repor stock de ${donor.name}.',
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

  void simulateRuptureDemo() {
    final dieselB = _stock.firstWhere(
      (s) => s.producerId == 'p-b' && s.productId == 'ins-diesel',
    );
    dieselB.quantity = 200;
    _pushActivity('Demo: forcei rutura de diesel no Sítio Boa Vista.');
    notifyListeners();
  }

  void _pushActivity(String message) {
    _activity.insert(0, message);
    if (_activity.length > 40) {
      _activity.removeRange(40, _activity.length);
    }
  }
}
