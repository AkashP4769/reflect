import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:icon_decoration/icon_decoration.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:reflect/models/chapter.dart';
import 'package:reflect/services/image_service.dart';

class ChapterHeader extends StatefulWidget {
  final bool isEditing;
  final Chapter chapter;
  final ThemeData themeData;
  //final void Function(String title, String description, DateTime dateTime)? editChapter;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final DateTime date;
  final Function()? showDatePickerr;
  final Function() toggleEdit;
  final Function(List<String> imageUrl) updateChapter;
  ChapterHeader({super.key, required this.chapter, required this.themeData, required this.isEditing, required this.titleController, required this.descriptionController, required this.date, required this.showDatePickerr, required this.toggleEdit, required this.updateChapter});

  @override
  State<ChapterHeader> createState() => _ChapterHeaderState();
}

class _ChapterHeaderState extends State<ChapterHeader> {
  File? _image;
  late Chapter chapter;
  List<String> imageUrl = [];

  @override
  void initState() {
    super.initState();
    chapter = widget.chapter;
    imageUrl = chapter.imageUrl ?? [];
  }

  final ImagePicker _picker = ImagePicker();

  String imageType = 'url';

  Future<void> updateChapter() async {
    List<String> newImageUrl = await uploadImage();
    widget.updateChapter(newImageUrl);
    widget.toggleEdit();
  }

  Future<List<String>> uploadImage() async {
    String? newImageUrl = null;
    if(imageType == 'file'){
      newImageUrl = await ImageService().uploadImage(_image!);
      if(newImageUrl == null) return [];
      imageUrl = [newImageUrl];
      if(mounted) setState(() {});
    }
    else if(imageType == 'url'){
      newImageUrl = imageUrl[0];
    }
    return newImageUrl == null ? [] : [newImageUrl];

  }

  void getRandomImage() => setState((){
    imageUrl = [ImageService().getRandomImage()];
    imageType = 'url';
  });

