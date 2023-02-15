import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../models/http_exception.dart';
import '../core/constants/enums/preferences_keys_enum.dart';
import '../core/init/cache/locale_manager.dart';
import '../core/init/dotenv/dotenv_manager.dart';

class AuthNotifier with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  String get _firebaseWebApiKey => DotEnvManager.instance.firebaseWebApiKey;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null && _expiryDate!.isAfter(DateTime.now()) && _token != null) {
      return _token;
    }
    return null;
  }

  String? get userId {
    return _userId;
  }

  String get _jsonUserData {
    return json.encode(
      {
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate!.toIso8601String(),
      },
    );
  }

  Future<void> _authenticate(String email, String password, String urlSegment) async {
    try {
      final res = await http.post(
        Uri.parse(
            'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=$_firebaseWebApiKey'),
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final resData = json.decode(res.body);
      if (resData['error'] != null) {
        throw HttpException(resData['error']['message']);
      }
      _token = resData['idToken'];
      _userId = resData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(resData['expiresIn']),
        ),
      );
      _autoLogout();
      notifyListeners();
      LocaleManager.instance.setStringValue(PreferencesKeysEnum.userData, _jsonUserData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final userData = LocaleManager.instance.getStringValue(PreferencesKeysEnum.userData);
    if (userData.isEmpty) return false;
    final extractedUserData = json.decode(userData);
    print(extractedUserData);
    final expiryDate = DateTime.parse(extractedUserData['expiryDate'] as String);
    if (expiryDate.isBefore(DateTime.now())) return false;
    _token = extractedUserData['token'] as String;
    _userId = extractedUserData['userId'] as String;
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    LocaleManager.instance.setStringValue(PreferencesKeysEnum.userData, '');
    notifyListeners();
  }

  void _autoLogout() {
    if (_expiryDate == null) return;
    if (_authTimer != null) _authTimer!.cancel();
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
