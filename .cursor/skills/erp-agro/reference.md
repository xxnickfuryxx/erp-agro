# ERP Agro — Documento de Referência

## Visão Geral do Projeto

O **ERP Agro** é um sistema multiplataforma (Web e Mobile) concebido para orquestrar a gestão de inventário, a consolidação de compras e a logística fracionada de produtores rurais. O seu principal diferencial é a **Rede de Empréstimo Inteligente**, um algoritmo que monitoriza o stock de propriedades vizinhas e automatiza transferências de insumos essenciais (como combustível, sementes e peças) para mitigar ruturas operacionais em tempo real.

O projeto visa transformar as necessidades individuais dos agricultores num volume de compra consolidado, aumentando o poder de negociação junto das multinacionais, ao mesmo tempo que mantém a autonomia do produtor através da faturação direta.

## Core Features e Regras de Negócio

O sistema é construído sobre quatro pilares funcionais:

### 1. Sistema Bifurcado de Compras

*   **Compra Planeada (Lote Único):** O ERP recolhe a programação de consumo anual/sazonal dos produtores, consolida os dados e negocia o volume total diretamente com os fornecedores.
*   **Compra Direta (Just-in-Time):** Funcionalidade para necessidades imediatas, permitindo ao produtor ignorar a consolidação e efetuar o pedido diretamente ao fornecedor.
*   **Separação de Responsabilidades:** O fluxo financeiro é estabelecido diretamente entre o fornecedor e o produtor agrícola. O sistema ERP encarrega-se unicamente da gestão lógica e física da operação.

### 2. Rede de Transferência e Empréstimos Laterais

*   **Algoritmo de Matching de Stock:** Quando o sistema deteta uma rutura de stock num produtor (ex: Produtor B sem gasóleo), procura ativamente por um excedente ocioso noutro produtor do ecossistema.
*   **Validação de Grupo:** A transferência física só é autorizada se o Produtor A (com excedente) e o Produtor B (com défice) pertencerem ao mesmo grupo operativo.
*   **Custos e Reposição:** O frete da transferência é faturado diretamente ao produtor que solicita o empréstimo (Produtor B). O ERP gera uma ordem de compra vinculativa para que o Produtor B reponha o stock original do Produtor A.

### 3. Orquestração Logística Terceirizada

*   **Armazéns de Retaguarda:** A carga adquirida no fornecedor é retida num pólo central de armazenamento gerido pela entidade operadora do sistema.
*   **Logística Fracionada:** O sistema aciona transportadoras parceiras para fracionar a carga total e efetuar as entregas nas fazendas de acordo com o registo de consumo diário.
*   **Gestão de Entregadores:** A plataforma possui um módulo de integração dedicado às empresas de logística terceirizadas, que gerem os fretes de entrega e das transferências de empréstimos.

### 4. Categorização Estruturada

*   Os clientes/produtores são classificados por:
    *   **Área de Exploração:** Registo em hectares (ha).
    *   **Foco Produtivo:** Tipificação agrícola (Ex: Soja, Leite, Pecuária de Corte).
    *   **Volume:** Escalão de produção.
*   O sistema cobra uma taxa de gestão de 33 kg de soja por cada hectare anual administrado, suportando configurações para áreas de safra única ou múltipla.

## Stack Tecnológica

*   **Frontend (MVP e Painel Web):** Flutter Web. (Permite forte partilha de código para futuras implementações em iOS/Android nativo para os motoristas e equipas de terreno).
*   **Backend (Motor ERP):** Java Spring Boot. (Responsável pelas regras transacionais, validação de grupos e algoritmo de *matching* de stock).
*   **Base de Dados:** PostgreSQL. (Estrutura relacional robusta com suporte a PostGIS, para garantir a consistência das transações de inventário e preparar a infraestrutura para a otimização de rotas geográficas de frete).

## Versão Atual (0.0.1 - Mockup Executável)

O repositório atual contém o protótipo inicial (MVP Visual) construído inteiramente em Flutter Web. O seu objetivo é validar a interface de utilizador (UI) e o fluxo lógico (UX) com investidores.

**Características da Versão 0.0.1:**

*   Ausência de backend e base de dados.
*   Dados de *mock* integrados diretamente no código (Produtores, Insumos, Transportadoras).
*   Simulação funcional das regras de "Compra Direta vs Planeada" e "Transferência de Insumos com Cobrança de Frete".
