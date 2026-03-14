import 'package:expense_managment/models/category.dart';
import 'package:expense_managment/models/transaction.dart';
import 'package:expense_managment/providers/category_provider.dart';
import 'package:expense_managment/providers/transaction_provider.dart';
import 'package:expense_managment/screens/summary_screen.dart';
import 'package:expense_managment/screens/transaction_form_screen.dart';
import 'package:expense_managment/screens/transaction_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
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
      // locale: const Locale('es'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: const [
        Locale('es'),
        Locale('en'),
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => SummaryScreen(),
        '/history': (context) => TransactionHistoryScreen(),
        '/frmtransaction': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final Transaction? transaction = args['transaction'];
          final CategoryType categoryType = args['categoryType'];
          return TransactionFormScreen(transaction: transaction, categoryType: categoryType);
        },
      }
    );
  }
}
