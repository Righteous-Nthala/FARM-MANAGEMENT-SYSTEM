import 'package:flutter/material.dart';

class Home  extends StatelessWidget {
  const Home({super.key});


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('Labor Records'),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 30.0,
          fontWeight: FontWeight.bold
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
                InkWell(
                  child: Container(
                    margin: EdgeInsets.only(top: 0.0),
                    width: 350,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(width: 3, color: Colors.green),
                    ),
                    child: Center(
                      child: Text(
                        'Permanent Labor',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 30.0,
                        ),
                      ),
                    ),
                  )
                ),

            InkWell(
                child: Container(
                  margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  width: 350,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 3, color: Colors.green),
                  ),
                  child: Center(
                    child: Text(
                      'Temporary Labor',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 30.0,
                      ),
                    ),
                  ),
                )
            )
              ],
            )
        )
      );
  }
}

