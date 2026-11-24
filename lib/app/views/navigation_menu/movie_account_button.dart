import 'package:flutter/material.dart';
import 'package:moviewebapp/app/providers/auth_session.dart';
import 'package:moviewebapp/app/views/auth_screen/email_login_dialog.dart';
import 'package:provider/provider.dart';

class MovieAccountButton extends StatelessWidget {
  const MovieAccountButton({super.key});

  Future<void> _signOut(BuildContext context, AuthSession session) async {
    final message = await session.signOut();
    if (context.mounted && message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthSession>(
      builder: (context, auth, child) {
        final session = auth.state;
        if (session.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        if (session.hasError) {
          return TextButton.icon(
            onPressed: auth.refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry login status'),
          );
        }
        final user = session.data;
        if (user == null) {
          return TextButton(onPressed: () => showMovieLoginDialog(context), child: const Text('Login'));
        }
        return PopupMenuButton<String>(
          tooltip: 'Account',
          icon: const Icon(Icons.person_outline),
          onSelected: (value) {
            if (value == 'signOut') _signOut(context, auth);
          },
          itemBuilder: (_) => [
            PopupMenuItem<String>(enabled: false, child: Text(user.email.isEmpty ? 'Signed in' : user.email)),
            const PopupMenuItem<String>(value: 'signOut', child: Text('Sign out')),
          ],
        );
      },
    );
  }
}
