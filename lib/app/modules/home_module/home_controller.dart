import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as loc;

import 'package:permission_handler/permission_handler.dart';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../main.dart';
import '../../data/model/AddressModel.dart';
import '../../data/model/BannerModel.dart';
import '../../data/model/FavouriteModel.dart';
import '../../data/model/ProductModel.dart';
import '../../data/model/User.dart';
import '../../data/model/VendorCategoryModel.dart';
import '../../data/model/VendorModel.dart';
import '../../data/model/offer_model.dart';
import '../../data/services/FirebaseHelper.dart';
import '../../utils/constants.dart';

class homeController extends GetxController {
  final fireStoreUtils = FireStoreUtils();


  late Future<List<ProductModel>> productsFuture;
  final PageController pageController =
      PageController(viewportFraction: 0.8, keepPage: true);
  List<VendorModel> vendors = [];
  List<VendorModel> popularRestaurantLst = [];
  List<VendorModel> newArrivalLst = [];
  List<VendorModel> offerVendorList = [];
  List<OfferModel> offersList = [];
  Stream<List<VendorModel>>? lstAllRestaurant;
  List<ProductModel> lstNearByFood = [];
  bool islocationGet = false;

  //Stream<List<FavouriteModel>>? lstFavourites;
  late Future<List<FavouriteModel>> lstFavourites;
  List<String> lstFav = [];

  String? name = "";

  String? currentLocation = "";

  String? selctedOrderTypeValue = "Delivery".tr;

  _getLocation() async {
    islocationGet = true;
    if (MyAppState.selectedPosotion.longitude == 0 &&
        MyAppState.selectedPosotion.latitude == 0) {
      Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .whenComplete(() {});
      MyAppState.selectedPosotion = position;
      islocationGet = false;
    }

    List<Placemark> placemarks = await placemarkFromCoordinates(
            MyAppState.selectedPosotion.latitude,
            MyAppState.selectedPosotion.longitude)
        .catchError((error) {
      debugPrint("------>${error.toString()}");
    });
    Placemark placeMark = placemarks[0];

    currentLocation = placeMark.name.toString() +
        ", " +
        placeMark.subLocality.toString() +
        ", " +
        placeMark.locality.toString() +
        ", " +
        placeMark.administrativeArea.toString() +
        ", " +
        placeMark.postalCode.toString() +
        ", " +
        placeMark.country.toString();

    getData();

    if (MyAppState.currentUser != null) {
      if (MyAppState.currentUser!.location.longitude == 0.01 &&
          MyAppState.currentUser!.location.longitude == 0.01) {
        await FirebaseFirestore.instance
            .collection(USERS)
            .doc(MyAppState.currentUser!.userID)
            .update(
          {
            "location": UserLocation(
                    latitude: MyAppState.selectedPosotion.latitude,
                    longitude: MyAppState.selectedPosotion.longitude)
                .toJson()
          },
        );
      }
      MyAppState.currentUser!.location = UserLocation(
          latitude: MyAppState.selectedPosotion.latitude,
          longitude: MyAppState.selectedPosotion.longitude);
      AddressModel userAddress = AddressModel(
          name: MyAppState.currentUser!.fullName(),
          postalCode: placeMark.postalCode.toString(),
          line1: placeMark.name.toString() +
              ", " +
              placeMark.subLocality.toString(),
          line2: placeMark.administrativeArea.toString(),
          country: placeMark.country.toString(),
          city: placeMark.locality.toString(),
          location: MyAppState.currentUser!.location,
          email: MyAppState.currentUser!.email);
      MyAppState.currentUser!.shippingAddress = userAddress;
      await FireStoreUtils.updateCurrentUserAddress(userAddress);
    }
  }

  bool isLocationPermissionAllowed = false;
  loc.Location location = loc.Location();

