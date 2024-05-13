import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo_app_flutter/components/td_app_bar.dart';
import 'package:todo_app_flutter/components/td_search_box.dart';
import 'package:todo_app_flutter/components/todo_item.dart';
import 'package:todo_app_flutter/models/todo_model.dart';
import 'package:todo_app_flutter/resources/app_color.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController searchController = TextEditingController();
  TextEditingController editingController = TextEditingController();
  List<TodoModel> todos = [];
  List<TodoModel> searchList = [];

  @override
  void initState() {
    super.initState();
    todos = [...todoListA];
    searchList = [...todos];
  }

  void _search(String value) {
    value = value.toLowerCase();
    searchList = todos
        .where((e) => (e.text ?? '').toLowerCase().contains(value))
        .toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.bgColor,
        appBar: _buildAppBar(context),
        body: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TdSearchBox(
                  controller: searchController,
                  onChanged: _search,
                ),
              ),
              const SizedBox(height: 16.0),
              _divider(),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0)
                      .copyWith(top: 16.0, bottom: 98.0),
                  itemBuilder: (context, index) {
                    final todo = searchList.reversed.toList()[index];
                    return TodoItem(
                      todo,
                      onTap: () {
                        todo.isDone = !(todo.isDone ?? false);
                        setState(() {});
                      },
                      onEditing: () => _editing(context, todo),
                      onDelete: () => _delele(context, todo),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 20.0),
                  itemCount: searchList.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editing(BuildContext context, TodoModel todo) {
    String text = todo.text ?? '';
    editingController.text = text;
    bool textEmpty = text.isEmpty;

    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setStatus) {
          return AlertDialog(
            title: Align(
              alignment: Alignment.centerLeft,
              child: CircleAvatar(
                backgroundColor: AppColor.orange.withOpacity(0.8),
                radius: 14.0,
                child:
                    const Icon(Icons.edit, size: 16.0, color: AppColor.white),
              ),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: editingController,
                    onChanged: (value) {
                      textEmpty = value.trim().isEmpty;
                      setStatus(() {});
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: textEmpty
                    ? null
                    : () {
                        todo.text = editingController.text.trim();
                        setState(() {});
                        Navigator.of(context).pop();
                      },
                child: Text(
                  'Save',
                  style: TextStyle(
                      color: textEmpty ? AppColor.grey : AppColor.blue,
                      fontSize: 16.8),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColor.blue, fontSize: 16.8),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  void _delele(BuildContext context, TodoModel todo) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('😐'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Delete this todo?',
                  style: TextStyle(color: AppColor.brown, fontSize: 20.0),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Yes',
                style: TextStyle(color: AppColor.blue, fontSize: 16.8),
              ),
              onPressed: () {
                todos.removeWhere((e) => e.id == todo.id);
                searchList.removeWhere((e) => e.id == todo.id);
                setState(() {});
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'No',
                style: TextStyle(color: AppColor.blue, fontSize: 16.8),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Divider _divider() {
    return const Divider(
      height: 1.2,
      thickness: 1.2,
      indent: 20.0,
      endIndent: 20.0,
      color: AppColor.grey,
    );
  }

  TdAppBar _buildAppBar(BuildContext context) {
    return TdAppBar(
      rightPressed: () => showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('😍'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    'Do you want to exit app?',
                    style: TextStyle(color: AppColor.brown, fontSize: 18.0),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  'Yes',
                  style: TextStyle(color: AppColor.blue, fontSize: 16.8),
                ),
                onPressed: () {
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                },
              ),
              TextButton(
                child: const Text(
                  'No',
                  style: TextStyle(color: AppColor.blue, fontSize: 16.8),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      ),
      title: widget.title,
      icon: Icon(
        Icons.logout,
        size: 24.0,
        color: AppColor.brown.withOpacity(0.8),
      ),
    );
  }
}
