import 'dart:async';

import 'package:client/main.dart' show serverLink;
import 'package:client/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';

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
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (context) =>
                                ProfilePage(userId: user["id"])))
                        .catchError((e) => print(e)),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user["name"],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              user["profession"],
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "add",
        child: const Icon(Icons.add),
        onPressed: () {},
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
      }
    }
    """;
    final query = QueryOptions(document: gql(readUsers));
    client.query(query).then((result) {
      _listData.clear();
      _listData.addAll((result.data!["users"] as List<dynamic>).map((u) =>
          {"name": u["name"], "profession": u["profession"], "id": u["id"]}));
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
}
