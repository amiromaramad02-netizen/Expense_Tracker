import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsStore extends ChangeNotifier {
  static const _kCurrencyKey = 'app_currency_v1';

  String _currencyCode = 'INR';

  String get currencyCode => _currencyCode;

  String get currencySymbol {
    switch (_currencyCode) {
      case 'USD':
        return r'$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'RUB':
        return '₽';
      case 'ZAR':
        return 'R';
      case 'MZN':
        return 'MZN';
      default:
        return '₹';
    }
  }

  SettingsStore() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _currencyCode = prefs.getString(_kCurrencyKey) ?? _currencyCode;
    notifyListeners();
  }

  Future<void> setCurrency(String code) async {
    if (code == _currencyCode) return;
    _currencyCode = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCurrencyKey, code);
    notifyListeners();
  }
}

final settingsStore = SettingsStore();
