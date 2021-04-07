import 'dart:io' as io;
import 'package:flutsplash/helpers/download_manager.dart';
import 'package:flutsplash/helpers/keys.dart';
import 'package:flutsplash/helpers/path_manager.dart';
import 'package:flutsplash/helpers/permission_manager.dart';
import 'package:flutsplash/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageInfoScreen extends StatefulWidget {
  final Map<String, dynamic> imageDetails;

  ImageInfoScreen({required Map<String, dynamic> imageDetails})
      : this.imageDetails = imageDetails;

  @override
  _ImageInfoScreenState createState() => _ImageInfoScreenState(imageDetails);
}

class _ImageInfoScreenState extends State<ImageInfoScreen> {
  _ImageInfoScreenState(Map<String, dynamic> imageDetails);

  @override
  Widget build(BuildContext context) {
    String accessKey = Keys.UNSPLASH_API_CLIENT_ID;
    String webURL = widget.imageDetails['links']['html'];
    String imgURL = widget.imageDetails['urls']['small'];
    String rawImgURL = widget.imageDetails['urls']['raw'];
    String imgID = widget.imageDetails['id'];
    String imgCreator = widget.imageDetails['user']['name'];
    String downloadEndpoint = widget.imageDetails['links']['download_location'];
    String creatorPic = widget.imageDetails['user']['profile_image']['medium'];

    Future checkImage(String id) async {
      String imagePath = await getPath("$id.jpeg");
      var result = await io.File(imagePath).exists();
      return result;
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                icon: Icon(Icons.open_in_browser),
                onPressed: () {
                  launch("$webURL");
                }),
            IconButton(
                icon: Icon(Icons.share),
                onPressed: () {
                  Share.share("Photo by $imgCreator on Unsplash\n$webURL");
                })
          ],
        ),
        body: Container(
          child: Column(
            children: [
              InkWell(
                child: ClipRRect(
                  child: Image.network(
                    imgURL,
                    height: MediaQuery.of(context).size.height * 0.30,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  ),
                ),
                onTap: () {},
              ),
              Wrap(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 15, 20, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage("$creatorPic"),
                                  radius: 20,
                                ),
                                Padding(padding: EdgeInsets.only(left: 10)),
                                Text(
                                  "$imgCreator",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.download_outlined,
                                    size: 25,
                                  ),
                                  onPressed: () async {
                                    var downloadPath =
                                        await getPath("$imgID.jpeg");
                                    await dio.get(
                                        "$downloadEndpoint&client_id=$accessKey");
                                    await downloadFile(
                                        rawImgURL, downloadPath, context);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.favorite_border,
                                    size: 25,
                                  ),
                                  onPressed: () {},
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                              child: Divider(
                                color: Colors.white38,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          label: Row(
            children: [
              Icon(Icons.wallpaper),
              Padding(
                child: Text(
                  "OPEN IN GALLERY",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                padding: EdgeInsets.only(left: 10),
              ),
            ],
          ),
          onPressed: () async {
            var imgExist = await checkImage("$imgID");
            var status = await requestPermissions();
            String filePath = await getPath("$imgID.jpeg");
            if (imgExist == true) {
              print(filePath);
              OpenFile.open("$filePath");
            } else if (status == true) {
              await dio.get("$downloadEndpoint&client_id=$accessKey");
              await downloadFile(rawImgURL, filePath, context);
            }
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
