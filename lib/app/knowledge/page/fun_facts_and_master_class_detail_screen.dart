import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../common/app_color.dart';
import '../../../common/app_images.dart';
import '../../../common/app_strings.dart';
import '../../../common/widget/app_text.dart';
import '../../../common/widget/custom_app_bar.dart';
import '../../../network/modal/knowledge/content_knowledge_response.dart';
import '../controller/fun_facts_and_master_class_detail_controller.dart';

class FunFactsAndMasterClassDetailScreen extends StatefulWidget {
  final FileElement item;
  final String filePath;

  const FunFactsAndMasterClassDetailScreen(
      {required this.item, required this.filePath, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _FunFactsAndMasterClassDetailScreenState();
}

class _FunFactsAndMasterClassDetailScreenState
    extends State<FunFactsAndMasterClassDetailScreen> {
  final FunFactsAndMasterClassDetailController _controller =
      Get.isRegistered<FunFactsAndMasterClassDetailController>()
          ? Get.find<FunFactsAndMasterClassDetailController>()
          : Get.put(FunFactsAndMasterClassDetailController());

  @override
  void initState() {
    _controller.clearValue();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const CustomAppBar(
                title: '',
                isBackButtonVisible: true,
                isSearchButtonVisible: false,
              ),
              Expanded(
                child: Obx(() {
                  return _controller.isError.value
                      ? Align(
                          alignment: Alignment.center,
                          child: AppText(
                            text: AppStrings.pdfError,
                            textSize: 20.sp,
                            lineHeight: 1.1,
                            fontWeight: FontWeight.w500,
                            maxLines: 5,
                            textAlign: TextAlign.center,
                          ),
                        )
                      : PDFView(
                          filePath: widget.filePath,
                          autoSpacing: true,
                          fitPolicy: FitPolicy.BOTH,
                          onError: (e) {
                            //Show some error message or UI
                            debugPrint('PDFVIEWonError $e');
                            _controller.updateError(true);
                          },
                          onRender: (_pages) {
                            debugPrint('_totalPages $_pages');
                          },
                          onViewCreated: (PDFViewController vc) {},
                          onPageChanged: (int? page, int? total) {
                            debugPrint("_currentPage = $page");
                          },
                          onPageError: (page, e) {
                            debugPrint('PDFVIEW  onPageError $e');
                          },
                        );
                }),
              ),
              SizedBox(height: 12.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {
                      _controller.likeOrDislikeContentKnowledgeSectionApi(
                          item: widget.item);
                    },
                    icon: SvgPicture.asset(
                      AppImages.iconHeart,
                      color: AppColor.black,
                      height: 24.r,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset(
                      AppImages.iconChat,
                      color: AppColor.black,
                      height: 24.r,
                    ),
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 5.h),
                child: AppText(
                  text: widget.item.fileName,
                  textSize: 20.sp,
                  lineHeight: 1.1,
                  fontWeight: FontWeight.w500,
                  maxLines: 5,
                  textAlign: TextAlign.start,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 5.h, 20.w, 20.h),
                child: AppText(
                  text: widget.item.modifiedDate,
                  textSize: 20.sp,
                  fontWeight: FontWeight.w500,
                  textAlign: TextAlign.start,
                ),
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
}
