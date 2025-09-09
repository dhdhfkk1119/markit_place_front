import 'package:flutter/material.dart';

import 'community_filter_item.dart';

class CommunityFilterList extends StatefulWidget {
  const CommunityFilterList({super.key});

  @override
  State<CommunityFilterList> createState() => _CommunityFilterListState();
}

class _CommunityFilterListState extends State<CommunityFilterList> {
  final Map<String, bool> _placeFilters = {
    '맛집': false,
    '생활/편의': false,
    '미용': false,
    '병원/약구': false,
  };
  final Map<String, bool> _categoryFilters = {
    '반려동물': false,
    '운동': false,
    '취미': false,
    '고민/사연': false,
  };
  final Map<String, bool> _priceFilters = {
    '동네행사': false,
    '분실/실종': false,
    '동네사건사고': false,
    '공공소식': false,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ListView(children: [
        Row(
          children: [
            getTitle('필터'),
            TextButton(
              onPressed: () {
                // 초기화 로직 구현 (모든 필터 상태를 false로)
                setState(() {
                  _placeFilters.updateAll((key, value) => false);
                  _categoryFilters.updateAll((key, value) => false);
                  _priceFilters.updateAll((key, value) => false);
                });
              },
              child: const Text(
                "초기화",
                style: TextStyle(
                    fontFamily: "CookieRun",
                    color: Colors.grey,
                    decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
        Container(
          height: 2,
          color: Colors.grey,
        ),
        Row(
          children: [
            Icon(
              Icons.keyboard,
              color: Colors.deepPurpleAccent,
            ),
            SizedBox(
              width: 8,
            ),
            getTitle('동네 정보'),
          ],
        ),
        ..._placeFilters.keys.map((key) {
          return FilterItemWidget(
            title: key,
            initialValue: _placeFilters[key]!,
            onChanged: (bool newValue) {
              setState(() {
                _placeFilters[key] = newValue;
              });
            },
          );
        }).toList(),
        Container(
          height: 2,
          color: Colors.grey,
        ),
        Row(
          children: [
            Icon(
              Icons.night_shelter,
              color: Colors.deepPurpleAccent,
            ),
            SizedBox(
              width: 8,
            ),
            getTitle('이웃과 함께'),
          ],
        ),
        ..._categoryFilters.keys.map((key) {
          return FilterItemWidget(
            title: key,
            initialValue: _categoryFilters[key]!,
            onChanged: (bool newValue) {
              setState(() {
                _categoryFilters[key] = newValue;
              });
            },
          );
        }).toList(),
        Container(
          height: 2,
          color: Colors.grey,
        ),
        Row(
          children: [
            Icon(
              Icons.notifications_active_sharp,
              color: Colors.deepPurpleAccent,
            ),
            SizedBox(
              width: 8,
            ),
            getTitle('소식'),
          ],
        ),
        ..._priceFilters.keys.map((key) {
          return FilterItemWidget(
            title: key,
            initialValue: _priceFilters[key]!,
            onChanged: (bool newValue) {
              setState(() {
                _priceFilters[key] = newValue;
              });
            },
          );
        }).toList(),
        Container(
          height: 2,
          color: Colors.grey,
        ),
      ]),
    );
  }

  getTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontWeight: FontWeight.w700, fontSize: 16, fontFamily: "CookieRun"),
    );
  }
}
