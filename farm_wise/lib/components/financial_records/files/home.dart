import 'package:flutter/material.dart';
import 'package:farm_wise/components/utils/bottom_nav_bar.dart';
import 'package:farm_wise/components/financial_records/files/income.dart';
import 'package:farm_wise/components/financial_records/files/expenses.dart';
import 'package:farm_wise/components/financial_records/files/analysis.dart';

class FinancialRecordsPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Financial Records'),
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
                Navigator.push(context, MaterialPageRoute(builder: (context)=>IncomeRecordsPage()));
              },
              child:  Container(
                margin: EdgeInsets.fromLTRB(30.0, 100.0, 10.0, 10.0),
                width: 350,
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 3, color: Colors.green),
                ),
                child: Center(
                  child: Text(
                    'Income',
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
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ExpenditureRecordsPage()));
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
                    'Expenditures',
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
                Navigator.push(context, MaterialPageRoute(builder: (context)=>AnnualAnalysisPage()));
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
                    'Analysis',
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
