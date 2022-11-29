import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../common/app_color.dart';
import '../../../common/app_images.dart';
import '../../../common/app_strings.dart';
import '../../../common/utils.dart';
import '../../../common/widget/app_text.dart';
import '../../../common/widget/audio_player_widget.dart';
import '../../../common/widget/custom_app_bar.dart';
import '../../../common/widget/custom_read_more_text.dart';
import '../../../common/widget/portrait_landscape_player_page.dart';
import '../../../network/modal/podcast/pod_cast_response.dart';
import '../../comment/page/pod_cast_comment_screen.dart';
import '../controller/pod_cast_detail_controller.dart';

class PodCastDetailScreen extends StatefulWidget {
  final PodcastElement item;

  const PodCastDetailScreen({required this.item, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PodCastDetailScreenState();
}

class _PodCastDetailScreenState extends State<PodCastDetailScreen> {
  final PodCastDetailController _controller =
      Get.isRegistered<PodCastDetailController>()
          ? Get.find<PodCastDetailController>()
          : Get.put(PodCastDetailController());

  @override
  void initState() {
    _controller.clearAllData();
    _controller.item = widget.item;
    _controller.timeSpentOnPodcast = widget.item.timeSpentOnPodcast;
    _controller.hasLiked.value = widget.item.hasLiked;
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Utils.isVideo(widget.item.podcastFile)) {
        _controller.podcastViewedByUserApi(podcastId: widget.item.podcastId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (!Utils.isVideo(widget.item.podcastFile)) {
          _controller.podcastViewedByUserApi(
              podcastId: widget.item.podcastId, isBackPressed: true);
        } else {
          Get.back(result: _controller.hasLiked.value);
        }

        return Future.value(false);
      },
      child: Scaffold(
        body: Stack(
          children: [
            Utils.isVideo(widget.item.podcastFile)
                ? Stack(
                    children: [
                      Positioned(
                        top: 0,
                        right: 0,
                        left: 0,
                        bottom: 0,
                        child: PortraitLandscapePlayerPage(
                          url: widget.item.podcastFile,
                          aspectRatio: 2 / 3,
                          commentIcon: IconButton(
                            onPressed: () => _commentButtonPressed(),
                            icon: SvgPicture.asset(
                              AppImages.iconChat,
                              color: AppColor.white,
                              height: 24.r,
                            ),
                          ),
                          likeIcon: IconButton(
                            onPressed: () {
                              _controller.likeOrDislikePodcastApi(
                                  podcastId: widget.item.podcastId);
                            },
                            icon: Obx(() {
                              return SvgPicture.asset(
                                AppImages.iconHeart,
                                color: _controller.hasLiked.value
                                    ? AppColor.red
                                    : AppColor.white,
                                height: 24.r,
                              );
                            }),
                          ),
                          descriptionWidget: CustomReadMoreText(
                              value: widget.item.podcastDescription),
                          titleWidget: CustomReadMoreText(
                              value: widget.item.podcastTitle),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomAppBar(
                            title: '',
                            isVideoComponent: true,
                            onBackPressed: () {
                              SystemChrome.setPreferredOrientations([
                                DeviceOrientation.portraitUp,
                              ]);
                              Get.back();
                            },
                          ),
                        ],
                      ),
                    ],
                  )
                : Column(
                    children: [
                      CustomAppBar(
                        title: AppStrings.podCast,
                        isBackButtonVisible: true,
                        isNotificationButtonVisible: true,
                        isIconsTitle: true,
                        onBackPressed: () {
                          if (!Utils.isVideo(widget.item.podcastFile)) {
                            _controller.podcastViewedByUserApi(
                                podcastId: widget.item.podcastId,
                                isBackPressed: true);
                          } else {
                            Get.back(result: _controller.hasLiked.value);
                          }
                        },
                      ),
                      Container(
                        height: Get.height * 0.4,
                        width: Get.width,
                        margin: EdgeInsets.only(
                            top: 16.h, left: 30.w, right: 30.w, bottom: 16.h),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: AppColor.grey,
                            borderRadius: BorderRadius.circular(5.r)),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: CachedNetworkImage(
                          imageUrl: widget.item.thumbnailPath,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          placeholder: (context, url) => Container(
                            alignment: Alignment.center,
                            child: SizedBox(
                                height: 36.r,
                                width: 36.r,
                                child: const CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.mic,
                              size: 90.0.r,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(
                          left: 30.w,
                          right: 30.w,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              text: widget.item.podcastTitle,
                              textSize: 18.sp,
                              color: AppColor.black,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              lineHeight: 1.3,
                              fontWeight: FontWeight.w600,
                            ),
                            SizedBox(
                              height: 5.w,
                            ),
                            AppText(
                              text: widget.item.podcastDescription,
                              textSize: 15.sp,
                              color: AppColor.black,
                              maxLines: 1,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              lineHeight: 1.3,
                              fontWeight: FontWeight.w500,
                            ),
                            // SizedBox(
                            //   height: 5.w,
                            // ),
                            // AppText(
                            //   text: 'widget.item.podCastCategory',
                            //   textSize: 15.sp,
                            //   color: AppColor.black,
                            //   maxLines: 1,
                            //   textAlign: TextAlign.start,
                            //   overflow: TextOverflow.ellipsis,
                            //   lineHeight: 1.3,
                            //   fontWeight: FontWeight.w500,
                            // ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Obx(() {
                          debugPrint(
                              'IS_LIKED:--  ${_controller.hasLiked.value}  ${widget.item.podcastFile}');
                          return AudioPlayerWidget(
                            // url: 'https://luan.xyz/files/audio/nasa_on_a_mission.mp3',
                            url: widget.item.podcastFile,
                            onLikePressed: () {
                              _controller.likeOrDislikePodcastApi(
                                  podcastId: widget.item.podcastId);
                            },
                            onCommentPressed: () => _commentButtonPressed(),
                            hasLiked: _controller.hasLiked.value,
                            showLoader: (value) {
                              _controller.showLoader.value = value;
                            },
                            positionOnPressed: (value) {
                              debugPrint(
                                  'POSITION_ON_PRESSED:------ -- -- -- -- -  $value');
                              _controller.timeSpentOnPodcast = value;
                            },
                            currentDuration: widget.item.timeSpentOnPodcast,
                            // url: widget.item.podcastFile,
                          );
                        }),
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
      ),
    );
  }

  _commentButtonPressed() {
    showModalBottomSheet<void>(
      // context and builder are
      // required properties in this widget
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.w), topRight: Radius.circular(30.w))),

      builder: (BuildContext context) {
        // we set up a container inside which
        // we create center column and display text

        // Returning SizedBox instead of a Container
        return Container(
          height: Get.height * 0.8,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50.w),
                  topRight: Radius.circular(50.w))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close)),
                ],
              ),
              Expanded(
                child: PodCastCommentScreen(
                  title: widget.item.podcastTitle,
                  hasLike: _controller.hasLiked.value,
                  itemMediaUrl: widget.item.thumbnailPath,
                  podCastId: widget.item.podcastId,
                ),
              ),
            ],
          ),
        );
      },
    );

    // Get.to(() => PodCastCommentScreen(
    //       title: widget.item.podcastTitle,
    //       hasLike: _controller.hasLiked.value,
    //       itemMediaUrl: widget.item.thumbnailPath,
    //       podCastId: widget.item.podcastId,
    //     ))?.then((value) {
    //   if (value != null && value is bool) {
    //     _controller.hasLiked.value = value;
    //   }
    // });
  }
}