  getLoc() async {
    bool _serviceEnabled;
    _serviceEnabled = await location.requestService();
    if (_serviceEnabled) {
      var status = await Permission.location.status;
      if (status.isDenied) {
        if (Platform.isIOS) {
          status = await Permission.locationWhenInUse.request();
        } else {
          status = await Permission.location.request();
        }

        if (status.isGranted) {
          _getLocation();
        } else if (status.isPermanentlyDenied) {
          if (Platform.isIOS) {
            openAppSettings();
          } else {
            await Permission.contacts.shouldShowRequestRationale;
            if (status.isPermanentlyDenied) {
              getTempLocation();
            }
          }
        }
      } else if (status.isRestricted) {
        getTempLocation();
      } else if (status.isPermanentlyDenied) {
        if (Platform.isIOS) {
          openAppSettings();
        } else {
          await Permission.contacts.shouldShowRequestRationale;
        }
      } else {
        _getLocation();
      }
      return;
    } else {
      getTempLocation();
    }
    //_currentPosition = await location.getLocation();
  }

  // Database db;

  @override
  void onInit() {
    super.onInit();
    getLoc();
    getBanner();
  }

  List<VendorCategoryModel> categoryWiseProductList = [];

  List<BannerModel> bannerTopHome = [];
  List<BannerModel> bannerMiddleHome = [];

  bool isHomeBannerLoading = true;
  bool isHomeBannerMiddleLoading = true;
  List<OfferModel> offerList = [];
  bool? storyEnable = false;

  getBanner() async {
    await fireStoreUtils.getHomeTopBanner().then((value) {
      bannerTopHome = value;
      isHomeBannerLoading = false;
      update();
    });

    await fireStoreUtils.getHomePageShowCategory().then((value) {
      categoryWiseProductList = value;
      update();
    });

    await fireStoreUtils.getHomeMiddleBanner().then((value) {
      bannerMiddleHome = value;
      isHomeBannerMiddleLoading = false;
    });
    await FireStoreUtils().getAllCoupons().then((value) {
      offerList = value;
      update();
    });

    await FirebaseFirestore.instance
        .collection(Setting)
        .doc('story')
        .get()
        .then((value) {
      storyEnable = value.data()!['isEnabled'];
      update();
    });
  }

  Future<void> getData() async {
    getFoodType();
    lstNearByFood.clear();
    fireStoreUtils.getRestaurantNearBy().whenComplete(() async {
      lstAllRestaurant = fireStoreUtils.getAllRestaurants().asBroadcastStream();

      if (MyAppState.currentUser != null) {
        lstFavourites = fireStoreUtils
            .getFavouriteRestaurant(MyAppState.currentUser!.userID);
        lstFavourites.then((event) {
          lstFav.clear();
          for (int a = 0; a < event.length; a++) {
            lstFav.add(event[a].restaurantId!);
          }
        });
        name = toBeginningOfSentenceCase(MyAppState.currentUser!.firstName);
      }

      lstAllRestaurant!.listen((event) {
        vendors.clear();
        vendors.addAll(event);
        allstoreList.clear();
        allstoreList.addAll(event);
        productsFuture.then((value) {
          for (int a = 0; a < event.length; a++) {
            for (int d = 0; d < (value.length > 20 ? 20 : value.length); d++) {
              if (event[a].id == value[d].vendorID &&
                  !lstNearByFood.contains(value[d])) {
                lstNearByFood.add(value[d]);
              }
            }
          }
        });

        popularRestaurantLst.addAll(event);
        List<VendorModel> temp5 = popularRestaurantLst
            .where((element) =>
                num.parse(
                    (element.reviewsSum / element.reviewsCount).toString()) ==
                5)
            .toList();
        List<VendorModel> temp5_ = popularRestaurantLst
            .where((element) =>
                num.parse((element.reviewsSum / element.reviewsCount)
                        .toString()) >
                    4 &&
                num.parse((element.reviewsSum / element.reviewsCount)
                        .toString()) <
                    5)
            .toList();
        List<VendorModel> temp4 = popularRestaurantLst
            .where((element) =>
                num.parse((element.reviewsSum / element.reviewsCount)
                        .toString()) >
                    3 &&
                num.parse((element.reviewsSum / element.reviewsCount)
                        .toString()) <
                    4)
            .toList();
        List<VendorModel> temp3 = popularRestaurantLst
            .where((element) =>
                num.parse((element.reviewsSum / element.reviewsCount)
                        .toString()) >
                    2 &&
                num.parse((element.reviewsSum / element.reviewsCount)
                        .toString()) <
                    3)
            .toList();
        List<VendorModel> temp2 = popularRestaurantLst
            .where((element) =>
                num.parse((element.reviewsSum / element.reviewsCount)
                        .toString()) >
                    1 &&
                num.parse((element.reviewsSum / element.reviewsCount)
                        .toString()) <
                    2)
            .toList();
        List<VendorModel> temp1 = popularRestaurantLst
            .where((element) =>
                num.parse(
                    (element.reviewsSum / element.reviewsCount).toString()) ==
                1)
            .toList();
        List<VendorModel> temp0 = popularRestaurantLst
            .where((element) =>
                num.parse(
                    (element.reviewsSum / element.reviewsCount).toString()) ==
                0)
            .toList();
        List<VendorModel> temp0_ = popularRestaurantLst
            .where((element) =>
                element.reviewsSum == 0 && element.reviewsCount == 0)
            .toList();

        popularRestaurantLst.clear();
        popularRestaurantLst.addAll(temp5);
        popularRestaurantLst.addAll(temp5_);
        popularRestaurantLst.addAll(temp4);
        popularRestaurantLst.addAll(temp3);
        popularRestaurantLst.addAll(temp2);
        popularRestaurantLst.addAll(temp1);
        popularRestaurantLst.addAll(temp0);
        popularRestaurantLst.addAll(temp0_);

        FireStoreUtils().getAllCoupons().then((value) {
          offersList.clear();
          offerVendorList.clear();
          value.forEach((element1) {
            event.forEach((element) {
              if (element1.restaurantId == element.id &&
                  element1.expireOfferDate!.toDate().isAfter(DateTime.now())) {
                offersList.add(element1);
                offerVendorList.add(element);
              }
            });
          });
        });
        update();
      });
      update();
    });
  }

