import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:icon_decoration/icon_decoration.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:reflect/components/common/error_network_image.dart';
import 'package:reflect/models/chapter.dart';
import 'package:reflect/services/image_service.dart';

class ChapterHeader extends StatelessWidget {
  final bool isEditing;
  final Chapter chapter;
  final ThemeData themeData;
  //final void Function(String title, String description, DateTime dateTime)? editChapter;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final DateTime date;
  final Function()? showDatePickerr;
  final Function() toggleEdit;
  final Function() updateChapter;
  final String imageType;
  final List<String> imageUrl;
  final File? image;
  final Function() getRandomImage;
  final Function() onEditImage;
  final Function() removeSelectedPhoto;
  
  const ChapterHeader({super.key, required this.chapter, required this.themeData, required this.isEditing, required this.titleController, required this.descriptionController, required this.date, required this.showDatePickerr, required this.toggleEdit, required this.updateChapter, required this.imageType, required this.imageUrl, required this.image,  required this.getRandomImage, required this.onEditImage, required this.removeSelectedPhoto});


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columnCount = width < 720 ? 1 : 2;

    final List<Widget> widgets = [
      Container(
        //height: 250,
        
        width: columnCount == 1 ? double.infinity : (MediaQuery.of(context).size.width / 2) - (MediaQuery.of(context).size.width / 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if(isEditing && !((imageUrl != null && imageUrl!.isNotEmpty) || (imageType =='file' && image != null))) Container(
              height: columnCount == 1 ? 200 : 300,
              width: columnCount == 1 ? MediaQuery.of(context).size.width - 40 : (MediaQuery.of(context).size.width / 2) - (MediaQuery.of(context).size.width / 20),
              alignment: Alignment.topRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: getRandomImage,
                    icon: const DecoratedIcon(icon: Icon(Icons.shuffle, color: Colors.white), decoration: IconDecoration(border: IconBorder(width: 1)),),
                  ),
                  IconButton(
                    onPressed: onEditImage,
                    icon: const DecoratedIcon(icon: Icon(Icons.add_photo_alternate_outlined, color: Colors.white), decoration: IconDecoration(border: IconBorder(width: 1)),),
                  ),
                ]
              )
            ),
        
            if((imageUrl != null && imageUrl!.isNotEmpty) || (imageType =='file' && image != null)) Container(
              height: columnCount == 1 ? 200 : 300,
              width: columnCount == 1 ? MediaQuery.of(context).size.width - 40 : (MediaQuery.of(context).size.width / 2) - (MediaQuery.of(context).size.width / 20),
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
                    if(!isEditing && imageType == 'url' && chapter.imageUrl!.isNotEmpty) CachedNetworkImage(imageUrl: chapter.imageUrl![0], width: double.infinity, height: 200, fit: BoxFit.cover, errorWidget: (context, url, error) => ErrorNetworkImage(error: error.toString()),),
                    if(isEditing && imageType == 'url' && imageUrl.isNotEmpty) CachedNetworkImage(imageUrl: imageUrl[0], width: double.infinity, height: 200, fit: BoxFit.cover, errorWidget: (context, url, error) => ErrorNetworkImage(error: error.toString()),),
                    if(isEditing && imageType =='file' && image != null) Image.file(image!, fit: BoxFit.cover, height: 200,),
                  
                    if(isEditing && ((imageType == 'url' && imageUrl != null) || (imageType =='file' && image != null))) Align(
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
          ],
        ),
      ),

      Container(
        //height: 500,
        width: columnCount == 1 ? double.infinity : (MediaQuery.of(context).size.width / 2) - (MediaQuery.of(context).size.width / 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if(!isEditing) Text(chapter.title, style: themeData.textTheme.titleLarge?.copyWith(color: const Color(0xffFF9432), fontSize: columnCount == 1 ? 32 : 42), textAlign: TextAlign.center,),
            if(isEditing) TextField(
              controller: titleController,
              maxLines:  null,
              style: themeData.textTheme.titleLarge?.copyWith(color: themeData.colorScheme.primaryFixed, fontSize: columnCount == 1 ? 32 : 42), 
              textAlign: TextAlign.center, 
              decoration: InputDecoration(
                hintText: 'Chapter Title',
                hintStyle: themeData.textTheme.titleLarge?.copyWith(color: themeData.colorScheme.primaryFixed.withOpacity(0.7),),
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
            if(!isEditing) Text(chapter.description, style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onPrimary, fontWeight: FontWeight.w600, fontSize: columnCount == 1 ? 16 : 22), textAlign: TextAlign.center,),
            if(isEditing) TextField(
              controller: descriptionController,
              style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onPrimary, fontWeight: FontWeight.w600, fontSize: columnCount == 1 ? 16 : 22), textAlign: TextAlign.center,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Description',
                hintStyle: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onPrimary.withOpacity(0.7), fontWeight: FontWeight.w600, fontSize: columnCount == 1 ? 16 : 22),
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
            SizedBox(height: columnCount == 1 ? 20 : 40,),
        
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.book, color: themeData.colorScheme.onPrimary,),
                    const SizedBox(width: 5),
                    Text('Entries - ${chapter.entryCount}', style: themeData.textTheme.bodySmall?.copyWith(color: themeData.colorScheme.onPrimary, fontSize: columnCount == 1 ? 14 : 16),)
                  ],
                ),
                GestureDetector(
                  onTap: isEditing ? (){
                    showDatePickerr!();
                  } : null,
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: themeData.colorScheme.onPrimary,),
                      const SizedBox(width: 5),
                      Text('Created - ${DateFormat('dd/MM/yyyy').format(date)}', style: themeData.textTheme.bodySmall?.copyWith(color: themeData.colorScheme.onPrimary, fontSize: columnCount == 1 ? 14 : 16),)
                    ],
                  ),
                )
              ],
            ),

            if(isEditing) SizedBox(height: columnCount == 1 ? 20 : 40,),
            
            if(isEditing) Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: toggleEdit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeData.colorScheme.surface,
                        elevation: 10
                      ),
                      child: Icon(Icons.close, color: themeData.colorScheme.onPrimary,)
                    ),
                  ),
                  const SizedBox(width: 20,),
                  Expanded(
                    flex: 4,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 10,
                      ),
                      onPressed: (){
                        toggleEdit();
                        updateChapter();
                      },
                      child: Text("Save", style: themeData.textTheme.titleMedium?.copyWith(color: Colors.white, fontSize: columnCount == 1 ? 16 : 22),)
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      )
    ];

    
    print(width);
    return Container(
      //color: Colors.green,
      width: double.infinity,
      padding: EdgeInsetsDirectional.symmetric(horizontal: columnCount == 1 ? 0 : 60,),
      child: columnCount == 2 ? GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnCount,
          childAspectRatio: 1.0,
          mainAxisExtent: columnCount == 1 ? 200 : 360,
          crossAxisSpacing: 40,
        ),
        
        shrinkWrap: true,
        clipBehavior: Clip.hardEdge,
        itemCount: widgets.length,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          return widgets[index];
        },
      ) : 
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 20,
        children: widgets,
      ),
    );
  }
}
