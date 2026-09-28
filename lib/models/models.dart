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

/// Classificação de cliente pedida na reunião.
enum ProductionType { soja, leite, carne }

extension ProductionTypeX on ProductionType {
  String get label => switch (this) {
        ProductionType.soja => 'Produtor de Soja',
        ProductionType.leite => 'Produtor de Leite',
        ProductionType.carne => 'Produtor de Carne',
      };

  String get shortLabel => switch (this) {
        ProductionType.soja => 'Soja',
        ProductionType.leite => 'Leite',
        ProductionType.carne => 'Carne',
      };
}

enum ProductionSize { pequeno, medio, grande }

extension ProductionSizeX on ProductionSize {
  String get label => switch (this) {
        ProductionSize.pequeno => 'Pequeno',
        ProductionSize.medio => 'Médio',
        ProductionSize.grande => 'Grande',
      };
}

enum PurchaseMode { planeada, direta }

enum LotStatus {
  programacao,
  consolidado,
  cotacao,
  aprovado,
  faturado,
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
        LotStatus.emTransito => 'Em trânsito',
        LotStatus.noArmazem => 'No armazém',
        LotStatus.emDistribuicao => 'Distribuição JIT',
        LotStatus.concluido => 'Concluído',
      };
}

enum TransferStatus { pendente, emTransito, entregue, bloqueado, reposicaoGerada }

enum DirectOrderStatus { enviado, confirmado, emTransito, entregue }

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
    required this.productionType,
    required this.productionSize,
    required this.groupId,
    required this.groupName,
  });

  final String id;
  final String name;
  final String farm;
  final double hectares;
  final ProductionType productionType;
  final ProductionSize productionSize;
  String groupId;
  String groupName;

  /// Compatível com UI antiga.
  String get focus => productionType.label;
  String get volumeTier => productionSize.label;

  double get managementFeeKg => hectares * 33;
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
  String? blockReason;
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
