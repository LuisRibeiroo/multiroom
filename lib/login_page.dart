import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import 'app/core/widgets/app_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = "".asSignal();
  final password = "".asSignal();
  final isLoading = false.asSignal();

  bool get isValidData => isValidEmail && password.value.isNotEmpty;

  bool get isValidEmail => email.value.contains("@") && email.value.contains(".com");

  @override
  Widget build(BuildContext context) {
    return Watch(
      (_) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              children: [
                const Spacer(),
                Image.asset("assets/logo_completo.png"),
                const Spacer(),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => isValidEmail ? null : 'Campo obrigatório',
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'E-mail',
                  ),
                  onChanged: email.set,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Senha',
                  ),
                  obscureText: true,
                  onChanged: password.set,
                ),
                const SizedBox(height: 24),
                AppButton(
                  onPressed: isValidData
                      ? () {
                          isLoading.set(true);
                        }
                      : null,
                  text: 'Login',
                  leading: Visibility(
                    visible: isLoading.value,
                    child: const CircularProgressIndicator(),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
