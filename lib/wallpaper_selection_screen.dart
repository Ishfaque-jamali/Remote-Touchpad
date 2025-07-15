import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WallpaperSelectionScreen extends StatefulWidget {
  const WallpaperSelectionScreen({super.key});

  @override
  State<WallpaperSelectionScreen> createState() =>
      _WallpaperSelectionScreenState();
}

class _WallpaperSelectionScreenState extends State<WallpaperSelectionScreen> {
  String default_bg ='assets/images/touchpadBackground.jpg';
  File? selectedImage;

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> confirmWallpaper() async {
    if (selectedImage != null) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.setString('Touchpad Wallpaper', selectedImage!.path);
      Navigator.pop(context, true); // close modal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Wallpaper set successfully!")),
      );
    }
  }

  void showBottomAlertBox(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Selected Image", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: (){
                        pickImage(ImageSource.gallery);
                        },
                      icon: Icon(Icons.photo),
                      label: Text('Gallery'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        pickImage(ImageSource.camera);
                        Navigator.pop(context);
                      },

                      icon: Icon(Icons.camera_alt),
                      label: Text('Camera'),
                    ),
                  ],
                ),


              ],
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
        iconTheme: IconThemeData(
            color: Color(0xFF4CBA54)
        ),
        title: Text('Select wallpaper'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: "Default\nBackground",
            onPressed: () async {
              SharedPreferences preferences = await SharedPreferences.getInstance();
              await preferences.remove('Touchpad Wallpaper'); // Clear saved wallpaper path

              setState(() {
                selectedImage = null; // Reset preview to default
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Wallpaper reset to default')),
              );
            },

          )
        ],
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 50),
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                border: Border.all(color: Colors.black12),
                image: selectedImage != null
                    ? DecorationImage(
                  image: FileImage(selectedImage!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: selectedImage == null
                  ? Icon(Icons.wallpaper, size: 200)
                  : null,
            ),
            SizedBox(height: 30),

            selectedImage != null
            ?ElevatedButton(
              onPressed: selectedImage != null ? confirmWallpaper : null,
              child: Text("Confirm & Set Wallpaper"),
            ):
            ElevatedButton(
              onPressed: () => showBottomAlertBox(context),
              child: Text("Select Image"),
            ),
          ],
        ),
      ),
    );
  }
}
