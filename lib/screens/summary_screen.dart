import 'package:expense_managment/models/category.dart';
import 'package:expense_managment/models/expense_data.dart';
import 'package:expense_managment/models/transaction.dart';
import 'package:expense_managment/providers/category_provider.dart';
import 'package:expense_managment/providers/transaction_provider.dart';
import 'package:expense_managment/widgets/expense_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  CategoryType _selectedType = CategoryType.expense;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<TransactionProvider>().loadTransactions();
      context.read<TransactionProvider>().loadCategories();
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    final transactions = transactionProvider.transactions;

    final totalIncome = transactionProvider.totalIncome();
    final totalExpense = transactionProvider.totalExpense();
    
    final balance = (double.parse(totalIncome) - double.parse(totalExpense)).toStringAsFixed(2);

    final categoriesByType = categoryProvider.categoriesByType(_selectedType);
    final exInDataCurrent = categoriesByType
        .map(
          (category) => ExInData(
            category.name,
            transactions
                .where((t) => t.categoryId == category.id)
                .fold(0.0, (sum, t) => sum + t.amount),
          ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: const Text('Control Financiero'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/history');
            },
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Resumen',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.arrow_upward_sharp, color: Colors.green),
                  title: const Text('Ingresos'),
                  subtitle: Text('S/$totalIncome'),
                  onTap: () {
                    Navigator.pushNamed(context, '/frmtransaction', arguments: {
                      'transaction': null,
                      'categoryType': CategoryType.income,
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.arrow_downward_outlined, color: Colors.red),
                  title: const Text('Egresos'),
                  subtitle: Text('S/$totalExpense'),
                  onTap: () {
                    Navigator.pushNamed(context, '/frmtransaction', arguments: {
                      'transaction': null,
                      'categoryType': CategoryType.expense,
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined, color: Colors.black),
                  title: const Text('Saldo actual'),
                  subtitle: Text(
                    '\$$balance',
                    style: TextStyle(
                      color: double.parse(balance) >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ExpenseChart(data: exInDataCurrent, type: _selectedType),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: RadioListTile<CategoryType>(
                      value: CategoryType.expense,
                      title: const Text('Egresos'),
                      groupValue: _selectedType,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedType = value);
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<CategoryType>(
                      value: CategoryType.income,
                      title: const Text('Ingresos'),
                      groupValue: _selectedType,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedType = value);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
