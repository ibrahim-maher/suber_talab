import 'dart:io';
import 'dart:js';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart' as apple;

import '../../../main.dart';
import '../../data/model/User.dart';
import '../../data/services/FirebaseHelper.dart';
import '../../data/services/helper.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import 'reauth_user_screen.dart';



class profileController extends GetxController{
  late final User user ;

  GlobalKey<FormState> key = GlobalKey();
  AutovalidateMode validate = AutovalidateMode.disabled;


  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController mobile = TextEditingController();

  var imagePicker;

  TextEditingController _passwordController = TextEditingController();

  String? _verificationID;


  void onInit() {
    super.onInit();
    user =  MyAppState.currentUser!;
  }



  bool _isPhoneValid = false;
  String? _phoneNumber = "";

  showAlertDialogPage(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child:  Text("Cancel".tr),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child:  Text("continue".tr),
      onPressed: () {
        if (_isPhoneValid) {

            MyAppState.currentUser!.phoneNumber = _phoneNumber.toString();
            mobile.text = _phoneNumber.toString();
         update();
          Navigator.pop(context);
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title:  Text("Change Phone Number".tr),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), shape: BoxShape.rectangle, border: Border.all(color: Colors.grey.shade200)),
        child: InternationalPhoneNumberInput(
          onInputChanged: (value) {
            _phoneNumber = "${value.phoneNumber}";
          },
          onInputValidated: (bool value) => _isPhoneValid = value,
          ignoreBlank: true,
          autoValidateMode: AutovalidateMode.onUserInteraction,
          inputDecoration: InputDecoration(
            hintText: 'Phone Number'.tr,
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            isDense: true,
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
          ),
          inputBorder: const OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          initialValue: PhoneNumber(isoCode: 'US'),
          selectorConfig: const SelectorConfig(selectorType: PhoneInputSelectorType.DIALOG),
        ),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  validateAndSave() async {
    if (key.currentState?.validate() ?? false) {
      key.currentState!.save();
      AuthProviders? authProvider;
      List<auth.UserInfo> userInfoList = auth.FirebaseAuth.instance.currentUser?.providerData ?? [];
      await Future.forEach(userInfoList, (auth.UserInfo info) {
        if (info.providerId == 'password') {
          authProvider = AuthProviders.PASSWORD;
        } else if (info.providerId == 'phone') {
          authProvider = AuthProviders.PHONE;
        }
      });
      bool? result = false;
      if (authProvider == AuthProviders.PHONE && auth.FirebaseAuth.instance.currentUser!.phoneNumber != mobile) {
        result = await showDialog(
          context: context as BuildContext,
          builder: (context) => ReAuthUserScreen(
            provider: authProvider!,
            phoneNumber: mobile.text,
            deleteUser: false,
          ),
        );
        if (result != null && result) {
          await showProgress(context as BuildContext, 'Saving details...'.tr, false);
          await updateUser();
          await hideProgress();
        }
      } else if (authProvider == AuthProviders.PASSWORD && auth.FirebaseAuth.instance.currentUser!.email != email) {
        result = await showDialog(
          context: context as BuildContext ,
          builder: (context) => ReAuthUserScreen(
            provider: authProvider!,
            email: email.text,
            deleteUser: false,
          ),
        );
        if (result != null && result) {
          await showProgress(context as BuildContext, 'Saving details...'.tr, false);
          await updateUser();
          await hideProgress();
        }
      } else {
        showProgress(context as BuildContext, 'Saving details...'.tr, false);
        await updateUser();
        hideProgress();
      }
    } else {

        validate = AutovalidateMode.onUserInteraction;
      update();
    }
  }

  updateUser() async {
    user.firstName = firstName.text;
    user.lastName = lastName.text;
    user.email = email.text;
    user.phoneNumber = mobile.text;
    var updatedUser = await FireStoreUtils.updateCurrentUser(user);
    if (updatedUser != null) {
      MyAppState.currentUser = user;
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(SnackBar(
          content: Text(
            'detailsSavedSuccessfully'.tr,
            style: TextStyle(fontSize: 17),
          )));
    } else {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(SnackBar(
          content: Text(
            'couldNotSaveDetailsPleaseTryAgain',
            style: TextStyle(fontSize: 17),
          )));
    }
  }


  onCameraClick() {
    final action = CupertinoActionSheet(
      message: Text(
        "addProfilePicture".tr,
        style: TextStyle(fontSize: 15.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text("removePicture".tr),
          isDestructiveAction: true,
          onPressed: () async {
            Navigator.pop(context as BuildContext);
            showProgress(context as BuildContext, "removingPicture".tr, false);
            user.profilePictureURL = '';
            await FireStoreUtils.updateCurrentUser(user);
            MyAppState.currentUser = user;
            hideProgress();
            update();
          },
        ),
        CupertinoActionSheetAction(
          child: Text("chooseFromGallery".tr),
          onPressed: () async {
            Navigator.pop(context as BuildContext);
            XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              await _imagePicked(File(image.path));
            }
            update();
          },
        ),
        CupertinoActionSheetAction(
          child: Text("takeAPicture".tr),
          onPressed: () async {
            Navigator.pop(context as BuildContext);
            var _imagePicker;
            XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null) {
              await _imagePicked(File(image.path));
            }
            update();
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel'.tr),
        onPressed: () {
          Navigator.pop(context as BuildContext);
        },
      ),
    );
    showCupertinoModalPopup(context: context as BuildContext, builder: (context) => action);
  }

  Future<void> _imagePicked(File image) async {
    showProgress(context as BuildContext, "uploadingImage".tr, false);
    File compressedImage = (await FireStoreUtils.compressImage(image as File)) as File;
    final bytes = compressedImage.readAsBytesSync().lengthInBytes;
    final kb = bytes / 1024;
    final mb = kb / 1024;

    if (mb > 2) {
      hideProgress();
      showAlertDialogPage(context as BuildContext);
      return;
    }
    user.profilePictureURL = await FireStoreUtils.uploadUserImageToFireStorage(compressedImage as File, user.userID);
    await FireStoreUtils.updateCurrentUser(user);
    MyAppState.currentUser = user;
    hideProgress();
  }




}
