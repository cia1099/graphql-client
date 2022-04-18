import "package:graphql/client.dart";

void main() {
  final _httpLink = HttpLink("https://app-gql-test.herokuapp.com/graphql");
  final client = GraphQLClient(link: _httpLink, cache: GraphQLCache());

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
  client.query(query).then((result) {
    final users = result.data!["users"] as List<dynamic>;
    print("We have user:");
    for (int i = 0; i < users.length; i++) {
      final tmp = {
        "name": users[i]["name"],
        "age": users[i]["age"],
        "profession": users[i]["profession"]
      };
      print(tmp);
    }
  }).catchError((onError) => print(onError.toString()));

  // const queryID = "sLawWv49dtOrXtCEaqoO";
  // const changedName = r"""
  // mutation ($id:ID!,$age:Int,$name:String){
  //   updateUser(id:$id,age:$age,name:$name){
  //     id
  //     name
  //     age
  //   }
  // }
  // """;
  // final mutation = MutationOptions(
  //     document: gql(changedName),
  //     variables: {"id": queryID, "name": "Pitt", "age": 55});

  // client.mutate(mutation).then((result) {
  //   final user = result.data!["updateUser"];
  //   print("\n**** Successfully changed. ****");
  //   print({"name": user["name"], "age": user["age"], "id": user["id"]});
  // }).catchError((err) => print(err));

  // const queryUser = r"""
  // query ($id: ID!){
  //   user(id: $id){
  //     age
  //     name
  //   }
  // }
  // """;
  // final qq = QueryOptions(document: gql(queryUser), variables: {"id": queryID});
  // client.query(qq).then((result) {
  //   final user = result.data!["user"];
  //   print("We changed user:");
  //   final tmp = {
  //     "name": user["name"],
  //     "age": user["age"],
  //     "profession": user["profession"]
  //   };
  //   print(tmp);
  // }).catchError((onError) => print(onError.toString()));
}
