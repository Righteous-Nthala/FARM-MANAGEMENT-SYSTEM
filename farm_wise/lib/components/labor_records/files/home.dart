import 'package:farm_wise/components/labor_records/files/permanent.dart';
import 'package:farm_wise/components/labor_records/files/temporary.dart';
import 'package:flutter/material.dart';
import 'package:farm_wise/components/utils/bottom_nav_bar.dart';

class Home extends StatelessWidget {
  const Home({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Labor Records'),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30.0,
          color: Colors.black,
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>PermanentRecordsPage()));
              },
              child:  Container(
                margin: EdgeInsets.fromLTRB(30.0, 200.0, 10.0, 10.0),
                width: 350,
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 3, color: Colors.green),
                ),
                child: Center(
                  child: Text(
                    'Permanent Labor',
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),

            ),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>TemporaryRecordsPage()));
              },
              child:  Container(
                margin: EdgeInsets.fromLTRB(30.0, 40.0, 10.0, 10.0),
                width: 350,
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 3, color: Colors.green),
                ),
                child: Center(
                  child: Text(
                    'Temporary Labor',
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTabSelected: (int) {},
      ),
    );
  }
}
