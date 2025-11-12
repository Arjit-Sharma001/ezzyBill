import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezzybill/widgetsCommon/BgWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'package:ezzybill/consts/consts.dart';
import 'package:ezzybill/consts/list.dart';

class ItemEditScreen extends StatefulWidget {
  @override
  State<ItemEditScreen> createState() => _ItemEditScreenState();
}

class _ItemEditScreenState extends State<ItemEditScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  File? _pickedImage;
  String? _selectedCategory;
  String? imageUrl;
  bool isUploading = false;

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  Future<String?> uploadImageToGitHub(String name, File imageFile) async {
    final base64Image = base64Encode(await imageFile.readAsBytes());
    final response = await http.put(
      Uri.parse(
          'https://api.github.com/repos/Arjit-Sharma001/ezzyBill_fs/contents/assets/images/$name'),
      headers: {
        'Authorization': 'Bearer ',
        'Accept': 'application/vnd.github+json',
      },
      body: jsonEncode({
        'message': 'Upload $name',
        'content': base64Image,
        'branch': 'main',
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['content']['download_url'];
    } else {
      print('GitHub upload failed: ${response.body}');
      return null;
    }
  }

  Future<void> addItem() async {
    final name = nameController.text.trim();
    final priceText = priceController.text.trim();

    if (name.isEmpty ||
        priceText.isEmpty ||
        _selectedCategory == null ||
        _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields including image are required")),
      );
      return;
    }

    setState(() => isUploading = true);
    imageUrl = await uploadImageToGitHub(name, _pickedImage!);
    setState(() => isUploading = false);

    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image upload failed")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('food_items').add({
      'name': name,
      'price': int.parse(priceText),
      'image_url': imageUrl!,
      'category': _selectedCategory!,
      'createdAt': Timestamp.now(),
    });

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return BgWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("Add New Item", style: TextStyle(color: primaryColor)),
          backgroundColor: secondaryColor,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: primaryColor),
        ),
        body: Stack(
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey.shade300],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        height: h * 0.25,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey),
                          color: Colors.grey.shade200,
                        ),
                        child: _pickedImage == null
                            ? Center(
                                child: Icon(Icons.add_a_photo_outlined,
                                    size: 48, color: Colors.grey),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(_pickedImage!,
                                    fit: BoxFit.cover),
                              ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Item Name",
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.fastfood),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Price (₹)",
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.currency_rupee),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Choose Category",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600)),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: FoodCatagoryList.map((cat) {
                        final selected = _selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat,
                              style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : Colors.grey.shade700)),
                          selected: selected,
                          selectedColor: secondaryColor,
                          backgroundColor: Colors.grey.shade200,
                          onSelected: (_) =>
                              setState(() => _selectedCategory = cat),
                        );
                      }).toList(),
                    ),
                    Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.save),
                        label: Text("Add Item"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          textStyle: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: isUploading ? null : addItem,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    )
                  ],
                ),
              ),
            ),
            if (isUploading)
              Container(
                color: Colors.black45,
                child: Center(
                  child: CircularProgressIndicator(
                      color: secondaryColor, strokeWidth: 4),
                ),
              )
          ],
        ),
      ),
    );
  }
}
