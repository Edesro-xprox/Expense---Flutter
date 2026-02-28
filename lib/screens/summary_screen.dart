import 'package:expense_managment/models/expense_data.dart';
import 'package:expense_managment/models/transaction.dart';
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
  @override
  void initState() {
    super.initState();
    Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: true);
    final transactions = transactionProvider.transactions;

    final List<ExpenseData> expenseData = [
      ExpenseData(
        'Comida',
        transactions.where((t) => t.category == 'Comida' && t.type == TransactionType.expense).fold(0.00, (sum, t) => sum + t.amount)
      ),
      ExpenseData(
        'Transporte',
        transactions.where((t) => t.category == 'Transporte' && t.type == TransactionType.expense).fold(0.00, (sum, t) => sum + t.amount)
      ),
      ExpenseData(
        'Salud',
        transactions.where((t) => t.category == 'Salud' && t.type == TransactionType.expense).fold(0.00, (sum, t) => sum + t.amount)
      ),
      ExpenseData(
        'Otros',
        transactions.where((t) => t.category == 'Otros' && t.type == TransactionType.expense).fold(0.00, (sum, t) => sum + t.amount)
      )
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: const Text('Resumen de Gastos'),
        centerTitle: true,
        actions:[
          IconButton(
            onPressed: (){
              Navigator.pushNamed(context, '/history');
            },
            icon: Icon(Icons.history)
          )
        ]
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen del Mes',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold 
              )
            ),
            SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(Icons.arrow_upward_sharp, color: Colors.green),
                title: Text('Ingresos'),
                subtitle: Text('S/${transactionProvider.totalIncome.toStringAsFixed(2)}'),
                onTap: (){
                  
                }
              )
            ),
            SizedBox(height: 20,),
            Card(
              child: ListTile(
                leading: Icon(Icons.arrow_downward_outlined, color: Colors.red),
                title: Text('Gastos'),
                subtitle: Text('S/${transactionProvider.totalExpense.toStringAsFixed(2)}'),
                onTap: (){
                  
                }
              )
            ),
            SizedBox(height: 20,),
            Center(
              child: ElevatedButton.icon(
                onPressed: (){
                  Navigator.pushNamed(context, '/transaction');
                },
                icon: Icon(Icons.add),
                label: Text('Añadir Transacción'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                )
              )
            ),
            SizedBox(height: 20),
            ExpenseChart(data: expenseData)
          ]
        ) 
      )
    );
  }
}