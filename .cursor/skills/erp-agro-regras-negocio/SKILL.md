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

**Separação de responsabilidades:** fluxo financeiro é **fornecedor ↔ produtor**. O ERP gere apenas a operação **lógica e física** (pedidos, stock, entregas) — não intermedia pagamento.

### Checklist de implementação

- [ ] UI distingue claramente Planeada vs Direta
- [ ] Consolidação só entra no fluxo Planeada
- [ ] Mock/API não mistura faturação ERP com faturação fornecedor

## 2. Rede de Transferência e Empréstimos Laterais

Fluxo obrigatório:

1. Detetar **rutura** no Produtor B (ex.: sem gasóleo).
2. **Matching de stock:** procurar excedente ocioso noutro produtor (A).
3. **Validação de grupo:** A e B no **mesmo grupo operativo** — senão, bloquear transferência.
4. Autorizar transferência física A → B.
5. **Frete** faturado ao solicitante (**Produtor B**).
6. Gerar **ordem de compra vinculativa** para B repor o stock original de A.

### Invariantes

- Sem mesmo grupo → sem transferência.
- Frete nunca fica a cargo do doador (A) neste fluxo.
- Empréstimo implica compromisso de reposição (não é doação).

## 3. Orquestração Logística Terceirizada

1. **Armazém de retaguarda:** carga do fornecedor fica no pólo central da operadora.
2. **Logística fracionada:** transportadoras parceiras fracionam e entregam conforme consumo diário nas fazendas.
3. **Módulo de entregadores:** integra empresas de logística para fretes de entrega **e** de transferências de empréstimo.

### Checklist

- [ ] Distinguir frete de entrega consolidada vs frete de empréstimo lateral
- [ ] Modelar transportadora como entidade de domínio (já no mock da v0.0.1)

## 4. Categorização Estruturada

Produtores classificados por:

- **Área de exploração** (hectares)
- **Foco produtivo** (ex.: Soja, Leite, Pecuária de Corte)
- **Volume** (escalão de produção)

**Taxa de gestão:** 33 kg de soja por hectare anual administrado; suportar safra única ou múltipla.

## Domínio mínimo (mock / modelos)

Entidades esperadas no MVP:

- Produtor (ha, foco, volume, grupo operativo, stock)
- Insumo (tipo, quantidade, unidade)
- Grupo operativo
- Transportadora / frete
- Pedido (planeado | direto)
- Transferência / empréstimo (origem, destino, frete, ordem de reposição)

## Ao simular na v0.0.1

Priorizar UX que demonstre:

1. Escolha Compra Direta vs Planeada
2. Transferência com matching + frete ao solicitante + reposição
