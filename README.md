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

## O que o mock cobre agora

- CADPRO com Nº Identificador, edição, status, pesquisa
- Tipos de produção dinâmicos + reservas de ha
- **Cadastro de fornecedores**
- **Parâmetros de taxa** (kg/ha, commodity, safra) editáveis
- Insumos com sync de stock em todas as fazendas
- Relatórios (taxa, lotes, rede, armazém)
- Reset demo + cenários UML
- Produtor vê **Minha fazenda**
- Letreiro de cotações no header (soja, boi gordo, leite, diesel) atualizado a cada 10 min

## Documentação

- `.cursor/skills/erp-agro/SKILL.md`
- `.cursor/skills/erp-agro-regras-negocio/SKILL.md`
- `.cursor/skills/erp-agro/reference.md`
- `lib/modules/README.md`
