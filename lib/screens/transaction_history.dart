import 'package:expense_managment/models/transaction.dart';
import 'package:expense_managment/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final transactions = transactionProvider.transactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de transacciones'),
        centerTitle: true
      ),
      body: transactions.isEmpty ? Center(
        child: Text('No hay transacciones registradas')
        ) : ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return Card(
              child: ListTile(
                leading: Icon(transaction.type == TransactionType.income ? Icons.arrow_upward_sharp : Icons.arrow_downward_outlined, color: transaction.type == TransactionType.income ? Colors.green : Colors.red),
                title: Text(transaction.category),
                subtitle: Text('S/${transaction.amount.toStringAsFixed(2)}'),
                trailing: Text(
                  '\$${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: transaction.type == TransactionType.income ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold
                  ),
                ),
                onTap: (){
                  Navigator.pushNamed(context, '/frmtransaction', arguments: transaction);
                },
                onLongPress: (){
                  transactionProvider.removeTransaction(transaction.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Transacción eliminada'), 
                      duration: Duration(seconds: 2)
                    )
                  );
                }
              )
            );
          }
      )
    );
  }
}