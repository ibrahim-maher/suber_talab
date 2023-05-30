import 'dart:js';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../main.dart';
import '../../data/model/User.dart';
import '../../data/services/FirebaseHelper.dart';
import '../../data/services/helper.dart';
import '../../utils/constants.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart' as apple;



/**
 * GetX Template Generator - fb.com/htngu.99
 * */

class authController extends GetxController{
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  AutovalidateMode validate = AutovalidateMode.disabled;
  GlobalKey<FormState> loginFormKey = GlobalKey();

  File? image;

  final ImagePicker _imagePicker = ImagePicker();
  TextEditingController signUppasswordController = TextEditingController();
  GlobalKey<FormState> signUpFormKey = GlobalKey();
  String? firstName, lastName, email, mobile, password, confirmPassword,referralCode;
  AutovalidateMode signUpvalidate = AutovalidateMode.disabled;


  login() async {
    if (loginFormKey.currentState?.validate() ?? false) {
      loginFormKey.currentState!.save();
      await loginWithEmailAndPassword(emailController.text.trim(), passwordController.text.trim());
    } else {

        validate = AutovalidateMode.onUserInteraction;
        update();
    }
  }

  /// login with email and password with firebase
  /// @param email user email
  /// @param password user password
  loginWithEmailAndPassword(String email, String password) async {
    await showProgress(context as BuildContext, "loggingInPleaseWait".tr, false);
    dynamic result = await FireStoreUtils.loginWithEmailAndPassword(email.trim(), password.trim());
    await hideProgress();
    if (result != null && result is User && result.role == USER_ROLE_CUSTOMER) {
      result.fcmToken = await FireStoreUtils.firebaseMessaging.getToken() ?? '';
      await FireStoreUtils.updateCurrentUser(result).then((value) {
        MyAppState.currentUser = result;
        print(MyAppState.currentUser!.active.toString() + "===S");
        if (MyAppState.currentUser!.active == true) {
       //   pushAndRemoveUntil(context as BuildContext, ContainerScreen(user: result), false);
        } else {
          showAlertDialog(context as BuildContext, "accountDisabledContactAdmin".tr, "", true);
        }
      });
    } else if (result != null && result is String) {
      showAlertDialog(context as BuildContext, "NotAuthenticate".tr, result, true);
    } else {
      showAlertDialog(context as BuildContext, "NotAuthenticate".tr, 'Login failed, Please try again.'.tr, true);
    }
  }

  ///dispose text editing controllers to avoid memory leaks
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  loginWithFacebook() async {
    try {
      await showProgress(context as BuildContext, "loggingInPleaseWait".tr, false);
      dynamic result = await FireStoreUtils.loginWithFacebook();
      await hideProgress();
      if (result != null && result is User) {
        MyAppState.currentUser = result;

        if (MyAppState.currentUser!.active == true) {
         // pushAndRemoveUntil(context as BuildContext, ContainerScreen(user: result), false);
        } else {
          showAlertDialog(context as BuildContext, "accountDisabledContactAdmin".tr, "", true);
        }
      } /*else if (result != null && result is String) {
        showAlertDialog(context, 'Error'.tr(), result.tr(), true);
      } else {
        showAlertDialog(
            context, 'Error', "notLoginFacebook".tr(), true);
      }*/
    } catch (e, s) {
      await hideProgress();
      print('_LoginScreen.loginWithFacebook $e $s');
      showAlertDialog(context as BuildContext, 'error'.tr, "notLoginFacebook".tr, true);
    }
  }

  loginWithApple() async {
    try {
      await showProgress(context as BuildContext, "loggingInPleaseWait".tr, false);
      dynamic result = await FireStoreUtils.loginWithApple();
      await hideProgress();
      if (result != null && result is User) {
        MyAppState.currentUser = result;
        // pushAndRemoveUntil(context, ContainerScreen(user: result), false);
        if (MyAppState.currentUser!.active == true) {
       //   pushAndRemoveUntil(context as BuildContext, ContainerScreen(user: result), false);
        } else {
          showAlertDialog(context as BuildContext, "accountDisabledContactAdmin".tr, "", true);
        }
      } else if (result != null && result is String) {
        showAlertDialog(context as BuildContext, 'error'.tr, result.tr, true);
      } else {
        showAlertDialog(context as BuildContext, 'error', "notLoginApple".tr, true);
      }
    } catch (e, s) {
      await hideProgress();
      print('_LoginScreen.loginWithApple $e $s');
      showAlertDialog(context as BuildContext, 'error'.tr, "notLoginApple".tr, true);
    }
  }


  Future<void> retrieveLostData() async {
    final LostDataResponse? response = await _imagePicker.retrieveLostData();
    if (response == null) {
      return;
    }
    if (response.file != null) {

      image = File(response.file!.path);
    update();
    }
  }

  onCameraClick() {
    final action = CupertinoActionSheet(
      message: Text(
        'addProfilePicture'.tr,
        style: TextStyle(fontSize: 15.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('chooseFromGallery'.tr),
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context as BuildContext);
            XFile? Uploadedimage = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (Uploadedimage != null)

              image = File(Uploadedimage.path);
              update();
          },
        ),
        CupertinoActionSheetAction(
          child: Text('takeAPicture'.tr),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context as BuildContext);
            XFile? Uploadedimage = await _imagePicker.pickImage(source: ImageSource.camera);
            if (Uploadedimage != null) {
              image = File(Uploadedimage.path);
              update();
            }
          },
        )
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('cancel'.tr),
        onPressed: () {
          Navigator.pop(context as BuildContext);
        },
      ),
    );
    showCupertinoModalPopup(context: context as BuildContext, builder: (context) => action);
  }


  signUp() async {
    if (signUpFormKey.currentState?.validate() ?? false) {
      signUpFormKey.currentState!.save();
      if(referralCode.toString().isNotEmpty){
        FireStoreUtils.checkReferralCodeValidOrNot(referralCode.toString()).then((value) async {
          if(value == true){
            await signUpWithEmailAndPassword();
          }else{
            final snack = SnackBar(
              content: Text(
                'Referral Code is Invalid'.tr,
                style: TextStyle(color: Colors.white),
              ),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.black,
            );
            ScaffoldMessenger.of(context as BuildContext).showSnackBar(snack);
          }

        });
      }else{
        await signUpWithEmailAndPassword();
      }

    } else {

      signUpvalidate = AutovalidateMode.onUserInteraction;
        update();
    }
  }

  signUpWithEmailAndPassword() async {
    await showProgress(context as BuildContext, "creatingNewAccountPleaseWait".tr, false);
    dynamic result = await FireStoreUtils.firebaseSignUpWithEmailAndPassword(email!.trim(), password!.trim(), image , firstName!, lastName!, mobile!, context as BuildContext,referralCode.toString());
    await hideProgress();
    if (result != null && result is User) {
      MyAppState.currentUser = result;
     // pushAndRemoveUntil(context as BuildContext, ContainerScreen(user: result), false);
    } else if (result != null && result is String) {
      showAlertDialog(context as BuildContext, 'failed'.tr, result, true);
    } else {
      showAlertDialog(context as BuildContext, 'failed'.tr, "couldNotSignUp".tr, true);
    }
  }
}
