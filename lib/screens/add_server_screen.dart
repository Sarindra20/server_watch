import 'package:flutter/material.dart';

import '../models/server.dart';

class AddServerScreen extends StatefulWidget {
  final Server? server; // renseigné quand on modifie un serveur existant

  const AddServerScreen({super.key, this.server});

  @override
  State<AddServerScreen> createState() => _AddServerScreenState();
}

class _AddServerScreenState extends State<AddServerScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ipController;

  bool get _editing => widget.server != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.server?.name ?? '');
    _ipController = TextEditingController(text: widget.server?.ip ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final server = Server(
        id: widget.server?.id,
        name: _nameController.text.trim(),
        ip: _ipController.text.trim(),
        online: widget.server?.online ?? true,
        cpu: widget.server?.cpu ?? 0,
        ram: widget.server?.ram ?? 0,
        disk: widget.server?.disk ?? 0,
      );
      Navigator.pop(context, server);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Modifier le serveur' : 'Ajouter un serveur'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du serveur',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Entre un nom'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ipController,
                decoration: const InputDecoration(
                  labelText: 'Adresse IP',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Entre une adresse IP'
                    : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(_editing ? 'Mettre à jour' : 'Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}