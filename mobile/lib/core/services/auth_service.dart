import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  String? _token;
  String? _userId;
  String? _userName;
  String? _userEmail;
  bool _isLoading = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  String? get token => _token;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  
  final ApiService _api = ApiService();
  
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.tokenKey);
    _userId = prefs.getString(AppConstants.userIdKey);
    _userName = prefs.getString('user_name');
    _userEmail = prefs.getString('user_email');
    if (_token != null) {
      _api.setToken(_token);
    }
    notifyListeners();
  }
  
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _api.login(email, password);
      final data = response.data;
      
      _token = data['accessToken'];
      _userId = data['user']['id'];
      _userName = '${data['user']['firstName']} ${data['user']['lastName'] ?? ''}'.trim();
      _userEmail = data['user']['email'];
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, _token!);
      await prefs.setString(AppConstants.userIdKey, _userId!);
      await prefs.setString(AppConstants.refreshTokenKey, data['refreshToken'] ?? '');
      if (_userName != null) await prefs.setString('user_name', _userName!);
      if (_userEmail != null) await prefs.setString('user_email', _userEmail!);
      
      _api.setToken(_token);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> register(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _api.register(data);
      final result = response.data;
      
      _token = result['accessToken'];
      _userId = result['user']['id'];
      _userName = '${result['user']['firstName']} ${result['user']['lastName'] ?? ''}'.trim();
      _userEmail = result['user']['email'];
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, _token!);
      await prefs.setString(AppConstants.userIdKey, _userId!);
      await prefs.setString(AppConstants.refreshTokenKey, result['refreshToken'] ?? '');
      if (_userName != null) await prefs.setString('user_name', _userName!);
      if (_userEmail != null) await prefs.setString('user_email', _userEmail!);
      
      _api.setToken(_token);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Register error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await _api.googleSignIn(idToken);
      final data = response.data;

      _token = data['accessToken'];
      _userId = data['user']['id'];
      _userName = '${data['user']['firstName']} ${data['user']['lastName'] ?? ''}'.trim();
      _userEmail = data['user']['email'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, _token!);
      await prefs.setString(AppConstants.userIdKey, _userId!);
      await prefs.setString(AppConstants.refreshTokenKey, data['refreshToken'] ?? '');
      if (_userName != null) await prefs.setString('user_name', _userName!);
      if (_userEmail != null) await prefs.setString('user_email', _userEmail!);

      _api.setToken(_token);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithApple() async {
    _isLoading = true;
    notifyListeners();

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final identityToken = appleCredential.identityToken;
      if (identityToken == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      String? fullName;
      if (appleCredential.givenName != null) {
        fullName = '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim();
      }

      final response = await _api.appleSignIn(identityToken, fullName: fullName);
      final data = response.data;

      _token = data['accessToken'];
      _userId = data['user']['id'];
      _userName = '${data['user']['firstName']} ${data['user']['lastName'] ?? ''}'.trim();
      _userEmail = data['user']['email'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, _token!);
      await prefs.setString(AppConstants.userIdKey, _userId!);
      await prefs.setString(AppConstants.refreshTokenKey, data['refreshToken'] ?? '');
      if (_userName != null) await prefs.setString('user_name', _userName!);
      if (_userEmail != null) await prefs.setString('user_email', _userEmail!);

      _api.setToken(_token);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Apple sign-in error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.refreshTokenKey);
    await prefs.remove(AppConstants.userIdKey);
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    
    _token = null;
    _userId = null;
    _userName = null;
    _userEmail = null;
    _api.setToken(null);
    notifyListeners();
  }
  
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardingKey, true);
  }
  
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.onboardingKey) ?? false;
  }
  
  ApiService get api => _api;
}
