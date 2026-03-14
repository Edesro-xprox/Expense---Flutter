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
        title: const Text('Historial de transacciones'),
        centerTitle: true
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
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _dateUtil.formattedDate(_selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.blue),
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
                      style: TextStyle(color: Colors.grey[600]),
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
                                ? Colors.green
                                : (transaction.isPaid ? Colors.blue : Colors.red),
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
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          trailing: Text(
                            '\$${transaction.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: category.first.type == CategoryType.income
                                  ? Colors.green
                                  : Colors.red,
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
