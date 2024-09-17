import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_alarm_clock/app/data/theme_data.dart';
import 'package:intl/intl.dart';

import 'clockview.dart';

class ClockPage extends StatefulWidget {
  @override
  _ClockPageState createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();

    var formattedDate = DateFormat('EEE, d MMM').format(now);
    var timezoneString = now.timeZoneOffset.toString().split('.').first;
    var offsetSign = '';
    if (!timezoneString.startsWith('-')) offsetSign = '+';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Text(
              'Clock',
              style: TextStyle(
                  fontFamily: 'avenir', fontWeight: FontWeight.w700, color: CustomColors.primaryTextColor, fontSize: 24),
            ),
          ),
          Flexible(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DigitalClockWidget(),
                Text(
                  formattedDate,
                  style: TextStyle(
                      fontFamily: 'avenir', fontWeight: FontWeight.w300, color: CustomColors.primaryTextColor, fontSize: 20),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 4,
            fit: FlexFit.tight,
            child: Align(
              alignment: Alignment.center,
              child: ClockView(
                size: MediaQuery.of(context).size.height / 4,
              ),
            ),
          ),
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Timezone',
                  style: TextStyle(
                      fontFamily: 'avenir', fontWeight: FontWeight.w500, color: CustomColors.primaryTextColor, fontSize: 24),
                ),
                SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.language,
                      color: CustomColors.primaryTextColor,
                    ),
                    SizedBox(width: 16),
                    Text(
                      'UTC' + offsetSign + timezoneString,
                      style: TextStyle(fontFamily: 'avenir', color: CustomColors.primaryTextColor, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DigitalClockWidget extends StatefulWidget {
  const DigitalClockWidget({
    Key? key,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return DigitalClockWidgetState();
  }
}

class DigitalClockWidgetState extends State<DigitalClockWidget> {
  String formattedTime = 'Loading...';
  late Timer timer;

  @override
  void initState() {
    super.initState();
    fetchTime();
    this.timer = Timer.periodic(Duration(minutes: 1), (timer) {
      fetchTime();
    });
  }

  Future<void> fetchTime() async {
    try {
      final response = await http.get(
        Uri.parse('https://timeapi.io/api/Time/current/zone?timeZone=Asia/Jakarta'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          formattedTime = data['time'].substring(0, 5); // format HH:mm
        });
      } else {
        throw Exception('Failed to load time');
      }
    } catch (e) {
      setState(() {
        formattedTime = 'Error';
      });
      print('Error fetching time: $e');
    }
  }

  @override
  void dispose() {
    this.timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      formattedTime,
      style: TextStyle(fontFamily: 'avenir', color: CustomColors.primaryTextColor, fontSize: 64),
    );
  }
}