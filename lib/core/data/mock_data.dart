import '../models/models.dart';

class MockData {
  static List<CatalogProduct> initialProducts() => [
        CatalogProduct(id: 'ins-diesel', name: 'Gasóleo / Diesel', unit: 'L'),
        CatalogProduct(id: 'ins-soja', name: 'Soja (grãos)', unit: 'sc'),
        CatalogProduct(
          id: 'ins-semente',
          name: 'Semente de Soja',
          unit: 'sc',
        ),
        CatalogProduct(id: 'ins-fert', name: 'Fertilizante NPK', unit: 't'),
      ];

  static List<FarmerGroup> initialGroups() => [
        FarmerGroup(
          id: 'g1',
          name: 'Grupo Cerrado Norte',
          region: 'MT / GO',
          description: 'Produtores vizinhos para trocas laterais',
        ),
        FarmerGroup(
          id: 'g2',
          name: 'Grupo Pantanal Leste',
          region: 'MS',
          description: 'Pecuária e insumos compartilhados',
        ),
      ];

  static List<ProductionTypeDef> initialProductionTypes() => [
        ProductionTypeDef(
          id: 'pt-soja',
          name: 'Produção de Soja',
          shortLabel: 'Soja',
        ),
        ProductionTypeDef(
          id: 'pt-leite',
          name: 'Produção de Leite',
          shortLabel: 'Leite',
        ),
        ProductionTypeDef(
          id: 'pt-carne',
          name: 'Produção de Carne',
          shortLabel: 'Carne',
        ),
      ];

  static List<Producer> initialProducers() => [
        Producer(
          id: 'p-a',
          name: 'Carlos Mendes',
          farm: 'Fazenda Horizonte',
          hectares: 1200,
          productionAreas: [
            ProductionArea(typeId: 'pt-soja', typeName: 'Soja', hectares: 900, harvestMode: HarvestMode.multipla),
            ProductionArea(typeId: 'pt-leite', typeName: 'Leite', hectares: 200),
            ProductionArea(typeId: 'pt-carne', typeName: 'Carne', hectares: 100),
          ],
          productionSize: ProductionSize.grande,
          groupId: 'g1',
          groupName: 'Grupo Cerrado Norte',
          cadproCode: 'CADPRO-2024-0142',
          document: '12.345.678/0001-90',
          car: 'MT-5100000-ABCDEF123456',
          municipality: 'Sorriso',
          stateUf: 'MT',
          phone: '(66) 99911-2200',
          email: 'carlos@horizonte.agro',
          harvestMode: HarvestMode.multipla,
        ),
        Producer(
          id: 'p-b',
          name: 'Ana Ribeiro',
          farm: 'Sítio Boa Vista',
          hectares: 480,
          productionAreas: [
            ProductionArea(typeId: 'pt-soja', typeName: 'Soja', hectares: 400),
            ProductionArea(typeId: 'pt-leite', typeName: 'Leite', hectares: 80),
          ],
          productionSize: ProductionSize.medio,
          groupId: 'g1',
          groupName: 'Grupo Cerrado Norte',
          cadproCode: 'CADPRO-2025-0088',
          document: '987.654.321-00',
          car: 'MT-5102500-XYZ987654321',
          municipality: 'Lucas do Rio Verde',
          stateUf: 'MT',
          phone: '(66) 98822-1100',
          email: 'ana@boavista.agro',
        ),
        Producer(
          id: 'p-c',
          name: 'Pedro Almeida',
          farm: 'Estância Vale Verde',
          hectares: 850,
          productionAreas: [
            ProductionArea(typeId: 'pt-carne', typeName: 'Carne', hectares: 600),
            ProductionArea(typeId: 'pt-leite', typeName: 'Leite', hectares: 250),
          ],
          productionSize: ProductionSize.grande,
          groupId: 'g2',
          groupName: 'Grupo Pantanal Leste',
          cadproCode: 'CADPRO-2023-0310',
          document: '11.222.333/0001-44',
          car: 'MS-5000000-PANTANAL001',
          municipality: 'Corumbá',
          stateUf: 'MS',
          phone: '(67) 97700-5500',
          email: 'pedro@valeverde.agro',
        ),
        Producer(
          id: 'p-d',
          name: 'Juliana Souza',
          farm: 'Laticínios Serra Azul',
          hectares: 220,
          productionAreas: [
            ProductionArea(typeId: 'pt-leite', typeName: 'Leite', hectares: 180),
            ProductionArea(typeId: 'pt-carne', typeName: 'Carne', hectares: 40),
          ],
          productionSize: ProductionSize.pequeno,
          groupId: 'g1',
          groupName: 'Grupo Cerrado Norte',
          cadproCode: 'CADPRO-2025-0155',
          document: '123.456.789-10',
          car: 'MT-5107000-SERRAAZUL01',
          municipality: 'Sinop',
          stateUf: 'MT',
          phone: '(66) 99100-3344',
          email: 'juliana@serraazul.agro',
          harvestMode: HarvestMode.unica,
        ),
      ];

