import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controller/feature_controller/bloodBank_controller.dart';

class BloodBankView extends StatelessWidget {

  final BloodBankController controller = Get.put(BloodBankController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Campus Blood Bank", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // --- Filter Section ---
          Container(
            padding: EdgeInsets.all(20),
            color: Colors.redAccent,
            child: Column(
              children: [
                Text(
                  "Find A Donor",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: DropdownButtonHideUnderline(
                    // Obx দিয়ে র‍্যাপ করা যাতে সিলেকশন চেঞ্জ হলে UI আপডেট হয়
                    child: Obx(
                      () => DropdownButton<String>(
                        isExpanded: true,
                        hint: Text("Select Blood Group"),
                        value: controller.selectedGroup.value,
                        items: controller.bloodGroups
                            .map(
                              (bg) =>
                                  DropdownMenuItem(value: bg, child: Text(bg)),
                            )
                            .toList(),
                        onChanged: (val) {
                          controller.selectedGroup.value = val;
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- Donor List ---
          Expanded(
            // Obx ব্যবহার করা হয়েছে যাতে selectedGroup চেঞ্জ হলে পুরো বডি রিফ্রেশ হয়
            child: Obx(() {
              if (controller.selectedGroup.value == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.water_drop,
                        size: 80,
                        color: Colors.red.shade100,
                      ),
                      Text(
                        "Select a blood group to search",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return StreamBuilder<QuerySnapshot>(
                stream: controller.donorsStream, // কন্ট্রোলার থেকে স্ট্রিম
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final donors = snapshot.data!.docs;

                  if (donors.isEmpty) {
                    return Center(
                      child: Text(
                        "No donors found for ${controller.selectedGroup.value}",
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: donors.length,
                    padding: EdgeInsets.all(10),
                    itemBuilder: (context, index) {
                      var data = donors[index].data() as Map<String, dynamic>;

                      // সেফটি চেক (যদি কারো নাম না থাকে)
                      String name = data['name'] ?? 'Unknown';
                      String dept = data['dept'] ?? 'Student';
                      String phone = data['phone'] ?? '';
                      String group = data['bloodGroup'] ?? '';

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Text(
                              group,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("$dept | $phone"),
                          trailing: IconButton(
                            icon: Icon(Icons.call, color: Colors.green),
                            onPressed: () => controller.callDonor(phone),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
