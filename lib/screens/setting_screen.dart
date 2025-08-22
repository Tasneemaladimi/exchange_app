import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final itemProv = Provider.of<ItemProvider>(context, listen: false);
    final themeProv = Provider.of<ThemeProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text('الإعدادات')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // مسح جميع الأغراض
            ElevatedButton(
              onPressed: () async {
                for (var item in itemProv.items) {
                  await itemProv.removeItem(item.id);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم مسح جميع الأغراض')),
                );
              },
              child: Text('مسح جميع الأغراض'),
            ),
            SizedBox(height: 20),
            // إعادة الوضع الافتراضي للثيم
            ElevatedButton(
              onPressed: () async {
                if (themeProv.isDarkMode) {
                  themeProv.toggleTheme();
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم إعادة الوضع الافتراضي للثيم')),
                );
              },
              child: Text('إعادة الوضع الافتراضي للثيم'),
            ),
          ],
        ),
      ),
    );
  }
}
