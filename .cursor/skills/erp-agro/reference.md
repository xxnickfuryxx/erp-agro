# ERP Agro — Documento de Referência

## Visão Geral do Projeto

O **ERP Agro** é um sistema multiplataforma (Web e Mobile) concebido para orquestrar a gestão de inventário, a consolidação de compras e a logística fracionada de produtores rurais. O seu principal diferencial é a **Rede de Empréstimo Inteligente**, um algoritmo que monitoriza o stock de propriedades vizinhas e automatiza transferências de insumos essenciais (como combustível, sementes e peças) para mitigar ruturas operacionais em tempo real.

O projeto visa transformar as necessidades individuais dos agricultores num volume de compra consolidado, aumentando o poder de negociação junto das multinacionais, ao mesmo tempo que mantém a autonomia do produtor através da faturação direta.

## Core Features e Regras de Negócio

O sistema é construído sobre quatro pilares funcionais:

### 1. Sistema Bifurcado de Compras

*   **Compra Planeada (Lote Único):** O ERP recolhe a programação de consumo anual/sazonal dos produtores, consolida os dados e negocia o volume total diretamente com os fornecedores.
*   **Compra Direta (Just-in-Time):** Funcionalidade para necessidades imediatas, permitindo ao produtor ignorar a consolidação e efetuar o pedido diretamente ao fornecedor.
*   **Pipeline completo:** programação → consolidação → cotação → aprovação → faturação → **liquidação financeira** → despacho em trânsito → receção no armazém → distribuição JIT.
*   **Separação de Responsabilidades:** O pagamento ocorre entre fornecedor e produtor. O ERP **regista** faturação e liquidação para auditoria operacional (`FinancialSettlement`).

### 2. Rede de Transferência e Empréstimos Laterais

*   **Algoritmo de Matching de Stock:** Quando o sistema deteta uma rutura de stock num produtor (ex: Produtor B sem gasóleo), procura ativamente por um excedente ocioso noutro produtor do ecossistema.
*   **Validação de Grupo:** A transferência física só é autorizada se o Produtor A (com excedente) e o Produtor B (com défice) pertencerem ao mesmo grupo operativo.
*   **Custos e Reposição:** O frete é faturado ao solicitante (B). O ERP gera **OC-REP** (`ReplenishmentOrder`) e uma **compra direta de reposição** cujo stock final é creditado ao **doador A** (passos 15→16 do UML).

### 3. Orquestração Logística Terceirizada

*   **Armazéns de Retaguarda:** A carga adquirida no fornecedor é retida num pólo central de armazenamento gerido pela entidade operadora do sistema.
*   **Logística Fracionada:** O sistema aciona transportadoras parceiras para fracionar a carga total e efetuar as entregas nas fazendas de acordo com o registo de consumo diário.
*   **Gestão de Entregadores:** A plataforma possui um módulo de integração dedicado às empresas de logística terceirizadas, que gerem os fretes de entrega e das transferências de empréstimos.

### 4. CADPRO e Categorização Estruturada

*   **CADPRO:** registo com **Nº Identificador** editável, CPF/CNPJ, CAR, município/UF, contactos e status.
*   **Tipos de produção dinâmicos:** catálogo cadastrável (`ProductionTypeDef`); no formulário usa-se **Adicionar tipo** + dropdown + hectares (não campos fixos Soja/Leite/Carne).
*   **Produção multi-tipo:** soma das reservas ≤ área total da fazenda.
*   **Taxa de gestão:** 33 kg soja × ha × multiplicador de safra.

## Stack Tecnológica

*   **Frontend (MVP e Painel Web):** Flutter Web, organizado em **submódulos** (`lib/modules/*`) e núcleo partilhado (`lib/core/*`).
*   **Backend (Motor ERP):** Java Spring Boot (futuro).
*   **Base de Dados:** PostgreSQL (+ PostGIS futuro).

## Versão Atual (0.0.1 - Mockup Executável)

*   Ausência de backend e base de dados.
*   Mock em `lib/core/data/mock_data.dart`.
*   Modules: `auth`, `shell`, `producer`, `purchases`, `logistics`, `network`, `stock`, `fees`.
*   Cenários UML no painel Admin/Gestora.

### Ficheiros-chave

*   `lib/modules/producer/producer_screen.dart` — CADPRO + tipos dinâmicos
*   `lib/core/models/models.dart` — `ProductionTypeDef`, `ProductionArea`, `Producer`
*   `lib/core/state/app_state.dart` — regras e cenários
*   `lib/modules/README.md` — mapa dos submódulos
