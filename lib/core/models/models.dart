enum UserRole {
  admin,
  produtor,
  gestora,
  fornecedor,
  transportadora,
}

extension UserRoleX on UserRole {
  String get label => switch (this) {
        UserRole.admin => 'Administrador',
        UserRole.produtor => 'Produtor Agrícola',
        UserRole.gestora => 'Gestora / ERP',
        UserRole.fornecedor => 'Fornecedor Multinacional',
        UserRole.transportadora => 'Transportadora',
      };

  String get shortLabel => switch (this) {
        UserRole.admin => 'Admin',
        UserRole.produtor => 'Produtor',
        UserRole.gestora => 'Gestora',
        UserRole.fornecedor => 'Fornecedor',
        UserRole.transportadora => 'Logística',
      };

  /// Acesso total ao sistema (todas as telas e ações operacionais).
  bool get isAdmin => this == UserRole.admin;

  bool get canManageEcosystem =>
      this == UserRole.admin || this == UserRole.gestora;

  bool get canActAsSupplier =>
      this == UserRole.admin || this == UserRole.fornecedor;

  bool get seesAllClients =>
      this == UserRole.admin || this == UserRole.gestora;
}

/// Tipo de produção cadastrável (catálogo dinâmico — Soja, Leite, Carne, etc.).
class ProductionTypeDef {
  ProductionTypeDef({
    required this.id,
    required this.name,
    required this.shortLabel,
    this.active = true,
  });

  final String id;
  String name;
  String shortLabel;
  bool active;

  String get label => name;
}

enum ProductionSize { pequeno, medio, grande }

extension ProductionSizeX on ProductionSize {
  String get label => switch (this) {
        ProductionSize.pequeno => 'Pequeno',
        ProductionSize.medio => 'Médio',
        ProductionSize.grande => 'Grande',
      };

  /// Heurística de porte a partir da área total da fazenda.
  static ProductionSize fromHectares(double ha) {
    if (ha < 300) return ProductionSize.pequeno;
    if (ha <= 800) return ProductionSize.medio;
    return ProductionSize.grande;
  }
}

enum HarvestMode { unica, multipla }

extension HarvestModeX on HarvestMode {
  String get label => switch (this) {
        HarvestMode.unica => 'Safra única',
        HarvestMode.multipla => 'Safra múltipla',
      };

  /// Multiplicador da taxa anual (múltipla = 2 safras).
  double get feeMultiplier => switch (this) {
        HarvestMode.unica => 1,
        HarvestMode.multipla => 2,
      };
}

/// Fatia de hectares reservada a um tipo de produção na mesma fazenda.
class ProductionArea {
  ProductionArea({
    required this.typeId,
    required this.typeName,
    required this.hectares,
    this.harvestMode = HarvestMode.unica,
  });

  String typeId;
  String typeName;
  double hectares;
  HarvestMode harvestMode;

  String get label => '$typeName: ${hectares.toStringAsFixed(0)} ha';
}

enum CadproStatus { pendente, ativo, inativo }

extension CadproStatusX on CadproStatus {
  String get label => switch (this) {
        CadproStatus.pendente => 'Pendente',
        CadproStatus.ativo => 'Ativo',
        CadproStatus.inativo => 'Inativo',
      };
}

enum PurchaseMode { planeada, direta }

enum LotStatus {
  programacao,
  consolidado,
  cotacao,
  aprovado,
  faturado,
  liquidado,
  emTransito,
  noArmazem,
  emDistribuicao,
  concluido,
}

extension LotStatusX on LotStatus {
  String get label => switch (this) {
        LotStatus.programacao => 'Programação',
        LotStatus.consolidado => 'Lote consolidado',
        LotStatus.cotacao => 'Em cotação',
        LotStatus.aprovado => 'Negócio fechado',
        LotStatus.faturado => 'Faturação emitida',
        LotStatus.liquidado => 'Liquidação financeira',
        LotStatus.emTransito => 'Em trânsito',
        LotStatus.noArmazem => 'No armazém',
        LotStatus.emDistribuicao => 'Distribuição JIT',
        LotStatus.concluido => 'Concluído',
      };
}

