import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_store/screens/auth/registration_page.dart';

import '../../cubits/auth_cubit.dart';
import '../../cubits/auth_state.dart';
import '../main/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Back'),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
            context.read<AuthCubit>().clearError();
          }

          if (state.isAuthenticated) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Login",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      color: Colors.cyan,
                    ),
                  ),
                  const Text(
                    'Please sign in to continue',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      labelText: 'Username',
                      filled: true,
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    validator: (value) => value!.isEmpty ? 'Enter a username' : null,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      labelText: 'Password',
                      filled: true,
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    validator: (value) => value!.isEmpty ? 'Enter a password' : null,
                  ),
                  const SizedBox(height: 32.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 3,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      ),
                      onPressed: state.isLoading
                          ? null
                          : () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthCubit>().login(
                            _usernameController.text,
                            _passwordController.text,
                          );
                        }
                      },
                      child: state.isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                        'Login',
                        style: TextStyle(color: Colors.cyan, fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.isLoading
                          ? null
                          : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegistrationPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 3,
                        padding: const EdgeInsets.all(10),
                      ),
                      child: const Text(
                        'Or create new account',
                        style: TextStyle(color: Colors.black87, fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}