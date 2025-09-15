import 'package:flutter/material.dart';

import '../../../../../../_core/constants/assets.dart';

class FilterItemWidget extends StatefulWidget {
  final String title;
  final bool initialValue;
  final ValueChanged<bool> onChanged;

  const FilterItemWidget({
    super.key,
    required this.title,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<FilterItemWidget> createState() => _FilterItemWidgetState();
}

class _FilterItemWidgetState extends State<FilterItemWidget> {
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.initialValue;
  }

  // 부모 상태가 바뀌면 내부 _isChecked도 업데이트
  @override
  void didUpdateWidget(covariant FilterItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setState(() {
        _isChecked = widget.initialValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Checkbox(
          value: _isChecked,
          onChanged: (bool? value) {
            setState(() {
              _isChecked = value!;
            });
            widget.onChanged(value!);
          },
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: const VisualDensity(horizontal: -4),
        ),
        Text(
          widget.title,
          style: TextStyle(
            fontFamily: Assets.Fonts.cookieRun,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
