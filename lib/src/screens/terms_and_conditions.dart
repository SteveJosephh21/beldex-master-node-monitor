import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:master_node_monitor/generated/l10n.dart';
import 'package:master_node_monitor/src/widgets/base_page.dart';

class TermsAndConditions extends BasePage{
  @override
  String get title => S.current.termsConditions;

  @override
  Widget body(BuildContext context) => TermsAndConditionsPageBody();
}

class TermsAndConditionsPageBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TermsAndConditionsPageBodyState();
}

class TermsAndConditionsPageBodyState extends State<TermsAndConditionsPageBody> {

  String _fileText = '';

  Future getFileLines() async {
    _fileText = await rootBundle.loadString('assets/text/Terms_of_Use.txt');
    setState(() {
    });
  }

  @override
  void initState() {
    super.initState();
    getFileLines();
  }

  @override
  Widget build(BuildContext context){
    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 25.0, right: 25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Center(
            child: Text(
              'Legal Disclaimer',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14.0, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Text(
            _fileText,
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 12.0),
          ),
          SizedBox(
            height: 16.0,
          )
        ],
      ),
    );
  }
  
}