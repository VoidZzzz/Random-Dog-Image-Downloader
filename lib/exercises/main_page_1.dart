import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:random_dog_image_downloader/add_ons/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'ob.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String imageURL = "";

  bool isLoading = false;

  final _scaffoldState = GlobalKey<ScaffoldState>();

  // https://dog.ceo/api/breeds/image/random

  var requestURL = Uri.http("dog.ceo", "/api/breeds/image/random");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        backgroundColor: AppColor.fifthColor,
        title: const Text("Dog Image Downloader"),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              getImage();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 70.0),
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: AppColor.fifthColor,
                    borderRadius: BorderRadius.circular(15)),
                child: const Center(
                    child: Text(
                  'Get random dog image',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
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
              padding: const EdgeInsets.symmetric(horizontal: 70.0),
              child: imageURL.isEmpty
                  ? null
                  : Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: AppColor.fifthColor,
                          borderRadius: BorderRadius.circular(15)),
                      child: const Center(
                          child: Text(
                        'Download image',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      )),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              clipBehavior: Clip.antiAlias,
              height: 400,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  // color: Colors.grey,
                  borderRadius: BorderRadius.circular(10)),
              child: isLoading == true
                  ? const Center(child: CircularProgressIndicator())
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

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      Map<String, dynamic> map = await json.decode(response.body);

      print(map['message']);

      Ob dob = Ob.fromMap(map);
      setState(() {
        isLoading = false;
        imageURL = dob.message;
      });
    } else {
      print('error');
      isLoading = false;
    }
  }

  void downloadImage() async {
    var response = await Dio()
        .get(imageURL, options: Options(responseType: ResponseType.bytes));
    await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        quality: 60,
        name: "Dogs image");
    print('saved successfully');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColor.fifthColor,
        content: Text('saved successfully'),
      ),
    );
  }
}
