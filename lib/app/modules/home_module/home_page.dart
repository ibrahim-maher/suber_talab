import 'dart:js';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:super_talab/app/modules/home_module/home_controller.dart';
import 'package:place_picker/place_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../main.dart';
import '../../data/model/BannerModel.dart';
import '../../data/model/ProductModel.dart';
import '../../data/model/User.dart';
import '../../data/model/VendorCategoryModel.dart';
import '../../data/model/VendorModel.dart';
import '../../data/model/offer_model.dart';
import '../../data/repository/localDatabase.dart';
import '../../data/services/FirebaseHelper.dart';
import '../../data/services/helper.dart';
import '../../utils/constants.dart';
import '../AppGlobal.dart';

class homePage extends GetView<homeController> {
  final User? user;
  final String? vendorId;

  const homePage({
    Key? key,
    required this.user,
    this.vendorId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isLocationAvail = (MyAppState.selectedPosotion.latitude == 0 &&
        MyAppState.selectedPosotion.longitude == 0);
    return SafeArea(
      child: Scaffold(
          backgroundColor: isDarkMode(context)
              ? const Color(DARK_BG_COLOR)
              : const Color(0xffFFFFFF),
          body: isLocationAvail
              ? Center(
                  child: showEmptyState("notHaveLocation".tr, context,
                      description: "locationSearchingRestaurants".tr,
                      action: () async {
                    if (controller.islocationGet) {
                    } else {
                      LocationResult result = await Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) =>
                                  PlacePicker(GOOGLE_API_KEY)));

                      MyAppState.selectedPosotion = Position.fromMap({
                        'latitude': result.latLng!.latitude,
                        'longitude': result.latLng!.longitude
                      });
                      controller.currentLocation = result.formattedAddress;
                      controller.getData();
                    }
                  }, buttonTitle: 'Select'.tr),
                )
              : SingleChildScrollView(
                  child: Container(
                    color: isDarkMode(context)
                        ? const Color(DARK_COLOR)
                        : const Color(0xffFFFFFF),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            color: Colors.black,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                            child: Text(
                                                controller.currentLocation
                                                    .toString(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: "Poppinsr".tr,
                                                    fontSize: 14)),
                                          ),
                                          ElevatedButton(
                                              onPressed: () {
                                                // Navigator.of(context)
                                                //     .push(PageRouteBuilder(
                                                //   pageBuilder: (context,
                                                //       animation,
                                                //       secondaryAnimation) {
                                                //     //   const CurrentAddressChangeScreen(),
                                                //   },
                                                //   transitionsBuilder: (context,
                                                //       animation,
                                                //       secondaryAnimation,
                                                //       child) {
                                                //     return child;
                                                //   },
                                                // ))
                                                //     .then((value) {
                                                //   if (value
                                                //       .toString()
                                                //       .isNotEmpty) {
                                                //     controller.currentLocation =
                                                //         value;
                                                //     controller.getData();
                                                //   }
                                                // });
                                              },
                                              child: Text("Change".tr),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                foregroundColor:
                                                    Color(COLOR_PRIMARY),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                elevation: 4.0,
                                              )),
                                        ],
                                      )),
                                  Container(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10, bottom: 5),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                                "Find your Restaurant".tr,
                                                style: TextStyle(
                                                    fontSize: 22,
                                                    color: Colors.white,
                                                    fontFamily:
                                                        "Poppinssb".tr)),
                                          ),
                                          DropdownButton(
                                            // Not necessary for Option 1
                                            value: controller
                                                .selctedOrderTypeValue,
                                            isDense: true,
                                            dropdownColor: Colors.black,
                                            onChanged: (newValue) async {
                                              int cartProd = 0;
                                              await CartDatabase().allCartProducts
                                                  .then((value) {
                                                cartProd = value.length;
                                              });

                                              if (cartProd > 0) {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) =>
                                                          ShowDialogToDismiss(
                                                    title: '',
                                                    content:
                                                        "wantChangeDeliveryOption"
                                                                .tr +
                                                            "Your cart will be empty"
                                                                .tr,
                                                    buttonText: 'CLOSE'.tr,
                                                    secondaryButtonText:
                                                        'OK'.tr,
                                                    action: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    CartDatabase().deleteAllProducts();

                                                      controller
                                                              .selctedOrderTypeValue =
                                                          newValue.toString();
                                                      controller
                                                          .saveFoodTypeValue();
                                                      controller.getData();
                                                    },
                                                  ),
                                                );
                                              } else {
                                                controller
                                                        .selctedOrderTypeValue =
                                                    newValue.toString();

                                                controller.saveFoodTypeValue();
                                                controller.getData();
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.keyboard_arrow_down,
                                              color: Colors.white,
                                            ),
                                            items: [
                                              'Delivery'.tr,
                                              'Takeaway'.tr,
                                            ].map((location) {
                                              return DropdownMenuItem(
                                                child: Text(location,
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                value: location,
                                              );
                                            }).toList(),
                                          )
                                        ],
                                      )),
                                ]),
                          ),
                        ),
                        // buildTitleRow(
                        //   titleValue: "Categories".tr,
                        //   onClick: () {
                        //     push(
                        //       context,
                        //       const CuisinesScreen(
                        //         isPageCallFromHomeScreen: true,
                        //       ),
                        //     );
                        //   },
                        // ),
                        Container(
                          color: isDarkMode(context)
                              ? const Color(DARK_COLOR)
                              : const Color(0xffFFFFFF),
                          child: FutureBuilder<List<VendorCategoryModel>>(
                              future: controller.fireStoreUtils.getCuisines(),
                              initialData: const [],
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator.adaptive(
                                      valueColor: AlwaysStoppedAnimation(
                                          Color(COLOR_PRIMARY)),
                                    ),
                                  );
                                }

                                if ((snapshot.hasData ||
                                    (snapshot.data?.isNotEmpty ?? false))) {
                                  return Container(
                                      padding: const EdgeInsets.only(left: 10),
                                      height: 150,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: snapshot.data!.length >= 15
                                            ? 15
                                            : snapshot.data!.length,
                                        itemBuilder: (context, index) {
                                          return buildCategoryItem(
                                              snapshot.data![index]);
                                        },
                                      ));
                                } else {
                                  return showEmptyState(
                                      'No Categories'.tr, context);
                                }
                              }),
                        ),
                        Visibility(
                          visible: controller.bannerTopHome.isNotEmpty,
                          child: Container(
                              color: isDarkMode(context)
                                  ? const Color(DARK_COLOR)
                                  : const Color(0xffFFFFFF),
                              padding: const EdgeInsets.only(bottom: 10),
                              child: controller.isHomeBannerLoading
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.23,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: PageView.builder(
                                            padEnds: false,
                                            itemCount: controller.bannerTopHome.length,
                                            scrollDirection: Axis.horizontal,
                                            controller: controller.pageController,
                                            itemBuilder: (context, index) =>
                                                buildBestDealPage(
                                                    controller.bannerTopHome[index])),
                                      ))),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            buildTitleRow(
                              titleValue: "Top Selling".tr,
                              onClick: () {
                                // push(
                                //   context,
                                //   const ViewAllPopularFoodNearByScreen(),
                                // );
                              },
                            ),
                            SizedBox(
                              height: 120,
                              child: controller.lstNearByFood.isEmpty
                                  ? showEmptyState(
                                      'No popular Item found'.tr, context)
                                  : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          controller.lstNearByFood.length >= 15
                                              ? 15
                                              : controller.lstNearByFood.length,
                                      itemBuilder: (context, index) {
                                        VendorModel? popularNearFoodVendorModel;
                                        if (controller.vendors.isNotEmpty) {
                                          for (int a = 0;
                                              a < controller.vendors.length;
                                              a++) {
                                            if (controller.vendors[a].id ==
                                                controller.lstNearByFood[index]
                                                    .vendorID) {
                                              popularNearFoodVendorModel =
                                                  controller.vendors[a];
                                            }
                                          }
                                        }
                                        return popularNearFoodVendorModel ==
                                                null
                                            ? Container()
                                            : popularFoodItem(
                                                context,
                                                controller.lstNearByFood[index],
                                                popularNearFoodVendorModel);
                                      }),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            buildTitleRow(
                              titleValue: "New Arrivals".tr,
                              onClick: () {
                                // push(
                                //   context,
                                //   const ViewAllNewArrivalRestaurantScreen(),
                                // );
                              },
                            ),
                            StreamBuilder<List<VendorModel>>(
                                stream: controller.fireStoreUtils
                                    .getVendorsForNewArrival()
                                    .asBroadcastStream(),
                                initialData: const [],
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator.adaptive(
                                        valueColor: AlwaysStoppedAnimation(
                                            Color(COLOR_PRIMARY)),
                                      ),
                                    );
                                  }

                                  if ((snapshot.hasData ||
                                      (snapshot.data?.isNotEmpty ?? false))) {
                                    controller.newArrivalLst = snapshot.data!;

                                    return controller.newArrivalLst.isEmpty
                                        ? showEmptyState(
                                            'No Vendors'.tr, context)
                                        : Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 260,
                                            margin: const EdgeInsets.fromLTRB(
                                                10, 0, 0, 10),
                                            child: ListView.builder(
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                physics:
                                                    const BouncingScrollPhysics(),
                                                itemCount: controller
                                                            .newArrivalLst
                                                            .length >=
                                                        15
                                                    ? 15
                                                    : controller
                                                        .newArrivalLst.length,
                                                itemBuilder: (context, index) =>
                                                    buildNewArrivalItem(controller
                                                        .newArrivalLst[index])));
                                  } else {
                                    return showEmptyState(
                                        'No Vendors'.tr, context);
                                  }
                                }),
                          ],
                        ),
                        buildTitleRow(
                          titleValue: "Offers For You".tr,
                          onClick: () {
                            // push(
                            //   context,
                            //   OffersScreen(
                            //     vendors: controller.vendors,
                            //   ),
                            // );
                          },
                        ),
                        controller.offerVendorList.isEmpty
                            ? showEmptyState('No Offers Found'.tr, context)
                            : Container(
                                width: MediaQuery.of(context).size.width,
                                height: 300,
                                margin: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount:
                                        controller.offerVendorList.length >= 15
                                            ? 15
                                            : controller.offerVendorList.length,
                                    itemBuilder: (context, index) {
                                      return buildCouponsForYouItem(
                                          context,
                                          controller.offerVendorList[index],
                                          controller.offersList[index]);
                                    })),
                        Visibility(
                          visible: controller.bannerMiddleHome.isNotEmpty,
                          child: Container(
                              color: isDarkMode(context)
                                  ? const Color(DARK_COLOR)
                                  : const Color(0xffFFFFFF),
                              padding: const EdgeInsets.only(bottom: 10),
                              child: controller.isHomeBannerMiddleLoading
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.23,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: PageView.builder(
                                            padEnds: false,
                                            itemCount: controller
                                                .bannerMiddleHome.length,
                                            scrollDirection: Axis.horizontal,
                                            controller: controller.pageController,
                                            itemBuilder: (context, index) =>
                                                buildBestDealPage(controller
                                                    .bannerMiddleHome[index])),
                                      ))),
                        ),
                        Column(
                          children: [
                            buildTitleRow(
                              titleValue: "Popular Restaurant".tr,
                              onClick: () {
                                // push(
                                //   context,
                                //   const ViewAllPopularRestaurantScreen(),
                                // );
                              },
                            ),
                            controller.popularRestaurantLst.isEmpty
                                ? showEmptyState(
                                    'No Popular restaurant'.tr, context)
                                : Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 260,
                                    margin:
                                        const EdgeInsets.fromLTRB(10, 0, 0, 10),
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        physics: const BouncingScrollPhysics(),
                                        itemCount: controller
                                                    .popularRestaurantLst
                                                    .length >=
                                                5
                                            ? 5
                                            : controller
                                                .popularRestaurantLst.length,
                                        itemBuilder: (context, index) =>
                                            buildPopularsItem(controller
                                                .popularRestaurantLst[index]))),
                          ],
                        ),
                        ListView.builder(
                          itemCount: controller.categoryWiseProductList.length,
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            return StreamBuilder<List<VendorModel>>(
                              stream: FireStoreUtils().getCategoryRestaurants(
                                  controller.categoryWiseProductList[index].id
                                      .toString()),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator.adaptive(
                                      valueColor: AlwaysStoppedAnimation(
                                          Color(COLOR_PRIMARY)),
                                    ),
                                  );
                                }
                                if ((snapshot.hasData ||
                                    (snapshot.data?.isNotEmpty ?? false))) {
                                  return snapshot.data!.isEmpty
                                      ? Container()
                                      : Column(
                                          children: [
                                            buildTitleRow(
                                              titleValue: controller
                                                  .categoryWiseProductList[
                                                      index]
                                                  .title
                                                  .toString(),
                                              onClick: () {
                                                // push(
                                                //   context,
                                                //   ViewAllCategoryProductScreen(
                                                //     vendorCategoryModel: controller
                                                //             .categoryWiseProductList[
                                                //         index],
                                                //   ),
                                                // );
                                              },
                                              isViewAll: false,
                                            ),
                                            SizedBox(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.28,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10),
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    physics:
                                                        const BouncingScrollPhysics(),
                                                    padding: EdgeInsets.zero,
                                                    itemCount:
                                                        snapshot.data!.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      VendorModel vendorModel =
                                                          snapshot.data![index];
                                                      double distanceInMeters =
                                                          Geolocator.distanceBetween(
                                                              vendorModel
                                                                  .latitude,
                                                              vendorModel
                                                                  .longitude,
                                                              MyAppState
                                                                  .selectedPosotion
                                                                  .latitude,
                                                              MyAppState
                                                                  .selectedPosotion
                                                                  .longitude);
                                                      double kilometer =
                                                          distanceInMeters /
                                                              1000;
                                                      double minutes = 1.2;
                                                      double value =
                                                          minutes * kilometer;
                                                      final int hour =
                                                          value ~/ 60;
                                                      final double minute =
                                                          value % 60;
                                                      return Container(
                                                        margin: const EdgeInsets
                                                                .symmetric(
                                                            horizontal: 10,
                                                            vertical: 8),
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            // push(
                                                            //   context,
                                                            //   NewVendorProductsScreen(
                                                            //       vendorModel:
                                                            //           vendorModel),
                                                            // );
                                                          },
                                                          child: SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.65,
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                                border: Border.all(
                                                                    color: isDarkMode(context)
                                                                        ? const Color(
                                                                            DarkContainerBorderColor)
                                                                        : Colors
                                                                            .grey
                                                                            .shade100,
                                                                    width: 1),
                                                                color: isDarkMode(context)
                                                                    ? const Color(
                                                                        DarkContainerColor)
                                                                    : Colors
                                                                        .white,
                                                                boxShadow: [
                                                                  isDarkMode(
                                                                          context)
                                                                      ? const BoxShadow()
                                                                      : BoxShadow(
                                                                          color: Colors
                                                                              .grey
                                                                              .withOpacity(0.5),
                                                                          blurRadius:
                                                                              5,
                                                                        ),
                                                                ],
                                                              ),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Expanded(
                                                                      child:
                                                                          Stack(
                                                                    children: [
                                                                      CachedNetworkImage(
                                                                        imageUrl:
                                                                            getImageVAlidUrl(vendorModel.photo),
                                                                        imageBuilder:
                                                                            (context, imageProvider) =>
                                                                                Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                                                                            image:
                                                                                DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                                          ),
                                                                        ),
                                                                        placeholder: (context,
                                                                                url) =>
                                                                            Center(
                                                                                child: CircularProgressIndicator.adaptive(
                                                                          valueColor:
                                                                              AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                                                                        )),
                                                                        errorWidget: (context,
                                                                                url,
                                                                                error) =>
                                                                            ClipRRect(
                                                                          borderRadius: BorderRadius.only(
                                                                              topLeft: Radius.circular(20),
                                                                              topRight: Radius.circular(20)),
                                                                          child:
                                                                              Image.network(
                                                                            AppGlobal.placeHolderImage!,
                                                                            width:
                                                                                MediaQuery.of(context).size.width * 0.75,
                                                                            fit:
                                                                                BoxFit.contain,
                                                                          ),
                                                                        ),
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                      Positioned(
                                                                        bottom:
                                                                            10,
                                                                        right:
                                                                            10,
                                                                        child:
                                                                            Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Colors.green,
                                                                            borderRadius:
                                                                                BorderRadius.circular(5),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                                            child:
                                                                                Row(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              children: [
                                                                                Text(vendorModel.reviewsCount != 0 ? (vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(1) : 0.toString(),
                                                                                    style: const TextStyle(
                                                                                      fontFamily: "Poppinsm",
                                                                                      letterSpacing: 0.5,
                                                                                      fontSize: 12,
                                                                                      color: Colors.white,
                                                                                    )),
                                                                                const SizedBox(width: 3),
                                                                                const Icon(
                                                                                  Icons.star,
                                                                                  size: 16,
                                                                                  color: Colors.white,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  )),
                                                                  const SizedBox(
                                                                      height:
                                                                          5),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            5),
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                            vendorModel
                                                                                .title,
                                                                            maxLines:
                                                                                1,
                                                                            style: TextStyle(
                                                                                fontFamily: "Poppinsm".tr,
                                                                                fontSize: 16,
                                                                                fontWeight: FontWeight.w700,
                                                                                letterSpacing: 0.2)),
                                                                        const SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            Icon(
                                                                              Icons.location_pin,
                                                                              color: Color(COLOR_PRIMARY),
                                                                              size: 20,
                                                                            ),
                                                                            SizedBox(width: 5),
                                                                            Expanded(
                                                                              child: Text(vendorModel.location, maxLines: 1, style: TextStyle(fontFamily: "Poppinsm".tr, color: isDarkMode(context) ? Colors.white : Colors.black.withOpacity(0.60))),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            Icon(
                                                                              Icons.timer_sharp,
                                                                              color: Color(COLOR_PRIMARY),
                                                                              size: 20,
                                                                            ),
                                                                            SizedBox(
                                                                              width: 5,
                                                                            ),
                                                                            Text(
                                                                              '${hour.toString().padLeft(2, "0")}h ${minute.toStringAsFixed(0).padLeft(2, "0")}m',
                                                                              style: TextStyle(fontFamily: "Poppinsm", letterSpacing: 0.5, color: isDarkMode(context) ? Colors.white : Colors.black.withOpacity(0.60)),
                                                                            ),
                                                                            SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            Icon(
                                                                              Icons.my_location_sharp,
                                                                              color: Color(COLOR_PRIMARY),
                                                                              size: 20,
                                                                            ),
                                                                            SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            Text(
                                                                              "${kilometer.toDouble().toStringAsFixed(decimal)} km",
                                                                              style: TextStyle(fontFamily: "Poppinsm".tr, letterSpacing: 0.5, color: isDarkMode(context) ? Colors.white : Colors.black.withOpacity(0.60)),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                )),
                                          ],
                                        );
                                } else {
                                  return Container();
                                }
                              },
                            );
                          },
                        ),
                        buildTitleRow(
                          titleValue: "All Restaurant".tr,
                          onClick: () {},
                          isViewAll: true,
                        ),
                        controller.vendors.isEmpty
                            ? showEmptyState('No Vendors'.tr, context)
                            : Container(
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: controller.vendors.length > 15
                                      ? 15
                                      : controller.vendors.length,
                                  itemBuilder: (context, index) {
                                    VendorModel vendorModel =
                                        controller.vendors[index];
                                    return buildAllRestaurantsData(vendorModel);
                                  },
                                ),
                              ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.06,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(COLOR_PRIMARY),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: BorderSide(
                                      color: Color(COLOR_PRIMARY),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'See All restaurant around you'.tr,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.white),
                                ),
                                onPressed: () {
                                  // push(
                                  //   context,
                                  //   const ViewAllRestaurant(),
                                  // );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
    );
  }

  Widget buildNewArrivalItem(VendorModel vendorModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () {},
        child: SizedBox(
          // margin: EdgeInsets.all(5),
          width: MediaQuery.of(context as BuildContext).size.width * 0.75,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: isDarkMode(context as BuildContext)
                      ? const Color(DarkContainerBorderColor)
                      : Colors.grey.shade100,
                  width: 1),
              color: isDarkMode(context as BuildContext)
                  ? const Color(DarkContainerColor)
                  : Colors.white,
              boxShadow: [
                isDarkMode(context as BuildContext)
                    ? const BoxShadow()
                    : BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        blurRadius: 5,
                      ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                    child: CachedNetworkImage(
                  imageUrl: getImageVAlidUrl(vendorModel.photo),
                  width:
                      MediaQuery.of(context as BuildContext).size.width * 0.75,
                  memCacheWidth:
                      (MediaQuery.of(context as BuildContext).size.width * 0.75)
                          .toInt(),
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  placeholder: (context, url) => Center(
                      child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                  )),
                  errorWidget: (context, url, error) => ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        AppGlobal.placeHolderImage!,
                        width: MediaQuery.of(context).size.width * 0.75,
                        fit: BoxFit.fitWidth,
                      )),
                  fit: BoxFit.cover,
                )),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.fromLTRB(15, 0, 5, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vendorModel.title,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: "Poppinsm".tr,
                            letterSpacing: 0.5,
                            color: isDarkMode(context as BuildContext)
                                ? Colors.white
                                : Colors.black,
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageIcon(
                            const AssetImage('assets/images/location3x.png'),
                            size: 15,
                            color: Color(COLOR_PRIMARY),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Text(vendorModel.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: "Poppinsm",
                                  letterSpacing: 0.5,
                                  color: isDarkMode(context as BuildContext)
                                      ? Colors.white60
                                      : const Color(0xff555353),
                                )),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 20,
                                  color: Color(COLOR_PRIMARY),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                    vendorModel.reviewsCount != 0
                                        ? '${(vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(1)}'
                                        : 0.toString(),
                                    style: TextStyle(
                                      fontFamily: "Poppinsm",
                                      letterSpacing: 0.5,
                                      color: isDarkMode(context as BuildContext)
                                          ? Colors.white
                                          : const Color(0xff000000),
                                    )),
                                const SizedBox(width: 3),
                                Text(
                                    '(${vendorModel.reviewsCount.toStringAsFixed(1)})',
                                    style: TextStyle(
                                      fontFamily: "Poppinsm",
                                      letterSpacing: 0.5,
                                      color: isDarkMode(context as BuildContext)
                                          ? Colors.white70
                                          : const Color(0xff666666),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPopularsItem(VendorModel vendorModel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () {
          // push(
          //   context as BuildContext,
          //    NewVendorProductsScreen(vendorModel: vendorModel),
          // );
        },
        child: Container(
          width: MediaQuery.of(context as BuildContext).size.width * 0.75,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isDarkMode(context as BuildContext)
                    ? const Color(DarkContainerBorderColor)
                    : Colors.grey.shade100,
                width: 1),
            color: isDarkMode(context as BuildContext)
                ? const Color(DarkContainerColor)
                : Colors.white,
            boxShadow: [
              isDarkMode(context as BuildContext)
                  ? const BoxShadow()
                  : BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 5,
                    ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                  child: CachedNetworkImage(
                imageUrl: getImageVAlidUrl(vendorModel.photo),
                memCacheWidth:
                    (MediaQuery.of(context as BuildContext).size.width * 0.75)
                        .toInt(),
                memCacheHeight: 250,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => Center(
                    child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                )),
                errorWidget: (context, url, error) => ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    AppGlobal.placeHolderImage!,
                    width: MediaQuery.of(context).size.width * 0.75,
                    fit: BoxFit.fitHeight,
                  ),
                ),
                fit: BoxFit.cover,
              )),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.fromLTRB(15, 0, 5, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vendorModel.title,
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: "Poppinsm",
                          letterSpacing: 0.5,
                          color: isDarkMode(context as BuildContext)
                              ? Colors.white
                              : const Color(0xff000000),
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ImageIcon(
                          const AssetImage('assets/images/location3x.png'),
                          size: 15,
                          color: Color(COLOR_PRIMARY),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Text(vendorModel.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: "Poppinsm",
                                letterSpacing: 0.5,
                                color: isDarkMode(context as BuildContext)
                                    ? Colors.white70
                                    : const Color(0xff555353),
                              )),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 20,
                                color: Color(COLOR_PRIMARY),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                  vendorModel.reviewsCount != 0
                                      ? '${(vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(1)}'
                                      : 0.toString(),
                                  style: TextStyle(
                                    fontFamily: "Poppinsm",
                                    letterSpacing: 0.5,
                                    color: isDarkMode(context as BuildContext)
                                        ? Colors.white70
                                        : const Color(0xff000000),
                                  )),
                              const SizedBox(width: 3),
                              Text(
                                  '(${vendorModel.reviewsCount.toStringAsFixed(1)})',
                                  style: TextStyle(
                                    fontFamily: "Poppinsm",
                                    letterSpacing: 0.5,
                                    color: isDarkMode(context as BuildContext)
                                        ? Colors.white60
                                        : const Color(0xff666666),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCouponsForYouItem(
      BuildContext context1, VendorModel? vendorModel, OfferModel offerModel) {
    return vendorModel == null
        ? Container()
        : Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: GestureDetector(
              onTap: () {
                if (vendorModel.id.toString() ==
                    offerModel.restaurantId.toString()) {
                  // push(
                  //context as BuildContext,
                  //  NewVendorProductsScreen(vendorModel: vendorModel),
                  // );
                } else {
                  showModalBottomSheet(
                    context: context as BuildContext,
                    isScrollControlled: true,
                    isDismissible: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    backgroundColor: Colors.transparent,
                    enableDrag: true,
                    builder: (context) => openCouponCode(context, offerModel),
                  );
                }
              },
              child: SizedBox(
                height: MediaQuery.of(context as BuildContext).size.height,
                child: Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: [
                    Container(
                      width: MediaQuery.of(context as BuildContext).size.width *
                          0.75,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.grey.shade100, width: 0.1),
                          boxShadow: [
                            isDarkMode(context as BuildContext)
                                ? const BoxShadow()
                                : BoxShadow(
                                    color: Colors.grey.shade400,
                                    blurRadius: 8.0,
                                    spreadRadius: 1.2,
                                    offset: const Offset(0.2, 0.2),
                                  ),
                          ],
                          color: isDarkMode(context as BuildContext)
                              ? const Color(DARK_BG_COLOR)
                              : Colors.white),
                      child: Column(
                        children: [
                          Expanded(
                              child: CachedNetworkImage(
                            imageUrl: getImageVAlidUrl(offerModel.imageOffer!),
                            memCacheWidth:
                                (MediaQuery.of(context as BuildContext)
                                            .size
                                            .width *
                                        0.75)
                                    .toInt(),
                            memCacheHeight:
                                MediaQuery.of(context as BuildContext)
                                    .size
                                    .width
                                    .toInt(),
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.cover),
                              ),
                            ),
                            placeholder: (context, url) => Center(
                                child: CircularProgressIndicator.adaptive(
                              valueColor:
                                  AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                            )),
                            errorWidget: (context, url, error) => ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                AppGlobal.placeHolderImage!,
                                width: MediaQuery.of(context).size.width * 0.75,
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                            fit: BoxFit.cover,
                          )),
                          const SizedBox(height: 8),
                          vendorModel.id.toString() ==
                                  offerModel.restaurantId.toString()
                              ? Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(15, 0, 5, 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(vendorModel.title.tr,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontFamily: "Poppinsm",
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                            color: isDarkMode(
                                                    context as BuildContext)
                                                ? Colors.white
                                                : const Color(0xff000000),
                                          )),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ImageIcon(
                                            const AssetImage(
                                                'assets/images/location3x.png'),
                                            size: 15,
                                            color: Color(COLOR_PRIMARY),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                            child: Text(vendorModel.location,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontFamily: "Poppinsm",
                                                  letterSpacing: 0.5,
                                                  color: isDarkMode(context
                                                          as BuildContext)
                                                      ? Colors.white70
                                                      : const Color(0xff555353),
                                                )),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8.0, bottom: 10),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  offerModel.offerCode!,
                                                  style: TextStyle(
                                                    fontFamily: "Poppinsm",
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(COLOR_PRIMARY),
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.star,
                                                      size: 20,
                                                      color:
                                                          Color(COLOR_PRIMARY),
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                        vendorModel.reviewsCount !=
                                                                0
                                                            ? '${(vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(1)}'
                                                            : 0.toString(),
                                                        style: TextStyle(
                                                          fontFamily:
                                                              "Poppinsm",
                                                          letterSpacing: 0.5,
                                                          color: isDarkMode(context
                                                                  as BuildContext)
                                                              ? Colors.white
                                                              : const Color(
                                                                  0xff000000),
                                                        )),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                        '(${vendorModel.reviewsCount.toStringAsFixed(1)})',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              "Poppinsm",
                                                          letterSpacing: 0.5,
                                                          color: isDarkMode(context
                                                                  as BuildContext)
                                                              ? Colors.white60
                                                              : const Color(
                                                                  0xff666666),
                                                        )),
                                                    const SizedBox(width: 5),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(15, 0, 5, 8),
                                  width: MediaQuery.of(context as BuildContext)
                                      .size
                                      .width,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Foodie's Offer".tr,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppinsm",
                                            letterSpacing: 0.5,
                                            color: Color(0xff000000),
                                          )),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text("Apply Offer".tr,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: "Poppinsm",
                                            letterSpacing: 0.5,
                                            color: Color(0xff555353),
                                          )),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          // FlutterClipboard.copy(
                                          //         offerModel.offerCode!)
                                          //     .then((value) => print('copied'));
                                        },
                                        child: Text(
                                          offerModel.offerCode!,
                                          style: TextStyle(
                                            fontFamily: "Poppinsm",
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(COLOR_PRIMARY),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                        ],
                      ),
                    ),
                    /* vendorModel.id.toString()==offerModel.restaurantId.toString()?*/
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        margin: const EdgeInsets.only(top: 150),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Container(
                                    width: 120,
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: const Image(
                                        image: AssetImage(
                                            "assets/images/offer_badge.png"))),
                                Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    "${offerModel.discountTypeOffer == "Fix Price" ? "$symbol" : ""}${offerModel.discountOffer}${offerModel.discountTypeOffer == "Percentage" ? "% Off" : " Off"} ",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.7),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ) /*:Container()*/
                  ],
                ),
              ),
            ),
          );
  }

  Widget buildBestDealPage(BannerModel categoriesModel) {
    return InkWell(
      onTap: () async {
        if (categoriesModel.redirect_type == "store") {
          VendorModel? vendorModel = await FireStoreUtils.getVendor(
              categoriesModel.redirect_id.toString());
          // push(
          //   context,
          //   NewVendorProductsScreen(vendorModel: vendorModel!),
          // );
        } else if (categoriesModel.redirect_type == "product") {
          ProductModel? productModel = await controller.fireStoreUtils
              .getProductByProductID(categoriesModel.redirect_id.toString());
          VendorModel? vendorModel =
              await FireStoreUtils.getVendor(productModel.vendorID);

          if (vendorModel != null) {
            // push(
            //   context,
            //   ProductDetailsScreen(
            //     vendorModel: vendorModel,
            //     productModel: productModel,
            //   ),
            // );
          }
        } else if (categoriesModel.redirect_type == "external_link") {
          final uri = Uri.parse(categoriesModel.redirect_id.toString());
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          } else {
            throw 'Could not launch ${categoriesModel.redirect_id.toString()}';
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          child: CachedNetworkImage(
            imageUrl: getImageVAlidUrl(categoriesModel.photo.toString()),
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              ),
            ),
            color: Colors.black.withOpacity(0.5),
            placeholder: (context, url) => Center(
                child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
            )),
            errorWidget: (context, url, error) => ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  AppGlobal.placeHolderImage!,
                  width: MediaQuery.of(context).size.width * 0.75,
                  fit: BoxFit.fitWidth,
                )),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget buildVendorItem(VendorModel vendorModel) {
    return GestureDetector(
      onTap: () {
        // push(
        //   context as BuildContext,
        //   NewVendorProductsScreen(vendorModel: vendorModel),
        // );
      },
      child: Container(
        height: 120,
        width: MediaQuery.of(context as BuildContext).size.width,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isDarkMode(context as BuildContext)
                  ? const Color(DarkContainerBorderColor)
                  : Colors.grey.shade100,
              width: 1),
          color: isDarkMode(context as BuildContext)
              ? const Color(DarkContainerColor)
              : Colors.white,
          boxShadow: [
            isDarkMode(context as BuildContext)
                ? const BoxShadow()
                : BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 5,
                  ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
                child: CachedNetworkImage(
              imageUrl: getImageVAlidUrl(vendorModel.photo),
              memCacheWidth:
                  (MediaQuery.of(context as BuildContext).size.width).toInt(),
              memCacheHeight: 120,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
              placeholder: (context, url) => Center(
                  child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
              )),
              errorWidget: (context, url, error) => ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(AppGlobal.placeHolderImage!)),
              fit: BoxFit.cover,
            )),
            const SizedBox(height: 8),
            ListTile(
              title: Text(vendorModel.title.tr,
                  maxLines: 1,
                  style: const TextStyle(
                    fontFamily: "Poppinsm",
                    letterSpacing: 0.5,
                    color: Color(0xff000000),
                  )),
              subtitle: Row(
                children: [
                  ImageIcon(
                    AssetImage('assets/images/location3x.png'),
                    size: 15,
                    color: Color(COLOR_PRIMARY),
                  ),
                  SizedBox(
                    width: 200,
                    child: Text(vendorModel.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: "Poppinsm",
                          letterSpacing: 0.5,
                          color: Color(0xff555353),
                        )),
                  ),
                ],
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 20,
                          color: Color(COLOR_PRIMARY),
                        ),
                        const SizedBox(width: 3),
                        Text(
                            vendorModel.reviewsCount != 0
                                ? '${(vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(1)}'
                                : 0.toString(),
                            style: const TextStyle(
                              fontFamily: "Poppinsm",
                              letterSpacing: 0.5,
                              color: Color(0xff000000),
                            )),
                        const SizedBox(width: 3),
                        Text('(${vendorModel.reviewsCount.toStringAsFixed(1)})',
                            style: const TextStyle(
                              fontFamily: "Poppinsm",
                              letterSpacing: 0.5,
                              color: Color(0xff666666),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildAllRestaurantsData(VendorModel vendorModel) {
    debugPrint(vendorModel.photo);
    List<OfferModel> tempList = [];
    List<double> discountAmountTempList = [];
    controller.offerList.forEach((element) {
      if (vendorModel.id == element.restaurantId && element.expireOfferDate!.toDate().isAfter(DateTime.now())) {
        tempList.add(element);
        discountAmountTempList.add(double.parse(element.discountOffer.toString()));
      }
    });
    return GestureDetector(
      // onTap: () => push(
      //   context as BuildContext,
      //   NewVendorProductsScreen(vendorModel: vendorModel),
      // ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDarkMode(context as BuildContext) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
            color: isDarkMode(context as BuildContext) ? const Color(DarkContainerColor) : Colors.white,
            boxShadow: [
              isDarkMode(context as BuildContext)
                  ? const BoxShadow()
                  : BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                blurRadius: 5,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      // child: Image.network(height: 80,
                      //     width: 80,vendorModel.photo),
                      child: CachedNetworkImage(
                        imageUrl: vendorModel.photo,
                        height: 80,
                        width: 80,
                        placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              AppGlobal.placeHolderImage!,
                            )),
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (discountAmountTempList.isNotEmpty)
                      Positioned(
                        bottom: -6,
                        left: -1,
                        child: Container(
                          decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/offer_badge.png'))),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              discountAmountTempList.reduce(min).toStringAsFixed(decimal) + "% off",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      )
                  ],
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              vendorModel.title,
                              style: TextStyle(
                                fontFamily: "Poppinsm",
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode(context as BuildContext) ? Colors.white : Colors.black,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_pin,
                            size: 20,
                            color: Color(COLOR_PRIMARY),
                          ),
                          Expanded(
                            child: Text(
                              vendorModel.location,
                              maxLines: 1,
                              style: TextStyle(
                                fontFamily: "Poppinsm",
                                color: isDarkMode(context as BuildContext) ? Colors.white70 : const Color(0xff9091A4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 20,
                            color: Color(COLOR_PRIMARY),
                          ),
                          const SizedBox(width: 3),
                          Text(vendorModel.reviewsCount != 0 ? '${(vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(1)}' : 0.toString(),
                              style: TextStyle(
                                fontFamily: "Poppinsm",
                                letterSpacing: 0.5,
                                color: isDarkMode(context as BuildContext) ? Colors.white : const Color(0xff000000),
                              )),
                          const SizedBox(width: 3),
                          Text('(${vendorModel.reviewsCount.toStringAsFixed(1)})',
                              style: TextStyle(
                                fontFamily: "Poppinsm",
                                letterSpacing: 0.5,
                                color: isDarkMode(context as BuildContext) ? Colors.white60 : const Color(0xff666666),
                              )),
                          const SizedBox(width: 5),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

}

openCouponCode(
  BuildContext context,
  OfferModel offerModel,
) {
  return Container(
    height: 250,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            margin: const EdgeInsets.only(
              left: 40,
              right: 40,
            ),
            padding: const EdgeInsets.only(
              left: 50,
              right: 50,
            ),
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/offer_code_bg.png"))),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                offerModel.offerCode!,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.9),
              ),
            )),
        GestureDetector(
          onTap: () {
            FlutterClipboard.copy(offerModel.offerCode!).then((value) {
              final SnackBar snackBar = SnackBar(
                content: Text(
                  "Coupon code copied".tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.black38,
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              return Navigator.pop(context);
            });
          },
          child: Container(
            margin: const EdgeInsets.only(top: 30, bottom: 30),
            child: Text(
              "COPY CODE".tr,
              style: TextStyle(
                  color: Color(COLOR_PRIMARY),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 30),
          child: RichText(
            text: TextSpan(
              text: "Use code".tr,
              style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey,
                  fontWeight: FontWeight.w700),
              children: <TextSpan>[
                TextSpan(
                  text: offerModel.offerCode,
                  style: TextStyle(
                      color: Color(COLOR_PRIMARY),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.1),
                ),
                TextSpan(
                  text: " & get".tr +
                      " ${offerModel.discountTypeOffer == "Fix Price" ? "$symbol" : ""}${offerModel.discountOffer}${offerModel.discountTypeOffer == "Percentage" ? "% off" : " off"} ",
                  style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

buildCategoryItem(VendorCategoryModel model) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: GestureDetector(
      onTap: () {
        // push(
        //   context,
        //   CategoryDetailsScreen(
        //     category: model,
        //     isDineIn: false,
        //   ),
        // );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CachedNetworkImage(
            imageUrl: getImageVAlidUrl(model.photo.toString()),
            imageBuilder: (context, imageProvider) => Container(
              height: MediaQuery.of(context).size.height * 0.11,
              width: MediaQuery.of(context).size.width * 0.23,
              decoration: BoxDecoration(
                  border: Border.all(width: 6, color: Color(COLOR_PRIMARY)),
                  borderRadius: BorderRadius.circular(30)),
              child: Container(
                // height: 80,width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: isDarkMode(context)
                          ? const Color(DarkContainerBorderColor)
                          : Colors.grey.shade100,
                      width: 1),
                  color: isDarkMode(context)
                      ? const Color(DarkContainerColor)
                      : Colors.white,
                  boxShadow: [
                    isDarkMode(context)
                        ? const BoxShadow()
                        : BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            blurRadius: 5,
                          ),
                  ],
                ),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      )),
                ),
              ),
            ),
            memCacheHeight:
                (MediaQuery.of(context as BuildContext).size.height * 0.11)
                    .toInt(),
            memCacheWidth:
                (MediaQuery.of(context as BuildContext).size.width * 0.23)
                    .toInt(),
            placeholder: (context, url) => ClipOval(
              child: Container(
                // padding: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(75 / 1)),
                  border: Border.all(
                    color: Color(COLOR_PRIMARY),
                    style: BorderStyle.solid,
                    width: 2.0,
                  ),
                ),
                width: 75,
                height: 75,
                child: Icon(
                  Icons.fastfood,
                  color: Color(COLOR_PRIMARY),
                ),
              ),
            ),
            errorWidget: (context, url, error) => ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  AppGlobal.placeHolderImage!,
                  fit: BoxFit.cover,
                )),
          ),
          // displayCircleImage(model.photo, 90, false),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Center(
                child: Text(model.title.toString().tr,
                    style: TextStyle(
                      color: isDarkMode(context as BuildContext)
                          ? Colors.white
                          : const Color(0xFF000000),
                      fontFamily: "Poppinsr",
                    ))),
          )
        ],
      ),
    ),
  );
}