enum TransferStatus {
  pendente,
  emTransito,
  entregue,
  bloqueado,
  reposicaoGerada,
  reposicaoConcluida,
}

extension TransferStatusX on TransferStatus {
  String get label => switch (this) {
        TransferStatus.pendente => 'Pendente',
        TransferStatus.emTransito => 'Em trânsito',
        TransferStatus.entregue => 'Entregue',
        TransferStatus.bloqueado => 'Bloqueado',
        TransferStatus.reposicaoGerada => 'OC reposição gerada',
        TransferStatus.reposicaoConcluida => 'Reposição concluída',
      };
}

enum DirectOrderStatus { enviado, confirmado, emTransito, entregue }

enum ReplenishmentStatus {
  aberta,
  compraEmitida,
  emTransito,
  entregueAoDoador,
}

extension ReplenishmentStatusX on ReplenishmentStatus {
  String get label => switch (this) {
        ReplenishmentStatus.aberta => 'Aberta',
        ReplenishmentStatus.compraEmitida => 'Compra emitida',
        ReplenishmentStatus.emTransito => 'Em trânsito',
        ReplenishmentStatus.entregueAoDoador => 'Entregue ao doador',
      };
}

enum FeeChargeStatus { pendente, cobrada }

extension FeeChargeStatusX on FeeChargeStatus {
  String get label => switch (this) {
        FeeChargeStatus.pendente => 'Pendente',
        FeeChargeStatus.cobrada => 'Cobrada',
      };
}

/// Identificadores dos cenários mock alinhados ao UML.
enum DemoScenarioId {
  compraPlaneadaCompleta,
  ruturaEmprestimoReposicao,
  liquidacaoFinanceira,
  taxaGestao,
}

extension DemoScenarioIdX on DemoScenarioId {
  String get title => switch (this) {
        DemoScenarioId.compraPlaneadaCompleta =>
          'Compra planeada (lote → armazém)',
        DemoScenarioId.ruturaEmprestimoReposicao =>
          'Rutura → empréstimo → reposição',
        DemoScenarioId.liquidacaoFinanceira => 'Liquidação financeira',
        DemoScenarioId.taxaGestao => 'Cobrança taxa 33 kg/ha',
      };

  String get description => switch (this) {
        DemoScenarioId.compraPlaneadaCompleta =>
          'Consolida fertilizante, cotação, aprovação, faturação, liquidação e despacho ao armazém.',
        DemoScenarioId.ruturaEmprestimoReposicao =>
          'Força rutura de diesel em B, matching com A, frete ao solicitante e OC-REP com compra para repor A.',
        DemoScenarioId.liquidacaoFinanceira =>
          'Regista liquidação fornecedor↔produtores no lote em cotação (visibilidade ERP).',
        DemoScenarioId.taxaGestao =>
          'Cobra taxa de gestão (33 kg soja/ha) em safra única ou múltipla.',
      };
}

class DemoUser {
  const DemoUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.title,
    required this.organization,
    this.producerId,
    this.supplierId,
    this.carrierId,
  });

  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String title;
  final String organization;
  final String? producerId;
  final String? supplierId;
  final String? carrierId;
}

class Producer {
  Producer({
    required this.id,
    required this.name,
    required this.farm,
    required this.hectares,
    required this.productionAreas,
    required this.productionSize,
    required this.groupId,
    required this.groupName,
    required this.cadproCode,
    this.document = '',
    this.car = '',
    this.municipality = '',
    this.stateUf = '',
    this.phone = '',
    this.email = '',
    this.cadproStatus = CadproStatus.ativo,
    DateTime? registeredAt,
    this.harvestMode = HarvestMode.unica,
  }) : registeredAt = registeredAt ?? DateTime.now();

  final String id;
  final String name;
  final String farm;

  /// Área total da fazenda (ha).
  double hectares;

  /// Reservas de hectares por tipo (leite/carne/soja). Soma ≤ [hectares].
  List<ProductionArea> productionAreas;

  ProductionSize productionSize;
  String groupId;
  String groupName;

  /// Código / Nº Identificador CADPRO — Cadastro do Produtor Rural.
  String cadproCode;
  String document;
  String car;
  String municipality;
  String stateUf;
  String phone;
  String email;
  CadproStatus cadproStatus;
  final DateTime registeredAt;

