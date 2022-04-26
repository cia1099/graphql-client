import 'package:client/main.dart' show serverLink;
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Form Profile"),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Form(
              key: _userForm,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    initialValue: _editUser["name"],
                    decoration: const InputDecoration(
                        labelText: "Name", focusColor: Color(0xffef5350)),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.name,
                    validator: (value) =>
                        value!.isEmpty ? "Please enter name" : null,
                    onSaved: (newValue) {
                      _editUser["name"] = newValue;
                    },
                  ),
                  TextFormField(
                    initialValue: _editUser["age"],
                    decoration: InputDecoration(labelText: "Age"),
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
                    decoration: InputDecoration(labelText: "Profession"),
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        value!.isEmpty ? "Please provide profession" : null,
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
                      style: ElevatedButton.styleFrom(primary: Colors.red[400]),
                      child: const Text(
                        "SAVE USER",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      onPressed: () {},
                    ),
                  )
                ],
              ),
            ),
            //post, hobbies form
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
                      _editUser["post"] = newValue;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Hobby Title"),
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        value!.isEmpty ? "Please provide contents" : null,
                    onSaved: (newValue) {
                      _editUser["hobby"] = newValue;
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
                      onPressed: () {},
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
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
