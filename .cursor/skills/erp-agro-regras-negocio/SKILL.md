---
name: erp-agro-regras-negocio
description: >-
  Regras de negócio do ERP Agro nos quatro pilares: compras bifurcadas
  (planeada vs direta), rede de empréstimos laterais com matching de stock,
  logística fracionada terceirizada e categorização de produtores. Usar ao
  implementar, simular ou validar fluxos de compra, transferência, frete,
  inventário, grupos operativos, armazém de retaguarda ou taxa de gestão.
---

# ERP Agro — Regras de Negócio

Aplicar estas regras em qualquer feature, mock ou validação de fluxo. Para visão geral e stack, ver skill `erp-agro`.

## 1. Sistema Bifurcado de Compras

| Modalidade | Comportamento |
|------------|---------------|
| **Compra Planeada (Lote Único)** | Recolher programação anual/sazonal → consolidar volume → negociar com fornecedor |
| **Compra Direta (JIT)** | Necessidade imediata → produtor ignora consolidação → pedido direto ao fornecedor |

**Pipeline planeada (UML):** programação → consolidação → cotação → aprovação → faturação → **liquidação** → trânsito → armazém → JIT.

**Separação de responsabilidades:** o pagamento real é **fornecedor ↔ produtor**. O ERP **regista** faturação e liquidação para visibilidade operacional — não intermedia o dinheiro.

### Checklist de implementação

- [x] UI distingue claramente Planeada vs Direta
- [x] Consolidação só entra no fluxo Planeada (qualquer produto com necessidades)
- [x] Mock regista liquidação sem misturar com pagamento real
- [x] Despacho (`emTransito`) separado da receção no armazém

## 2. Rede de Transferência e Empréstimos Laterais

Fluxo obrigatório:

1. Detetar **rutura** no Produtor B (ex.: sem gasóleo).
2. **Matching de stock:** procurar excedente ocioso noutro produtor (A).
3. **Validação de grupo:** A e B no **mesmo grupo operativo** — senão, bloquear transferência.
4. Autorizar transferência física A → B.
5. **Frete** faturado ao solicitante (**Produtor B**).
6. Gerar **ordem de compra vinculativa (OC-REP)** + **compra direta de reposição** para B comprar e repor o stock de A.
7. Ao entregar a compra de reposição, o stock entra no **doador A** (não em B).

### Invariantes

- Sem mesmo grupo → sem transferência.
- Frete nunca fica a cargo do doador (A) neste fluxo.
- Empréstimo implica compromisso de reposição (não é doação).
- `ReplenishmentOrder` + `DirectPurchase.isReplenishment` ligam os passos 15→16 do UML.

## 3. Orquestração Logística Terceirizada

1. **Armazém de retaguarda:** carga do fornecedor fica no pólo central da operadora.
2. **Logística fracionada:** transportadoras parceiras fracionam e entregam conforme consumo diário nas fazendas.
3. **Módulo de entregadores:** integra empresas de logística para fretes de entrega **e** de transferências de empréstimo.

### Checklist

- [x] Distinguir frete de entrega consolidada vs frete de empréstimo lateral
- [x] Modelar transportadora como entidade de domínio

## 4. CADPRO e Categorização Estruturada

### CADPRO — Cadastro do Produtor Rural

Registo obrigatório no módulo `lib/modules/producer/`:

- **Nº Identificador CADPRO** (campo editável; único)
- Identificação: nome, fazenda, CPF/CNPJ, CAR, município/UF, contactos
- Status: pendente | ativo | inativo
- Associação a **grupo operativo**

### Tipos de produção dinâmicos

Catálogo `ProductionTypeDef` (não enum fixo):

- Aba **Tipos** no CADPRO → listar / adicionar / ativar-desativar
- No formulário do produtor: linhas dinâmicas (**Adicionar tipo** + dropdown + ha)
- `ProductionArea` referencia `typeId` + `typeName` + hectares
- Soma das reservas **≤ área total** da fazenda

Métodos: `registerProductionType`, `registerClient(cadproCode:)`, `updateProductionAreas`.

### Taxa de gestão

33 kg de soja × hectare total administrado × multiplicador de safra (`unica`=1, `multipla`=2).  
Cobrança: `chargeManagementFee` / `chargeAllManagementFees` + histórico `FeeCharge`.

## Domínio mínimo (mock / modelos)

- **Producer / CADPRO** (nº identificador, documento, CAR, áreas)
- **ProductionTypeDef** (catálogo dinâmico)
- **ProductionArea** (typeId + ha)
- Insumo / CatalogProduct
- Grupo operativo
- Pedidos, lotes, transferências, OC-REP, liquidação, FeeCharge

## Arquitetura modular

| Module | Path |
|--------|------|
| Auth | `lib/modules/auth/` |
| Shell / Dashboard | `lib/modules/shell/` |
| Producer (CADPRO) | `lib/modules/producer/` |
| Purchases | `lib/modules/purchases/` |
| Logistics | `lib/modules/logistics/` |
| Network (loans) | `lib/modules/network/` |
| Stock | `lib/modules/stock/` |
| Fees | `lib/modules/fees/` |
| Shared core | `lib/core/` |

## Cenários mock (`DemoScenarioId`)

| ID | O que demonstra |
|----|-----------------|
| `compraPlaneadaCompleta` | Lote → cotação → aprovação → fatura → liquidação → armazém |
| `ruturaEmprestimoReposicao` | Rutura B → matching → OC-REP entregue a A |
| `liquidacaoFinanceira` | Liquidação de lote pendente |
| `taxaGestao` | Cobrança 33 kg/ha (safra múltipla em A) |

Correr via `AppState.runDemoScenario` (UI no painel Admin/Gestora).

## Ao simular na v0.0.1

Priorizar UX que demonstre:

1. CADPRO com Nº Identificador + tipos dinâmicos e ha por tipo
2. Escolha Compra Direta vs Planeada
3. Liquidação financeira registada
4. Transferência com matching + frete + reposição ao doador
5. Cobrança efetiva da taxa de gestão
