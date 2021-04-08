import 'package:dio/dio.dart';
import 'package:flutsplash/helpers/keys.dart';
import 'package:flutsplash/models/photo.dart';
import 'package:flutsplash/screens/card_shimmer.dart';
import 'package:flutsplash/screens/image_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class LatestPhotos extends StatefulWidget {
  @override
  _LatestPhotosState createState() => _LatestPhotosState();
}

String accessKey = Keys.UNSPLASH_API_CLIENT_ID;
String apiURL =
    "https://api.unsplash.com/photos/?client_id=$accessKey&per_page=10";

class _LatestPhotosState extends State<LatestPhotos>
    with AutomaticKeepAliveClientMixin<LatestPhotos> {
  @override
  bool get wantKeepAlive => true;

  late List<Photo> imageList;
  Dio dio = new Dio();

  Future _getJsonData() async {
    var response = await dio.get(apiURL);
    List<dynamic> jsonData = response.data;
    imageList = jsonData.map((d) => Photo.fromJson(d)).toList();
    return imageList;
  }

  Future _getImageDetails(String imageID) async {
    var response = await dio
        .get("https://api.unsplash.com/photos/$imageID?client_id=$accessKey");
    Map<String, dynamic> imageData = response.data;
    return imageData;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: FutureBuilder(
        future: _getJsonData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                var imgID = snapshot.data![index].id;
                var imageCreator = snapshot.data![index].user.first_name;
                var creatorUsername = snapshot.data![index].user.username;
                var imageCreatedAt =
                    snapshot.data![index].created_at.toString().split(" ")[0];
                var imageLink = snapshot.data![index].urls.small;
                var creatorProfile = snapshot.data![index].user.links.html;
                var userImage = snapshot.data![index].user.profile_image.medium;
                return Padding(
                  padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Ink(
                      color: Color(0xFF2e2e2e),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            child: InkWell(
                              onTap: () async {
                                Map<String, dynamic> imgDetails =
                                    await _getImageDetails("$imgID");
                                Get.to(
                                  ImageInfoScreen(
                                    imageDetails: imgDetails,
                                  ),
                                  transition: Transition.cupertinoDialog,
                                );
                              },
                              child: Image.network(
                                "$imageLink",
                                height:
                                    MediaQuery.of(context).size.height * 0.25,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              launch("$creatorProfile");
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage("$userImage"),
                                radius: 25,
                                backgroundColor: Colors.transparent,
                              ),
                              title: Text(
                                "$imageCreator (@$creatorUsername)",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: Text(
                                  "Uploaded on $imageCreatedAt",
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return ShimmerCards();
          }
        },
      ),
    );
  }
}
