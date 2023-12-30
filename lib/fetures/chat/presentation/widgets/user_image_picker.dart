import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({
    super.key,
    required this.onPickImage,
  });

  final void Function(File pickedImage) onPickImage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImageFile;

  //TODO : Function Pick Image
  void _pickedImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera, //โหมดกล้องถ่ายรูป
      imageQuality: 50, //ความชัด
      maxWidth: 150, //ขนาดภาพ
    );

    if (pickedImage == null) return;

    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });

    //ส่งค่าให้ Function ไปใช้ในหน้าอื่น
    widget.onPickImage(_pickedImageFile!);
  }

  //==============================================================================================================
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //TODO : Image Avatar
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage:
              _pickedImageFile != null ? FileImage(_pickedImageFile!) : null,
        ),

        //TODO : Button
        TextButton.icon(
          onPressed: _pickedImage,
          icon: const Icon(Icons.image),
          label: Text(
            'Add Image',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
