import 'dart:io';
import 'package:flutter/material.dart';
import '/controllers/profile_controller.dart';
import '/models/user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _controller = ProfileController();
  final _formKey = GlobalKey<FormState>();

  UserModel? user;
  File? newImage;

  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    user = await _controller.loadUserData();
    setState(() => loading = false);
  }

  Future<void> pickImage(bool camera) async {
    final file = await _controller.pickImage(camera);
    if (file != null) {
      setState(() => newImage = file);
    }
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    setState(() => saving = true);

    await _controller.saveProfile(user!, newImage);

    setState(() => saving = false);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Perfil actualizado")));
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Perfil")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 65,
                    backgroundImage: newImage != null
                        ? FileImage(newImage!)
                        : (user!.photoUrl != null && user!.photoUrl!.isNotEmpty)
                            ? NetworkImage(user!.photoUrl!)
                            : const AssetImage("assets/avatar_placeholder.png")
                                as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: PopupMenuButton<String>(
                      icon: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.camera_alt, color: Colors.white),
                      ),
                      onSelected: (value) {
                        pickImage(value == "camera");
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: "camera",
                          child: Text("Tomar foto"),
                        ),
                        const PopupMenuItem(
                          value: "gallery",
                          child: Text("Galería"),
                        ),
                      ],
                    ),
                  )
                ],
              ),

              const SizedBox(height: 20),

              TextFormField(
                initialValue: user!.name,
                decoration: const InputDecoration(
                  labelText: "Nombre",
                  border: OutlineInputBorder(),
                ),
                onSaved: (v) => user = UserModel(
                  uid: user!.uid,
                  name: v,
                  email: user!.email,
                  photoUrl: user!.photoUrl,
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Ingresa un nombre" : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                initialValue: user!.email,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: "Correo",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saving ? null : save,
                  child: saving
                      ? const CircularProgressIndicator()
                      : const Text("Guardar cambios"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
