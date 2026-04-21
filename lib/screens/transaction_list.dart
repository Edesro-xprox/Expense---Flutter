import 'package:expense_managment/models/category.dart';
import 'package:expense_managment/models/transaction.dart';
import 'package:expense_managment/providers/category_provider.dart';
import 'package:expense_managment/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_managment/util/date_util.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  late DateTime _selectedDate;
  final _dateUtil = DateUtil();
  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    Future.microtask(() {
      context.read<TransactionProvider>().loadTransactions();
      context.read<TransactionProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final allTransactions = transactionProvider.transactions;
    final allCategories = categoryProvider.categories;

    // Filtrar transacciones por mes y año seleccionado
    final filteredTransactions = allTransactions.where((transaction) {
      return transaction.date.day <= _selectedDate.day && 
          transaction.date.year == _selectedDate.year &&
          transaction.date.month == _selectedDate.month;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Lista de Transacciones'),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Notas:'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selección de fecha:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Al seleccionar una fecha, podrá ver todas las transacciones registradas hasta el día de la fecha pero solo dentro del mes seleccionado',
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Íconos:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: const [
                              Icon(Icons.arrow_upward_sharp, color: Colors.green),
                              SizedBox(width: 8),
                              Expanded(child: Text(': Transacción de ingreso')),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: const [
                              Icon(Icons.check_circle, color: Colors.blue),
                              SizedBox(width: 8),
                              Expanded(child: Text(': Transacción de egreso pagado')),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: const [
                              Icon(Icons.arrow_downward_outlined, color: Colors.deepOrange,),
                              SizedBox(width: 8),
                              Expanded(child: Text(': Transacción de egreso')),
                            ],
                          ),
                        ],
                      ),
                    ),
      ),
    );
              }
            )
          ]
        )
      ),
      body: Column(
        children: [
          // Widget para seleccionar mes y año
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () async {
                final selected = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2025),
                  lastDate: DateTime(2030),
                );

                if (selected != null) {
                  setState(() {
                    _selectedDate = selected;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                  color: colorScheme.surface,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _dateUtil.formattedDate(_selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                    Icon(Icons.calendar_today, color: colorScheme.tertiary),
                  ],
                ),
              ),
            ),
          ),
          // Lista de transacciones filtradas
          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(
                    child: Text(
                      'No hay transacciones registradas para este mes',
                      style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = filteredTransactions[index];
                      final category = allCategories.where(
                        (c) => c.id == transaction.categoryId,
                      );
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            category.first.type == CategoryType.income
                                ? Icons.arrow_upward_sharp
                                : (transaction.isPaid 
                                    ? Icons.check_circle 
                                    : Icons.arrow_downward_outlined),
                            color: category.first.type == CategoryType.income
                                ? colorScheme.primary
                                : (transaction.isPaid ? colorScheme.tertiary : colorScheme.secondary),
                          ),
                          title: Text(category.first.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('S/${transaction.amount.toStringAsFixed(2)}'),
                              const SizedBox(height: 2),
                              Text(
                                _dateUtil.formattedDate(transaction.date),
                                style: TextStyle(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          trailing: Text(
                            '\$${transaction.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: category.first.type == CategoryType.income
                                  ? colorScheme.primary
                                  : colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, '/frmtransaction',
                                arguments: {
                                  'transaction': transaction,
                                  'categoryType': category.first.type
                                });
                          },
                          onLongPress: () {
                            transactionProvider.removeTransaction(transaction.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Transacción eliminada'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
