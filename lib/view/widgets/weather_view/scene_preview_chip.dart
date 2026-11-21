import 'package:flutter/material.dart';
import 'package:weather/shared/constants/app_strings.dart';
import 'package:weather/shared/extensions/colors_extension.dart';
import 'package:weather/shared/extensions/space_extension.dart';
import 'package:weather/theme/color_palette.dart';
import 'package:weather/theme/text_style.dart';

class ScenePreviewChip extends StatelessWidget {
  const new({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppStrings.scenePreview,
      child: GestureDetector(
        behavior: .opaque,
        onTap: onTap,
        child: Container(
          padding: const .symmetric(horizontal: 9, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.fade(0.16),
            borderRadius: .circular(20),
            border: .all(color: Colors.white.fade(0.24)),
          ),
          child: Row(
            mainAxisSize: .min,
            children: [
              const Icon(
                Icons.palette_outlined,
                size: 14,
                color: Colors.white70,
              ),
              5.w,
              Text(
                AppStrings.scenes,
                style: CustomTextStyle.caption.copyWith(
                  color: ColorPalette.ink,
                  fontSize: 10.5,
                  fontWeight: .w600,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
