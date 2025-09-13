import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exchange_provider.dart';
import '../models/exchange.dart';

class MyExchangesScreen extends StatelessWidget {
  const MyExchangesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exchangeProvider = Provider.of<ExchangeProvider>(context, listen: false);

    return StreamBuilder<List<Exchange>>(
      stream: exchangeProvider.getIncomingExchangeRequestsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('You have no incoming exchange requests.'));
        }

        final exchanges = snapshot.data!;

        return ListView.builder(
          itemCount: exchanges.length,
          itemBuilder: (ctx, i) {
            final exchange = exchanges[i];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                title: Text('Request for: ${exchange.productTitle}'),
                subtitle: Text('From: ${exchange.requesterId}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      child: const Text('REJECT', style: TextStyle(color: Colors.red)),
                      onPressed: () async {
                        await exchangeProvider.rejectExchange(exchange.exchangeId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Request rejected.')),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      child: const Text('ACCEPT'),
                      onPressed: () async {
                        await exchangeProvider.acceptExchange(exchange.exchangeId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Request accepted!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
