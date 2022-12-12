import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:random_dog_image_downloader/add_ons/colors.dart';
import 'package:random_dog_image_downloader/obj/dog_obj.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;

  String imageURL = "";

  // "https://dog.ceo/api/breeds/image/random"
  var requestURL = Uri.http("dog.ceo", "/api/breeds/image/random");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Dog Image Downloader'),
        backgroundColor: AppColor.thirdColor,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              getImage();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                    color: AppColor.thirdColor,
                    borderRadius: BorderRadius.circular(15)),
                child: const Center(
                    child: Text(
                  'Get Random Dog Image',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                )),
              ),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              downloadImage();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                    color: AppColor.thirdColor,
                    borderRadius: BorderRadius.circular(15)),
                child: const Center(
                  child: Text(
                    'Download Image',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              clipBehavior: Clip.antiAlias,
              height: 300,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  // color: Colors.blueGrey,
                  borderRadius: BorderRadius.circular(20)),
              child: isLoading == true
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColor.primaryColor,
                        // strokeWidth: 10,
                      ),
                    )
                  : imageURL.isEmpty
                      ? const Center(
                          child: Text('no image'),
                        )
                      : Image.network(
                          imageURL,
                          fit: BoxFit.cover,
                        ),
            ),
          ),
        ],
      ),
    );
  }

  void getImage() async {
    setState(() {
      isLoading = true;
    });

    var response = await http.get(requestURL);
    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      print(data['message']);

      DogObj dob = DogObj.fromMap(data);
      setState(() {
        imageURL = dob.message;
      });

      setState(() {
        setState(() {
          isLoading = false;
        });
      });
    } else {
      print('error');
    }
  }

  void downloadImage() async {
    var status = await Permission.storage.status;
    if (status == PermissionStatus.granted) {
      var response = await Dio()
          .get(imageURL, options: Options(responseType: ResponseType.bytes));
      final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.data),
          quality: 60,
          name: "hello");
      print(result);
    } else {
      await Permission.storage.request();
    }
  }
}
