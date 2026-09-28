---
name: erp-agro
description: >-
  Contexto do projeto ERP Agro — sistema multiplataforma de gestão logística e
  compras agrícolas com Rede de Empréstimo Inteligente. Usar sempre ao trabalhar
  neste repositório, ao criar features, mockups, fluxos UX, entidades de domínio
  ou ao discutir arquitetura, stack, compras, empréstimos laterais, logística
  fracionada ou inventário agrícola.
---

# ERP Agro — Contexto do Projeto

## O que é

O **ERP Agro** orquestra inventário, consolidação de compras e logística fracionada de produtores rurais. Diferencial: **Rede de Empréstimo Inteligente** — algoritmo que monitoriza stock de propriedades vizinhas e automatiza transferências de insumos (combustível, sementes, peças) para mitigar ruturas em tempo real.

Objetivo: transformar necessidades individuais em volume de compra consolidado (poder de negociação com multinacionais), mantendo autonomia do produtor via faturação direta.

## Stack

| Camada | Tecnologia | Papel |
|--------|------------|--------|
| Frontend MVP / Painel Web | **Flutter Web** | UI/UX; partilha de código para iOS/Android (motoristas/terreno) |
| Backend ERP | **Java Spring Boot** | Regras transacionais, validação de grupos, matching de stock |
| Base de dados | **PostgreSQL** (+ PostGIS futuro) | Inventário, consistência; base para otimização geográfica de frete |

## Versão atual (0.0.1 — Mockup Executável)

- Protótipo **Flutter Web** para validar UI/UX com investidores.
- **Sem backend nem base de dados.**
- Código organizado em **submódulos** (`lib/modules/`) + `lib/core/`.
- CADPRO com **Nº Identificador** e **tipos de produção dinâmicos** (cadastro + reservas de ha).
- Simular: Compras, logística, empréstimos, liquidação, OC-REP, taxa 33 kg/ha.
- Cenários demo no painel Admin/Gestora.

## Arquitetura de pastas

```
lib/core/          → models, state, data, theme, widgets
lib/modules/auth|shell|producer|purchases|logistics|network|stock|fees
```

## Pipeline UML (mock)

1. Programação de necessidades  
2. Consolidação em lote único  
3. Cotação  
4. Aprovação / fecho  
5. Faturação direta  
6. **Liquidação financeira** (registo ERP; pagamento fora)  
7–8. Despacho em trânsito → receção no armazém  
9–10. Distribuição JIT → stock na fazenda  
11–12. Consumo diário → rutura  
13–14. Matching + transferência A→B  
15–16. **OC-REP + compra vinculativa** → stock reposto em A  
17. **Cobrança taxa** 33 kg soja/ha (safra única/múltipla)

## Como a IA deve agir neste repo

1. Tratar o código como **MVP visual + simulação de regras**, não como ERP completo.
2. Não inventar integração real com Spring Boot/PostgreSQL nesta fase, salvo pedido explícito.
3. Preferir mock local coerente com o domínio (produtores, grupos, insumos, transportadoras).
4. Respeitar as regras de negócio dos quatro pilares — ver skill `erp-agro-regras-negocio`.
5. Separação financeira: ERP **regista** faturação/liquidação; o pagamento real é fornecedor↔produtor.
6. Responder e documentar em português, alinhado ao domínio agrícola.

## Pilares (resumo)

1. **Compras bifurcadas** — Planeada (lote consolidado) vs Direta (JIT)
2. **Empréstimos laterais** — matching + mesmo grupo + frete ao solicitante + OC-REP → compra de reposição
3. **Logística terceirizada** — armazém de retaguarda + fracionamento + transportadoras
4. **CADPRO + categorização** — cadastro do produtor rural; fazenda com **múltiplos focos** e **hectares reservados** por tipo; taxa 33 kg soja/ha/ano

## Referência detalhada

- Documento completo: [reference.md](reference.md)
- Regras de negócio operacionais: skill `erp-agro-regras-negocio`
