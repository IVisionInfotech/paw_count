import 'package:flutter/material.dart';
import 'package:survey_dogapp/components/theme.dart';
import '../../generated/assets.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: double.infinity,
      height: size.height * 0.3,
      child: Container(
        color: AppColors.primary,
        child: Image(
          image: AssetImage(Assets.imagesLogin),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
