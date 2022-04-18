import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  final String userId;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Details Activity"),
      ),
      body: Container(
        margin: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 1,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                color: Colors.orange[300],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "Name",
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        "Age: ",
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                      Text(
                        "Profession: ",
                        style: TextStyle(color: Colors.grey[800]),
                      )
                    ],
                  ),
                ),
              ),
            ),
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
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          onPressed: () {},
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            onPressed: () {}),
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
                      border: Border.all(width: 3, color: Color(0xff263238)),
                      borderRadius: BorderRadius.circular(5)),
                  child: SizedBox(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