  // Compat: aliases usados antes.
  static List<CatalogProduct> get exchangeableProducts => initialProducts();
  static List<Producer> get producers => initialProducers();

  static List<Supplier> initialSuppliers() => [
        Supplier(
          id: 's1',
          name: 'AgroSupply Multinacional',
          cnpj: '00.111.222/0001-33',
          contact: 'ricardo@agrosupply.com',
          country: 'Brasil / Global',
        ),
        Supplier(
          id: 's2',
          name: 'CampoVerde Insumos',
          cnpj: '55.666.777/0001-88',
          contact: 'comercial@campoverde.com',
          country: 'Brasil — Centro-Oeste',
        ),
      ];

  static FeeConfig initialFeeConfig() => FeeConfig(
        kgPerHa: 33,
        defaultSeason: 'Safra 2026/27',
        commodityLabel: 'soja',
      );

  /// Cotações base do letreiro (atualizadas com variação mock a cada 10 min).
  static List<MarketQuote> initialMarketQuotes() => [
        MarketQuote(
          id: 'mq-soja',
          label: 'SOJA',
          unit: 'sc',
          price: 128.50,
          previousPrice: 127.80,
        ),
        MarketQuote(
          id: 'mq-boi',
          label: 'BOI GORDO',
          unit: '@',
          price: 312.40,
          previousPrice: 314.10,
        ),
        MarketQuote(
          id: 'mq-leite',
          label: 'LEITE',
          unit: 'L',
          price: 2.48,
          previousPrice: 2.45,
        ),
        MarketQuote(
          id: 'mq-diesel',
          label: 'DIESEL',
          unit: 'L',
          price: 5.89,
          previousPrice: 5.92,
        ),
      ];

  static List<CarrierCompany> initialCarriers() => [
        CarrierCompany(
          id: 'c1',
          name: 'TransCampo Logística',
          cnpj: '12.345.678/0001-90',
          contact: 'lucas@transcampo.com',
          region: 'MT / GO',
          fleetSize: 48,
        ),
        CarrierCompany(
          id: 'c2',
          name: 'AgroFrete Brasil',
          cnpj: '98.765.432/0001-10',
          contact: 'ops@agrofrete.com',
          region: 'Centro-Oeste',
          fleetSize: 32,
        ),
        CarrierCompany(
          id: 'c3',
          name: 'Rota Safra Transportes',
          cnpj: '11.222.333/0001-44',
          contact: 'contato@rotasafra.com',
          region: 'MS / MT',
          fleetSize: 21,
        ),
      ];

  static const users = [
    DemoUser(
      id: 'u0',
      name: 'Tiago Admin',
      email: 'admin@erpagro.com',
      password: 'demo',
      role: UserRole.admin,
      title: 'Administrador do Sistema',
      organization: 'ERP Agro',
    ),
    DemoUser(
      id: 'u1',
      name: 'Carlos Mendes',
      email: 'carlos@horizonte.agro',
      password: 'demo',
      role: UserRole.produtor,
      title: 'Produtor de Soja · Grande porte',
      organization: 'Fazenda Horizonte',
      producerId: 'p-a',
    ),
    DemoUser(
      id: 'u2',
      name: 'Ana Ribeiro',
      email: 'ana@boavista.agro',
      password: 'demo',
      role: UserRole.produtor,
      title: 'Produtor de Soja · Médio porte',
      organization: 'Sítio Boa Vista',
      producerId: 'p-b',
    ),
    DemoUser(
      id: 'u3',
      name: 'Marina Costa',
      email: 'marina@erpagro.com',
      password: 'demo',
      role: UserRole.gestora,
      title: 'Operadora do Ecossistema',
      organization: 'ERP Agro Gestora',
    ),
    DemoUser(
      id: 'u4',
      name: 'Ricardo Blum',
      email: 'ricardo@agrosupply.com',
      password: 'demo',
      role: UserRole.fornecedor,
      title: 'Gerente Comercial Brasil',
      organization: 'AgroSupply Multinacional',
      supplierId: 's1',
    ),
    DemoUser(
      id: 'u5',
      name: 'Lucas Ferreira',
      email: 'lucas@transcampo.com',
      password: 'demo',
      role: UserRole.transportadora,
      title: 'Coordenador de Fretes',
      organization: 'TransCampo Logística',
      carrierId: 'c1',
    ),
    DemoUser(
      id: 'u6',
      name: 'Juliana Souza',
      email: 'juliana@serraazul.agro',
      password: 'demo',
      role: UserRole.produtor,
      title: 'Produtor de Leite · Pequeno porte',
      organization: 'Laticínios Serra Azul',
      producerId: 'p-d',
    ),
  ];

