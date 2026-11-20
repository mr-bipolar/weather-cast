import 'package:flutter/material.dart';
import 'package:weather/shared/constants/app_strings.dart';
import 'package:weather/shared/extensions/colors_extension.dart';
import 'package:weather/theme/color_palette.dart';
import 'package:weather/theme/text_style.dart';

class OfflineOverlay extends StatelessWidget {
  final bool isOffline;

  const new({super.key, required this.isOffline});

  @override
  Widget build(BuildContext context) {
    if (isOffline) return Center(child: Text("Connected : $isOffline"));
    return Positioned.fill(
      child: Semantics(
        liveRegion: true,
        label: AppStrings.internetError,
        child: DecoratedBox(
          decoration: BoxDecoration(color: Colors.black.fade(0.62)),
          child: Center(
            child: Container(
              margin: const .symmetric(horizontal: 28),
              padding: const .symmetric(horizontal: 24, vertical: 22),
              decoration: BoxDecoration(
                color: Colors.black.fade(0.32),
                borderRadius: .circular(20),
                border: .all(color: Colors.white.fade(0.14)),
              ),
              child: const Column(
                mainAxisSize: .min,
                children: [
                  Icon(
                    Icons.wifi_off_outlined,
                    color: ColorPalette.peach,
                    size: 44,
                  ),
                  SizedBox(height: 10),
                  Text(
                    AppStrings.internetError,
                    style: CustomTextStyle.location,
                    textAlign: .center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
