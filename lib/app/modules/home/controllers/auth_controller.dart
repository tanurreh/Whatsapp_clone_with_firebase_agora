import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:whatsapp_clone/app/auth/screen/otp_screen.dart';
import 'package:whatsapp_clone/app/auth/screen/user_information_screen.dart';
import 'package:whatsapp_clone/app/landing/landing_screen.dart';
import 'package:whatsapp_clone/app/mobile_layout_screen.dart';
import 'package:whatsapp_clone/app/services.dart/database_services.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseServices db = DatabaseServices();
  late Rx<User?> _user;
  User get user => _user.value!;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(_auth.currentUser);
    _user.bindStream(_auth.authStateChanges());
    ever(_user, _setInitialScreen);
  }

  _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAll(() => LandingScreen());
    } else {
      Get.offAll(() => MobileLayoutScreen());
    }
  }

  // registeration of user
  void signInWithPhone(String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (e) {
          throw Exception(e.message);
        },
        codeSent: ((String verificationId, int? resendToken) async {
          Get.to(() => OTPScreen(verificationId: verificationId));
          // Navigator.pushNamed(
          //   context,
          //   OTPScreen.routeName,
          //   arguments: verificationId,
          // );
        }),
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Authntication Failed', e.toString());
    }
  }

  void verifyOTP(String verificationId, String userOTP) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userOTP,
      );
      await _auth.signInWithCredential(credential);
      Get.offAll(() => UserInformationScreen());
      // Navigator.pushNamedAndRemoveUntil(
      //   context,
      //   UserInformationScreen.routeName,
      //   (route) => false,
      // );
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Verification Failed', e.toString());
    }
  }

  signOut() async {
    await _auth.signOut();
  }
}
