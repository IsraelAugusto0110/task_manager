import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _taskController;
  List<Task> _tasks = [];
  List<bool> _tasksDone = [];

  void saveTask() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Task t = Task.fromString(_taskController.text);

    String? tasks = prefs.getString("task");
    List list = (tasks == null) ? [] : json.decode(tasks);

    list.add(json.encode(t.getMap()));
    prefs.setString('task', json.encode(list));
    _taskController.text = '';
    Navigator.of(context).pop();
    _getTasks();
  }

  void _getTasks() async {
    _tasks = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasks = prefs.getString('task');
    List list = (tasks == null) ? [] : json.decode(tasks);
    for (dynamic d in list) {
      _tasks.add(Task.fromMap(json.decode(d)));
    }
    print(_tasks);
    _tasksDone = List.generate(_tasks.length, (index) => false);
    setState(() {});
  }

  void updatePendingTasksList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Task> pendingList = [];
    for (var i = 0; i < _tasks.length; i++)
      if (!_tasksDone[i]) pendingList.add(_tasks[i]);

    var pendingListEncoded = List.generate(
        pendingList.length, (i) => json.encode(pendingList[i].getMap()));

    prefs.setString('task', json.encode(pendingListEncoded));

    _getTasks();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _taskController = TextEditingController();

    _getTasks();
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Task Manager')),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: updatePendingTasksList,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('task', json.encode([]));

              _getTasks();
            },
          ),
        ],
      ),
      body: (_tasks == [])
          ? Center(
              child: Text(
                'No task added.',
                style: GoogleFonts.roboto(),
              ),
            )
          : Column(
              children: _tasks
                  .map((e) => Container(
                        height: 70.0,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        padding: const EdgeInsets.only(left: 5),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(color: Colors.black, width: 0.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              e.task,
                              style: GoogleFonts.roboto(
                                fontSize: 15,
                              ),
                            ),
                            Checkbox(
                                value: _tasksDone[_tasks.indexOf(e)],
                                key: GlobalKey(),
                                onChanged: (val) {
                                  setState(() {
                                    _tasksDone[_tasks.indexOf(e)] = val!;
                                  });
                                })
                          ],
                        ),
                      ))
                  .toList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          showModalBottomSheet(
              context: context,
              builder: (BuildContext context) => Container(
                    padding: const EdgeInsets.all(11.0),
                    color: Colors.lightBlue,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Add Task",
                              style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold),
                            ),
                            GestureDetector(
                                onTap: (() => Navigator.of(context).pop()),
                                child: Icon(Icons.close)),
                          ],
                        ),
                        Divider(
                          thickness: 1.5,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        TextField(
                          controller: _taskController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(color: Colors.blue)),
                              fillColor: Colors.white,
                              filled: true,
                              hintText: 'New Task',
                              hintStyle: GoogleFonts.roboto()),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          width: MediaQuery.of(context).size.width,
                          height: 100,
                          child: Row(
                            children: [
                              Container(
                                width: (MediaQuery.of(context).size.width / 2) -
                                    20,
                                padding: const EdgeInsets.all(10),
                                child: ElevatedButton(
                                  child: Text(
                                    'Reset',
                                    style: GoogleFonts.roboto(
                                        color: Colors.white,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () => _taskController.text = '',
                                ),
                              ),
                              Container(
                                width: (MediaQuery.of(context).size.width / 2) -
                                    20,
                                padding: const EdgeInsets.all(10),
                                child: ElevatedButton(
                                  child: Text(
                                    'Add',
                                    style: GoogleFonts.roboto(
                                        color: Colors.white,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () => saveTask(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
        },
        child: Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 40,
        ),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
