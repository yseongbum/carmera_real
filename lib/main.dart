import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false, // 배너 삭제
      theme: ThemeData.dark(),
      home: TakePictureScreen(
        // 적절한 카메라를 TakePictureScreen 위젯에게 전달합니다.
        camera: firstCamera, //camera 라는게플러그 인이야 camera랑
        //     camera: ^0.10.0+1
        // path_provider: ^2.0.11
        // path: ^1.8.1 이 세개가 플러그인으로 들어가야 camera앱을 실행할 수 있다
        //   camera: provides tools to work with the cameras on the device.
        //     path_provider: finds the correct paths to store images
        //     path: creates paths that work on any platform을 해주는 plugin들이다.
      ),
    ),
  );
}

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller; //CameraController가 사진 찍을 수 있게 해주는거
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    // 다음으로 controller를 초기화합니다. 초기화 메서드는 Future를 반환합니다.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    // 위젯의 생명주기 종료시 컨트롤러 역시 해제시켜줍니다.
    _controller.dispose();
    super.dispose();
  }

  // Widget buildCameraPreview(CameraController cameraController) {
  //   final double previewAspectRatio = 0.7;
  //   return AspectRatio(
  //     aspectRatio: 1 / previewAspectRatio,
  //     child: ClipRect(
  //       child: Transform.scale(
  //         scale: cameraController.value.aspectRatio / previewAspectRatio,
  //         child: Center(
  //           child: CameraPreview(cameraController),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, //backgrouncolor
      body: Column(
        //임의로 넣어본것 futurebuilder부터이긴한데
        children: [
          SizedBox(
            //text 위젯간 거리 조절
            height: 25,
          ),
          SizedBox(
            height: 128,
          ), //콤마를 넣어야 오류 안남
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // Future가 완료되면, 프리뷰를 보여줍니다.
                return Align(
                    //일단은 CameraPreviewl르aspectratio의 child로 하고 aspectratio를 align의 child로
                    alignment: Alignment.center,
                    child: AspectRatio(
                        aspectRatio: 1 / 1, child: CameraPreview(_controller)));
              } else {
                //
                // 그렇지 않다면, 진행 표식을 보여줍니다.
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),

          Container(
            width: 100.0, //container로 사이즈 조절
            height: 100.0,
            child: FloatingActionButton(
              elevation: 0.0,
              backgroundColor: Colors.lightGreen[50],
              //이전에는 column내부에 있었으니까 2차 제출이후로는 다시
              //본래의 코드랑 비교해서 봐야함.
              // onPressed 콜백을 제공합니다.
              onPressed: () async {
                // try / catch 블럭에서 사진을 촬영합니다. 만약 뭔가 잘못된다면 에러에
                // 대응할 수 있습니다.
                try {
                  // 카메라 초기화가 완료됐는지 확인합니다.
                  await _initializeControllerFuture;

                  // Attempt to take a picture and get the file `image`
                  // where it was saved.
                  final image = await _controller.takePicture();

                  if (!mounted) return;

                  // 사진을 촬영하면, 새로운 화면으로 넘어갑니다.
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DisplayPictureScreen(
                        // Pass the automatically generated path to
                        // the DisplayPictureScreen widget.
                        imagePath: image.path,
                      ),
                    ),
                  );
                } catch (e) {
                  // 만약 에러가 발생하면, 콘솔에 에러 로그를 남깁니다.
                  print(e);
                }
              },
              child: const Icon(Icons.camera, size: 70), //아이콘 사이즈
            ),
          ),
          Container(
            height: 110.6,
            child: BottomNavigationBar(
              showSelectedLabels: true,
              showUnselectedLabels: true,
              backgroundColor: Colors.lightGreen[50],
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.black54,
              selectedLabelStyle: TextStyle(
                height: 1.6,
                fontSize: 25,
                color: Colors.black,
              ),
              unselectedLabelStyle: TextStyle(
                height: 1.6,
                fontSize: 25,
                color: Colors.black54,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.search, size: 32),
                  label: "검색",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.camera_alt, size: 32),
                  label: "촬영",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings, size: 32),
                  label: "설정",
                ),
              ],
            ),
          )
        ], //children
      ),
    );
  }
}

// 사용자가 촬영한 사진을 보여주는 위젯
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      // 이미지는 디바이스에 파일로 저장됩니다. 이미지를 보여주기 위해 주어진
      // 경로로 `Image.file`을 생성하세요.
      body: Image.file(File(imagePath)),
    );
  }
}
