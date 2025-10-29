import 'package:flutter/material.dart';

class EntryListAppbar extends StatelessWidget {
  const EntryListAppbar({
    super.key,
    required this.themeData,
    required this.searchController,
    this.deleteChapter,
    this.toggleEdit,
    this.popScreenWithUpdate,
    this.toggleSortSetting
  });

  final ThemeData themeData;
  final TextEditingController searchController;
  final void Function()? deleteChapter;
  final void Function()? toggleEdit;
  final void Function()? popScreenWithUpdate;
  final void Function()? toggleSortSetting;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            //padding: EdgeInsets.zero,
            //visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
            icon: Icon(Icons.arrow_back, color: themeData.colorScheme.onPrimary,),
            onPressed: () {
              popScreenWithUpdate!();
            },
          ),
          //const SizedBox(width: 10),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 0),
              height: 45,
              //width: double.infinity,
              child: SearchBar(
                controller: searchController,
                backgroundColor: WidgetStateProperty.all(themeData.colorScheme.secondaryContainer),
                elevation: WidgetStateProperty.all(0),
                trailing: [
                  IconButton(
                    onPressed: (){},
                    icon: const Icon(Icons.search),
                    color: themeData.colorScheme.onPrimary,
                  ),
                  
                ],
              ),
            ),
          ),
          PopupMenuButton(
            color: themeData.colorScheme.secondaryContainer,
            itemBuilder: (context) => [
              PopupMenuItem(
                height: 50,
                child: ListTile(
                  leading: Icon(Icons.edit, color: themeData.colorScheme.onPrimary,),
                  title: Text('Edit Chapter', style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onPrimary, fontWeight: FontWeight.w600),),
                  onTap: (){
                    Navigator.pop(context);
                    toggleEdit!();
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.delete, color: themeData.colorScheme.onPrimary,),
                  title: Text('Delete Chapter', style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onPrimary, fontWeight: FontWeight.w600),),
                  onTap: deleteChapter,
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.sort, color: themeData.colorScheme.onPrimary,),
                  title: Text('Sort Entries', style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onPrimary, fontWeight: FontWeight.w600),),
                  onTap: toggleSortSetting,
                ),
              ),
            ]
          )
        ],
      ),
    );
  }
}