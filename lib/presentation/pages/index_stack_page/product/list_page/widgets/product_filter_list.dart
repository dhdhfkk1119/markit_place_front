import 'package:flutter/material.dart';

import '../../../../../../_core/constants/assets.dart';
import 'filter_item.dart';

class ProductFilterList extends StatefulWidget {
  const ProductFilterList({super.key});

  @override
  State<ProductFilterList> createState() => _ProductFiterListState();
}

class _ProductFiterListState extends State<ProductFilterList> {
  final Map<String, bool> _filters = {
    '거래 가능한 상품 보기': false,
  };
  final Map<String, bool> _placeFilters = {
    '부전동': false,
    '전포동': false,
    '양정동': false,
    '개금동': false,
  };
  final Map<String, bool> _categoryFilters = {
    '취미/게임/음반': false,
    '도서': false,
    '디지털': false,
    '뷰티/미용': false,
  };
  final Map<String, bool> _priceFilters = {
    '나눔': false,
    '5,000원 이하': false,
    '10,000원 이하': false,
    '20,000원 이하': false,
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
                  _filters.updateAll((key, value) => false);
                  _placeFilters.updateAll((key, value) => false);
                  _categoryFilters.updateAll((key, value) => false);
                  _priceFilters.updateAll((key, value) => false);
                });
              },
              child: const Text(
                "초기화",
                style: TextStyle(
                    fontFamily: Fonts.cookieRun,
                    color: Colors.grey,
                    decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
        FilterItemWidget(
          title: _filters.keys.first,
          initialValue: _filters[_filters.keys.first]!,
          onChanged: (bool newValue) {
            setState(() {
              _filters[_filters.keys.first] = newValue;
            });
          },
        ),
        Container(
          height: 2,
          color: Colors.grey,
        ),
        getTitle('위치'),
        getTitle('부산 광역시 부산 진구'),
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
        getTitle('카테고리'),
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
        getTitle('가격'),
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
          fontWeight: FontWeight.w700,
          fontSize: 16,
          fontFamily: Fonts.cookieRun),
    );
  }
}
