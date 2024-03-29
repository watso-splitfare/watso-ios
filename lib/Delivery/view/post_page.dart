import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:watso/Common/view/error_page.dart';
import 'package:watso/Common/widget/appbar.dart';
import 'package:watso/Delivery/models/post_model.dart';
import 'package:watso/Delivery/models/post_request_model.dart';

import '../../Auth/models/user_model.dart';
import '../../Auth/provider/user_provider.dart';
import '../../Common/theme/color.dart';
import '../../Common/theme/text.dart';
import '../../Common/widget/primary_button.dart';
import '../../Common/widget/secondary_button.dart';
import '../models/post_response_model.dart';
import '../provider/order_option_provider.dart';
import '../provider/post_list_provider.dart';
import '../repository/order_repository.dart';
import '../repository/post_repository.dart';
import '../widgets/common/information_tile.dart';
import '../widgets/common/store_detail_box.dart';
import '../widgets/post_page/modify_fee_dialog.dart';
import '../widgets/post_page/post_account_box.dart';
import '../widgets/post_page/post_comment_list.dart';
import 'menu_list_page.dart';
import 'option_edit_page.dart';
import 'post_order_detail_page.dart';
import 'post_order_me_detail_page.dart';

class PostPage extends ConsumerWidget {
  const PostPage({
    Key? key,
    required this.postId,
  }) : super(key: key);
  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<ResponsePost> postData = ref.watch(postDetailProvider(postId));
    User? user = ref.watch(userNotifierProvider);

    ref.watch(orderOptionNotifierProvider);
    if (user == null) {
      return ErrorPage(
        error: Exception("로그인이 필요합니다."),
      );
    }
    User nowUser = user;

