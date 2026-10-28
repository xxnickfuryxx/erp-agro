# ERP Agro

Sistema multiplataforma de gestão logística e compras agrícolas — **MVP visual mock** (v0.0.1).

## Demonstração

```bash
flutter pub get
flutter run -d chrome
```

### Perfis (senha: `demo`)

| Perfil | E-mail |
|--------|--------|
| Admin | admin@erpagro.com |
| Produtor A | carlos@horizonte.agro |
| Produtor B | ana@boavista.agro |
| Gestora | marina@erpagro.com |
| Fornecedor | ricardo@agrosupply.com |
| Transportadora | lucas@transcampo.com |

## Módulos (`lib/modules/`)

| Module | Função |
|--------|--------|
| `auth` | Login |
| `shell` | Shell + painel + cenários + reset demo |
| `producer` | CADPRO, tipos, insumos, **fornecedores**, grupos |
| `purchases` | Compras planeada / direta |
| `logistics` | Armazém + fretes (avançar status) |
| `network` | Empréstimos laterais / OC-REP |
| `stock` | Inventário / consumo |
| `fees` | Taxa configurável (kg/ha) + cobrança |
| `reports` | Relatórios consolidados |

## Uso rápido

1. Login (`demo`) → Painel mostra o guia em 3 passos  
2. **CADPRO** — nº identificador certifica o produtor (documento de classe); insumos ficam na aba do catálogo  
3. **Compras → Incluir no pool** — informar quantidade por fazenda  
4. **Compras → Lotes** — consolidar e acompanhar negociação  
5. **Taxas → Cobrar taxa** — valor da regra geral já vem preenchido; dá para reduzir (desconto combinado) e confirmar  

## O que o mock cobre agora

- CADPRO, tipos, insumos, fornecedores, grupos
- Compras em abas: **Pool** | **Lotes** (ou Urgente para produtor)
- Pool R\$/ha · negociação vs realizada
- Logística, rede/empréstimos, stock, taxas, relatórios
- Letreiro de cotações + prévia económica da safra
- Cenários demo + reset

## Documentação

- `.cursor/skills/erp-agro/SKILL.md`
- `.cursor/skills/erp-agro-regras-negocio/SKILL.md`
- `.cursor/skills/erp-agro/reference.md`
- `lib/modules/README.md`
