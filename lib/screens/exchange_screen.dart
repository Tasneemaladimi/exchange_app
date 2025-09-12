import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_provider.dart';
import '../models/item.dart';

class ExchangeScreen extends StatefulWidget {
  final String currentUserId;

  const ExchangeScreen({super.key, required this.currentUserId});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  Item? mySelectedItem;
  Item? otherSelectedItem;

  @override
  Widget build(BuildContext context) {
    final itemProv = Provider.of<ItemProvider>(context);

    final myItems = itemProv.getMyItems();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Exchange Items"),
        backgroundColor: const Color(0xFF4E6CFF),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // اختيار عنصر المستخدم
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<Item>(
              hint: const Text("Select your item"),
              value: mySelectedItem,
              isExpanded: true,
              items: myItems.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item.title),
                );
              }).toList(),
              onChanged: (item) {
                setState(() {
                  mySelectedItem = item;
                });
              },
            ),
          ),
          const Divider(),
          const SizedBox(height: 10),
          // عرض عناصر الآخرين من Firestore
          Expanded(
            child: StreamBuilder<List<Item>>(
              stream: itemProv.otherUsersItemsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No items available for exchange"));
                }

                final otherItems = snapshot.data!;

                return ListView.builder(
                  itemCount: otherItems.length,
                  itemBuilder: (ctx, i) {
                    final item = otherItems[i];
                    final isSelected = item == otherSelectedItem;

                    return ListTile(
                      title: Text(item.title),
                      subtitle: Text("Owner: ${item.ownerId}"),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                      onTap: () {
                        setState(() {
                          otherSelectedItem = item;
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
          // زر التبادل
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              onPressed: (mySelectedItem != null && otherSelectedItem != null)
                  ? () async {
                      await itemProv.exchangeItems(mySelectedItem!, otherSelectedItem!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Items exchanged successfully")),
                      );
                      setState(() {
                        mySelectedItem = null;
                        otherSelectedItem = null;
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4E6CFF),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              ),
              child: const Text("Exchange", style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
