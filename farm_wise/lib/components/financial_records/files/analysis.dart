import 'package:flutter/material.dart';
import 'package:farm_wise/components/utils/bottom_nav_bar.dart';

class AnnualAnalysisPage extends StatefulWidget {
  @override
  _AnnualAnalysisPageState createState() => _AnnualAnalysisPageState();
}

class _AnnualAnalysisPageState extends State<AnnualAnalysisPage> {
  final TextEditingController expenditureController = TextEditingController();
  final TextEditingController incomeController = TextEditingController();
  final TextEditingController observationController = TextEditingController();

  double? profitOrLoss;
  List<Map<String, dynamic>> observations = [];

  void calculateProfitOrLoss() {
    final expenditure = double.tryParse(expenditureController.text) ?? 0;
    final income = double.tryParse(incomeController.text) ?? 0;
    setState(() {
      profitOrLoss = income - expenditure;
    });
  }

  void addOrUpdateObservation({int? index}) {
    if (observationController.text.isNotEmpty) {
      setState(() {
        if (index != null) {
          observations[index]['text'] = observationController.text;
        } else {
          observations.add({
            'text': observationController.text,
            'date': DateTime.now().toString(),
          });
        }
        observationController.clear();
      });
    }
  }

  void deleteObservation(int index) {
    setState(() {
      observations.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Annual Analysis'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Financial Metrics",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Table(
                border: TableBorder.all(),
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(2),
                },
                children: [
                  _buildTableRow("Total Expenditure (MWK)", expenditureController),
                  _buildTableRow("Total Income (MWK)", incomeController),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Profit/Loss (MWK)",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          profitOrLoss != null
                              ? profitOrLoss!.toStringAsFixed(2)
                              : "N/A",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "Observations",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: observationController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Write your observation",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: addOrUpdateObservation,
                child: const Text("Save Observation"),
              ),
              const SizedBox(height: 20),
              const Text(
                "Saved Observations",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...observations.map((observation) {
                int index = observations.indexOf(observation);
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    title: Text(observation['text']),
                    subtitle: Text("Created: ${observation['date']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            observationController.text = observation['text'];
                            addOrUpdateObservation(index: index);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => deleteObservation(index),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTabSelected: (int) {},
      ),
    );
  }

  TableRow _buildTableRow(String label, TextEditingController controller) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            onChanged: (_) => calculateProfitOrLoss(),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
