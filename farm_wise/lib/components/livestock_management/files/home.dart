import 'package:farm_wise/components/livestock_management/files/breeding.dart';
import 'package:farm_wise/components/livestock_management/files/feeding.dart';
import 'package:farm_wise/components/livestock_management/files/parasitediseasecontrol.dart';
import 'package:farm_wise/components/livestock_management/files/product.dart';
import 'package:flutter/material.dart';
import 'package:farm_wise/components/livestock_management/files/sales.dart';
import 'package:farm_wise/components/livestock_management/files/animal.dart';

class LivestockManagementPage extends StatelessWidget {
  const LivestockManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Livestock management'),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 30.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>Animal()));
                  },
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(width: 3, color: Colors.green),
                    ),
                    child: Center(
                      child: Text(
                        'Animal',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 30.0,
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>Product()));
                  },
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(width: 3, color: Colors.green),
                    ),
                    child: Center(
                      child: Text(
                        'Products',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 30.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>BreedingRecordsPage()));
                  },
                 child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(width: 3, color: Colors.green),
                    ),
                    child: Center(
                      child: Text(
                        'Breeding',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 30.0,
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>FeedingRecordsPage()));
                  },
                 child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(width: 3, color: Colors.green),
                    ),
                    child: Center(
                      child: Text(
                        'Feeding',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 30.0,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>SalesRecordsPage()));
                  },
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(width: 3, color: Colors.green),
                    ),
                    child: Center(
                      child: Text(
                        'Sales',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 30.0,
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
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(width: 3, color: Colors.green),
                    ),
                    child: Center(
                      child: Text(
                        'Health',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),

                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

