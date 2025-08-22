import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import '../providers/item_provider.dart';
import 'item_list_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context, listen: false);

    return ChangeNotifierProvider(
      create: (_) => ItemProvider(userId: authProv.user!.uid),
      child: Scaffold(
        appBar: AppBar(
          title: Text('تبادل الأغراض'),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await authProv.logout();
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => LoginScreen()));
              },
            ),
          ],
        ),
        body: Center(
          child: ElevatedButton.icon(
            icon: Icon(Icons.list),
            label: Text('عرض قائمة الأغراض'),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => ItemListScreen()));
            },
          ),
        ),
      ),
    );
  }
}
