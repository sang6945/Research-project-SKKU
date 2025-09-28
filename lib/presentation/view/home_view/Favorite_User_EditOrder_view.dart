// ignore_for_file: camel_case_types, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fineplay/utils/screen_ratio.dart';

class Favorite_User_EditOrder_view extends ConsumerWidget {
  const Favorite_User_EditOrder_view({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    S.init(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context); // 이전 페이지로 이동
          },
        ),
        title: Text("즐겨찾는 플레이어", style: TextStyle(fontSize: 18*S.Y_RATIO),),
        backgroundColor: const Color(0xFF030319),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: S.Y_RATIO * 28),
              child: Stack(
                children: [
                  Container(
                    alignment: Alignment.topRight,
                    padding: EdgeInsets.only(right: S.Y_RATIO * 30, bottom: S.Y_RATIO*10),
                  ),
                ],
              ),
            ),
            // 최근 검색 기록이 없을 때 중앙에 문구 표시

            const FavoriteBox_order1(),
            const SizedBox(height: 10),
            const FavoriteBox_order2(),
            const SizedBox(height: 10),
            const FavoriteBox_order3(),

          ],
        ),
      ),
      bottomNavigationBar: SizedBox(

        height: 90 * S.Y_RATIO,
        child: Center(

          child: ElevatedButton(
            style: ElevatedButton.styleFrom(

              backgroundColor: const Color(0xFFFF7400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              minimumSize: Size(300 * S.X_RATIO, 45 * S.Y_RATIO),
            ),
            onPressed: () {
              // 버튼 클릭 시 동작
            },
            child: Text(
              "순서 편집 완료하기",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18 * S.Y_RATIO,
                fontWeight: FontWeight.w500,

              ),
            ),
          ),
        ),
      ),
    );
  }
}


class FavoriteBox_order1 extends ConsumerStatefulWidget {
  const FavoriteBox_order1({super.key});

  @override
  _FavoriteBox1_orderState createState() => _FavoriteBox1_orderState();
}

class _FavoriteBox1_orderState extends ConsumerState<FavoriteBox_order1> {


  @override
  Widget build(BuildContext context) {
    S.init(context);

    return
    Container(
      height: S.Y_RATIO * 60,
      width: S.X_RATIO * 300,
      decoration: BoxDecoration(
        color: const Color(0xFF21213d),
        borderRadius: BorderRadius.circular(10.0*S.Y_RATIO),
      ),
      child: Center(
        child: Stack(
          children: [
            Row(
              children: [
                SizedBox(width: 20 * S.X_RATIO),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Icon(
                    Icons.circle,
                    size: 45 * S.Y_RATIO,
                    color: const Color(0xFFD9D9D9),
                  ),
                ),
                SizedBox(width: 11 * S.X_RATIO),
                Center(
                  child: Container(
                    padding: EdgeInsets.only(top: 10 * S.Y_RATIO),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "용드리",
                          style: TextStyle(
                            fontSize: 18 * S.Y_RATIO,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Wanted sans',
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "MF / 95",
                          style: TextStyle(
                            fontSize: 12 * S.Y_RATIO,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Wanted sans',
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // 별 아이콘
            Positioned(
              right: 10*S.X_RATIO,
              child:  Container(
                padding: EdgeInsets.only(top: 10 * S.Y_RATIO),
                child: Icon(Icons.menu_sharp,
                    size: 35* S.Y_RATIO,
                    color: Colors.white,
                  ),
              ),

            ),


          ],
        ),
      ),
    );

}}

class FavoriteBox_order2 extends ConsumerStatefulWidget {
  const FavoriteBox_order2({super.key});

  @override
  _FavoriteBox_order2State createState() => _FavoriteBox_order2State();
}

class _FavoriteBox_order2State extends ConsumerState<FavoriteBox_order2> {


  @override
  Widget build(BuildContext context) {
    S.init(context);

    return
      Container(
        height: S.Y_RATIO * 60,
        width: S.X_RATIO * 300,
        decoration: BoxDecoration(
          color: const Color(0xFF21213d),
          borderRadius: BorderRadius.circular(10.0*S.Y_RATIO),
        ),
        child: Center(
          child: Stack(
            children: [
              Row(
                children: [
                  SizedBox(width: 20 * S.X_RATIO),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.circle,
                      size: 45 * S.Y_RATIO,
                      color: const Color(0xFFD9D9D9),
                    ),
                  ),
                  SizedBox(width: 11 * S.X_RATIO),
                  Center(
                    child: Container(
                      padding: EdgeInsets.only(top: 10 * S.Y_RATIO),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "용드리",
                            style: TextStyle(
                              fontSize: 18 * S.Y_RATIO,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Wanted sans',
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "MF / 95",
                            style: TextStyle(
                              fontSize: 12 * S.Y_RATIO,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Wanted sans',
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // 별 아이콘
              Positioned(
                right: 10*S.X_RATIO,
                child:  Container(
                  padding: EdgeInsets.only(top: 10 * S.Y_RATIO),
                  child: Icon(Icons.menu_sharp,
                    size: 35* S.Y_RATIO,
                    color: Colors.white,
                  ),
                ),

              ),


            ],
          ),
        ),
      );

  }}

class FavoriteBox_order3 extends ConsumerStatefulWidget {
  const FavoriteBox_order3({super.key});

  @override
  _FavoriteBox_order3State createState() => _FavoriteBox_order3State();
}

class _FavoriteBox_order3State extends ConsumerState<FavoriteBox_order3> {


  @override
  Widget build(BuildContext context) {
    S.init(context);

    return
      Container(
        height: S.Y_RATIO * 60,
        width: S.X_RATIO * 300,
        decoration: BoxDecoration(
          color: const Color(0xFF21213d),
          borderRadius: BorderRadius.circular(10.0*S.Y_RATIO),
        ),
        child: Center(
          child: Stack(
            children: [
              Row(
                children: [
                  SizedBox(width: 20 * S.X_RATIO),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.circle,
                      size: 45 * S.Y_RATIO,
                      color: const Color(0xFFD9D9D9),
                    ),
                  ),
                  SizedBox(width: 11 * S.X_RATIO),
                  Center(
                    child: Container(
                      padding: EdgeInsets.only(top: 10 * S.Y_RATIO),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "용드리",
                            style: TextStyle(
                              fontSize: 18 * S.Y_RATIO,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Wanted sans',
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "MF / 95",
                            style: TextStyle(
                              fontSize: 12 * S.Y_RATIO,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Wanted sans',
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // 별 아이콘
              Positioned(
                right: 10*S.X_RATIO,
                child:  Container(
                  padding: EdgeInsets.only(top: 10 * S.Y_RATIO),
                  child: Icon(Icons.menu_sharp,
                    size: 35* S.Y_RATIO,
                    color: Colors.white,
                  ),
                ),

              ),


            ],
          ),
        ),
      );

  }}