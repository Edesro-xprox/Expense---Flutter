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
  late List<Transaction> transactions;
  late TransactionProvider transactionProvider;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  TransactionType _selectedType = TransactionType.expense;

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final transactions = transactionProvider.transactions;
    final totalIncome = transactionProvider.totalIncome(_selectedDate);
    final totalExpense = transactionProvider.totalExpense(_selectedDate);

    final List<ExInData> expenseData = [
      ExInData(
        'Comida',
        transactions
          .where((t) => t.category == 'Comida' && t.type == TransactionType.expense && t.date.day <= _selectedDate.day && t.date.month == _selectedDate.month && t.date.year == _selectedDate.year)
          .fold(0.00, (sum, t) => sum + t.amount)
      ),
      ExInData(
        'Transporte',
        transactions.where((t) => t.category == 'Transporte' && t.type == TransactionType.expense && t.date.day <= _selectedDate.day && t.date.month == _selectedDate.month && t.date.year == _selectedDate.year).fold(0.00, (sum, t) => sum + t.amount)
      ),
      ExInData(
        'Salud',
        transactions.where((t) => t.category == 'Salud' && t.type == TransactionType.expense && t.date.day <= _selectedDate.day && t.date.month == _selectedDate.month && t.date.year == _selectedDate.year).fold(0.00, (sum, t) => sum + t.amount)
      ),
      ExInData(
        'Otros',
        transactions.where((t) => t.category == 'Otros' && t.type == TransactionType.expense && t.date.day <= _selectedDate.day && t.date.month == _selectedDate.month && t.date.year == _selectedDate.year).fold(0.00, (sum, t) => sum + t.amount)
      )
    ];

    final List<ExInData> incomeData = [
      ExInData(
        'Sueldo',
        transactions.where((t) => t.category == 'Sueldo' && t.type == TransactionType.income && t.date.day <= _selectedDate.day && t.date.month == _selectedDate.month && t.date.year == _selectedDate.year).fold(0.00, (sum, t) => sum + t.amount)
      ),
      ExInData(
        'Venta',
        transactions.where((t) => t.category == 'Venta' && t.type == TransactionType.income && t.date.day <= _selectedDate.day && t.date.month == _selectedDate.month && t.date.year == _selectedDate.year).fold(0.00, (sum, t) => sum + t.amount)
      ),
      ExInData(
        'Otros',
        transactions.where((t) => t.category == 'Otros' && t.type == TransactionType.income && t.date.day <= _selectedDate.day && t.date.month == _selectedDate.month && t.date.year == _selectedDate.year).fold(0.00, (sum, t) => sum + t.amount)
      )
    ];

    List<ExInData> exInDataCurrent = _selectedType == TransactionType.expense ? expenseData : incomeData;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                Text(
                  'Resumen ${_selectedDate.month}/${_selectedDate.year}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold 
                  )
                ),
                IconButton(
                  onPressed: () async {
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
                  icon: const Icon(Icons.calendar_today, color: Colors.blue)
                )
              ]
            ),
            SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(Icons.arrow_upward_sharp, color: Colors.green),
                title: Text('Ingresos'),
                subtitle: Text('S/${totalIncome}'),
                onTap: (){
                  Navigator.pushNamed(context, '/frmtransaction', arguments: {
                    'transaction': null,
                    'transactionType': TransactionType.income
                  });  
                }
              )
            ),
            SizedBox(height: 20,),
            Card(
              child: ListTile(
                leading: Icon(Icons.arrow_downward_outlined, color: Colors.red),
                title: Text('Gastos'),
                subtitle: Text('S/${totalExpense}'),
                onTap: (){
                  Navigator.pushNamed(context, '/frmtransaction', arguments: {
                    'transaction': null,
                    'transactionType': TransactionType.expense
                  });
                }
              )
            ),
            SizedBox(height: 20),
            ExpenseChart(data: exInDataCurrent, type: _selectedType),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
                Expanded(
                  child: RadioListTile(
                    value: TransactionType.expense,
                    title: Text('Gastos'),
                    groupValue: _selectedType, 
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                        exInDataCurrent = expenseData;
                      });
                    },
                  )
                ),
                Expanded(
                  child: RadioListTile(
                    value: TransactionType.income, 
                    title: Text('Ingresos'),
                    groupValue: _selectedType,
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                        exInDataCurrent = incomeData;
                      });
                    }
                  )
                )
              ]
            )
          ]
        ) 
      )
    );
  }
}