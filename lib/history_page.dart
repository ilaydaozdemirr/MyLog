import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(child: Text("Kullanıcı oturumu açık değil."));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Analysis History'),
        backgroundColor: const Color.fromARGB(245, 203, 200, 194),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('analyses')
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text("No analyses found."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final date = DateTime.tryParse(doc.id);
              final formattedDate =
                  date != null ? DateFormat.yMMMMd().format(date) : doc.id;

              final analysis = doc['analysis'] ?? 'No content';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text("🗓 $formattedDate"),
                  subtitle: Text(
                    analysis,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: const Text("Delete Analysis"),
                              content: const Text(
                                "Are you sure you want to delete this analysis?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Delete"),
                                ),
                              ],
                            ),
                      );
                      if (confirmed == true) {
                        await doc.reference.delete();
                      }
                    },
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder:
                          (_) => AlertDialog(
                            title: Text("Full Analysis - $formattedDate"),
                            content: SingleChildScrollView(
                              child: Text(analysis),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Close"),
                              ),
                            ],
                          ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
