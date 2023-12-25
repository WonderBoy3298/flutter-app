import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';


void main() {
runApp(MyApp());
}
class MyApp extends StatelessWidget {
@override
Widget build(BuildContext context) {
return MaterialApp(
home: HomePage(),
);
}
}
class HomePage extends StatefulWidget {
@override
_HomePageState createState() => _HomePageState();
}
class _HomePageState extends State< HomePage > {
final ImagePicker _picker = ImagePicker();
File? file;
var outputs;
var v = "";
// var dataList = [];
@override
void initState() {
super.initState();
loadmodel().then((value) {
setState(() {});
});
}

loadmodel() async {
await Tflite.loadModel(
model: "assets/best_modele_cnn.tflite",
labels: "assets/labels.txt",
);
}
Future<void> _pickImage() async {
try {
final XFile? image = await _picker.pickImage(source:
ImageSource.gallery);
 if (image == null) return;
setState(() {
file = File(image!.path);
});
detectimage(file!);
} catch (e) {
print('Error picking image: $e');
}
}
Future detectimage(File image) async {
  int startTime = new DateTime.now().millisecondsSinceEpoch;
  var predictions = await Tflite.runModelOnImage(
    path: image.path,
    numResults: 2, // Update to the correct number of results based on your model.
    threshold: 0.05,
    imageMean: 127.5,
    imageStd: 127.5,
  );
  setState(() {
    outputs = predictions;
  });
  print("//////////////////////////////////////////////////");
  print(predictions);
  print("//////////////////////////////////////////////////");
  int endTime = new DateTime.now().millisecondsSinceEpoch;
  print("Inference took ${endTime - startTime}ms");
}


@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
  title: Text('Image classification'),
),
body: Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: <Widget>[
file != null ?
Image.file(
file!,
height: 200,
width: 200,
) : Text('No image selected'),
SizedBox(height: 20),
outputs!= null ?
Text(outputs[0]['label'].toString().substring(2)) : Text(''),
],
),
),
 floatingActionButton: FloatingActionButton(
 onPressed: () {
 _pickImage();
 },
 child: Icon(Icons.add_a_photo),
 tooltip: 'Pick Image from Gallery'
),
);
}
}