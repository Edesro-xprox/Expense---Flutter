import 'package:expense_managment/models/transaction.dart';
import 'package:expense_managment/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionFormScreen extends StatefulWidget {
  final Transaction? transaction;
  final TransactionType transactionType;
  const TransactionFormScreen({super.key, this.transaction, required this.transactionType});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreen();
}

class _TransactionFormScreen extends State<TransactionFormScreen>{
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late String _selectedCategory;
  List<String> get categories => widget.transactionType == TransactionType.income 
    ? ['Sueldo', 'Venta', 'Otros'] 
    : ['Comida', 'Transporte', 'Salud', 'Otros'];

  @override
  void initState() {
    super.initState();
    if(widget.transaction != null){
      _amountController.text = widget.transaction!.amount.toString();
      _descriptionController.text = widget.transaction!.description;
      _selectedCategory = widget.transaction!.category;
    }else{
      _selectedCategory = widget.transactionType == TransactionType.income ? 'Sueldo' : 'Comida';
    }
  }

  @override
  Widget build(BuildContext build){
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null ? 'Registrar transacción' : 'Editar transacción'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Monto'),
                keyboardType: TextInputType.number,
                validator: (value){
                  if(value == null || value.isEmpty){
                    return 'Por favor ingrese un monto';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                maxLines: null,
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Descripción'),
                keyboardType: TextInputType.multiline
              ),
              SizedBox(height: 20),
              DropdownButtonFormField(
                value: widget.transaction?.category ?? _selectedCategory,
                decoration: InputDecoration(labelText: 'Categoría'), 
                items: categories.map((category){
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value){
                  setState((){
                    _selectedCategory = value!;
                  });
                }
              ),
              SizedBox(height: 20),

              // Row(
              //   children:[
              //   ]
              // ),

              Center(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.save),
                  onPressed: (){
                    if(_formKey.currentState!.validate()){
                      final transactionCurrent = Transaction(
                        id: widget.transaction == null ? DateTime.now().toString() : widget.transaction!.id,
                        amount: double.parse(_amountController.text),
                        description: _descriptionController.text,
                        category: _selectedCategory,
                        type: widget.transactionType,
                        date: widget.transaction?.date ?? DateTime.now()
                      );
                      if(widget.transaction == null){
                        Provider.of<TransactionProvider>(context, listen: false).addTransaction(transactionCurrent);
                      }else{
                        Provider.of<TransactionProvider>(context, listen: false).updateTransaction(transactionCurrent);
                      }
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Transacción ${widget.transaction == null ? 'registrada' : 'actualizada'}'), 
                            duration: Duration(seconds: 2)
                          )
                        );
                    Navigator.pop(context);
                  },
                  label: Text('Guardar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  )
                )
              )
            ]
          )
        )
      )
    );
  }
}