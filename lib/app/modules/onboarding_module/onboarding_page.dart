import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:super_talab/app/modules/onboarding_module/onboarding_controller.dart';
import '../../data/services/helper.dart';
import '../../utils/constants.dart';
import '../auth_module/auth_page.dart';

class onboardingPage extends GetView<onboardingController> {
  PageController pageController = PageController();

  onboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? Color(0XFF151618) : null,
      body: Stack(
        children: <Widget>[
          PageView.builder(
            itemBuilder: (context, index) => getPage(
                isDarkMode(context)
                    ? controller.darkimageList[index]
                    : controller.imageList[index],
                controller.titlesList[index],
                controller.subtitlesList[index],
                context,
                isDarkMode(context)
                    ? (index + 1) == controller.darkimageList.length
                    : (index + 1) == controller.imageList.length),
            controller: pageController,
            itemCount: isDarkMode(context)
                ? controller.darkimageList.length
                : controller.imageList.length,
            onPageChanged: (int index) {
              controller.currentIndex = index;
            },
          ),
          Visibility(
              visible:
                  controller.currentIndex + 1 == controller.imageList.length,
              child: Positioned(
                  right: 13,
                  bottom: 17,
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.94,
                      height: MediaQuery.of(context).size.height * 0.08,
                      padding: EdgeInsets.all(10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                            backgroundColor: Color(COLOR_PRIMARY)),
                        child: Text(
                          "GET STARTED".tr,
                          style: TextStyle(fontSize: 16),
                        ),
                        onPressed: () {
                          controller.setFinishedOnBoarding();
                           pushReplacement(context, AuthPage());
                        },
                      )))
              //     onPressed: () {
              //       setFinishedOnBoarding();
              //       pushReplacement(context, AuthScreen());
              //     },
              //     child: Text(
              //       'Continue',
              //       style: TextStyle(
              //           fontSize: 14.0,
              //           color: Colors.white,
              //           fontWeight: FontWeight.bold),
              //     ).tr,
              //   ),
              // )),
              ),
          Center(
              child: Padding(
            padding: const EdgeInsets.only(bottom: 130),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SmoothPageIndicator(
                controller: pageController,
                count: controller.imageList.length,
                effect: ScrollingDotsEffect(
                    spacing: 20,
                    activeDotColor: Color(COLOR_PRIMARY),
                    dotColor: Color(0XFFFBDBD1),
                    dotWidth: 7,
                    dotHeight: 7,
                    fixedCenter: false),
              ),
            ),
          )),
          Visibility(
            visible: controller.currentIndex + 1 == controller.imageList.length,
            child: Positioned(
                left: 15,
                top: 30,
                child: GestureDetector(
                    onTap: () {
                      pageController.previousPage(
                          duration: Duration(milliseconds: 100),
                          curve: Curves.bounceIn);
                    },
                    child: Icon(Icons.chevron_left,
                        size: 40,
                        color:
                            isDarkMode(context) ? Color(0xffFFFFFF) : null))),
          ),
          Visibility(
            visible: controller.currentIndex + 2 == controller.imageList.length,
            child: Positioned(
                left: 15,
                top: 30,
                child: GestureDetector(
                    onTap: () {
                      pageController.previousPage(
                          duration: Duration(milliseconds: 100),
                          curve: Curves.bounceIn);
                    },
                    child: Icon(
                      Icons.chevron_left,
                      size: 40,
                      color: isDarkMode(context) ? Color(0xffFFFFFF) : null,
                    ))),
          ),
          Visibility(
              visible:
                  controller.currentIndex + 1 != controller.imageList.length,
              child: Positioned(
                  right: 20,
                  top: 40,
                  child: InkWell(
                      onTap: () {
                        controller.setFinishedOnBoarding();
                        pushReplacement(context, AuthPage());
                      },
                      child: Text(
                        "SKIP".tr,
                        style: TextStyle(
                            fontSize: 18,
                            color: Color(COLOR_PRIMARY),
                            fontFamily: 'Poppinsm'),
                      )))),
          Visibility(
              visible:
                  controller.currentIndex + 1 != controller.imageList.length,
              child: Positioned(
                  right: 13,
                  bottom: 17,
                  child: InkWell(
                      onTap: () {},
                      child: Container(
                          width: MediaQuery.of(context).size.width * 0.94,
                          height: MediaQuery.of(context).size.height * 0.08,
                          padding: EdgeInsets.all(10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                                backgroundColor: Color(COLOR_PRIMARY)),
                            child: Text(
                              "NEXT".tr,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode(context)
                                      ? Color(0xffFFFFFF)
                                      : Color(0XFF333333)),
                            ),
                            onPressed: () {
                              pageController.nextPage(
                                  duration: Duration(milliseconds: 100),
                                  curve: Curves.bounceIn);
                            },
                          )))))
        ],
      ),
    );
  }

  Widget getPage(dynamic image, _titlesList, _subtitlesList,
      BuildContext context, bool isLastPage) {
    return Container(
        child: Column(
      //  crossAxisAlignment: CrossAxisAlignment.stretch,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // image is String ?
        Expanded(
            child: Container(
                //  height:  MediaQuery.of(context).size.height*0.55,
                width: MediaQuery.of(context).size.width * 1,
                decoration: BoxDecoration(
                    color: isDarkMode(context)
                        ? Color(0XFF242528)
                        : Color(0XFFFCEEE9),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.elliptical(400, 180),
                        bottomRight: Radius.elliptical(400, 180))),
                child: Container(
                  margin: EdgeInsets.only(right: 40, left: 40, top: 30),

                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(image), fit: BoxFit.contain)),

                  //  child:
                  //       Image.asset(
                  //           image,
                  //           width: 50.00,
                  //           fit: BoxFit.contain,
                  //         )
                ))),
        SizedBox(height: MediaQuery.of(context).size.height * 0.08),
        Text(
          _titlesList,
          textAlign: TextAlign.center,
          style: TextStyle(
              color:
                  isDarkMode(context) ? Color(0xffFFFFFF) : Color(0XFF333333),
              fontFamily: 'Poppinsm',
              fontSize: 20),
        ),

        Padding(
            padding: const EdgeInsets.only(right: 35, left: 35, top: 30),
            child: Text(
              _subtitlesList,
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    isDarkMode(context) ? Color(0xffFFFFFF) : Color(0XFF333333),
                fontFamily: 'Poppinsl',
                height: 2,
                letterSpacing: 1.2,
              ),
            )),
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        // : Icon(
        //     image as IconData,
        //     color: Colors.white,
        //     size: 150,
        //   ),
        // Text(
        //   title.toUpperCase(),
        //   style: TextStyle(
        //       color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
        //   textAlign: TextAlign.center,
        // ),
        // Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: Text(
        //     subTitle,
        //     style: TextStyle(color: Colors.white, fontSize: 14.0),
        //     textAlign: TextAlign.center,
        //   ),
        // ),
      ],
    ));
  }
}
