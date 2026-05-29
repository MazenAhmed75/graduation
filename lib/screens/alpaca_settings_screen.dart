import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../Services/alpaca_service.dart';
import 'package:mindful_curator/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../Utils/currency_formatter.dart'; // Adjust path based on your actual directory structure

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
    final l10n = AppLocalizations.of(context)!;
    if (_keyCtrl.text.isEmpty || _secretCtrl.text.isEmpty) {
      setState(() => _testError = l10n.alpacaMissingFields);
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
      _testError  = account == null ? l10n.alpacaConnectionFailed : null;
    });

    if (account != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppTheme.primary,
    content: Text(l10n.alpacaConnectedSnackbar,
            style: TextStyle(color: Colors.white)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.neutral,
      appBar: AppBar(
        backgroundColor: AppTheme.neutral,
        elevation: 0,
        title: Text(l10n.alpacaSettingsTitle,
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
              Text(l10n.alpacaHowToTitle,
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 16)),
              const SizedBox(height: 12),
              _step(1, l10n.alpacaStep1),
              _step(2, l10n.alpacaStep2),
              _step(3, l10n.alpacaStep3),
              _step(4, l10n.alpacaStep4),
              const SizedBox(height: 8),
              Text(
                l10n.alpacaPaperInfo,
                style: TextStyle(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w600),
              ),
            ]),
          ),
          const SizedBox(height: 28),

          // Mode toggle
          Text(l10n.alpacaTradingMode, style: TextStyle(fontWeight: FontWeight.bold,
              color: AppTheme.onSurface, fontSize: 15)),
          const SizedBox(height: 8),
          Row(children: [
            _modeChip(l10n.alpacaPaperMode, true),
            const SizedBox(width: 10),
            _modeChip(l10n.alpacaLiveMode, false),
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
                child: Text(
                  l10n.alpacaLiveWarning,
                  style: TextStyle(color: AppTheme.onErrorContainer, fontSize: 13),
                ),
              ),
            ),
          const SizedBox(height: 24),

          // API Key
          Text(l10n.alpacaApiKey, style: TextStyle(fontWeight: FontWeight.bold,
              color: AppTheme.onSurface, fontSize: 15)),
          const SizedBox(height: 8),
          TextField(
            controller: _keyCtrl,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              hintText: l10n.alpacaApiKeyHint,
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
          Text(l10n.alpacaSecretKey, style: TextStyle(fontWeight: FontWeight.bold,
              color: AppTheme.onSurface, fontSize: 15)),
          const SizedBox(height: 8),
          TextField(
            controller: _secretCtrl,
            obscureText: _obscure,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              hintText: l10n.alpacaSecretHint,
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
                  ?  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const  SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                     const SizedBox(width: 12),
                Text(l10n.alpacaTesting),
                    ])
                  : Text(l10n.alpacaConnectButton, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                Text(l10n.alpacaConnected, style: TextStyle(fontWeight: FontWeight.bold,
                    color: AppTheme.primary, fontSize: 16)),
                const SizedBox(height: 8),
                Builder(
                    builder: (context) {
                      final localeStr = Localizations.localeOf(context).languageCode;
                      return Column(
                        children: [
                          _infoRow(l10n.alpacaCash, CurrencyFormatter.format(_testResult!.cash, localeStr)),
                          _infoRow(l10n.alpacaBuyingPower, CurrencyFormatter.format(_testResult!.buyingPower, localeStr)),
                          _infoRow(l10n.alpacaPortfolioValue, CurrencyFormatter.format(_testResult!.portfolioValue, localeStr)),
                        ],
                      );
                    }
                ),
                _infoRow(l10n.alpacaStatus, _testResult!.status.toUpperCase()),
              ]),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _step(int num, String text) {
    final formattedNum = NumberFormat('#', Localizations.localeOf(context).languageCode).format(num);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Container(
          width: 22, height: 22,
          decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
          child: Center(child: Text(formattedNum, style: const TextStyle(color: Colors.white,
              fontSize: 11, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(color: AppTheme.onSurface, fontSize: 13))),
      ]),
    );
  }

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
