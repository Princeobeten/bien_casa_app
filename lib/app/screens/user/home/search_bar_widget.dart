import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchBarWidget extends StatelessWidget {
  final Function()? onTap;

  const SearchBarWidget({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 60,
        decoration: BoxDecoration(
          color: Color(0xffF8F8F8),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/search icon.svg',
              color: Colors.black,
            ),
            const SizedBox(width: 10),
            Text(
              'Search Bien Casa...',
              style: TextStyle(
                color: Color(0xffBDBDBD),
                fontFamily: 'ProductSans Light',
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.normal,
                fontSize: 18,
              ),
            ),
            const Spacer(),
            SvgPicture.asset(
              'assets/icons/filter icon.svg',
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
