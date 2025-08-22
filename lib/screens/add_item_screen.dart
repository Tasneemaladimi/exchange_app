import 'package:flutter/material.dart';
import '../models/item.dart';

class AddItemScreen extends StatefulWidget {
  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إضافة غرض جديد')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'اسم الغرض'),
                validator: (val) => val == null || val.isEmpty
                    ? 'الرجاء إدخال اسم الغرض'
                    : null,
                onSaved: (val) => title = val!.trim(),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'وصف الغرض'),
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty
                    ? 'الرجاء إدخال وصف الغرض'
                    : null,
                onSaved: (val) => description = val!.trim(),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'رابط صورة (اختياري)'),
                onSaved: (val) {
                  if (val != null && val.trim().isNotEmpty)
                    imageUrl = val.trim();
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('إضافة'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final newItem = Item(
                      id: '',
                      title: title,
                      description: description,
                      imageUrl: imageUrl,
                    );
                    Navigator.pop(context, newItem);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
