import 'package:client/main.dart' show serverLink;
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';

enum HasUser { none, loading, exiting, error }

class FormProfile extends StatefulWidget {
  const FormProfile({Key? key, this.name, this.profession, this.id, this.age})
      : super(key: key);
  final String? name, profession, id;
  final int? age;
  @override
  State<FormProfile> createState() => _FormProfileState();
}

class _FormProfileState extends State<FormProfile> {
  final _userForm = GlobalKey<FormState>();
  final _detailForm = GlobalKey<FormState>();
  late Map<String, String?> _editUser;

  final link = HttpLink(serverLink);
  late GraphQLClient client;
  var _hasUser = HasUser.exiting;
  bool? _isSubmit;
  var _postLoading = false;

  @override
  void initState() {
    _editUser = {
      "name": widget.name ?? "",
      "profession": widget.profession ?? "",
      "age": widget.age == null ? "" : "${widget.age}",
      "id": widget.id
    };
    client = GraphQLClient(
        link: link,
        cache: GraphQLCache(),
        defaultPolicies: DefaultPolicies(
          watchQuery: Policies(fetch: FetchPolicy.noCache),
          query: Policies(fetch: FetchPolicy.noCache),
          mutate: Policies(fetch: FetchPolicy.noCache),
        ));
    if (_editUser["id"] == null) {
      _hasUser = HasUser.none;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userButtomText = _editUser["id"] == null ? "ADD" : "UPDATE";
    return Scaffold(
      appBar: AppBar(
        title: const Text("Form Profile"),
        //ref. https://stackoverflow.com/questions/51927885/flutter-back-button-with-return-data
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(_isSubmit),
        ),
      ),
      body: Scrollbar(
        child: CustomScrollView(
            //ref. https://stackoverflow.com/questions/61510337/mainaxisalignment-under-singlechildscrollview-is-not-working
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Container(
                  alignment: Alignment.center,
                  margin:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: _postLoading
                      ? const Center(
                          child: CircularProgressIndicator.adaptive(),
                        )
                      : Column(
                          mainAxisAlignment: _hasUser == HasUser.exiting
                              ? MainAxisAlignment.spaceBetween
                              : MainAxisAlignment.start,
                          children: [
                            Form(
                              key: _userForm,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    initialValue: _editUser["name"],
                                    decoration: const InputDecoration(
                                        labelText: "Name",
                                        focusColor: Color(0xffef5350)),
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.name,
                                    validator: (value) => value!.isEmpty
                                        ? "Please enter name"
                                        : null,
                                    onSaved: (newValue) {
                                      _editUser["name"] = newValue;
                                    },
                                  ),
                                  TextFormField(
                                    initialValue: _editUser["age"],
                                    decoration:
                                        InputDecoration(labelText: "Age"),
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter an age.';
                                      }
                                      if (int.tryParse(value) == null) {
                                        return 'Please enter an integer number.';
                                      }
                                      if (int.parse(value) <= 0) {
                                        return 'Please enter a number greater than zero.';
                                      }
                                      return null;
                                    },
                                    onSaved: (newValue) {
                                      _editUser["age"] = newValue;
                                    },
                                  ),
                                  TextFormField(
                                    initialValue: _editUser["profession"],
                                    decoration: InputDecoration(
                                        labelText: "Profession"),
                                    textInputAction: TextInputAction.next,
                                    validator: (value) => value!.isEmpty
                                        ? "Please provide profession"
                                        : null,
                                    onSaved: (newValue) {
                                      _editUser["profession"] = newValue;
                                    },
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  SizedBox(
                                    height: 40,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          primary: Colors.red[400]),
                                      child: Text(
                                        userButtomText + " USER",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                      onPressed: _mutateUser,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            //post, hobbies form
                            ..._detailFormDisplay(_hasUser)
                          ],
                        ),
                ),
              ),
            ]),
      ),
    );
  }

  List<Widget> _detailFormDisplay(HasUser hasUser) {
    switch (hasUser) {
      case HasUser.exiting:
        return [
          Form(
            key: _detailForm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: "Post Comment"),
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      value!.isEmpty ? "Please provide contents" : null,
                  onSaved: (newValue) {
                    _editUser["comment"] = newValue;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Hobby Title"),
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      value!.isEmpty ? "Please provide contents" : null,
                  onSaved: (newValue) {
                    _editUser["title"] = newValue;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Hobby Description"),
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      value!.isEmpty ? "Please provide contents" : null,
                  onSaved: (newValue) {
                    _editUser["description"] = newValue;
                  },
                ),
                SizedBox(
                  height: 16,
                ),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.red[400]),
                    child: const Text(
                      "SAVE POST AND HOBBY",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    onPressed: _mutateHobbyAndPost,
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Chip(
                  backgroundColor: const Color(0xFFEFEFEF),
                  padding: const EdgeInsets.all(18),
                  avatar: CircleAvatar(
                    //another avatar: https://pub.dev/packages/avatar_view
                    backgroundColor: Colors.grey[800],
                    child: const Text(
                      "id",
                    ),
                  ),
                  label: Text(
                    _editUser["id"] ?? "123456789",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ];
      case HasUser.loading:
        return [
          const Center(
            child: CircularProgressIndicator.adaptive(),
          )
        ];
      case HasUser.error:
        return [
          const Center(
            child: Text("Error on connection"),
          )
        ];
      default:
        return [Container()];
    }
  }

  void _mutateUser() async {
    if (!_userForm.currentState!.validate()) {
      return;
    }
    _userForm.currentState!.save();
    late String post;
    if (_editUser["id"] == null) {
      post = r"""
      mutation ($age:Int,$name:String,$profession:String){
        createUser(profession:$profession,age:$age,name:$name){
          id
        }
      }
      """;
      try {
        setState(() {
          _hasUser = HasUser.loading;
        });
        final result = await client.mutate(MutationOptions(
          document: gql(post),
          variables: {..._editUser}
            ..update("age", (value) => int.parse(value))
            ..removeWhere((key, value) => value == null),
        ));
        _isSubmit = true;
        setState(() {
          _editUser["id"] = result.data!["createUser"]["id"];
          _hasUser = HasUser.exiting;
        });
      } catch (err, _) {
        setState(() {
          _hasUser = HasUser.error;
        });
        print(err);
      }
    } else {
      post = r"""
      mutation ($id:ID!,$age:Int,$name:String,$profession:String){
        updateUser(id:$id,profession:$profession,age:$age,name:$name){
          id
        }
      }
      """;
      try {
        setState(() {
          _hasUser = HasUser.loading;
        });
        final result = await client.mutate(MutationOptions(
          document: gql(post),
          variables: {..._editUser}..update("age", (value) => int.parse(value)),
        ));
        _isSubmit = true;
        setState(() {
          _editUser["id"] = result.data!["updateUser"]["id"];
          _hasUser = HasUser.exiting;
        });
      } catch (err, _) {
        setState(() {
          _hasUser = HasUser.error;
        });
        print(err);
      }
    }
  }

  void _mutateHobbyAndPost() {
    if (!_detailForm.currentState!.validate()) {
      return;
    }
    _detailForm.currentState!.save();
    const post = r"""
    mutation ($id:ID!,$comment:String,$title:String,$description:String){
      createHobby(userId:$id,title:$title,description:$description){
        user{
          name
        }
      }
      createPost(userId:$id,comment:$comment){
        comment
      }
    }
    """;
    setState(() {
      _postLoading = true;
    });
    client
        .mutate(MutationOptions(document: gql(post), variables: _editUser))
        .then((result) => setState(() {
              _postLoading = false;
            }))
        .catchError((onError) {
      print(onError);
    });
  }
}