  /// Modo de safra padrão da fazenda (pode ser sobrescrito por área).
  HarvestMode harvestMode;

  double get allocatedHectares =>
      productionAreas.fold<double>(0, (a, e) => a + e.hectares);

  double get unallocatedHectares =>
      (hectares - allocatedHectares).clamp(0, hectares);

  bool get hasValidAllocation =>
      productionAreas.isNotEmpty && allocatedHectares <= hectares + 0.001;

  /// Tipo dominante (maior fatia de ha).
  String get primaryTypeId {
    if (productionAreas.isEmpty) return '';
    final sorted = [...productionAreas]
      ..sort((a, b) => b.hectares.compareTo(a.hectares));
    return sorted.first.typeId;
  }

  String get primaryTypeName {
    if (productionAreas.isEmpty) return '—';
    final sorted = [...productionAreas]
      ..sort((a, b) => b.hectares.compareTo(a.hectares));
    return sorted.first.typeName;
  }

  String get focus => productionAreas.isEmpty
      ? primaryTypeName
      : productionAreas.map((a) => a.typeName).toSet().join(' + ');

  String get focusDetail => productionAreas.isEmpty
      ? primaryTypeName
      : productionAreas.map((a) => a.label).join(' · ');

  String get volumeTier => productionSize.label;

  List<String> get productionTypeIds =>
      productionAreas.map((a) => a.typeId).toSet().toList();

  bool produces(String typeId) =>
      productionAreas.any((a) => a.typeId == typeId);

  /// Taxa: 33 kg soja / ha total administrado × multiplicador da safra.
  double get managementFeeKg =>
      hectares * 33 * harvestMode.feeMultiplier;
}

class FarmerGroup {
  FarmerGroup({
    required this.id,
    required this.name,
    required this.region,
    this.description = '',
  });

  final String id;
  final String name;
  final String region;
  String description;
}

class CatalogProduct {
  CatalogProduct({
    required this.id,
    required this.name,
    required this.unit,
    this.category = 'Insumo',
  });

  final String id;
  final String name;
  final String unit;
  final String category;
}

class CarrierCompany {
  CarrierCompany({
    required this.id,
    required this.name,
    required this.cnpj,
    required this.contact,
    required this.region,
    required this.fleetSize,
    this.active = true,
  });

  final String id;
  final String name;
  final String cnpj;
  final String contact;
  final String region;
  final int fleetSize;
  bool active;
}

class StockItem {
  StockItem({
    required this.producerId,
    required this.productId,
    required this.productName,
    required this.unit,
    required this.quantity,
    required this.minThreshold,
  });

  final String producerId;
  final String productId;
  final String productName;
  final String unit;
  double quantity;
  final double minThreshold;

  bool get isRupture => quantity <= minThreshold;
  bool get isLow => quantity <= minThreshold * 1.5 && !isRupture;
}

class NeedLine {
  NeedLine({
    required this.id,
    required this.producerId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.mode,
    this.season = 'Safra 2026/27',
  });

  final String id;
  final String producerId;
  final String productId;
  final String productName;
  double quantity;
  final String unit;
  PurchaseMode mode;
  final String season;
}

/// Compra direta (JIT) — ignora consolidação de lote.
class DirectPurchase {
  DirectPurchase({
    required this.id,
    required this.code,
    required this.producerId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.supplierName,
    required this.status,
    this.carrierId,
    this.carrierName,
    this.isReplenishment = false,
    this.replenishmentOrderId,
    this.stockDestinationProducerId,
  });

  final String id;
  final String code;
  final String producerId;
  final String productId;
  final String productName;
  final double quantity;
  final String unit;
  final String supplierName;
  DirectOrderStatus status;
  String? carrierId;
  String? carrierName;

  /// Compra vinculada a OC-REP: stock final vai ao doador, não ao comprador.
  final bool isReplenishment;
  final String? replenishmentOrderId;
  final String? stockDestinationProducerId;
}

class PurchaseLot {
  PurchaseLot({
    required this.id,
    required this.code,
    required this.productId,
    required this.productName,
    required this.totalQuantity,
    required this.unit,
    required this.participantIds,
    required this.status,
    this.quotedPricePerUnit,
    this.supplierName,
    this.settled = false,
    this.settledAt,
  });

