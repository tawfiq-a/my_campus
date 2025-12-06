import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'add_book_screen.dart';
import 'borrow_request.dart';

class LibraryHomeScreen extends StatefulWidget {
  @override
  _LibraryHomeScreenState createState() => _LibraryHomeScreenState();
}

class _LibraryHomeScreenState extends State<LibraryHomeScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool isLibrarian = false;
  String _searchText = "";
  final _searchController = TextEditingController();

  List<String> myRequestedBookIds = [];

  @override
  void initState() {
    super.initState();
    _checkRole();
    _fetchMyRequests();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  void _checkRole() async {
    User? user = _auth.currentUser;
    if (user != null) {
      var doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          isLibrarian = (doc.data() as Map)['role'] == 'teacher';
        });
      }
    }
  }

  void _fetchMyRequests() {
    User? user = _auth.currentUser;
    if (user == null) return;

    _firestore
        .collection('borrow_requests')
        .where('uid', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
          if (mounted) {
            setState(() {
              myRequestedBookIds = snapshot.docs
                  .where(
                    (doc) => doc['status'] != 'Returned',
                  ) // ফেরত দেওয়া বই বাদে
                  .map((doc) => doc['bookId'] as String)
                  .toList();
            });
          }
        });
  }

  void _requestBook(String bookId, String bookName) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    var userDoc = await _firestore.collection('users').doc(user.uid).get();
    String studentName = userDoc['name'];
    String roll = userDoc['roll'];

    await _firestore.collection('borrow_requests').add({
      'bookId': bookId,
      'bookName': bookName,
      'studentName': studentName,
      'roll': roll,
      'uid': user.uid,
      'status': 'Pending',
      'requestDate': FieldValue.serverTimestamp(),
      'returnDate': null,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Request Sent!")));
  }

  // --- Delete Book ---
  void _deleteBook(String bookId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Book?"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: Text("Delete", style: TextStyle(color: Colors.red)),
            onPressed: () {
              _firestore.collection('books').doc(bookId).delete();
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Digital Library", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.brown,
          iconTheme: IconThemeData(color: Colors.white),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "All Books"),
              Tab(text: "My Borrow List"),
            ],
          ),
          actions: [
            if (isLibrarian) ...[
              IconButton(
                icon: Icon(Icons.list_alt),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BorrowRequestsScreen()),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddBookScreen()),
                ),
              ),
            ],
          ],
        ),
        body: TabBarView(children: [_buildAllBooksTab(), _buildMyBooksTab()]),
      ),
    );
  }


  Widget _buildAllBooksTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search books...",
              prefixIcon: Icon(Icons.search, color: Colors.brown),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              filled: true,
              fillColor: Colors.brown.shade50,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('books').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              final allBooks = snapshot.data!.docs;

              final filteredBooks = allBooks.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['title'].toString().toLowerCase().contains(
                  _searchText,
                );
              }).toList();

              if (filteredBooks.isEmpty) {
                return Center(child: Text("No books found"));
              }

              return GridView.builder(
                padding: EdgeInsets.all(10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: filteredBooks.length,
                itemBuilder: (context, index) {
                  final doc = filteredBooks[index];
                  final data = doc.data() as Map<String, dynamic>;
                  int available = data['available_copies'] ?? 0;


                  bool isRequested = myRequestedBookIds.contains(doc.id);

                  return Card(
                    elevation: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.grey[300],
                            child:
                                data['coverUrl'] != null &&
                                    data['coverUrl'].toString().isNotEmpty
                                ? Image.network(
                                    data['coverUrl'],
                                    fit: BoxFit.cover,
                                  )
                                : Icon(
                                    Icons.menu_book,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['title'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                data['author'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Copies: $available",
                                style: TextStyle(
                                  color: available > 0
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),

                              // --- Action Button ---
                              SizedBox(
                                width: double.infinity,
                                height: 30,
                                child: isRequested
                                    ? OutlinedButton(
                                        onPressed: null,
                                        child: Text(
                                          "Requested",
                                          style: TextStyle(
                                            color: Colors.orange,
                                          ),
                                        ),
                                      )
                                    : ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: available > 0
                                              ? Colors.brown
                                              : Colors.grey,
                                          padding: EdgeInsets.zero,
                                        ),
                                        onPressed: available > 0
                                            ? () => _requestBook(
                                                doc.id,
                                                data['title'],
                                              )
                                            : null,
                                        child: Text(
                                          available > 0
                                              ? "Borrow"
                                              : "Out of Stock",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                              ),

                              // Edit/Delete for Librarian
                              if (isLibrarian)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    onPressed: () => _deleteBook(doc.id),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }


  Widget _buildMyBooksTab() {
    User? user = _auth.currentUser;
    if (user == null) return Center(child: Text("Please login"));

    return StreamBuilder<QuerySnapshot>(

      stream: _firestore
          .collection('borrow_requests')
          .where('uid', isEqualTo: user.uid)
          //.orderBy('requestDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final myReqs = snapshot.data!.docs;

        if (myReqs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.library_books, size: 60, color: Colors.grey),
                Text(
                  "You haven't borrowed any books yet.",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: myReqs.length,
          padding: EdgeInsets.all(10),
          itemBuilder: (context, index) {
            final data = myReqs[index].data() as Map<String, dynamic>;
            String status = data['status'];
            String returnDate = "Not Set";

            if (data['returnDate'] != null) {
              returnDate = DateFormat(
                'dd MMM yyyy',
              ).format((data['returnDate'] as Timestamp).toDate());
            }

            return Card(
              elevation: 2,
              margin: EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: status == 'Approved'
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  child: Icon(
                    status == 'Approved' ? Icons.check : Icons.access_time,
                    color: status == 'Approved' ? Colors.green : Colors.orange,
                  ),
                ),
                title: Text(
                  data['bookName'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Status: $status",
                      style: TextStyle(color: Colors.black54),
                    ),
                    if (status == 'Approved')
                      Text(
                        "Return by: $returnDate",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
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