  static List<StockItem> initialStock() => [
        StockItem(
          producerId: 'p-a',
          productId: 'ins-diesel',
          productName: 'Gasóleo / Diesel',
          unit: 'L',
          quantity: 18000,
          minThreshold: 2000,
        ),
        StockItem(
          producerId: 'p-a',
          productId: 'ins-soja',
          productName: 'Soja (grãos)',
          unit: 'sc',
          quantity: 2800,
          minThreshold: 400,
        ),
        StockItem(
          producerId: 'p-a',
          productId: 'ins-semente',
          productName: 'Semente de Soja',
          unit: 'sc',
          quantity: 420,
          minThreshold: 80,
        ),
        StockItem(
          producerId: 'p-a',
          productId: 'ins-fert',
          productName: 'Fertilizante NPK',
          unit: 't',
          quantity: 95,
          minThreshold: 15,
        ),
        StockItem(
          producerId: 'p-b',
          productId: 'ins-diesel',
          productName: 'Gasóleo / Diesel',
          unit: 'L',
          quantity: 900,
          minThreshold: 1500,
        ),
        StockItem(
          producerId: 'p-b',
          productId: 'ins-soja',
          productName: 'Soja (grãos)',
          unit: 'sc',
          quantity: 180,
          minThreshold: 250,
        ),
        StockItem(
          producerId: 'p-b',
          productId: 'ins-semente',
          productName: 'Semente de Soja',
          unit: 'sc',
          quantity: 110,
          minThreshold: 40,
        ),
        StockItem(
          producerId: 'p-b',
          productId: 'ins-fert',
          productName: 'Fertilizante NPK',
          unit: 't',
          quantity: 28,
          minThreshold: 8,
        ),
        StockItem(
          producerId: 'p-c',
          productId: 'ins-diesel',
          productName: 'Gasóleo / Diesel',
          unit: 'L',
          quantity: 6500,
          minThreshold: 1200,
        ),
        StockItem(
          producerId: 'p-c',
          productId: 'ins-soja',
          productName: 'Soja (grãos)',
          unit: 'sc',
          quantity: 900,
          minThreshold: 150,
        ),
        StockItem(
          producerId: 'p-d',
          productId: 'ins-diesel',
          productName: 'Gasóleo / Diesel',
          unit: 'L',
          quantity: 2100,
          minThreshold: 800,
        ),
        StockItem(
          producerId: 'p-d',
          productId: 'ins-soja',
          productName: 'Soja (grãos)',
          unit: 'sc',
          quantity: 40,
          minThreshold: 60,
        ),
      ];

  static List<NeedLine> initialNeeds() => [
        NeedLine(
          id: 'n1',
          producerId: 'p-a',
          productId: 'ins-semente',
          productName: 'Semente de Soja',
          quantity: 200,
          unit: 'sc',
          mode: PurchaseMode.planeada,
        ),
        NeedLine(
          id: 'n2',
          producerId: 'p-b',
          productId: 'ins-semente',
          productName: 'Semente de Soja',
          quantity: 90,
          unit: 'sc',
          mode: PurchaseMode.planeada,
        ),
        NeedLine(
          id: 'n3',
          producerId: 'p-a',
          productId: 'ins-fert',
          productName: 'Fertilizante NPK',
          quantity: 40,
          unit: 't',
          mode: PurchaseMode.planeada,
        ),
      ];

  static List<PurchaseLot> initialLots() => [
        PurchaseLot(
          id: 'lot1',
          code: 'LOTE-2026-014',
          productId: 'ins-semente',
          productName: 'Semente de Soja',
          totalQuantity: 290,
          unit: 'sc',
          participantIds: ['p-a', 'p-b'],
          status: LotStatus.cotacao,
          quotedPricePerUnit: 485.0,
          supplierName: 'AgroSupply Multinacional',
        ),
        PurchaseLot(
          id: 'lot2',
          code: 'LOTE-2026-011',
          productId: 'ins-fert',
          productName: 'Fertilizante NPK',
          totalQuantity: 40,
          unit: 't',
          participantIds: ['p-a'],
          status: LotStatus.noArmazem,
          quotedPricePerUnit: 3120.0,
          supplierName: 'AgroSupply Multinacional',
          settled: true,
          settledAt: DateTime(2026, 3, 12),
        ),
        PurchaseLot(
          id: 'lot3',
          code: 'LOTE-2026-009',
          productId: 'ins-diesel',
          productName: 'Gasóleo / Diesel',
          totalQuantity: 12000,
          unit: 'L',
          participantIds: ['p-a', 'p-b', 'p-d'],
          status: LotStatus.faturado,
          quotedPricePerUnit: 5.85,
          supplierName: 'AgroSupply Multinacional',
        ),
      ];

