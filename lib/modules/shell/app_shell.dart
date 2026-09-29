import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/market_ticker.dart';
import 'dashboard_screen.dart';
import '../fees/fees_screen.dart';
import '../producer/producer_screen.dart';
import '../logistics/logistics_screen.dart';
import '../purchases/purchases_screen.dart';
import '../stock/stock_screen.dart';
import '../network/transfers_screen.dart';
import '../reports/reports_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.state});

  final AppState state;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.builder);

  final String label;
  final IconData icon;
  final Widget Function(AppState state) builder;
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  List<_NavItem> _itemsFor(UserRole role) {
    final common = <_NavItem>[
      _NavItem('Painel', Icons.dashboard_outlined, (s) => DashboardScreen(state: s)),
    ];

    /// Admin vê e opera tudo.
    if (role.isAdmin) {
      return [
        ...common,
        _NavItem('CADPRO', Icons.badge_outlined, (s) => ProducerScreen(state: s)),
        _NavItem('Compras', Icons.shopping_bag_outlined, (s) => PurchasesScreen(state: s)),
        _NavItem('Logística', Icons.local_shipping_outlined, (s) => LogisticsScreen(state: s)),
        _NavItem('Rede', Icons.hub_outlined, (s) => TransfersScreen(state: s)),
        _NavItem('Stock', Icons.inventory_2_outlined, (s) => StockScreen(state: s)),
        _NavItem('Taxas', Icons.payments_outlined, (s) => FeesScreen(state: s)),
        _NavItem('Relatórios', Icons.bar_chart_rounded, (s) => ReportsScreen(state: s)),
      ];
    }

    switch (role) {
      case UserRole.admin:
        return []; // tratado acima
      case UserRole.produtor:
        return [
          ...common,
          _NavItem('Minha fazenda', Icons.badge_outlined, (s) => ProducerScreen(state: s, myFarmOnly: true)),
          _NavItem('Compras', Icons.shopping_bag_outlined, (s) => PurchasesScreen(state: s)),
          _NavItem('Stock', Icons.inventory_2_outlined, (s) => StockScreen(state: s)),
          _NavItem('Empréstimos', Icons.swap_horiz_rounded, (s) => TransfersScreen(state: s)),
          _NavItem('Taxa', Icons.payments_outlined, (s) => FeesScreen(state: s)),
        ];
      case UserRole.gestora:
        return [
          ...common,
          _NavItem('CADPRO', Icons.badge_outlined, (s) => ProducerScreen(state: s)),
          _NavItem('Lotes', Icons.layers_outlined, (s) => PurchasesScreen(state: s)),
          _NavItem('Logística', Icons.local_shipping_outlined, (s) => LogisticsScreen(state: s)),
          _NavItem('Rede', Icons.hub_outlined, (s) => TransfersScreen(state: s)),
          _NavItem('Stock', Icons.inventory_2_outlined, (s) => StockScreen(state: s)),
          _NavItem('Taxas', Icons.payments_outlined, (s) => FeesScreen(state: s)),
          _NavItem('Relatórios', Icons.bar_chart_rounded, (s) => ReportsScreen(state: s)),
        ];
      case UserRole.fornecedor:
        return [
          ...common,
          _NavItem('Cotações', Icons.request_quote_outlined, (s) => PurchasesScreen(state: s)),
          _NavItem('Logística', Icons.local_shipping_outlined, (s) => LogisticsScreen(state: s)),
        ];
      case UserRole.transportadora:
        return [
          ...common,
          _NavItem('Fretes', Icons.local_shipping_outlined, (s) => LogisticsScreen(state: s)),
          _NavItem('Transferências', Icons.swap_horiz_rounded, (s) => TransfersScreen(state: s)),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.state.currentUser!;
    final items = _itemsFor(user.role);
    if (_index >= items.length) _index = 0;
    final wide = MediaQuery.sizeOf(context).width >= 960;

    final body = AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: KeyedSubtree(
        key: ValueKey('${user.id}-$_index'),
        child: items[_index].builder(widget.state),
      ),
    );

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            _SideNav(
              user: user,
              items: items,
              index: _index,
              onSelect: (i) => setState(() => _index = i),
              onLogout: widget.state.logout,
            ),
            Expanded(
              child: Column(
                children: [
                  _TopBar(user: user, state: widget.state),
                  MarketQuotesTicker(state: widget.state),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
                      child: body,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('ERP Agro · ${user.role.shortLabel}'),
        actions: [
          IconButton(
            onPressed: widget.state.logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Column(
        children: [
          MarketQuotesTicker(state: widget.state),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: body,
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        height: 68,
        destinations: [
          for (final item in items)
            NavigationDestination(icon: Icon(item.icon), label: item.label),
        ],
      ),
    );
  }
}

class _SideNav extends StatelessWidget {
  const _SideNav({
    required this.user,
    required this.items,
    required this.index,
    required this.onSelect,
    required this.onLogout,
  });

  final DemoUser user;
  final List<_NavItem> items;
  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 248,
      color: AppColors.forestDeep,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.agriculture_rounded, color: AppColors.forestDeep),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'ERP Agro',
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Mockup 0.0.1 · Demo',
                style: GoogleFonts.manrope(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final item = items[i];
                  final selected = i == index;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Material(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => onSelect(i),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item.icon,
                                size: 20,
                                color: selected
                                    ? AppColors.goldSoft
                                    : Colors.white.withValues(alpha: 0.55),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                item.label,
                                style: GoogleFonts.manrope(
                                  color: selected
                                      ? AppColors.goldSoft
                                      : Colors.white.withValues(alpha: 0.7),
                                  fontWeight:
                                      selected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      user.role.label,
                      style: GoogleFonts.manrope(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: onLogout,
                      icon: Icon(
                        Icons.logout,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      label: Text(
                        'Sair',
                        style: GoogleFonts.manrope(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.user, required this.state});

  final DemoUser user;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 18, 28, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.organization,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  user.title,
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          if (state.ruptures.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      size: 16, color: AppColors.danger),
                  const SizedBox(width: 6),
                  Text(
                    '${state.ruptures.length} rutura(s)',
                    style: GoogleFonts.manrope(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          CircleAvatar(
            backgroundColor: AppColors.forest.withValues(alpha: 0.12),
            child: Text(
              user.name.substring(0, 1),
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800,
                color: AppColors.forest,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
