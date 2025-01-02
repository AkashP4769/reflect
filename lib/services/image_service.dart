import 'dart:convert';
import 'dart:io';

import 'package:reflect/services/backend_services.dart';
import 'package:http/http.dart' as http;

class ImageService extends BackendServices{
  final List<String> possibleImages = [
      /*"https://cdn.pixabay.com/photo/2012/08/27/14/19/mountains-55067_640.png",
      "https://cdn.pixabay.com/photo/2024/02/23/21/25/landscape-8592826_1280.jpg",
      "https://cdn.pixabay.com/photo/2023/09/29/11/19/sunrays-8283601_1280.jpg",
      "https://cdn.pixabay.com/photo/2023/10/27/12/13/vineyard-8345243_960_720.jpg",
      "https://cdn.pixabay.com/photo/2023/10/26/08/24/autumn-8342089_960_720.jpg",

      "https://cdn.pixabay.com/photo/2022/12/13/18/00/autumn-7653897_960_720.jpg",
      "https://cdn.pixabay.com/photo/2016/05/25/18/02/maple-1415541_960_720.jpg",
      "https://cdn.pixabay.com/photo/2023/03/15/20/55/sunbeam-7855454_1280.jpg",
      "https://cdn.pixabay.com/photo/2020/06/23/19/23/fog-5333546_1280.jpg",
      "https://cdn.pixabay.com/photo/2020/12/06/17/58/trees-5809559_1280.jpg",
      
      "https://cdn.pixabay.com/photo/2023/10/24/08/24/sailboats-8337698_1280.jpg",*/

      "https://cdn.pixabay.com/photo/2024/09/19/22/21/ai-generated-9059933_1280.jpg",

      "https://img.freepik.com/free-photo/illustrated-watercolor-city_23-2151768998.jpg?t=st=1727633578~exp=1727637178~hmac=832056e2b0796154ecbbf6286f56bc84df55788d580704eb4f71e5c6d9f26e82&w=360",
      "https://img.freepik.com/free-photo/illustrated-watercolor-city_23-2151768901.jpg?t=st=1727633716~exp=1727637316~hmac=644795bb3ddf25f6331676148838424d51dec7b937627ef939704813bd5e9f0d&w=360",
      "https://img.freepik.com/free-photo/watercolor-city-illustrated_23-2151768980.jpg?t=st=1727633749~exp=1727637349~hmac=f394b698e1714f7ab8e0e61bf45887de2029b17f8c93b265f169769f74f5e541&w=1380",
      "https://img.freepik.com/free-photo/illustrated-watercolor-city_23-2151768902.jpg?t=st=1727633766~exp=1727637366~hmac=d5516bcf667fbb03619a863dd29c37d9bae17f759c6b198aa473812f096c2106&w=360",
      "https://img.freepik.com/free-photo/watercolor-moon-illustration_23-2151641645.jpg?t=st=1727633779~exp=1727637379~hmac=5e27e94c0d1bf13770bafa8a506423e0ae3c0dfd30833efa7198d6b98c15e602&w=360",
      "https://img.freepik.com/free-photo/illustrated-watercolor-city_23-2151768952.jpg?t=st=1727633799~exp=1727637399~hmac=369b593f289ab87e2d219a02170d9d19a811a0233916c25cf25374fbdbd3c79f&w=996",
      "https://img.freepik.com/free-photo/digital-art-fruit-illustration_23-2151773075.jpg?t=st=1727633827~exp=1727637427~hmac=69736165963480c8056db404cc01fcf6d0f7b90dd91d2f4048462cb7d2a20a0e&w=360",
      "https://img.freepik.com/free-photo/digital-art-style-river-nature-landscape_23-2151825792.jpg?t=st=1727633824~exp=1727637424~hmac=9414f70adc8deaa8fbfcb76720166319533a01c3aab771afb83d9d2da258f80c&w=900",
      "https://img.freepik.com/free-photo/watercolor-eyes-illustration_23-2151678436.jpg?t=st=1727633925~exp=1727637525~hmac=3652924254f93a463cb33eb07e8dcf48e4957ab99719105257e8ace56dbaa4f1&w=900",
      "https://img.freepik.com/free-photo/adorable-watercolor-cat-illustration_23-2151510050.jpg?t=st=1727633926~exp=1727637526~hmac=59372c4a1f4738df2e814af6f42041dc165a7ff4f5031a4b84f5b2d6eb0fe3c2&w=360",
      "https://img.freepik.com/free-photo/watercolor-eyes-illustration_23-2151678475.jpg?t=st=1727633928~exp=1727637528~hmac=a9ccbea04e0bcde8b4e65c7ad6b5a28b2988b85693523788a46b05ba2a64f497&w=900",
      
      "https://img.freepik.com/free-photo/watercolor-moon-illustration_23-2151641655.jpg?t=st=1727633974~exp=1727637574~hmac=3364c273654dec516e3b07af5d1dac0b4d20f93ecf3210dfc6df6b36bb6626ae&w=360",
      "https://img.freepik.com/free-photo/anime-moon-landscape_23-2151645879.jpg?t=st=1727633954~exp=1727637554~hmac=245eefddffc7aef46c63e78d2ad471ed9dfcfeff3b71003ca2ea945e57c09cd5&w=900",
      "https://img.freepik.com/free-photo/watercolor-moon-illustration_23-2151641604.jpg?t=st=1727633976~exp=1727637576~hmac=080db3c25fdc64da64931b0537d4ba6e6647c2282469b462e290ae08a50734f7&w=360",

      "https://img.freepik.com/free-photo/digital-art-style-illustration-mental-health-day-awareness_23-2151813358.jpg?t=st=1727633974~exp=1727637574~hmac=935f9dba2611770e351d1cc349e022942e5ec582cb59a1bd4458eba516e7ecd6&w=360",

      "https://img.freepik.com/free-photo/digital-art-flower-landscape-painting_23-2151596809.jpg?t=st=1727634053~exp=1727637653~hmac=f227d3ff675dea5dea557791242240d5b39dbc9b9d501d40a2976d7553c04048&w=900",
      "https://img.freepik.com/free-photo/farm-lifestyle-digital-art_23-2151551086.jpg?t=st=1727634052~exp=1727637652~hmac=4eb8e0b1b6afe0b6599eea0e3aca1bc504cb3493436a463d5a6e14709c92e6ca&w=360",
      "https://img.freepik.com/free-photo/digital-art-style-river-nature-landscape_23-2151825665.jpg?t=st=1727634051~exp=1727637651~hmac=ada1008e289adecbe01360d677e67675772c308bc90f29f68d295ebe4b134cbf&w=360",
      "https://img.freepik.com/free-photo/lifestyle-summer-scene-with-cartoon-design_23-2151068402.jpg?t=st=1727634050~exp=1727637650~hmac=21d920849060f5615131364db563f716198a64e141d7c8ae08ec61828c187b52&w=900",
  ];

  String getRandomImage(){
    return possibleImages[DateTime.now().microsecond % possibleImages.length];
  }

  Future<String?> uploadImage(File image) async {
    final uri = Uri.parse(baseUrl + '/images/upload'); // Replace with your Node.js endpoint
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', image.path, filename: image.path.split('/').last));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        print('Upload successful: $responseData');
        return jsonDecode(responseData)['imageUrl'];
      } else {
        print('Failed to upload: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }
}