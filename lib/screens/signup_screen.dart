import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool loading = false;

  void _signup() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => loading = true);
    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .register(email, password);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => HomeScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('خطأ في إنشاء الحساب')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إنشاء حساب')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: loading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration:
                          InputDecoration(labelText: 'البريد الإلكتروني'),
                      validator: (val) => val == null || val.isEmpty
                          ? 'الرجاء إدخال البريد'
                          : null,
                      onSaved: (val) => email = val!.trim(),
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'كلمة المرور'),
                      obscureText: true,
                      validator: (val) => val == null || val.isEmpty
                          ? 'الرجاء إدخال كلمة المرور'
                          : null,
                      onSaved: (val) => password = val!.trim(),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: _signup, child: Text('إنشاء حساب')),
                  ],
                ),
              ),
      ),
    );
  }
}
