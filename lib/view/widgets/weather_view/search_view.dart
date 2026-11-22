import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather/shared/constants/app_strings.dart';
import 'package:weather/shared/extensions/colors_extension.dart';

class SearchView extends StatelessWidget {
  final TextEditingController textEditingController;
  final void Function(String)? onChanged;

  const new({
    super.key,
    required this.textEditingController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? SizedBox(
            height: 48,
            child: CupertinoSearchTextField(
              controller: textEditingController,
              placeholder: AppStrings.enterAcity,
              style: const TextStyle(color: Colors.white),
              placeholderStyle: const TextStyle(color: Colors.white70),
              itemSize: 22,
              backgroundColor: Colors.black.fade(0.22),
              onChanged: onChanged,
            ),
          )
        : TextField(
            controller: textEditingController,
            autofocus: false,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            cursorColor: Colors.white70,
            decoration: InputDecoration(
              filled: true,
              isDense: true,
              fillColor: Colors.black.fade(0.22),
              contentPadding: const .symmetric(vertical: 12, horizontal: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: const .all(Radius.circular(16)),
                borderSide: BorderSide(color: Colors.white.fade(0.24)),
              ),
              border: const OutlineInputBorder(
                borderRadius: .all(Radius.circular(16)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const .all(Radius.circular(16)),
                borderSide: BorderSide(color: Colors.white.fade(0.50)),
              ),
              suffixIcon: const Icon(
                Icons.search,
                color: Colors.white70,
                size: 20,
              ),
              hintText: AppStrings.enterCityName,
              hintStyle: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            // function call
            onChanged: onChanged,
          );
  }
}
