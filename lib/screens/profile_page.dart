import 'dart:async';

import 'package:client/main.dart' show serverLink;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  final String userId;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final link = HttpLink(serverLink);
  late GraphQLClient client;
  String? name, profession;
  int? age;
  late ValueNotifier<List<dynamic>?> attributes;

  @override
  void initState() {
    client = GraphQLClient(
        link: link,
        cache: GraphQLCache(),
        defaultPolicies: DefaultPolicies(
          watchQuery: Policies(fetch: FetchPolicy.noCache),
          query: Policies(fetch: FetchPolicy.noCache),
          mutate: Policies(fetch: FetchPolicy.noCache),
        ));
    _initQuery();
    attributes = ValueNotifier<List<dynamic>?>([]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Details Activity"),
      ),
      body: Container(
        margin: const EdgeInsets.all(8.0),
        child: (name == null || age == null || profession == null)
            ? Center(
                child: CircularProgressIndicator.adaptive(),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                      flex: 1,
                      child: UserCard(
                        name: name ?? "Name",
                        age: age ?? 55,
                        profession: profession ?? "Nothing",
                      )),
                  Expanded(
                    flex: 1,
                    child: Container(
                      // outer container cannot constrait size of Row
                      padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: SizedBox(
                              height: 40,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.red[400],
                                ),
                                child: const Text(
                                  "HOBBIES",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                                onPressed: () {
                                  const content = r"""
                                      query ($id: ID!){
                                        user(id: $id){
                                          hobbies{
                                            title
                                            description
                                          }
                                        }
                                      }
                                    """;
                                  _querySomething(content, "hobbies")
                                      .then((result) {
                                    attributes.value = result;
                                  });
                                  attributes.value = null;
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            flex: 1,
                            child: SizedBox(
                              height: 40,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.red[400]),
                                  child: const Text(
                                    "POSTS",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  ),
                                  onPressed: () {
                                    const content = r"""
                                      query ($id: ID!){
                                        user(id: $id){
                                          posts{
                                            comment
                                            time
                                          }
                                        }
                                      }
                                    """;
                                    _querySomething(content, "posts")
                                        .then((result) {
                                      // result["time"] = DateFormat.yMMMMd(
                                      //         DateTime.tryParse(result["time"]))
                                      //     .toString();
                                      attributes.value = result;
                                    });
                                    attributes.value = null;
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      // list hobbies and posts
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color(0xFF008888),
                            border:
                                Border.all(width: 3, color: Color(0xff263238)),
                            borderRadius: BorderRadius.circular(5)),
                        child: ValueListenableBuilder(
                          valueListenable: attributes,
                          builder: (context, List<dynamic>? attri, _) {
                            return attri == null
                                ? Center(
                                    child: CircularProgressIndicator.adaptive(),
                                  )
                                : attri.isEmpty
                                    ? Center(
                                        child: Center(
                                            child: Text(
                                          "Still no any information",
                                          style: TextStyle(
                                              fontSize: 24,
                                              color: Colors.white70),
                                        )),
                                      )
                                    : ListView.builder(
                                        itemCount: attri.length,
                                        itemBuilder: (context, index) {
                                          final assets =
                                              attri[index].values.toList();
                                          return SizedBox(
                                            height: 100,
                                            child: Card(
                                              margin: EdgeInsets.fromLTRB(
                                                  8, 8, 8, 0),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      assets[1],
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                    Text(assets[2])
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }

  Future<dynamic> _querySomething(String content,
      [String attribute = ""]) async {
    try {
      final result = await client.query(QueryOptions(
          document: gql(content), variables: {"id": widget.userId}));
      return attribute.isEmpty
          ? result.data!["user"]
          : result.data!["user"][attribute];
    } on Exception catch (err) {
      debugPrint("$err");
      return null;
    }
  }

  Future<bool> _initQuery() async {
    const queryUser = r"""
      query ($id: ID!){
      user(id: $id){
        age
        name
        profession
        hobbies{
          title
          description
        }
      }
    }
    """;
    final qq = QueryOptions(
        document: gql(queryUser), variables: {"id": widget.userId});
    return client.query(qq).then((result) {
      final user = result.data!["user"];
      setState(() {
        name = user["name"];
        age = user["age"];
        profession = user["profession"];
        attributes.value = user["hobbies"];
      });
      return true;
    }).catchError((err) {
      debugPrint(err);
      return false;
    });
  }
}

class UserCard extends StatelessWidget {
  const UserCard(
      {Key? key,
      required this.name,
      required this.age,
      required this.profession})
      : super(key: key);
  final String name;
  final int age;
  final String profession;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      color: Colors.orange[300],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              name,
              style: TextStyle(fontSize: 20),
            ),
            Text(
              "Age: $age",
              style: TextStyle(color: Colors.grey[800]),
            ),
            Text(
              "Profession: " + profession,
              style: TextStyle(color: Colors.grey[800]),
            )
          ],
        ),
      ),
    );
  }
}