class buildTitleRow extends StatelessWidget {
  final String titleValue;
  final Function? onClick;
  final bool? isViewAll;

  const buildTitleRow({
    Key? key,
    required this.titleValue,
    this.onClick,
    this.isViewAll = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDarkMode(context)
          ? const Color(DARK_COLOR)
          : const Color(0xffFFFFFF),
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(titleValue.tr,
                  style: TextStyle(
                      color: isDarkMode(context)
                          ? Colors.white
                          : const Color(0xFF000000),
                      fontFamily: "Poppinsm",
                      fontSize: 18)),
              isViewAll!
                  ? Container()
                  : GestureDetector(
                      onTap: () {
                        onClick!.call();
                      },
                      child: Text('View All'.tr,
                          style: TextStyle(
                              color: Color(COLOR_PRIMARY),
                              fontFamily: "Poppinsm")),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget popularFoodItem(
    BuildContext context,
    ProductModel product,
    VendorModel popularNearFoodVendorModel,
    ) {
  return GestureDetector(
    behavior: HitTestBehavior.translucent,
    onTap: () async {
      VendorModel? vendorModel = await FireStoreUtils.getVendor(product.vendorID);
      if (vendorModel != null) {
        // push(
        //   context,
        //   ProductDetailsScreen(
        //     vendorModel: vendorModel,
        //     productModel: product,
        //   ),
        // );
      }
    },
    // onTap: () => push(
    //   context,
    //   NewVendorProductsScreen(vendorModel: popularNearFoodVendorModel),
    // ),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
        color: isDarkMode(context) ? const Color(DarkContainerColor) : Colors.white,
        boxShadow: [
          isDarkMode(context)
              ? const BoxShadow()
              : BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 5,
          ),
        ],
      ),
      width: MediaQuery.of(context).size.width * 0.8,
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      padding: const EdgeInsets.all(5),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: getImageVAlidUrl(product.photo),
              height: 100,
              width: 100,
              memCacheHeight: 100,
              memCacheWidth: 100,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
              placeholder: (context, url) => Center(
                  child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                  )),
              errorWidget: (context, url, error) => ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    AppGlobal.placeHolderImage!,
                    fit: BoxFit.cover,
                  )),
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontFamily: "Poppinsm",
                    fontSize: 18,
                    color: isDarkMode(context) ? Colors.white : Colors.black,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  product.description,
                  maxLines: 1,
                  style: const TextStyle(
                    fontFamily: "Poppinsm",
                    fontSize: 16,
                    color: Color(0xff9091A4),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                /*Text(
                    product.disPrice=="" || product.disPrice =="0"?"\$${product.price}":"\$${product.disPrice}",
                    style: TextStyle(
                      fontFamily: "Poppinsm",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffE87034),
                    ),
                  ),*/
                product.disPrice == "" || product.disPrice == "0"
                    ? Text(
                  symbol + double.parse(product.price).toStringAsFixed(decimal),
                  style: TextStyle(fontSize: 16, fontFamily: "Poppinsm", letterSpacing: 0.5, color: Color(COLOR_PRIMARY)),
                )
                    : Row(
                  children: [
                    Text(
                      "$symbol${double.parse(product.disPrice.toString()).toStringAsFixed(decimal)}",
                      style: TextStyle(
                        fontFamily: "Poppinsm",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(COLOR_PRIMARY),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      '$symbol${double.parse(product.price).toStringAsFixed(decimal)}',
                      style: const TextStyle(fontFamily: "Poppinsm", fontWeight: FontWeight.bold, color: Colors.grey, decoration: TextDecoration.lineThrough),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    ),
  );
}
