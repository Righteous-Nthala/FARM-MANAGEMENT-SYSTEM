import 'package:flutter/material.dart';
import 'package:farm_wise/components/livestock_management/files/observedparasitedisease.dart';
import 'package:farm_wise/components/livestock_management/files/parasitediseasecontrol.dart';
import 'package:farm_wise/components/utils/bottom_nav_bar.dart';

class Health extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Records'),
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
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ParasiteDiseaseRecordsPage()));
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
                    'Parasite & Disease Observation',
                    style: TextStyle(
                      fontSize: 23.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),

            ),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ParasiteDiseaseControlPage()));
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
                    'Treatment',
                    style: TextStyle(
                      fontSize: 24.0,
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
