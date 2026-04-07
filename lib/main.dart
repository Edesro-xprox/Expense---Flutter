import 'package:expense_managment/models/category.dart';
import 'package:expense_managment/models/transaction.dart';
import 'package:expense_managment/providers/category_provider.dart';
import 'package:expense_managment/providers/transaction_provider.dart';
import 'package:expense_managment/screens/category_form_screen.dart';
import 'package:expense_managment/screens/category_screen.dart';
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
    const colorScheme = ColorScheme.dark(
      primary: Color(0xFF2ECC71), // ingresos
      onPrimary: Color(0xFF05140C),
      secondary: Color(0xFFFF8F3D), // gastos
      onSecondary: Color(0xFF2B1400),
      tertiary: Color(0xFF5DADE2),
      onTertiary: Color(0xFF06121A),
      background: Color(0xFF0F1115),
      onBackground: Color(0xFFE6EAF2),
      surface: Color(0xFF171A21),
      onSurface: Color(0xFFE6EAF2),
      error: Color(0xFFE74C3C),
      onError: Color(0xFF2A0B07),
    );

    return MaterialApp(
      title: 'Gestor de Gastos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF171A21),
          foregroundColor: Color(0xFFE6EAF2),
          centerTitle: true,
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color(0xFF131720),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1D222C),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
          labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.8)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF1D222C),
          contentTextStyle: TextStyle(color: Color(0xFFE6EAF2)),
        ),
        useMaterial3: true,
      ),
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
        '/categories': (context) => const CategoryScreen(),
        '/history': (context) => TransactionHistoryScreen(),
        '/frmtransaction': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final Transaction? transaction = args['transaction'];
          final CategoryType categoryType = args['categoryType'];
          return TransactionFormScreen(transaction: transaction, categoryType: categoryType);
        },
        '/category-form': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final Category category = args['category'];
          return CategoryFormScreen(category: category);
        },
      }
    );
  }
}
