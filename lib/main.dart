import 'package:expense_managment/models/transaction.dart';
import 'package:expense_managment/providers/transaction_provider.dart';
import 'package:expense_managment/screens/summary_screen.dart';
import 'package:expense_managment/screens/transaction_form_screen.dart';
import 'package:expense_managment/screens/transaction_history.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider())
      ],
      child: MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de Gastos',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SummaryScreen(),
        '/transaction': (context) => TransactionFormScreen(), 
        '/history': (context) => TransactionHistoryScreen(),
        '/frmtransaction': (context) {
          final transaction = ModalRoute.of(context)!.settings.arguments as Transaction?;
          return TransactionFormScreen(transaction: transaction);
        },
      }
    );
  }
}