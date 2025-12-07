import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker_ocr/controllers/register_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final RegisterController _registerCtrl = RegisterController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  String? _name;
  String? _email;
  String? _password;
  String? _phone;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    final error = await _registerCtrl.registerUser(
      name: _name!,
      email: _email!,
      password: _password!,
      phone: _phone!,
    );

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text("Registro exitoso", style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 800));
      Navigator.pushReplacementNamed(context, "/login");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(error, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Crear Cuenta",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Nombre completo"),
                validator: (v) => v!.isEmpty ? "Ingrese un nombre" : null,
                onSaved: (v) => _name = v,
              ),
              const SizedBox(height: 15),

              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Correo",
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Ingrese un correo";
                  if (!v.contains("@gmail.com")) return "Correo inválido";
                  return null;
                },
                onSaved: (v) => _email = v,
              ),

              const SizedBox(height: 15),

              TextFormField(
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Teléfono",
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return "Ingrese un número telefónico";
                  if (!RegExp(r'^[0-9]+$').hasMatch(v))
                    return "Solo números permitidos";
                  if (v.length < 8) return "Número demasiado corto";
                  return null;
                },
                onSaved: (v) => _phone = v,
              ),

              const SizedBox(height: 15),

              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(labelText: "Contraseña"),
                validator: (v) => v!.length < 6 ? "Mínimo 6 caracteres" : null,
                onSaved: (v) => _password = v,
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Registrarse"),
                ),
              ),

              TextButton(
                onPressed: () => Navigator.pushNamed(context, "/login"),
                child: const Text("¿Ya tienes cuenta? Inicia sesión"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
