import 'package:expense_managment/models/category.dart';
import 'package:expense_managment/models/transaction.dart';
import 'package:expense_managment/providers/category_provider.dart';
import 'package:expense_managment/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionFormScreen extends StatefulWidget {
  final Transaction? transaction;
  final CategoryType categoryType;

  const TransactionFormScreen({
    super.key,
    this.transaction,
    required this.categoryType,
  });

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreen();
}

class _TransactionFormScreen extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _editCategoryController = TextEditingController();

  String? _selectedCategoryId;
  String? _editSelectedCategoryId;
  String? _deleteSelectedCategoryId;
  bool _isPaid = false;

  @override
  void initState() {
    super.initState();

    if (widget.transaction != null) {
      _amountController.text = widget.transaction!.amount.toString();
      _descriptionController.text = widget.transaction!.description;
      _selectedCategoryId = widget.transaction!.categoryId;
      _editSelectedCategoryId = widget.transaction!.categoryId;
      _deleteSelectedCategoryId = widget.transaction!.categoryId;
      _isPaid = widget.transaction!.isPaid;
    }

    Future.microtask(() {
      context.read<CategoryProvider>().loadCategories();
      context.read<TransactionProvider>().loadCategories();
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final transactionProvider = context.watch<TransactionProvider>();
    final allCategories = categoryProvider.categories;
    final allTransactions = transactionProvider.transactions;
    final filteredCategories = categoryProvider.categoriesByType(widget.categoryType);
    final typeLabel = widget.categoryType == CategoryType.expense ? 'egresos' : 'ingresos';

    if (
      filteredCategories.isNotEmpty &&
      (_selectedCategoryId == null || !filteredCategories.any((c) => c.id == _selectedCategoryId))
    )
    {
      _selectedCategoryId = filteredCategories.first.id;
      _editSelectedCategoryId = filteredCategories.first.id;
      _deleteSelectedCategoryId = filteredCategories.first.id;
      
    }

    final selectedCategory = filteredCategories.where((c) => c.id == _selectedCategoryId).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null ? 'Registrar transaccion' : 'Editar transaccion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Monto'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un monto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                maxLines: null,
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripcion'),
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // El Expanded es clave para que el Dropdown no de error de ancho
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      items: filteredCategories
                          .map(
                            (category) => DropdownMenuItem<String>(
                              value: category.id,
                              child: Text(category.name),
                            ),
                          )
                          .toList(),
                      onChanged: filteredCategories.isEmpty
                          ? null
                          : (value) {
                              if (value == null) return;
                              setState(() => _selectedCategoryId = value);
                            },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Seleccione una categoría';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Botón 1: Agregar
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.blue, size: 28),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: const Text('Agregar categoría'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Se visualiza las categorías de $typeLabel',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _categoryController,
                                  decoration: const InputDecoration(labelText: 'Nombre'),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(dialogContext).pop(),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final categoryName = _categoryController.text.trim();
                                  if (categoryName.isEmpty) return;

                                  final existsByName = allCategories.any(
                                    (c) => c.name.toLowerCase().trim() == categoryName.toLowerCase().trim() && c.type == widget.categoryType,
                                  );

                                  if (existsByName) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('La categoría ya existe')),
                                    );
                                    return;
                                  }

                                  await categoryProvider.addCategory(
                                    Category(
                                      id: DateTime.now().toString(),
                                      name: categoryName,
                                      type: widget.categoryType,
                                    ),
                                  );

                                  if (context.mounted) {
                                    await context.read<TransactionProvider>().loadCategories();
                                  }
                                  if (dialogContext.mounted) {
                                    Navigator.of(dialogContext).pop();
                                  }
                                  _categoryController.text = '';
                                },
                                child: const Text('Guardar'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  // Botón 2: Eliminar (Opcional, pero completa el diseño de 2 botones)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 28),
                    onPressed: (){
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: const Text('Editar categoría'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Se visualiza las categorías de $typeLabel',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(height: 10),
                                DropdownButtonFormField<String>(
                                  value: _selectedCategoryId,
                                  decoration: const InputDecoration(labelText: 'Categoría'),
                                  items: filteredCategories
                                      .map(
                                        (category) => DropdownMenuItem<String>(
                                          value: category.id,
                                          child: Text(category.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) async {
                                    setState(() => _editSelectedCategoryId = value);
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Seleccione una categoría';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _editCategoryController,
                                  decoration: const InputDecoration(labelText: 'Nuevo nombre'),
                                ),

                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(dialogContext).pop(),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final category = allCategories.firstWhere((c) => c.id == _editSelectedCategoryId);
                                  await categoryProvider.updateCategory(
                                    Category(
                                      id: category.id,
                                      name: _editCategoryController.text.trim(),
                                      type: category.type
                                    )
                                  );

                                  if (context.mounted) {
                                    await context.read<TransactionProvider>().loadCategories();
                                  }
                                  
                                  if (dialogContext.mounted) {
                                    Navigator.of(dialogContext).pop();
                                  }
                                },
                                child: const Text('Guardar'),
                              ),

                            ],
                          );
                        },
                      );
                    }
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.blue, size: 28),
                    onPressed: (){
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: const Text('Eliminar categoría'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Se visualiza las categorías de $typeLabel',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(height: 10),
                                DropdownButtonFormField<String>(
                                  value: _deleteSelectedCategoryId,
                                  decoration: const InputDecoration(labelText: 'Categoría'),
                                  items: filteredCategories
                                      .map(
                                        (category) => DropdownMenuItem<String>(
                                          value: category.id,
                                          child: Text(category.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) async {
                                    setState(() => _deleteSelectedCategoryId = value);
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Seleccione una categoría';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(dialogContext).pop(),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final useCategory = allTransactions.any((t) => t.categoryId == _deleteSelectedCategoryId);
                                  if(useCategory){
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('La categoría esta en uso')),
                                    );
                                    return;
                                  }
                                  await categoryProvider.deleteCategory(_deleteSelectedCategoryId!);
                                  _deleteSelectedCategoryId = null;
                                  if (context.mounted) {
                                    await context.read<TransactionProvider>().loadCategories();
                                  }
                                  
                                  if (dialogContext.mounted) {
                                    Navigator.of(dialogContext).pop();
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Categoría eliminada')),
                                    );                                                          
                                },
                                child: const Text('Aceptar'),
                              ),

                            ],
                          );
                        },
                      );
                    }
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (widget.categoryType == CategoryType.expense)
                SwitchListTile(
                  title: const Text('Pagado'),
                  value: _isPaid,
                  onChanged: (bool value) {
                    setState(() {
                      _isPaid = value;
                    });
                  },
                ),
              const SizedBox(height: 20),
              Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }

                        if (_selectedCategoryId == null || selectedCategory == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Seleccione una categoría valida')),
                          );
                          return;
                        }

                        final transactionCurrent = Transaction(
                          id: widget.transaction == null
                              ? DateTime.now().toString()
                              : widget.transaction!.id,
                          amount: double.parse(_amountController.text),
                          description: _descriptionController.text,
                          categoryId: _selectedCategoryId!,
                          date: widget.transaction?.date ?? DateTime.now(),
                          isPaid: widget.categoryType == CategoryType.expense ? _isPaid : true,
                        );

                        if (widget.transaction == null) {
                          await context.read<TransactionProvider>().addTransaction(transactionCurrent);
                        } else {
                          await context.read<TransactionProvider>().updateTransaction(transactionCurrent);
                        }

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Transaccion ${widget.transaction == null ? 'registrada' : 'actualizada'}',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                      label: const Text('Guardar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}