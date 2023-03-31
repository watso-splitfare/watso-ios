import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'menu_list_page.dart';

class OrderSetPage extends StatefulWidget {
  @override
  _OrderSetPageState createState() => _OrderSetPageState();
}

enum Selection { min, max }

class _OrderSetPageState extends State<OrderSetPage> {
  final _recruitFormKey = GlobalKey<FormState>();
  String minRecruit = '';
  String maxRecruit = '';
  bool minChecked = false;
  bool maxChecked = false;
  DateTime nowDate = DateTime.now();

  late DateTime _dateTime;
  List storeList = ["네네치킨", "맘스터치"];

  @override
  void initState() {
    super.initState();
    _dateTime = DateTime(nowDate.year, nowDate.month, nowDate.day, nowDate.hour,
        nowDate.minute - nowDate.minute % 10 + 10);
  }

  //_dateTime.minute=_dateTime.minute%10

  void _showTimePicker() {
    showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => Container(
              height: 216,
              padding: const EdgeInsets.only(top: 6.0),
              // The Bottom margin is provided to align the popup above the system
              // navigation bar.
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              // Provide a background color for the popup.
              color: CupertinoColors.systemBackground.resolveFrom(context),
              // Use a SafeArea widget to avoid system overlaps.
              child: SafeArea(
                top: false,
                child: CupertinoDatePicker(
                  initialDateTime: _dateTime,
                  minuteInterval: 10,
                  minimumDate: nowDate,
                  //maxdate nowDate + 1 day
                  maximumDate: nowDate.add(Duration(days: 1)),
                  use24hFormat: false,
                  // This is called when the user changes the dateTime.
                  onDateTimeChanged: (DateTime newDateTime) {
                    setState(() => _dateTime = newDateTime);
                  },
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text('배달톡 생성',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "주문 예정 시간",
                  style: TextStyle(fontSize: 15),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    _showTimePicker();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("5월 19일 5시 30분", style: TextStyle(fontSize: 20)),
                      Icon(Icons.timer),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "가계 선택",
                  style: TextStyle(fontSize: 15),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("가계를 선택해 주세요",
                          style: TextStyle(fontSize: 20, color: Colors.grey)),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Text(
                      "모집 인원 선택 ",
                      style: TextStyle(fontSize: 15),
                    ),
                    Text(
                      "(선택 사항)",
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                Form(
                  key: _recruitFormKey,
                  child: Row(
                    children: [
                      Checkbox(
                          value: minChecked,
                          onChanged: (value) {
                            setState(() {
                              minChecked = value!;
                            });
                          }),
                      Expanded(
                          child: TextFormField(
                        decoration: InputDecoration(
                          label: Text('최소 인원'),
                        ),
                        initialValue: '2',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onSaved: (value) => minRecruit = value!,
                      )),
                      Checkbox(
                          value: maxChecked,
                          onChanged: (value) {
                            setState(() {
                              maxChecked = value!;
                            });
                          }),
                      Expanded(
                          child: TextFormField(
                        initialValue: '4',
                        decoration: InputDecoration(
                          label: Text('최대 인원'),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onSaved: (value) => maxRecruit = value!,
                      )),
                    ],
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: ElevatedButton(
                onPressed: () {
                  _recruitFormKey.currentState!.save();
                  var minRecruitNum = int.tryParse(minRecruit) ?? 1;
                  var maxRecruitNum = int.tryParse(maxRecruit) ?? 999;
                  if (minChecked &&
                      maxChecked &&
                      minRecruitNum > maxRecruitNum) {
                    //alert error
                    showDialog<void>(
                      context: context,
                      barrierDismissible: true,
                      // false = user must tap button, true = tap outside dialog
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: Text('에러'),
                          content: Text('최소인원이 최대인원보다 클 수 없습니다.'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('확인'),
                              onPressed: () {
                                Navigator.of(dialogContext)
                                    .pop(); // Dismiss alert dialog
                              },
                            ),
                          ],
                        );
                      },
                    );
                    return;
                  }
                  if (minChecked) {
                    log("minRecruitNum: $minRecruitNum");
                  }
                  if (maxChecked) {
                    log("maxRecruitNum: $maxRecruitNum");
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MenuListPage()),
                  );
                },
                child: Text("주문하기"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}