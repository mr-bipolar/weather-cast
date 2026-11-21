import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:weather/shared/constants/app_strings.dart';
import 'package:weather/shared/extensions/colors_extension.dart';
import 'package:weather/shared/extensions/space_extension.dart';
import 'package:weather/theme/text_style.dart';
import 'package:weather/view/scene_preview_screen.dart';
import 'package:weather/view/widgets/weather_view/scene_preview_chip.dart';

class Header extends StatelessWidget {
  final bool isConnected;
  final String? cityname;

  const new({super.key, required this.isConnected, this.cityname});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.place_outlined, size: 16, color: Colors.white70),
        5.w,
        Expanded(
          child: Text(
            cityname ?? AppStrings.locating,
            style: CustomTextStyle.location,
            maxLines: 1,
            overflow: .ellipsis,
          ),
        ),
        Semantics(
          label: isConnected ? AppStrings.online : AppStrings.offline,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: .circle,
              color: isConnected ? const Color(0xFF7CE0A3) : Colors.redAccent,
              boxShadow: [
                BoxShadow(
                  color:
                      (isConnected ? const Color(0xFF7CE0A3) : Colors.redAccent)
                          .fade(0.6),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
        // Debug-only scene
        if (kDebugMode) ...[
          10.w,
          ScenePreviewChip(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ScenePreviewScreen()),
            ),
          ),
        ],
      ],
    );
  }
}
