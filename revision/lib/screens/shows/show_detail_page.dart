import 'package:flutter/material.dart';
import 'package:revision/screens/shows/update_show_page.dart';

import '../../config/api_config.dart';

class ShowDetailPage extends StatelessWidget {
  final Map<String, dynamic> showData;
  final Future<void> Function() refreshCallback;

  const ShowDetailPage({
    super.key,
    required this.showData,
    required this.refreshCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(showData['title']),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToUpdate(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showData['image'] != null)
                Image.network(
                  '${ApiConfig.baseUrl}${showData['image']}',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 20),
              Text(
                showData['title'],
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(
                'Category: ${showData['category']}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Text(
                showData['description'],
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToUpdate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateShowPage(
          show: showData,
          refreshCallback: refreshCallback,
        ),
      ),
    ).then((updated) {
      if (updated == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Show updated successfully')),
        );
      }
    });
  }
}