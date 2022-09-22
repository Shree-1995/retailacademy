import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:retail_academy/app/knowledge/widget/item_quiz_master_detail.dart';

import '../../../common/app_color.dart';
import '../../../common/app_strings.dart';
import '../../../common/widget/alert_dialog_box.dart';
import '../../../common/widget/app_button.dart';
import '../../../common/widget/app_text.dart';
import '../../../common/widget/custom_app_bar.dart';
import '../../../network/modal/knowledge/consolidated_quiz_questions_response.dart';
import '../../../network/modal/knowledge/quiz_category_response.dart';
import '../controller/quiz_master_detail_controller.dart';

class QuizMasterDetailScreen extends StatefulWidget {
  final QuizCategoryElement item;
  final Color color;

  const QuizMasterDetailScreen(
      {required this.item, this.color = AppColor.pinkKnowledge, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _QuizMasterDetailScreenState();
}

class _QuizMasterDetailScreenState extends State<QuizMasterDetailScreen> {
  final QuizMasterDetailController _controller =
      Get.isRegistered<QuizMasterDetailController>()
          ? Get.find<QuizMasterDetailController>()
          : Get.put(QuizMasterDetailController());

  final CarouselController _carouselController = CarouselController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _controller.consolidatedQuizQuestionsApi(
        categoryId: widget.item.categoryId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar(
                title: widget.item.categoryName,
                isBackButtonVisible: true,
                isSearchButtonVisible: false,
                isNotificationButtonVisible: false,
              ),
              SizedBox(
                height: 20.h,
              ),
              Expanded(
                child: Obx(() {
                  debugPrint('length:---  ${_controller.dataList.length}');
                  if (_controller.dataList.isEmpty) {
                    return const SizedBox();
                  }
                  return CarouselSlider.builder(
                    carouselController: _carouselController,
                    itemCount: _controller.dataList.length,
                    itemBuilder: (BuildContext context, int baseItemIndex,
                        int pageViewIndex) {
                      QuizResponseElement item =
                          _controller.dataList[baseItemIndex];
                      return ItemQuizMasterDetail(
                        item: item,
                        index: baseItemIndex,
                        listSize: _controller.dataList.length,
                        onItemPressed: (itemIndex, value) {
                          if (item.questionType ==
                              'Multiple Choice - Single Answer') {
                            _controller.updateAnswers(
                                baseIndex: baseItemIndex,
                                itemIndex: -1,
                                value: value);
                          } else {
                            _controller.updateAnswers(
                                baseIndex: baseItemIndex,
                                itemIndex: itemIndex,
                                value: value);
                          }
                        },
                      );
                    },
                    options: CarouselOptions(
                      scrollPhysics: const NeverScrollableScrollPhysics(),
                      height: Get.height,
                      // aspectRatio: 16 / 9,
                      viewportFraction: 1,
                      initialPage: 0,
                      enableInfiniteScroll: false,
                      reverse: false,
                      autoPlay: false,
                      // autoPlayInterval: Duration(seconds: 3),
                      // autoPlayAnimationDuration: Duration(milliseconds: 800),
                      // autoPlayCurve: Curves.fastOutSlowIn,
                      // enlargeCenterPage: false,
                      onPageChanged: (index, callbackFunction) {},
                      scrollDirection: Axis.horizontal,
                    ),
                  );
                }),
              ),
              SizedBox(
                height: 20.h,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 10.w,
                  ),
                  Expanded(
                    child: AppButton(
                      txt: AppStrings.cancel,
                      onPressed: () => openCancelAttemptedDialogBox(),
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Expanded(
                    child: AppButton(
                      txt: AppStrings.submit,
                      onPressed: () {
                        _carouselController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.linear);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                ],
              ),
              SizedBox(
                height: 20.h,
              ),
            ],
          ),
          Obx(
            () => Positioned.fill(
              child: _controller.showLoader.value
                  ? Container(
                      color: Colors.transparent,
                      width: Get.width,
                      height: Get.height,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColor.loaderColor),
                        ),
                      ),
                    )
                  : Container(
                      width: 0,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  openCancelAttemptedDialogBox() {
    AlertDialogBox(
      showCrossIcon: true,
      context: context,
      barrierDismissible: true,
      padding: EdgeInsets.zero,
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 15.h,
              ),
              AppText(
                text: AppStrings.alert,
                textSize: 22.sp,
                color: AppColor.black,
                maxLines: 2,
                lineHeight: 1.3,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(
                height: 15.h,
              ),
              Divider(
                height: 1.sp,
                color: AppColor.grey,
              ),
              SizedBox(
                height: 20.h,
              ),
              AppText(
                text: AppStrings.doYouWantToCancel,
                textSize: 18.sp,
                color: AppColor.black,
                maxLines: 2,
                textAlign: TextAlign.center,
                lineHeight: 1.3,
                fontWeight: FontWeight.w400,
              ),
              SizedBox(
                height: 20.h,
              ),
              Divider(
                height: 1.sp,
                color: AppColor.grey,
              ),
              Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Get.back();
                          Get.back();
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                          child: AppText(
                            text: AppStrings.cancel,
                            textSize: 18.sp,
                            color: Colors.lightBlue,
                            maxLines: 2,
                            lineHeight: 1.3,
                            textAlign: TextAlign.center,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Get.back(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                          child: AppText(
                            text: AppStrings.ok,
                            textSize: 18.sp,
                            color: Colors.lightBlue,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            lineHeight: 1.3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    ).show();
  }
}
