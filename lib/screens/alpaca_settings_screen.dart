import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../Services/alpaca_service.dart';

/// Settings screen where user connects their Alpaca account
class AlpacaSettingsScreen extends StatefulWidget {
  const AlpacaSettingsScreen({super.key});

  @override
  State<AlpacaSettingsScreen> createState() => _AlpacaSettingsScreenState();
}

class _AlpacaSettingsScreenState extends State<AlpacaSettingsScreen> {
  final _keyCtrl    = TextEditingController();
  final _secretCtrl = TextEditingController();
  bool  _paperMode  = true;
  bool  _testing    = false;
  bool  _obscure    = true;
  AlpacaAccount? _testResult;
  String? _testError;

  Future<void> _testAndSave() async {
    if (_keyCtrl.text.isEmpty || _secretCtrl.text.isEmpty) {
      setState(() => _testError = 'Please enter both API Key and Secret');
      return;
    }

    setState(() { _testing = true; _testResult = null; _testError = null; });

    AlpacaService().configure(
      apiKey:    _keyCtrl.text.trim(),
      apiSecret: _secretCtrl.text.trim(),
      paperMode: _paperMode,
    );

    final account = await AlpacaService().getAccount();
    setState(() {
      _testing    = false;
      _testResult = account;
      _testError  = account == null ? 'Connection failed. Check your keys.' : null;
    });

    if (account != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppTheme.primary,
        content: const Text('✅ Alpaca connected! Ready to trade.',
            style: TextStyle(color: Colors.white)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutral,
      appBar: AppBar(
        backgroundColor: AppTheme.neutral,
        elevation: 0,
        title: const Text('Connect Alpaca Account',
            style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold,
                color: AppTheme.primary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Info card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryContainer),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('🔗 How to get your API keys',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 16)),
              const SizedBox(height: 12),
              _step('1', 'Sign up FREE at alpaca.markets'),
              _step('2', 'Go to Paper Trading → API Keys'),
              _step('3', 'Generate a new key & copy both values below'),
              _step('4', 'Start in Paper mode (fake money) to test safely'),
              const SizedBox(height: 8),
              const Text(
                '💰 Alpaca gives you \$100,000 virtual cash in Paper mode.',
                style: TextStyle(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w600),
              ),
            ]),
          ),
          const SizedBox(height: 28),

          // Mode toggle
          const Text('Trading Mode', style: TextStyle(fontWeight: FontWeight.bold,
              color: AppTheme.onSurface, fontSize: 15)),
          const SizedBox(height: 8),
          Row(children: [
            _modeChip('📄 Paper (Safe)', true),
            const SizedBox(width: 10),
            _modeChip('💵 Live (Real Money)', false),
          ]),
          if (!_paperMode)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '⚠️ Live mode uses REAL money. Make sure you understand the risks.',
                  style: TextStyle(color: AppTheme.onErrorContainer, fontSize: 13),
                ),
              ),
            ),
          const SizedBox(height: 24),

          // API Key
          const Text('API Key ID', style: TextStyle(fontWeight: FontWeight.bold,
              color: AppTheme.onSurface, fontSize: 15)),
          const SizedBox(height: 8),
          TextField(
            controller: _keyCtrl,
            decoration: InputDecoration(
              hintText: 'PKXXXXXXXXXXXXXXXXXXXXXXXX',
              hintStyle: const TextStyle(color: AppTheme.outlineVariant),
              filled: true, fillColor: AppTheme.surfaceContainerLowest,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppTheme.outlineVariant.withOpacity(0.3))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppTheme.outlineVariant.withOpacity(0.3))),
            ),
          ),
          const SizedBox(height: 16),

          // Secret
          const Text('API Secret Key', style: TextStyle(fontWeight: FontWeight.bold,
              color: AppTheme.onSurface, fontSize: 15)),
          const SizedBox(height: 8),
          TextField(
            controller: _secretCtrl,
            obscureText: _obscure,
            decoration: InputDecoration(
              hintText: '••••••••••••••••••••••••••••••••••••••••',
              hintStyle: const TextStyle(color: AppTheme.outlineVariant),
              filled: true, fillColor: AppTheme.surfaceContainerLowest,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppTheme.outlineVariant.withOpacity(0.3))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppTheme.outlineVariant.withOpacity(0.3))),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                    color: AppTheme.onSurfaceVariant),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Test & Save button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _testing ? null : _testAndSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _testing
                  ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                      SizedBox(width: 12),
                      Text('Testing connection...'),
                    ])
                  : const Text('Connect & Test', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),

          // Result
          if (_testError != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppTheme.errorContainer.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12)),
              child: Text('❌ $_testError',
                  style: const TextStyle(color: AppTheme.onErrorContainer)),
            ),
          ],
          if (_testResult != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.primaryContainer.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('✅ Connected!', style: TextStyle(fontWeight: FontWeight.bold,
                    color: AppTheme.primary, fontSize: 16)),
                const SizedBox(height: 8),
                _infoRow('Cash', '\$${_testResult!.cash.toStringAsFixed(2)}'),
                _infoRow('Buying Power', '\$${_testResult!.buyingPower.toStringAsFixed(2)}'),
                _infoRow('Portfolio Value', '\$${_testResult!.portfolioValue.toStringAsFixed(2)}'),
                _infoRow('Status', _testResult!.status.toUpperCase()),
              ]),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _step(String num, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      Container(
        width: 22, height: 22,
        decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
        child: Center(child: Text(num, style: const TextStyle(color: Colors.white,
            fontSize: 11, fontWeight: FontWeight.bold))),
      ),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: const TextStyle(color: AppTheme.onSurface, fontSize: 13))),
    ]),
  );

  Widget _modeChip(String label, bool isPaper) => GestureDetector(
    onTap: () => setState(() => _paperMode = isPaper),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _paperMode == isPaper ? AppTheme.primary : AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(
          fontWeight: FontWeight.bold,
          color: _paperMode == isPaper ? Colors.white : AppTheme.onSurfaceVariant)),
    ),
  );

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
    ]),
  );
}
