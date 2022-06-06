import 'package:flutter/material.dart';

class Review extends StatelessWidget {
  final int participants_num = 6;
  final TextEditingController controller = TextEditingController();

  Review({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meeting Title'),
        actions: [
          ElevatedButton(onPressed: () {}, child: Icon(Icons.flag)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(child: Column()),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      children: List.generate(
                        participants_num,
                        (index) {
                          return Row(
                            children: [
                              Card(
                                  child: Checkbox(
                                      value: false, onChanged: (_) {})),
                              Card(
                                  child: Checkbox(
                                      value: false, onChanged: (_) {})),
                              Card(child: Text('$index')),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      scrollDirection: Axis.horizontal,
                      children: List.generate(6, (index) {
                        return Card(
                          child: Text('$index'),
                        );
                      }),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(onPressed: () {}, child: Text('Save all')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
