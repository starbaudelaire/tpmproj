import 'package:flutter/cupertino.dart';

import '../../../shared/widgets/glass_text_field.dart';

class LoginView extends StatelessWidget {
  const LoginView({
    required this.emailController,
    required this.passwordController,
    super.key,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassTextField(
          controller: emailController,
          placeholder: 'Email',
          prefix: const Icon(CupertinoIcons.mail),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        GlassTextField(
          controller: passwordController,
          placeholder: 'Password',
          obscureText: true,
          prefix: const Icon(CupertinoIcons.lock),
        ),
      ],
    );
  }
}
