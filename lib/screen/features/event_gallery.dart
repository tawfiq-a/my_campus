import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controller/feature_controller/evennt_controller.dart';

class EventGalleryView extends StatelessWidget {
  final EventGalleryController controller = Get.put(EventGalleryController());

  EventGalleryView({super.key});

  // --- Show Add Event Dialog ---
  void _showAddEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Add New Event"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller.titleCtrl,
                decoration: InputDecoration(labelText: "Event Title"),
              ),
              TextField(
                controller: controller.dateCtrl,
                decoration: InputDecoration(
                  labelText: "Date (e.g. 25 Dec 2023)",
                ),
              ),
              TextField(
                controller: controller.descCtrl,
                maxLines: 3,
                decoration: InputDecoration(labelText: "Description"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(child: Text("Cancel"), onPressed: () => Get.back()),
          ElevatedButton(
            child: Text("Post Event"),
            onPressed: () => controller.addEvent(),
          ),
        ],
      ),
    );
  }

  // --- Show Add Photo Dialog ---
  void _showAddPhotoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Add Photo Link"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller.linkCtrl,
              decoration: InputDecoration(
                labelText: "Image URL",
                hintText: "Paste direct image link here",
                prefixIcon: Icon(Icons.link),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: controller.captionCtrl,
              decoration: InputDecoration(labelText: "Caption (Optional)"),
            ),
          ],
        ),
        actions: [
          TextButton(child: Text("Cancel"), onPressed: () => Get.back()),
          ElevatedButton(
            child: Text("Add to Gallery"),
            onPressed: () => controller.addPhoto(),
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
          title: Text(
            "Events & Gallery",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.pinkAccent,
          iconTheme: IconThemeData(color: Colors.white),
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "Upcoming Events"),
              Tab(text: "Photo Gallery"),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildEventsTab(), _buildGalleryTab(context)],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.pinkAccent,
          child: Icon(Icons.add, color: Colors.white),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (ctx) => Container(
                height: 150,
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.event, color: Colors.pinkAccent),
                      title: Text("Add Event"),
                      onTap: () {
                        Get.back();
                        _showAddEventDialog(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.add_a_photo,
                        color: Colors.pinkAccent,
                      ),
                      title: Text("Add Photo Link"),
                      onTap: () {
                        Get.back();
                        _showAddPhotoDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Events Tab ---
  Widget _buildEventsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final events = snapshot.data!.docs;

        if (events.isEmpty) return Center(child: Text("No upcoming events"));

        return ListView.builder(
          itemCount: events.length,
          padding: EdgeInsets.all(15),
          itemBuilder: (context, index) {
            final data = events[index].data() as Map<String, dynamic>;
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: EdgeInsets.only(bottom: 15),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.pink.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            data['date'],
                            style: TextStyle(
                              color: Colors.pink,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () =>
                              controller.deleteItem('events', events[index].id),
                          child: Icon(
                            Icons.delete_outline,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      data['title'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      data['description'],
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Posted by: ${data['postedBy'] ?? 'Unknown'}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
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

  // --- Gallery Tab ---
  Widget _buildGalleryTab(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('gallery')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final photos = snapshot.data!.docs;

        if (photos.isEmpty) return Center(child: Text("Gallery is empty"));

        return GridView.builder(
          padding: EdgeInsets.all(10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.8,
          ),
          itemCount: photos.length,
          itemBuilder: (context, index) {
            final data = photos[index].data() as Map<String, dynamic>;
            return GestureDetector(
              onTap: () {
                // Full Screen Image
                Get.dialog(
                  Dialog(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.network(
                          data['imageUrl'],
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.broken_image,
                            size: 100,
                            color: Colors.grey,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              if (data['caption'] != null)
                                Text(
                                  data['caption'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              Text(
                                "Uploaded by: ${data['uploadedBy']}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              onLongPress: () =>
                  controller.deleteItem('gallery', photos[index].id),
              child: Card(
                elevation: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Image.network(
                        data['imageUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        data['uploadedBy'] ?? "User",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                        textAlign: TextAlign.center,
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
