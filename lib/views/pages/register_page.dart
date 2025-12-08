import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expense_tracker_ocr/controllers/auth_controller.dart';
import 'package:flutter_expense_tracker_ocr/core/constants/image_strings.dart';
import 'package:flutter_expense_tracker_ocr/core/constants/sizes.dart';
import 'package:flutter_expense_tracker_ocr/core/constants/text_strings.dart';
import 'package:flutter_expense_tracker_ocr/core/utils/theme/snackbar_utils.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthController _controller = AuthController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final sizeImage = MediaQuery.of(context).size;
    var mediaQuery = MediaQuery.of(context);
    var brightness = mediaQuery.platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(tFormHeight - 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado de la página
                Image(
                  image: AssetImage(tWelcomePageImage),
                  height: sizeImage.height * 0.2,
                ),
                Text(
                  tRegisterTitle,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text(
                  tRegisterSubtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),

                // Formulario de registro
                Form(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Campos de entrada de texto
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            label: Text(tName),
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                          autofocus: true,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),

                        SizedBox(height: tFormHeight - 20.0),

                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            label: Text(tEmail),
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),

                        SizedBox(height: tFormHeight - 20.0),

                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            label: Text(tPhone),
                            prefixIcon: Icon(Icons.phone),
                          ),
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),

                        SizedBox(height: tFormHeight - 20.0),

                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            label: Text(tPassword),
                            prefixIcon: Icon(Icons.fingerprint),
                            // suffixIcon: IconButton(
                            //   icon: Icon(Icons.remove_red_eye_sharp),
                            //   onPressed: () {},
                            // ),
                          ),
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),

                        const SizedBox(height: tFormHeight),

                        // Botones de registro
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _registerWithEmail(),
                            child: Text(tRegister.toUpperCase()),
                          ),
                        ),

                        const SizedBox(height: tFormHeight - 20.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(thickness: 1, endIndent: 10),
                                ),
                                Text(
                                  'O continúa con',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Expanded(
                                  child: Divider(thickness: 1, indent: 10),
                                ),
                              ],
                            ),
                            const SizedBox(height: tFormHeight - 20.0),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: Image(
                                  image: AssetImage(tGoogleLogoImage),
                                  width: 20.0,
                                ),
                                onPressed: () => _registerWithGoogle(),
                                label: Text(tSignInWithGoogle),
                              ),
                            ),
                            const SizedBox(height: tFormHeight - 20.0),

                            TextButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, "/login"),
                              child: Text.rich(
                                TextSpan(
                                  text: tAlredyHaveAnAccount,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  children: [
                                    TextSpan(
                                      text: tLogin.toUpperCase(),
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _registerWithEmail() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    final phoneRegex = RegExp(r'^[0-9]+$');

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      AppSnackBar.showError(context, "Por favor, completa todos los campos");
      return;
    }

    if (!emailRegex.hasMatch(email)) {
      AppSnackBar.showError(context, "Ingresa un correo válido");
      return;
    }

    if (!phoneRegex.hasMatch(phone)) {
      AppSnackBar.showError(context, "Ingresa un número de teléfono válido");
      return;
    }

    if (password.length < 6) {
      AppSnackBar.showError(
        context,
        "La contraseña debe tener al menos 6 caracteres",
      );
      return;
    }

    try {
      final user = await _controller.registerWithEmail(
        name,
        email,
        phone,
        password,
      );
      if (user != null) {
        AppSnackBar.showSuccess(context, "Registro exitoso");
      }
      Navigator.pushNamed(context, "/home");
    } catch (e) {
      AppSnackBar.showError(context, "Ha ocurrido un error: $e");
    }
  }

  Future<void> _registerWithGoogle() async {
    try {
      final user = await _controller.loginWithGoogle();
      if (user != null) {
        AppSnackBar.showSuccess(context, "Inicio de sesión con Google exitoso");

        Navigator.pushNamed(context, "/home");
      }
    } catch (e) {
      AppSnackBar.showError(context, "Ha ocurrido un error: $e");
    }
  }
}
