import 'package:appwrite/models.dart' as models;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moviewebapp/app/providers/auth_session.dart';
import 'package:provider/provider.dart';

Future<models.User?> showMovieLoginDialog(BuildContext context) {
  return context.read<AuthSession>().login(
    showLoginDialog: () => showDialog<models.User>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _EmailLoginDialog(),
    ),
  );
}

class _EmailLoginDialog extends StatefulWidget {
  const _EmailLoginDialog();

  @override
  State<_EmailLoginDialog> createState() => _EmailLoginDialogState();
}

class _EmailLoginDialogState extends State<_EmailLoginDialog> {
  final _email = TextEditingController();
  final _code = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _sendCode(AuthSession auth) async {
    final sent = await auth.sendLoginCode(_email.text);
    if (mounted && sent) _code.clear();
  }

  Future<void> _verify(AuthSession auth) async {
    final user = await auth.verifyLoginCode(_code.text);
    if (mounted && user != null) Navigator.of(context).pop(user);
  }

  @override
  Widget build(BuildContext context) => Consumer<AuthSession>(
    builder: (context, auth, child) {
      final codeSent = auth.loginCodeSent;
      final busy = auth.isLoginBusy;
      final sessionCreated = auth.loginSessionCreated;
      final error = auth.loginError;
      return PopScope(
        canPop: !busy,
        child: AlertDialog(
          title: const Text('Login'),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  codeSent
                      ? 'Enter the code sent to ${auth.loginEmail}.'
                      : 'Enter your email to receive a login code.',
                ),
                const SizedBox(height: 16),
                if (!codeSent)
                  TextField(
                    key: const ValueKey('login-email'),
                    controller: _email,
                    enabled: !busy,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(labelText: 'Email'),
                    onSubmitted: (_) => _sendCode(auth),
                  )
                else if (!sessionCreated)
                  TextField(
                    key: const ValueKey('login-code'),
                    controller: _code,
                    enabled: !busy,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Six-digit code',
                    ),
                    onSubmitted: (_) => _verify(auth),
                  ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    error,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                if (codeSent && !sessionCreated)
                  TextButton(
                    onPressed: busy ? null : () => _sendCode(auth),
                    child: const Text('Resend code'),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: busy ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            if (codeSent && !sessionCreated)
              TextButton(
                onPressed: busy
                    ? null
                    : () {
                  _code.clear();
                  auth.changeLoginEmail();
                },
                child: const Text('Change email'),
              ),
            FilledButton(
              onPressed: busy
                  ? null
                  : () => codeSent ? _verify(auth) : _sendCode(auth),
              child: Text(
                busy
                    ? 'Please wait...'
                    : sessionCreated
                    ? 'Retry'
                    : codeSent
                    ? 'Login'
                    : 'Send code',
              ),
            ),
          ],
        ),
      );
    },
  );
}