    return postData.when(
        skipLoadingOnRefresh: false,
        data: (data) {
          log("data: ${data.toMap()}");
          log("orderOption: ${data.orderOption.toMap()}");
          bool isJoined = data.users.any((element) => element == user.id);
          bool isOwner = data.userId == nowUser.id;
          return Scaffold(
            appBar: customAppBar(context,
                title: data.orderOption.store.name,
                action: _postActionButton(context, ref,
                    isOwner: isOwner,
                    status: data.status,
                    data: data,
                    user: nowUser)),
            body: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(postDetailProvider(postId));
                // ref.invalidate(postCommentListProvider(postId));
              },
              child: CustomScrollView(
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: StoreDetailBox(
                          store: data.orderOption.store,
                        ),
                      )),
                  SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 16.0, left: 16.0),
                                      child: Text(
                                        "모집정보",
                                        style: WatsoText.title,
                                      ),
                                    ),
                                  ],
                                ),

                                InformationTile(
                                    icon: Icons.access_time_rounded,
                                    title: "주문시간",
                                    content: DateFormat(
                                        "M월 d일(E) HH시 mm분", 'ko')
                                        .format(data.orderOption.orderTime)),
                                //"3월 19일(일) 10시 30분"
                                InformationTile(
                                    icon: Icons.people,
                                    title: "현재 모인 인원",
                                    content:
                                    "${data.users.length} 명 (최소 ${data
                                        .orderOption.minMember}명 필요)"),
                                if (isOwner ||
                                    (isJoined &&
                                        data.status == PostStatus.delivered))
                                  InformationTile(
                                      icon: Icons.delivery_dining,
                                      title: "확정 배달비",
                                      widget: Row(
                                        children: [
                                          Text("${data.fee}원"),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          if (isOwner)
                                            InkWell(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 2),
                                                child: Text(
                                                  '수정',
                                                  style: TextStyle(
                                                    color: WatsoColor.primary,
                                                  ),
                                                ),
                                              ),
                                              onTap: () {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        ModifyFeeDialog(
                                                          postId: postId,
                                                          storeFee: data.fee,
                                                        ));
                                              },
                                            )
                                        ],
                                      )),
                                InformationTile(
                                    icon: Icons.waves,
                                    title: "게시글 상태",
                                    content: "${data.status.korName}"),
                                if (isOwner)
                                  InformationTile(
                                      icon: data.status == PostStatus.recruiting
                                          ? Icons.person
                                          : Icons.person_off,
                                      title: "모집 여부",
                                      widget: ToggleButtons(
                                        children: [
                                          Text("모집중"),
                                          Text("모집완료"),
                                        ],
                                        isSelected: [
                                          data.status == PostStatus.recruiting,
                                          data.status != PostStatus.recruiting
                                        ],
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(8)),
                                        selectedBorderColor: Colors.green,
                                        selectedColor: Colors.white,
                                        fillColor: Colors.green[300],
                                        color: Colors.grey,
                                        constraints: const BoxConstraints(
                                          minHeight: 30.0,
                                          minWidth: 80.0,
                                        ),
                                        onPressed: (index) async {
                                          if (!isOwner) return;
                                          if (data.status ==
                                              PostStatus.ordered ||
                                              data.status ==
                                                  PostStatus.delivered) {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: Text(
                                                        "주문/배달 완료된 글은 모집 상태를 변경할 수 없습니다."),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text("확인"))
                                                    ],
                                                  );
                                                });
                                            return;
                                          }
                                          try {
                                            if (index == 0) {
                                              await ref
                                                  .read(postRepositoryProvider)
                                                  .updatePostStatus(postId,
                                                  PostStatus.recruiting);
                                            } else {
                                              await ref
                                                  .read(postRepositoryProvider)
                                                  .updatePostStatus(
                                                  postId, PostStatus.closed);
                                            }
                                            ref.invalidate(
                                                postDetailProvider(postId));
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                content: Text("모집 상태 변경 실패")));
                                          }
                                        },
                                      )),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 2),
                                  child: SizedBox(
                                    height: 40,
                                    child: Row(
                                      children: [
                                        if (isJoined) ...{
                                          Expanded(
                                            child: secondaryButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            MyPostOrderDetailPage(
                                                              postId: postId,
                                                              store: data
                                                                  .orderOption
                                                                  .store,
                                                              orderNum:
                                                              data.users.length,
                                                              status: data
                                                                  .status,
                                                              fee: data.fee,
                                                            )));
                                              },
                                              text: "내 배달 상세",
                                            ),
                                          ),
                                          SizedBox(
                                            width: 12,
                                          ),
                                        },
                                        Expanded(
                                          child: secondaryButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            PostOrderDetailPage(
                                                              postId: postId,
                                                              fee: data.fee,
                                                            )));
                                              },
                                              text: "전체 배달"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isJoined && isOwner)
                                  _statusButton(data, ref, context),
                                if (!isJoined &&
                                    !isOwner &&
                                    data.status == PostStatus.recruiting)
                                  _joinButton(data, context, ref),
                                if (isJoined && !isOwner)
                                  _quitButton(
                                      context, ref, status: data.status),
                                SizedBox(
                                  height: 10,
                                )
                              ]),
                        ),
                      )),
                  AccountCard(
                    isOwner: isOwner,
                    status: data.status,
                    postId: data.id,
                  ),
                  CommentList(
                    postId: postId,
                    isOwner: isOwner,
                    isJoined: isJoined,
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20)),
                  ),
                ],
              ),
            ),
          );
        },
        error: (error, track) => ErrorPage(error: Exception(error)),
        loading: () =>
            Scaffold(body: Center(child: CircularProgressIndicator())));
  }

  List<Widget>? _postActionButton(context, WidgetRef ref,
      {required bool isOwner,
        required PostStatus status,
        required User user,
        required ResponsePost data}) {
    if (isOwner &&
        (status == PostStatus.recruiting || status == PostStatus.closed)) {
      return [
        IconButton(
          onPressed: () {
            if (status == PostStatus.closed) {
              showDialog(
                  context: context,
                  builder: (context) =>
                      AlertDialog(
                        title: Text('게시글 수정'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '모집이 완료된 게시글은 수정할 수 없습니다.',
                            ),
                            Text(
                              '수정을 하기 위해서는 팀원들과 상의 후 모집 상태를 변경해주세요.',
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('확인'))
                        ],
                      ));
              return;
            }
            OrderOption option = OrderOption.clone(data.orderOption);
            option.postId = data.id;
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        OptionEditPage(
                          postData: PostOrder(
                              orderOption: option, order: Order.init(user)),
                        )));
          },
          icon: Icon(
            Icons.edit,
            color: Colors.grey,
          ),
        ),
        IconButton(
          onPressed: () async {
            if (status == PostStatus.closed) {
              showDialog(
                  context: context,
                  builder: (context) =>
                      AlertDialog(
                        title: Text('게시글 삭제'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '모집이 완료된 게시글은 삭제할 수 없습니다.',
                            ),
                            Text(
                              '삭제를 하기 위해서는 팀원들과 상의 후 모집 상태를 변경해주세요.',
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('확인'))
                        ],
                      ));
              return;
            }
            showDialog(
                context: context,
                builder: (context) =>
                    AlertDialog(
                      title: Text('게시글 삭제'),
                      content: Text('게시글을 삭제하시겠습니까?'),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('취소')),
                        TextButton(
                            onPressed: () {
                              ref
                                  .read(postRepositoryProvider)
                                  .deletePost(postId)
                                  .then((value) {
                                ref.invalidate(myPostListProvider);
                                Navigator.popUntil(
                                    context, (route) => route.isFirst);
                              }).onError((error, stackTrace) {
                                Navigator.pop(context);

                                showDialog(
                                    context: context,
                                    builder: (context) =>
                                        AlertDialog(
                                          title: Text('에러'),
                                          content: Text(
                                              '게시글 삭제에 실패했습니다.\n${error
                                                  .toString()}'),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('확인')),
                                          ],
                                        ));
                              });
                            },
                            child: Text('삭제')),
                      ],
                    ));
          },
          icon: Icon(
            Icons.delete,
            color: Colors.red[200],
          ),
        ),
      ];
    }
    return null;
  }

  Widget _statusButton(ResponsePost data, WidgetRef ref, context) {
    if (data.status == PostStatus.delivered ||
        data.status == PostStatus.recruiting ||
        data.status == PostStatus.canceled) {
      return const SizedBox(
        height: 0,
      );
    }

    final int index = data.status.index;
    onButtonClick() {
      if (index >= PostStatus.values.length - 2) {
        return;
      }
      showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(
                title: Text('게시글 상태 변경'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${PostStatus.values[index + 1].korName}을 완료 하였나요?',
                        style: WatsoText.readable),
                    Text('처리 후에는 되돌릴 수 없습니다.'),
                    Text(
                      '${PostStatus.values[index + 1]
                          .korName} 이후에 확인을 눌러주시기 바랍니다.',
                    )
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('취소')),
                  TextButton(
                      onPressed: () {
                        ref
                            .read(postRepositoryProvider)
                            .updatePostStatus(
                            data.id, PostStatus.values[index + 1])
                            .then((value) {
                          //배달완료 누른
                          ref.invalidate(postDetailProvider(postId));
                          ref.invalidate(myPostListProvider);
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('게시글 상태 업데이트 완료')));
                          Navigator.pop(context, true);
                        }).onError((error, stackTrace) {
                          //alertDialog
                          showDialog(
                              context: context,
                              builder: (context) =>
                                  AlertDialog(
                                    title: Text('에러'),
                                    content: Text(
                                        '게시글 상태 업데이트에 실패했습니다.\n${error
                                            .toString()}'),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('확인')),
                                    ],
                                  ));
                        });
                      },
                      child: Text('확인')),
                ],
              )).then((value) {
        if (value == true && data.status == PostStatus.ordered) {
          showDialog(
              context: context,
              builder: (context) =>
                  ModifyFeeDialog(
                    postId: postId,
                    storeFee: data.fee,
                    isConfirm: true,
                  ));
        }
      });
    }

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        child: primaryButton(
          onPressed: onButtonClick,
          text: PostStatus.values[index + 1].korName,
        ));
  }

  Widget _joinButton(ResponsePost data, context, WidgetRef ref) {
    onButtonClick() {
      OrderOption option = OrderOption.clone(data.orderOption);
      option.postId = data.id;
      ref.read(orderOptionNotifierProvider.notifier).setOption(option);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                MenuListPage(
                  storeId: data.orderOption.store.id,
                  recuitNum: data.users.length,
                )),
      );
    }

    return (Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: primaryButton(onPressed: onButtonClick, text: '배달 참가'),
    ));
  }

  Widget _quitButton(context, ref, {required PostStatus status}) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        child: primaryButton(
            onPressed: () async {
              if (status == PostStatus.recruiting) {
                showDialog(
                    context: context,
                    builder: (context) =>
                        AlertDialog(
                          title: Text('게시글 탈퇴'),
                          content: Text('해당 주문 내역을 모두 취소하고 게시글을 탈퇴하시겠습니까?'),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('아니요')),
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: Text('네')),
                          ],
                        )).then((value) async {
                  if (value) {
                    try {
                      await ref.read(orderRepositoryProvider(postId))
                          .leavePost();
                      ref.invalidate(myPostListProvider);
                      Navigator.popUntil(context, (route) => route.isFirst);
                    } catch (e) {
                      showDialog(
                          context: context,
                          builder: (context) =>
                              AlertDialog(
                                title: Text('에러'),
                                content: Text('주문 취소에 실패했습니다.\n${e
                                    .toString()}'),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('확인')),
                                ],
                              ));
                    }
                  }
                });
                return;
              }
              final errorText = status == PostStatus.closed
                  ? '모집 마감 상태에서는 주문을 삭제할 수 없습니다. 게시글 대표에게 문의해보세요'
                  : '${status.korName}상테어서는 주문을 삭제할 수 없습니다.';
              showDialog(
                  context: context,
                  builder: (context) =>
                      AlertDialog(
                        title: Text('에러'),
                        content: Text(errorText),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('확인')),
                        ],
                      ));
            },
            text: '배달 탈퇴하기'));
  }
}
