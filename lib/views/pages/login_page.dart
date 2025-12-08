import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker_ocr/controllers/auth_controller.dart';
import 'package:flutter_expense_tracker_ocr/core/constants/image_strings.dart';
import 'package:flutter_expense_tracker_ocr/core/constants/sizes.dart';
import 'package:flutter_expense_tracker_ocr/core/constants/text_strings.dart';
import 'package:flutter_expense_tracker_ocr/core/utils/theme/snackbar_utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthController _controller = AuthController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final sizeImage = MediaQuery.of(context).size;
    var mediaQuery = MediaQuery.of(context);
    var brightness = mediaQuery.platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    bool obscurePassword = true;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(tFormHeight - 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image(
                  image: const AssetImage(tWelcomePageImage),
                  height: sizeImage.height * 0.2,
                ),
                Text(
                  tLoginTitle,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text(
                  tLoginSubtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),

                Form(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: tEmail,
                            prefixIcon: Icon(Icons.person_outline_outlined),
                          ),
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          controller: emailController,
                        ),

                        SizedBox(height: tFormHeight),

                        TextFormField(
                          controller: passwordController,
                          key: ValueKey(obscurePassword),
                          obscureText: obscurePassword,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.fingerprint),
                            labelText: tPassword,
                            // suffixIcon: IconButton(
                            //   icon: Icon(Icons.remove_red_eye_sharp),
                            //   onPressed: () {
                            //     setState(() {
                            //       obscurePassword = !obscurePassword;
                            //     });
                            //   },
                            // ),
                          ),
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),

                        const SizedBox(height: tFormHeight - 20),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(tForgotPassword),
                          ),
                        ),

                        SizedBox(height: tFormHeight - 20),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loginWithEmail,
                            child: Text(tLogin.toUpperCase()),
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
                                onPressed: _loginWithGoogle,
                                label: Text(
                                  tSignInWithGoogle,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ),
                            const SizedBox(height: tFormHeight - 20.0),

                            TextButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, "/register"),
                              child: Text.rich(
                                TextSpan(
                                  text: tDontHaveAnAccount,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  children: [
                                    TextSpan(
                                      text: tSignUp.toUpperCase(),
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

  // Funciones de inicio de sesión
  Future<void> _loginWithEmail() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');

    if (email.isEmpty || password.isEmpty) {
      AppSnackBar.showError(context, "Por favor, completa todos los campos");
      return;
    }

    if (!emailRegex.hasMatch(email)) {
      AppSnackBar.showError(context, "Ingresa un correo válido");
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
      final user = await _controller.loginWithEmail(email, password);
      if (user != null) {
        AppSnackBar.showSuccess(context, "Inicio de sesión exitoso");

        Navigator.pushNamed(context, "/home");
      }
    } catch (e) {
      AppSnackBar.showError(context, "Ha ocurrido un error: $e");
    }
  }

  Future<void> _loginWithGoogle() async {
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
