import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Letreiro estilo canal de notícias com cotações de mercado.
/// Atualiza os valores a cada 10 minutos.
class MarketQuotesTicker extends StatefulWidget {
  const MarketQuotesTicker({super.key, required this.state});

  final AppState state;

  @override
  State<MarketQuotesTicker> createState() => _MarketQuotesTickerState();
}

class _MarketQuotesTickerState extends State<MarketQuotesTicker>
    with SingleTickerProviderStateMixin {
  static const _refreshInterval = Duration(minutes: 10);
  static const _scrollDuration = Duration(seconds: 40);

  late final AnimationController _scroll;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _scroll = AnimationController(vsync: this, duration: _scrollDuration)
      ..repeat();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      widget.state.refreshMarketQuotes();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quotes = widget.state.marketQuotes;
    final updated = widget.state.marketQuotesUpdatedAt;
    final timeFmt = DateFormat('HH:mm');

    if (quotes.isEmpty) return const SizedBox.shrink();

    final segment = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final q in quotes) _QuoteChip(quote: q),
        const SizedBox(width: 48),
      ],
    );

    return Container(
      height: 36,
      decoration: const BoxDecoration(
        color: AppColors.forestDeep,
        border: Border(
          bottom: BorderSide(color: Color(0xFF2A4A42)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: AppColors.gold,
            alignment: Alignment.center,
            child: Text(
              'MERCADO',
              style: GoogleFonts.manrope(
                color: AppColors.forestDeep,
                fontWeight: FontWeight.w800,
                fontSize: 11,
                letterSpacing: 0.6,
              ),
            ),
          ),
          Expanded(
            child: ClipRect(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Desloca aproximadamente 2× a largura visível; conteúdo
                  // duplicado mantém o loop visual contínuo no mock.
                  return AnimatedBuilder(
                    animation: _scroll,
                    builder: (context, child) {
                      final shift = _scroll.value * constraints.maxWidth * 2;
                      return Transform.translate(
                        offset: Offset(-shift, 0),
                        child: child,
                      );
                    },
                    child: OverflowBox(
                      maxWidth: double.infinity,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [segment, segment, segment],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (updated != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'atual. ${timeFmt.format(updated)}',
                style: GoogleFonts.manrope(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuoteChip extends StatelessWidget {
  const _QuoteChip({required this.quote});

  final MarketQuote quote;

  @override
  Widget build(BuildContext context) {
    final up = quote.isUp;
    final color = up ? const Color(0xFF6EE7B7) : const Color(0xFFFCA5A5);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            quote.label,
            style: GoogleFonts.manrope(
              color: AppColors.goldSoft,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${quote.currency} ${quote.formattedPrice}/${quote.unit}',
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${up ? '▲' : '▼'} ${quote.changePct.abs().toStringAsFixed(2)}%',
            style: GoogleFonts.manrope(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 18),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
