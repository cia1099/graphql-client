import 'package:flutter/material.dart';
import 'package:graphql/client.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ClientGQLApp"),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          final users = snapshot.data;
          return users == null
              ? Center(
                  child: Text("Failure fetch users"),
                )
              : Container(
                  margin: EdgeInsets.all(8.0),
                  child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (_, i) {
                        final user = users[i];
                        return Card(
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
                                  user["age"].toString(),
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                ),
                                Text(
                                  user["profession"],
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                ),
                              ],
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

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    final _httpLink = HttpLink("https://app-gql-test.herokuapp.com/graphql");
    final client = GraphQLClient(
      link: _httpLink,
      cache: GraphQLCache(),
      // defaultPolicies:
      //     DefaultPolicies(query: Policies(fetch: FetchPolicy.noCache))
    );
    const readUsers = r"""
    query{
      users{
        name
        age
        profession
      }
    }
    """;
    final query = QueryOptions(document: gql(readUsers));
    return client
        .query(query)
        .then((result) => (result.data!["users"] as List<dynamic>)
            .map((u) => {
                  "age": u["age"],
                  "name": u["name"],
                  "profession": u["profession"]
                })
            .toList())
        .catchError((err) {
      print(err);
    });
  }
}
