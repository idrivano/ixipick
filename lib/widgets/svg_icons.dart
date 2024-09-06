import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';


class SvgIcons extends StatelessWidget {
  const SvgIcons({super.key, required this.src, this.color, this.size});
  final String src;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      src,
      width: size ?? 24,
      height: size ?? 24,
      color: color ?? Theme.of(context).iconTheme.color!.withOpacity(
          Theme.of(context).brightness == Brightness.dark ? 0.3 : 1),
    );
  }
}