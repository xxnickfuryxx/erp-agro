# ERP Agro

Sistema multiplataforma de gestão logística e compras agrícolas — **MVP visual mock** (v0.0.1).

## Demonstração

```bash
flutter pub get
flutter run -d chrome
```

### Perfis de acesso (senha: `demo`)

| Perfil | Utilizador | E-mail |
|--------|------------|--------|
| Admin (acesso total) | Tiago Admin | admin@erpagro.com |
| Produtor A (excedente) | Carlos Mendes | carlos@horizonte.agro |
| Produtor B (défice) | Ana Ribeiro | ana@boavista.agro |
| Gestora ERP | Marina Costa | marina@erpagro.com |
| Fornecedor | Ricardo Blum | ricardo@agrosupply.com |
| Transportadora | Lucas Ferreira | lucas@transcampo.com |

## Modular architecture

```
lib/
  core/          → models, state, data, theme, widgets
  modules/
    auth/        → Login
    shell/       → Shell + dashboard
    producer/    → CADPRO (rural producer)
    purchases/   → Planned / direct purchases
    logistics/   → Warehouse + carriers
    network/     → Lateral loans
    stock/       → Inventory / consumption
    fees/        → Management fee
```

See `lib/modules/README.md`.

## Fluxo UML coberto

Programação → Lote → Cotação → Aprovação → Faturação → Liquidação → Trânsito → Armazém → JIT → Consumo → Rutura → Empréstimo → OC-REP → Taxa

### Cenários mock (Painel Admin / Gestora)

1. Compra planeada completa  
2. Rutura → empréstimo → reposição  
3. Liquidação financeira  
4. Cobrança taxa 33 kg/ha  

## Módulo CADPRO (`modules/producer`)

Menu **CADPRO** (Admin / Gestora):

| Aba | Função |
|-----|--------|
| **Produtores** | Novo CADPRO com **Nº Identificador** editável |
| **Tipos** | Cadastro dinâmico de tipos de produção |
| **Produtos** | Catálogo de insumos |
| **Grupos** | Grupos operativos para trocas |

### Reservas de hectares (dinâmicas)

- Botão **Adicionar tipo** / remover linha
- Dropdown com tipos cadastrados
- Soma das reservas ≤ área total da fazenda

## Documentação interna

- Skill: `.cursor/skills/erp-agro/SKILL.md`
- Regras: `.cursor/skills/erp-agro-regras-negocio/SKILL.md`
- Referência: `.cursor/skills/erp-agro/reference.md`
