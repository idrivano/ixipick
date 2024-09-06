import 'package:flutter/material.dart';

import 'styles/app_style.dart';


class DefaultButton extends StatelessWidget {
  const DefaultButton({super.key, this.text, this.onPressed, this.height, this.width, this.color, this.isLoading = false});
  final String? text;
  final Color? color;
  final bool isLoading;
  final double? height, width;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: height,
        width: width,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(
            horizontal: AppStyle.defaultPadding,
            vertical: AppStyle.defaultPadding/2
        ),
        decoration: BoxDecoration(
          color: color ?? AppStyle.primaryColor,
          borderRadius: BorderRadius.circular(AppStyle.defaultBorderRadious),
        ),
        child: isLoading ? const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ) : Text(
          text!,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontSize: 16, color: AppStyle.whiteColor, fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}