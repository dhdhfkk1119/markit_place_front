import 'package:flutter/material.dart';

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
          style: const TextStyle(
            fontFamily: "CookieRun",
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
