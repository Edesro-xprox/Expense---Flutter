import 'package:expense_managment/models/category.dart';
import 'package:expense_managment/providers/category_provider.dart';
import 'package:expense_managment/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  CategoryType _selectedType = CategoryType.expense;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CategoryProvider>().loadCategories();
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  Future<void> _confirmDelete(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminacion'),
        content: Text('¿Deseas eliminar la categoria "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final transactionProvider = context.read<TransactionProvider>();
    final inUse = transactionProvider.transactions.any(
      (t) => t.categoryId == category.id,
    );

    if (inUse) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puede eliminar la categoria porque esta en uso.'),
        ),
      );
      return;
    }

    await context.read<CategoryProvider>().removeCategory(category.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Categoria eliminada.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final categories = categoryProvider.categoriesByType(_selectedType);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<CategoryType>(
                    value: _selectedType,
                    decoration: const InputDecoration(labelText: 'Tipo de categoría'),
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
                ),
                SizedBox(width: 16),
                IconButton(
                  onPressed: (){
                    Navigator.pushNamed(
                      context, '/category-form',
                      arguments: {'category': Category(id: '', name: '', type: _selectedType)}
                    );
                  },
                  icon: Icon(Icons.add),
                  style: IconButton.styleFrom(
                    foregroundColor: colorScheme.onPrimary,
                    backgroundColor: colorScheme.primary,
                    disabledBackgroundColor: colorScheme.surface,
                    shape: RoundedRectangleBorder(      // Para hacerlo un poco cuadrado o circular
                      borderRadius: BorderRadius.circular(8),
                  ),
  ),
                )
              ]
            ),
            const SizedBox(height: 16),
            Expanded(
              child: categories.isEmpty
                  ? Center(
                      child: Text(
                        'No hay categorias registradas',
                        style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                      ),
                    )
                  : ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return Card(
                          child: ListTile(
                            title: Text(category.name),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/category-form',
                                      arguments: {'category': category},
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _confirmDelete(category),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
