import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:revision/config/api_config.dart';
import 'package:revision/screens/shows/add_show_page.dart';
import 'package:revision/screens/shows/show_detail_page.dart';
import 'package:revision/screens/shows/update_show_page.dart';
import 'package:revision/screens/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<dynamic> movies = [];
  List<dynamic> anime = [];
  List<dynamic> series = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchShows();
  }

  Future<void> fetchShows() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/shows'));
      if (response.statusCode == 200) {
        final List<dynamic> allShows = jsonDecode(response.body);
        setState(() {
          movies = allShows.where((s) => s['category'] == 'movie').toList();
          anime = allShows.where((s) => s['category'] == 'anime').toList();
          series = allShows.where((s) => s['category'] == 'serie').toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load shows');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<bool?> _confirmDelete(int id) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this show?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildShowList(List<dynamic> shows) {
    if (shows.isEmpty) {
      return const Center(child: Text("No shows available"));
    }

    return ListView.builder(
      itemCount: shows.length,
      itemBuilder: (ctx, index) {
        final show = shows[index];
        return Dismissible(
          key: Key(show['id'].toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (_) async {
            final confirmed = await _confirmDelete(show['id']);
            if (confirmed == true) {
              try {
                final response = await http.delete(
                  Uri.parse('${ApiConfig.baseUrl}/shows/${show['id']}'),
                );
                if (response.statusCode == 200) {
                  fetchShows();
                  return true;
                }
                return false;
              } catch (e) {
                return false;
              }
            }
            return false;
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: show['image'] != null
                  ? Image.network(
                '${ApiConfig.baseUrl}${show['image']}',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
              )
                  : const Icon(Icons.image, size: 50),
              title: Text(show['title']),
              subtitle: Text(show['description']),
              onTap: () => Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (_) => ShowDetailPage(
                    showData: show,
                    refreshCallback: fetchShows,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Show App"),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Text("Menu", style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text("Add Show"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddShowPage()))
                    .then((shouldRefresh) {
                  if (shouldRefresh == true) {
                    fetchShows();
                  }
                });
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchShows,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : IndexedStack(
          index: _selectedIndex,
          children: [
            _buildShowList(movies),
            _buildShowList(anime),
            _buildShowList(series),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: "Movies"),
          BottomNavigationBarItem(icon: Icon(Icons.animation), label: "Anime"),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: "Series"),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}