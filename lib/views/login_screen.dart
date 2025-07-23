import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fedis/viewmodels/auth_view_model.dart';
import 'package:fedis/language/app_localization.dart';
import 'widgets/custom_drawer.dart';
import 'widgets/custom_footer.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController email = TextEditingController(text: '');
  final TextEditingController password = TextEditingController(text: '');

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        elevation: 4,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalization.of(context)?.translate('welcome_back') ?? 'Welcome Back',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 400,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    border: Border.all(color: const Color(0xFFdee2e6)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextField(
                        label: AppLocalization.of(context)?.translate('email') ?? 'Email Address',
                        controller: email,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        label: AppLocalization.of(context)?.translate('password') ?? 'Password',
                        obscure: true,
                        controller: password,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFc69400),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: authViewModel.isLoading
                            ? null
                            : () {
                          if (email.text.trim().isEmpty || password.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill in all fields'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          authViewModel.login(
                            email.text.trim(),
                            password.text.trim(),
                            context,
                          );
                        },
                        child: authViewModel.isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : Text(
                          AppLocalization.of(context)?.translate('login') ?? 'Login',
                        ),
                      ),
                      if (authViewModel.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(color: Colors.red.shade200),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            authViewModel.errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const CustomFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: const InputDecoration(),
        ),
      ],
    );
  }
}