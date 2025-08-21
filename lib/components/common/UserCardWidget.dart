import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:survey_dogapp/components/common/custom_image_shimmer_effect.dart';
import 'package:survey_dogapp/utils/Common.dart';
import 'package:survey_dogapp/utils/Constant.dart';
import '../../generated/FontHelper.dart';
import '../theme.dart';
import 'package:marquee/marquee.dart';
import 'package:survey_dogapp/model/User.dart';

class UserCardWidget extends StatelessWidget {
  final User user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final void Function(int status) onUnRegested;

  const UserCardWidget({
    super.key,
    required this.user,
    required this.onEdit,
    required this.onDelete,
    required this.onUnRegested,
  });

  @override
  Widget build(BuildContext context) {
    final isRegistered = user.status == 1;
      return Card(
        color: AppColors.greyBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: user.profileLogo!.isNotEmpty
            ? Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey.shade400,
              width: 2,
            ),
          ),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: user.profileLogo!,
              width: 46,
              height: 46,
              fit: BoxFit.cover,
              placeholder: (context, url) => CommonShimmer(
                width: 46,
                height: 46,
              ),
              errorWidget: (context, url, error) => Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
                child: const Icon(Icons.error, color: Colors.red),
              ),
            ),
          ),
        )
            : Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey.shade400,
              width: 2,
            ),
          ),
          child: const CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, color: AppColors.white),
          ),
        ),
        title: SizedBox(
          height: 20,
          child: Marquee(
            text: user.name.toString(),
            style: FontHelper.bold(fontSize: 16, color: AppColors.primary),
            scrollAxis: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            blankSpace: 100.0,
            velocity: 40.0,
            pauseAfterRound: Duration(seconds: 1),
            accelerationDuration: Duration(seconds: 1),
            accelerationCurve: Curves.linear,
            decelerationDuration: Duration(milliseconds: 500),
            decelerationCurve: Curves.easeOut,
          ),
        ),
        subtitle: SizedBox(
          height: 16,
          child: Marquee(
            text: user.address.toString(),
            style: FontHelper.regular(fontSize: 12, color: Colors.black54),
            scrollAxis: Axis.horizontal,
            blankSpace: 100.0,
            velocity: 30.0,
            pauseAfterRound: Duration(seconds: 1),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primary),
              onPressed: onEdit,
            ),
            Visibility(
              visible: false,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: onDelete,
              ),
            ),
            if(CommonUtils.getUserRole() == UrlConstants.SUPER_ADMIN)
            IconButton(
              icon: Icon(
                isRegistered ? Icons.do_disturb_on : Icons.check_circle,
                color: isRegistered ? Colors.redAccent : Colors.green,
              ),
              onPressed: () {
                onUnRegested(isRegistered ? 0 : 1);
              },
            ),
          ],
        ),
      ),
    );
  }
}