  final String id;
  final String code;
  final String productId;
  final String productName;
  final double totalQuantity;
  final String unit;
  final List<String> participantIds;
  LotStatus status;
  double? quotedPricePerUnit;
  String? supplierName;
  bool settled;
  DateTime? settledAt;

  double get estimatedTotal =>
      (quotedPricePerUnit ?? 0) * totalQuantity;
}

class WarehouseBatch {
  WarehouseBatch({
    required this.id,
    required this.lotId,
    required this.productName,
    required this.receivedQty,
    required this.distributedQty,
    required this.unit,
  });

  final String id;
  final String lotId;
  final String productName;
  final double receivedQty;
  double distributedQty;
  final String unit;

  double get remaining => receivedQty - distributedQty;
}

class TransferLoan {
  TransferLoan({
    required this.id,
    required this.fromProducerId,
    required this.toProducerId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.freightCost,
    required this.freightPayerId,
    required this.sameGroup,
    required this.status,
    this.carrierId,
    this.carrierName,
    this.replenishmentOrderId,
    this.replenishmentPurchaseId,
    this.blockReason,
  });

  final String id;
  final String fromProducerId;
  final String toProducerId;
  final String productId;
  final String productName;
  final double quantity;
  final String unit;
  final double freightCost;
  /// Quem pediu emprestado paga o frete.
  final String freightPayerId;
  final bool sameGroup;
  TransferStatus status;
  String? carrierId;
  String? carrierName;
  String? replenishmentOrderId;
  String? replenishmentPurchaseId;
  String? blockReason;
}

/// Ordem vinculativa para B repor o stock de A (passos 15→16 do UML).
class ReplenishmentOrder {
  ReplenishmentOrder({
    required this.id,
    required this.code,
    required this.transferId,
    required this.borrowerId,
    required this.donorId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.status,
    this.linkedDirectPurchaseId,
  });

  final String id;
  final String code;
  final String transferId;
  final String borrowerId;
  final String donorId;
  final String productId;
  final String productName;
  final double quantity;
  final String unit;
  ReplenishmentStatus status;
  String? linkedDirectPurchaseId;
}

/// Registo de liquidação financeira (fornecedor ↔ produtores) — visibilidade no ERP.
class FinancialSettlement {
  FinancialSettlement({
    required this.id,
    required this.lotId,
    required this.lotCode,
    required this.totalAmount,
    required this.participantIds,
    required this.settledAt,
    this.notes =
        'Liquidação fora do ERP: pagamento direto fornecedor ↔ produtores.',
  });

  final String id;
  final String lotId;
  final String lotCode;
  final double totalAmount;
  final List<String> participantIds;
  final DateTime settledAt;
  final String notes;
}

/// Cobrança efetiva da taxa de gestão (33 kg soja/ha/ano).
class FeeCharge {
  FeeCharge({
    required this.id,
    required this.producerId,
    required this.season,
    required this.harvestMode,
    required this.hectares,
    required this.kgCharged,
    required this.status,
    this.chargedAt,
  });

  final String id;
  final String producerId;
  final String season;
  final HarvestMode harvestMode;
  final double hectares;
  final double kgCharged;
  FeeChargeStatus status;
  DateTime? chargedAt;
}

class ConsumptionLog {
  ConsumptionLog({
    required this.id,
    required this.producerId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.date,
  });

  final String id;
  final String producerId;
  final String productName;
  final double quantity;
  final String unit;
  final DateTime date;
}

class CarrierShipment {
  CarrierShipment({
    required this.id,
    required this.type,
    required this.origin,
    required this.destination,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.status,
    required this.carrierId,
    required this.carrierName,
    this.freightPayerName,
  });

  final String id;
  final String type; // entrega | transferencia | compra_direta
  final String origin;
  final String destination;
  final String productName;
  final double quantity;
  final String unit;
  String status;
  final String carrierId;
  final String carrierName;
  final String? freightPayerName;
}

/// Catálogo de produtos trocáveis / compráveis.
typedef ExchangeableProduct = CatalogProduct;
