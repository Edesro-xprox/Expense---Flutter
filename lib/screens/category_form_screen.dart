import 'package:expense_managment/models/category.dart';
import 'package:expense_managment/providers/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryFormScreen extends StatefulWidget {
  final Category category;

  const CategoryFormScreen({super.key, required this.category});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late CategoryType _selectedType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _selectedType = widget.category.type;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final ctg = Category(
      id: widget.category.id.isEmpty ? DateTime.now().toString() : widget.category.id,
      name: _nameController.text.trim(),
      type: _selectedType,
    );

    if(widget.category.id.isEmpty){
      await context.read<CategoryProvider>().addCategory(ctg);
    }else{
      await context.read<CategoryProvider>().updateCategory(ctg);
    }
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.category.id.isEmpty ? 'Categoria agregada' : 'Categoria actualizada')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.id.isEmpty ? 'Agregar categoria' : 'Editar categoria'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<CategoryType>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Tipo de categoria'),
                items: const [
                  DropdownMenuItem(
                    value: CategoryType.income,
                    child: Text('Ingresos'),
                  ),
                  DropdownMenuItem(
                    value: CategoryType.expense,
                    child: Text('Egresos'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedType = value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar'),
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