  Future<void> getTempLocation() async {
    if (MyAppState.currentUser == null &&
        MyAppState.selectedPosotion.longitude != 0 &&
        MyAppState.selectedPosotion.latitude != 0) {
      List<Placemark> placemarks = await placemarkFromCoordinates(
              MyAppState.selectedPosotion.latitude,
              MyAppState.selectedPosotion.longitude)
          .catchError((error) {
        debugPrint("------>$error");
      });
      Placemark placeMark = placemarks[0];

      currentLocation = placeMark.name.toString() +
          ", " +
          placeMark.subLocality.toString() +
          ", " +
          placeMark.locality.toString() +
          ", " +
          placeMark.administrativeArea.toString() +
          ", " +
          placeMark.postalCode.toString() +
          ", " +
          placeMark.country.toString();
      update();

      getData();
    }
    if (MyAppState.currentUser != null) {
      if (MyAppState.currentUser!.location.latitude != 0 &&
          MyAppState.currentUser!.location.longitude != 0) {
        MyAppState.selectedPosotion = Position.fromMap({
          'latitude': MyAppState.currentUser!.location.latitude,
          'longitude': MyAppState.currentUser!.location.longitude
        });
        List<Placemark> placeMarks = await placemarkFromCoordinates(
                MyAppState.selectedPosotion.latitude,
                MyAppState.selectedPosotion.longitude)
            .catchError((error) {
          debugPrint("------>${error.toString()}");
        });
        Placemark placeMark = placeMarks[0];

        currentLocation = placeMark.name.toString() +
            ", " +
            placeMark.subLocality.toString() +
            ", " +
            placeMark.locality.toString() +
            ", " +
            placeMark.administrativeArea.toString() +
            ", " +
            placeMark.postalCode.toString() +
            ", " +
            placeMark.country.toString();
        update();

        getData();
      }
    }
  }

  getFoodType() async {
    SharedPreferences sp = await SharedPreferences.getInstance();


        selctedOrderTypeValue = sp.getString("foodType") == "" || sp.getString("foodType") == null ? "Delivery" : sp.getString("foodType");
        update();
    if (selctedOrderTypeValue == "Takeaway") {
      productsFuture = fireStoreUtils.getAllTakeAWayProducts();
    } else {
      productsFuture = fireStoreUtils.getAllDelevryProducts();
    }
  }

  Future<void> saveFoodTypeValue() async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    sp.setString('foodType', selctedOrderTypeValue!);
  }
}
