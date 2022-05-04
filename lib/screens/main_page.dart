import 'dart:async';

import 'package:client/main.dart' show serverLink;
import 'package:client/screens/form_profile.dart';
import 'package:client/screens/profile_page.dart';
import 'package:client/utili/web_navigator.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

enum Status {
  loading,
  success,
  failure,
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final link = HttpLink(serverLink);
  late GraphQLClient client;
  late GraphQLCache _inMemoryCache;
  late StreamController<Status> _streamController;
  late List<Map<String, dynamic>> _listData;

  @override
  void initState() {
    _inMemoryCache = GraphQLCache();
    client = GraphQLClient(
        link: link,
        cache: _inMemoryCache,
        defaultPolicies: DefaultPolicies(
          watchQuery: Policies(fetch: FetchPolicy.noCache),
          query: Policies(fetch: FetchPolicy.noCache),
          mutate: Policies(fetch: FetchPolicy.noCache),
        ));
    _listData = [];
    _streamController = StreamController<Status>();
    WidgetsBinding.instance!.addPostFrameCallback((_) => _fetchUsers());

    super.initState();
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ClientGQLApp"),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: StreamBuilder(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          final status = snapshot.data;
          if (status != Status.success) {
            return Center(
              child: status == Status.loading
                  ? CircularProgressIndicator.adaptive()
                  : Text("Fail to fetch users"),
            );
          }
          return Container(
            margin: EdgeInsets.all(8.0),
            child: ListView.builder(
                itemCount: _listData.length,
                itemBuilder: (_, i) {
                  final user = _listData[i];
                  return GestureDetector(
                    onTap: () => LayoutNavigator.push(
                            context: context,
                            page: ProfilePage(userId: user["id"]))
                        .catchError((e) => print(e)),
                    child: Slidable(
                      endActionPane: ActionPane(
                        motion: const BehindMotion(),
                        children: [
                          SlidableAction(
                            backgroundColor: Color(0xFFFE4A49),
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                            onPressed: (_) => showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('Are you sure?'),
                                content: Text(
                                  'Do you want to remove the user?',
                                ),
                                actions: [
                                  TextButton(
                                    child: Text('No'),
                                    onPressed: () {
                                      Navigator.of(ctx).pop(false);
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Yes'),
                                    onPressed: () {
                                      _removeUser(user["id"]);
                                      Navigator.of(ctx).pop(true);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user["name"],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Text(
                                  user["profession"],
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    onLongPress: () => LayoutNavigator.push(
                        context: context,
                        page: FormProfile(
                          id: user["id"],
                          name: user["name"],
                          age: user["age"],
                          profession: user["profession"],
                        )).then((isSubmit) {
                      if (isSubmit == true) {
                        _fetchUsers();
                      }
                    }),
                  );
                }),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "add",
        child: const Icon(Icons.add),
        onPressed: () =>
            LayoutNavigator.push(context: context, page: FormProfile())
                .then((_) => _fetchUsers()),
      ),
    );
  }

  Future<void> _fetchUsers() async {
    _streamController.add(Status.loading);
    const readUsers = r"""
    query{
      users{
        name
        profession
        id
        age
      }
    }
    """;
    final query = QueryOptions(document: gql(readUsers));
    client.query(query).then((result) {
      _listData.clear();
      _listData.addAll((result.data!["users"] as List<dynamic>).map((u) => {
            "name": u["name"],
            "profession": u["profession"],
            "id": u["id"],
            "age": u["age"],
          }));
      _streamController.add(Status.success);
    }).catchError((err) {
      _streamController.add(Status.failure);
      debugPrint("$err");
    });
  }

  Stream<List<Map<String, dynamic>>> _currencyUsers() async* {
    const readUsers = r"""
    query{
      users{
        name
        profession
        id
      }
    }
    """;
    final query = QueryOptions(document: gql(readUsers));
    List<Map<String, dynamic>> susers = [];

    client.query(query).then((result) async* {
      final users = (result.data!["users"] as List<dynamic>).map((u) =>
          {"name": u["name"], "profession": u["profession"], "id": u["id"]});
      for (final user in users) {
        print(user);
        susers.add(user);
        yield susers;
      }
    }).catchError((err) {
      debugPrint("$err");
    });
  }

  void _removeUser(String userId) {
    const post = r"""
    mutation ($id:ID!){
      removeUser(id:$id){
        id
      }
    }
    """;
    client
        .mutate(MutationOptions(document: gql(post), variables: {"id": userId}))
        .then((_) => _fetchUsers());
  }
}
