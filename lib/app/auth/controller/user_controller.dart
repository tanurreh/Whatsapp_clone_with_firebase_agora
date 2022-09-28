import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:whatsapp_clone/app/mobile_layout_screen.dart';
import 'package:whatsapp_clone/app/model/user_model.dart';
import 'package:whatsapp_clone/app/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/app/services.dart/database_services.dart';

class UserController extends GetxController {
  final AuthController _authController = Get.find();
  DatabaseServices db = DatabaseServices();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Rx<UserModel?> _user = UserModel(
          uid: '',
          profilePic: '',
          phoneNumber: '',
          name: '',
          groupId: [],
          isOnline: true)
      .obs;
  UserModel get currentUser => _user.value!;

  UserModel get user => _user.value!;
  Future<UserModel> getCurrentUser({required String uid}) async {
    return await db.userCollection.doc(uid).get().then((doc) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    });
  }

  @override
  Future<void> onReady() async {
    _user.value = await getCurrentUser(uid: _authController.user.uid);
    super.onReady();
  }

  Future<String> storeFileToFirebase(String uid, File file) async {
    UploadTask uploadTask =
        _storage.ref().child('profilePic/$uid').putFile(file);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> saveUserDataToFirebase({
    required String name,
    required File? profilePic,
  }) async {
    try {
      String uId = _authController.user.uid;
      if (name.isNotEmpty && profilePic != null) {
        String photoUrl =
            await storeFileToFirebase(uId, profilePic);
        UserModel user = UserModel(
          name: name,
          uid: uId,
          profilePic: photoUrl,
          isOnline: true,
          phoneNumber: _authController.user.phoneNumber!,
          groupId: [],
        );

        await db.userCollection.doc(uId).set(user.toMap());
         Get.offAll(() => MobileLayoutScreen());

      } else {
        Get.snackbar(
          'Empty Feilds',
          'Please Input All feilds',
        );
      }
    } on FirebaseException catch (e) {
      Get.snackbar(
        'Error Uploading data',
        e.toString(),
      );
    }
  }
}
