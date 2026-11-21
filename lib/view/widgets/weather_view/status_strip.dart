import 'package:flutter/material.dart';
import 'package:weather/shared/constants/app_strings.dart';
import 'package:weather/shared/extensions/space_extension.dart';
import 'package:weather/theme/color_palette.dart';
import 'package:weather/theme/text_style.dart';

class StatusStrip extends StatelessWidget {
  final bool isLoading;
  final String? loadError;
  final VoidCallback onRetry;
  const new({
    super.key,
    required this.isLoading,
    this.loadError,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Padding(
        padding: const .only(top: 10),
        child: Semantics(
          label: AppStrings.loadingStatus,
          child: const Row(
            children: [
              ExcludeSemantics(
                child: SizedBox(
                  width: 13,
                  height: 13,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ColorPalette.peach,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              ExcludeSemantics(
                child: Text(
                  AppStrings.loadingStatus,
                  style: CustomTextStyle.caption,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final error = loadError;
    if (error == null) return const SizedBox.shrink();

    return Padding(
      padding: const .only(top: 10),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 14,
            color: ColorPalette.peach,
            semanticLabel: error,
          ),
          8.w,
          Expanded(
            child: ExcludeSemantics(
              child: Text(
                error,
                style: CustomTextStyle.caption,
                maxLines: 2,
                overflow: .ellipsis,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              padding: const .symmetric(horizontal: 8),
              minimumSize: const Size(44, 44),
              tapTargetSize: .shrinkWrap,
            ),
            child: const Text(AppStrings.retry, style: CustomTextStyle.caption),
          ),
        ],
      ),
    );
  }
}
