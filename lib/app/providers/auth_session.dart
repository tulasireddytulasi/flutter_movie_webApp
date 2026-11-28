import 'dart:developer';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/widgets.dart';
import 'package:moviewebapp/app/core/config/appwrite_config.dart';

class AuthSession extends ChangeNotifier {
  AuthSession()
    : client = Client()
        ..setEndpoint(AppwriteConfig.endpoint)
        ..setProject(AppwriteConfig.projectId) {
    _account = Account(client);
    refresh();
  }

  final Client client;
  late final Account _account;

  // Keep loading, user and error information together in one read-only state.
  AsyncSnapshot<models.User?> _state = const AsyncSnapshot.waiting();
  AsyncSnapshot<models.User?> get state => _state;

  bool _disposed = false;
  int _requestId = 0;

  String _loginEmail = '';
  String? _loginUserId;
  String? _loginError;
  bool _loginBusy = false;
  bool _sessionCreated = false;
  bool _loginOpen = false;
  int _loginRequestId = 0;
  static final _otpCodePattern = RegExp(r'^\d{6}$');

  String get loginEmail => _loginEmail;
  String? get loginError => _loginError;
  bool get isLoginBusy => _loginBusy;
  bool get loginCodeSent => _loginUserId != null;
  bool get loginSessionCreated => _sessionCreated;

  void _updateState(AsyncSnapshot<models.User?> next, int requestId) {
    // Ignore results from older requests or a provider that is no longer active.
    if (_disposed || requestId != _requestId || next == _state) return;
    _state = next;
    notifyListeners();
  }

  Future<void> refresh() async {
    if (_disposed) return;
    final requestId = ++_requestId;
    // Retain the current user while checking whether the session is still valid.
    _updateState(_state.inState(ConnectionState.waiting), requestId);
    try {
      final user = await _account.get();
      _updateState(
        AsyncSnapshot.withData(ConnectionState.done, user),
        requestId,
      );
    } catch (error, stack) {
      if (_disposed || requestId != _requestId) return;
      // Appwrite reports a guest session as unauthorized, not as a missing user.
      if (error is AppwriteException &&
          error.code == 401 &&
          error.type == 'general_unauthorized_scope') {
        _updateState(
          const AsyncSnapshot.withData(ConnectionState.done, null),
          requestId,
        );
        return;
      }
      log(
        'Could not check the Appwrite session',
        error: error,
        stackTrace: stack,
      );
      _updateState(
        AsyncSnapshot.withError(ConnectionState.done, error, stack),
        requestId,
      );
    }
  }

  void setUser(models.User user) {
    // A successful login takes priority over any earlier session check.
    final requestId = ++_requestId;
    _updateState(AsyncSnapshot.withData(ConnectionState.done, user), requestId);
  }

  Future<String?> signOut() async {
    final requestId = ++_requestId;
    final previous = _state;
    _updateState(previous.inState(ConnectionState.waiting), requestId);
    try {
      await _account.deleteSession(sessionId: 'current');
      _updateState(
        const AsyncSnapshot.withData(ConnectionState.done, null),
        requestId,
      );
      return null;
    } catch (error, stack) {
      log('Could not sign out', error: error, stackTrace: stack);
      // Preserve the session on failure and return a message for the UI.
      _updateState(previous, requestId);
      return 'Could not sign out. Please try again.';
    }
  }

  Future<models.User?> login({
    required Future<models.User?> Function() showLoginDialog,
  }) async {
    if (_disposed || _loginOpen) return null;
    _loginOpen = true;
    _resetLoginState();
    try {
      // The UI owns the dialog; this provider owns the login lifecycle.
      final user = await showLoginDialog();
      _loginRequestId++;
      if (user != null) {
        setUser(user);
      } else {
        // A session may exist even if fetching the user failed in the dialog.
        await refresh();
      }
      return user;
    } finally {
      _loginOpen = false;
      _resetLoginState();
    }
  }

  void _resetLoginState() {
    // Invalidate responses from a closed dialog before starting another login.
    _loginRequestId++;
    _loginEmail = '';
    _loginUserId = null;
    _loginError = null;
    _loginBusy = false;
    _sessionCreated = false;
    if (!_disposed) notifyListeners();
  }

  bool _isActiveLogin(int requestId) =>
      !_disposed && _loginOpen && requestId == _loginRequestId;

  String _loginMessage(Object error) {
    if (error is AppwriteException && error.message?.isNotEmpty == true) {
      return error.message!;
    }
    return 'Request failed. Check your connection and try again.';
  }

  Future<bool> sendLoginCode(String emailInput) async {
    if (_disposed || !_loginOpen || _loginBusy || _sessionCreated) return false;
    final email = emailInput.trim();
    if (email.isEmpty || !email.contains('@')) {
      _loginError = 'Enter a valid email address.';
      notifyListeners();
      return false;
    }

    final requestId = _loginRequestId;
    _loginBusy = true;
    _loginError = null;
    notifyListeners();
    try {
      final token = await _account.createEmailToken(
        userId: ID.unique(),
        email: email,
      );
      if (!_isActiveLogin(requestId)) return false;
      _loginEmail = email;
      _loginUserId = token.userId;
      return true;
    } catch (error, stack) {
      log('Could not send email login code', error: error, stackTrace: stack);
      if (_isActiveLogin(requestId)) _loginError = _loginMessage(error);
      return false;
    } finally {
      if (_isActiveLogin(requestId)) {
        _loginBusy = false;
        notifyListeners();
      }
    }
  }

  Future<models.User?> verifyLoginCode(String codeInput) async {
    if (_disposed || !_loginOpen || _loginBusy) return null;
    final userId = _loginUserId;
    final code = codeInput.trim();
    if (userId == null) {
      _loginError = 'Request a login code first.';
      notifyListeners();
      return null;
    }
    if (!_sessionCreated && !_otpCodePattern.hasMatch(code)) {
      _loginError = 'Enter the six-digit code from your email.';
      notifyListeners();
      return null;
    }

    final requestId = _loginRequestId;
    _loginBusy = true;
    _loginError = null;
    notifyListeners();
    try {
      // If user lookup fails, retry it without consuming the OTP a second time.
      if (!_sessionCreated) {
        await _account.createSession(userId: userId, secret: code);
        if (!_isActiveLogin(requestId)) return null;
        _sessionCreated = true;
        notifyListeners();
      }
      final user = await _account.get();
      return _isActiveLogin(requestId) ? user : null;
    } catch (error, stack) {
      log('Could not complete email login', error: error, stackTrace: stack);
      if (_isActiveLogin(requestId)) {
        _loginError = _sessionCreated
            ? 'Session created, but login status could not be verified. Check browser cookie settings and retry.'
            : _loginMessage(error);
      }
      return null;
    } finally {
      if (_isActiveLogin(requestId)) {
        _loginBusy = false;
        notifyListeners();
      }
    }
  }

  void changeLoginEmail() {
    if (_disposed || !_loginOpen || _loginBusy || _sessionCreated) return;
    _loginEmail = '';
    _loginUserId = null;
    _loginError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