  void onEditImage() async {
    await _pickImage(ImageSource.gallery);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
          _image = File(pickedFile.path);
          imageType = 'file';
      } else {
        print('No image selected.');
      }
      setState(() {});

    } catch (e) {
      print('Error picking image: $e');
      SnackBar snackBar = const SnackBar(content: Text("Error picking image"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      imageType = 'null';
      setState(() {});
    }
  }

  void removeSelectedPhoto(){
    _image = null;
    imageType = 'null';
    imageUrl = [];
    setState(() {});
  }

  /*void uploadImage() async {
    if(imageType == 'file' && _image != null){
      String? newUrl = await ImageService().uploadImage(_image!);
      if(newUrl != null) {
        print("new Image url: "+ newUrl);
    }
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if(widget.isEditing && !(imageUrl != null && imageUrl!.isNotEmpty) || (imageType =='file' && _image != null)) Align(
            alignment: Alignment.topRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: removeSelectedPhoto, 
                  icon: const DecoratedIcon(icon: Icon(Icons.close, color: Colors.white,), decoration: IconDecoration(border: IconBorder(width: 1)),),
                ),
                IconButton(
                  onPressed: getRandomImage,
                  icon: const DecoratedIcon(icon: Icon(Icons.shuffle, color: Colors.white), decoration: IconDecoration(border: IconBorder(width: 1)),),
                ),
                IconButton(
                  onPressed: onEditImage,
                  icon: const DecoratedIcon(icon: Icon(Icons.edit, color: Colors.white), decoration: IconDecoration(border: IconBorder(width: 1)),),
                ),
              ]
            )
          ),

          if((imageUrl != null && imageUrl!.isNotEmpty) || (imageType =='file' && _image != null)) Container(
            height: 200,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 4,
                  blurRadius: 7,
                  offset: const Offset(0, 3)
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if(imageType == 'url' && imageUrl.isNotEmpty) CachedNetworkImage(imageUrl: imageUrl[0], width: double.infinity, height: 200, fit: BoxFit.cover),
                  if(imageType =='file' && _image != null) Image.file(_image!, fit: BoxFit.cover, height: 200,),
                
                  if(widget.isEditing && ((imageType == 'url' && imageUrl != null) || (imageType =='file' && _image != null))) Align(
                    alignment: Alignment.topRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: removeSelectedPhoto, 
                          icon: const DecoratedIcon(icon: Icon(Icons.close, color: Colors.white,), decoration: IconDecoration(border: IconBorder(width: 1)),),
                        ),
                        IconButton(
                          onPressed: getRandomImage,
                          icon: const DecoratedIcon(icon: Icon(Icons.shuffle, color: Colors.white), decoration: IconDecoration(border: IconBorder(width: 1)),),
                        ),
                        IconButton(
                          onPressed: onEditImage,
                          icon: const DecoratedIcon(icon: Icon(Icons.edit, color: Colors.white), decoration: IconDecoration(border: IconBorder(width: 1)),),
                        ),
                      ]
                    )
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if(!widget.isEditing) Text(chapter.title, style: widget.themeData.textTheme.titleLarge?.copyWith(color: const Color(0xffFF9432),), textAlign: TextAlign.center,),
          if(widget.isEditing) TextField(
            controller: widget.titleController,
            maxLines:  null,
            style: widget.themeData.textTheme.titleLarge?.copyWith(color: widget.themeData.colorScheme.primaryFixed,), textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'Chapter Title',
              hintStyle: widget.themeData.textTheme.titleLarge?.copyWith(color: widget.themeData.colorScheme.primaryFixed.withOpacity(0.7),),
              alignLabelWithHint: true,
              contentPadding: EdgeInsets.zero,
              isDense: true,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
            ),
          ),
          const SizedBox(height: 10),
          if(!widget.isEditing) Text(chapter.description, style: widget.themeData.textTheme.bodyMedium?.copyWith(color: widget.themeData.colorScheme.onPrimary, fontWeight: FontWeight.w600,), textAlign: TextAlign.center,),
          if(widget.isEditing) TextField(
            controller: widget.descriptionController,
            style: widget.themeData.textTheme.bodyMedium?.copyWith(color: widget.themeData.colorScheme.onPrimary, fontWeight: FontWeight.w600,), textAlign: TextAlign.center,
            maxLines: null,
            decoration: InputDecoration(
              hintText: 'Description',
              hintStyle: widget.themeData.textTheme.bodyMedium?.copyWith(color: widget.themeData.colorScheme.onPrimary.withOpacity(0.7), fontWeight: FontWeight.w600,),
              alignLabelWithHint: true,
              contentPadding: EdgeInsets.zero,
              isDense: true,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.book, color: widget.themeData.colorScheme.onPrimary,),
                  const SizedBox(width: 5),
                  Text('Entries - ${chapter.entryCount}', style: widget.themeData.textTheme.bodySmall?.copyWith(color: widget.themeData.colorScheme.onPrimary, fontSize: 14),)
                ],
              ),
              GestureDetector(
                onTap: widget.isEditing ? (){
                  widget.showDatePickerr!();
                } : null,
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: widget.themeData.colorScheme.onPrimary,),
                    const SizedBox(width: 5),
                    Text('Created - ${DateFormat('dd/MM/yyyy').format(widget.date)}', style: widget.themeData.textTheme.bodySmall?.copyWith(color: widget.themeData.colorScheme.onPrimary, fontSize: 14),)
                  ],
                ),
              )
            ],
          ),
          Divider(color: widget.themeData.colorScheme.onPrimary, thickness: 1, height: 30),

          if(widget.isEditing) Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: widget.toggleEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.themeData.colorScheme.surface,
                      elevation: 10
                    ),
                    child: Icon(Icons.close, color: widget.themeData.colorScheme.onPrimary,)
                  ),
                ),
                const SizedBox(width: 20,),
                Expanded(
                  flex: 4,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 10,
                    ),
                    onPressed: updateChapter,
                    child: Text("Save", style: widget.themeData.textTheme.titleMedium?.copyWith(color: Colors.white),)
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}