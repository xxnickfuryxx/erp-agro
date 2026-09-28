import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.state});

  final AppState state;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _fill(DemoUser user) {
    setState(() {
      _email.text = user.email;
      _password.text = user.password;
    });
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 980;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.forestDeep,
              Color(0xFF16352E),
              Color(0xFF1F4A3E),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -80,
              top: -60,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              left: -100,
              bottom: -80,
              child: Container(
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: wide
                        ? Row(
                            children: [
                              Expanded(flex: 5, child: _brandPanel()),
                              const SizedBox(width: 28),
                              Expanded(flex: 6, child: _loginCard()),
                            ],
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                _brandPanel(compact: true),
                                const SizedBox(height: 24),
                                _loginCard(),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _brandPanel({bool compact = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.agriculture_rounded, color: AppColors.forestDeep),
            ),
            const SizedBox(width: 12),
            Text(
              'ERP Agro',
              style: GoogleFonts.manrope(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? 20 : 36),
        Text(
          'Gestão inteligente de\ncompras e logística agrícola',
          style: GoogleFonts.manrope(
            fontSize: compact ? 26 : 38,
            height: 1.15,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Consolide volume, orquestre entregas fracionadas e ative a Rede de Empréstimo Inteligente entre produtores do mesmo grupo.',
          style: GoogleFonts.manrope(
            fontSize: 15,
            height: 1.5,
            color: Colors.white.withValues(alpha: 0.72),
          ),
        ),
        if (!compact) ...[
          const SizedBox(height: 36),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _FeatureTag('Compra planeada vs direta'),
              _FeatureTag('Matching de stock'),
              _FeatureTag('Armazém de retaguarda'),
              _FeatureTag('Taxa 33 kg soja/ha'),
            ],
          ),
        ],
      ],
    );
  }

  Widget _loginCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Acesso à demonstração',
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Selecione um perfil ou autentique com as credenciais mock.',
            style: GoogleFonts.manrope(color: AppColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 22),
          TextField(
            controller: _email,
            decoration: const InputDecoration(
              labelText: 'E-mail',
              prefixIcon: Icon(Icons.mail_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Senha',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          if (widget.state.authError != null) ...[
            const SizedBox(height: 10),
            Text(
              widget.state.authError!,
              style: GoogleFonts.manrope(
                color: AppColors.danger,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submit,
              child: const Text('Entrar'),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Perfis de demonstração',
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          ...widget.state.users.map(_profileTile),
        ],
      ),
    );
  }

  Widget _profileTile(DemoUser user) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            _fill(user);
            widget.state.loginAs(user);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${user.role.shortLabel} · ${user.organization}',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Text(
                    user.role.shortLabel,
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.forest,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    widget.state.loginWithCredentials(_email.text, _password.text);
  }
}

class _FeatureTag extends StatelessWidget {
  const _FeatureTag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          color: AppColors.goldSoft,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