  static List<WarehouseBatch> initialWarehouse() => [
        WarehouseBatch(
          id: 'w1',
          lotId: 'lot2',
          productName: 'Fertilizante NPK',
          receivedQty: 40,
          distributedQty: 12,
          unit: 't',
        ),
      ];

  static List<CarrierShipment> initialShipments() => [
        CarrierShipment(
          id: 'sh1',
          type: 'entrega',
          origin: 'Armazém Retaguarda — Polo MT',
          destination: 'Fazenda Horizonte',
          productName: 'Fertilizante NPK',
          quantity: 8,
          unit: 't',
          status: 'Agendado',
          carrierId: 'c1',
          carrierName: 'TransCampo Logística',
        ),
        CarrierShipment(
          id: 'sh2',
          type: 'entrega',
          origin: 'Armazém Retaguarda — Polo MT',
          destination: 'Sítio Boa Vista',
          productName: 'Fertilizante NPK',
          quantity: 4,
          unit: 't',
          status: 'Em rota',
          carrierId: 'c2',
          carrierName: 'AgroFrete Brasil',
        ),
      ];

  /// Liquidação já concluída do lote de fertilizante (demo).
  static List<FinancialSettlement> initialSettlements() => [
        FinancialSettlement(
          id: 'fs1',
          lotId: 'lot2',
          lotCode: 'LOTE-2026-011',
          totalAmount: 40 * 3120.0,
          participantIds: ['p-a'],
          settledAt: DateTime(2026, 3, 12),
        ),
      ];

  /// Taxa já cobrada a Juliana (demo parcial).
  static List<FeeCharge> initialFeeCharges() => [
        FeeCharge(
          id: 'fee1',
          producerId: 'p-d',
          season: 'Safra 2025/26',
          harvestMode: HarvestMode.unica,
          hectares: 220,
          kgCharged: 220 * 33,
          status: FeeChargeStatus.cobrada,
          chargedAt: DateTime(2026, 2, 1),
        ),
      ];

  /// Empréstimo histórico com reposição ainda aberta (demo).
  static List<TransferLoan> initialTransfers() => [
        TransferLoan(
          id: 'tr-demo1',
          fromProducerId: 'p-a',
          toProducerId: 'p-d',
          productId: 'ins-diesel',
          productName: 'Gasóleo / Diesel',
          quantity: 400,
          unit: 'L',
          freightCost: 350,
          freightPayerId: 'p-d',
          sameGroup: true,
          status: TransferStatus.reposicaoGerada,
          carrierId: 'c1',
          carrierName: 'TransCampo Logística',
          replenishmentOrderId: 'OC-REP-1000',
          replenishmentPurchaseId: 'dp-rep-demo1',
        ),
      ];

  static List<ReplenishmentOrder> initialReplenishments() => [
        ReplenishmentOrder(
          id: 'rep1',
          code: 'OC-REP-1000',
          transferId: 'tr-demo1',
          borrowerId: 'p-d',
          donorId: 'p-a',
          productId: 'ins-diesel',
          productName: 'Gasóleo / Diesel',
          quantity: 400,
          unit: 'L',
          status: ReplenishmentStatus.compraEmitida,
          linkedDirectPurchaseId: 'dp-rep-demo1',
        ),
      ];

  static List<DirectPurchase> initialDirectPurchases() => [
        DirectPurchase(
          id: 'dp-rep-demo1',
          code: 'DIR-REP-1000',
          producerId: 'p-d',
          productId: 'ins-diesel',
          productName: 'Gasóleo / Diesel',
          quantity: 400,
          unit: 'L',
          supplierName: 'AgroSupply Multinacional',
          status: DirectOrderStatus.confirmado,
          carrierId: 'c1',
          carrierName: 'TransCampo Logística',
          isReplenishment: true,
          replenishmentOrderId: 'OC-REP-1000',
          stockDestinationProducerId: 'p-a',
        ),
      ];
}
