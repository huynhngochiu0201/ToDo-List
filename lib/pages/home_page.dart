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
  TextEditingController addController = TextEditingController();
  FocusNode addFocus = FocusNode();
  List<TodoModel> todos = [];
  List<TodoModel> searchList = [];
  bool showAddBox = false;

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
        body: Stack(
          children: [
            Positioned.fill(
              child: Padding(
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
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 20.0),
                        itemCount: searchList.length,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20.0,
              right: 20.0,
              bottom: 20.0,
              child: Row(
                children: [
                  Expanded(
                    child: Visibility(
                      visible: showAddBox,
                      child: _addBox(),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  _addButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addButton() {
    return GestureDetector(
      onTap: () {
        if (showAddBox == false) {
          showAddBox = true;
          setState(() {});
          addFocus.requestFocus();
        } else {
          String text = addController.text.trim();
          if (text.isEmpty) {
            showAddBox = false;
            setState(() {});
            addFocus.unfocus();
          } else {
            TodoModel todo = TodoModel()
              ..id = '${DateTime.now().millisecondsSinceEpoch}'
              ..text = text
              ..isDone = false;

            todos.add(todo);
            _search('');
            addController.clear();
            searchController.clear();
            addFocus.unfocus();
            showAddBox = false;
            setState(() {});
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: AppColor.orange,
          border: Border.all(color: AppColor.red, width: 1.2),
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          boxShadow: const [
            BoxShadow(
              color: AppColor.shadow,
              offset: Offset(0.0, 3.0),
              blurRadius: 6.0,
            ),
          ],
        ),
        child: const Icon(Icons.add, size: 32.6, color: AppColor.white),
      ),
    );
  }

  Widget _addBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: AppColor.white,
        border: Border.all(color: AppColor.orange, width: 1.2),
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        boxShadow: const [
          BoxShadow(
            color: AppColor.shadow,
            offset: Offset(0.0, 3.0),
            blurRadius: 6.0,
          ),
        ],
      ),
      child: TextField(
        controller: addController,
        focusNode: addFocus,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Add a new todo item',
          hintStyle: TextStyle(color: AppColor.grey),
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
