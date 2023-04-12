import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'helpers/dbhelper.dart';
import 'helpers/firebase_auth_helpers.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> updateKey = GlobalKey<FormState>();

  TextEditingController bookController = TextEditingController();
  TextEditingController authorController = TextEditingController();

  TextEditingController bookUpDateController = TextEditingController();
  TextEditingController authorUpDateController = TextEditingController();

  final ImagePicker imagePicker = ImagePicker();

  String? title;
  String? body;
  String? img;

  @override
  Widget build(BuildContext context) {
    User? data = ModalRoute.of(context)!.settings.arguments as User?;

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new),
            onPressed: () async {
              await FirebaseAuthHelper.firebaseAuthHelper.logOut();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ],
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const SizedBox(
              height: 70,
            ),
            const CircleAvatar(
              radius: 80,
            ),
            const Divider(
              indent: 20,
              endIndent: 20,
            ),
            (data != null) ? Text("Name: ${data.displayName}") : Container(),
            (data != null) ? Text("Email: ${data.email}") : Container(),
          ],
        ),
      ),
      body: Center(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("books").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text("ERROR: ${snapshot.error}"),
              );
            } else if (snapshot.hasData) {
              QuerySnapshot<Map<String, dynamic>> data =
              snapshot.data as QuerySnapshot<Map<String, dynamic>>;

              List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs =
                  data.docs;

              return ListView.builder(
                itemCount: allDocs.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      height: 250,
                      child: Card(
                        color: Colors
                            .accents[Random().nextInt(Colors.accents.length)],
                        elevation: 3,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Image(
                                image: MemoryImage(base64Decode(
                                    allDocs[i].data()['image'] as String)),
                                width: w * 0.33,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  height: 100,
                                  width: 200,
                                  child: Text(
                                    "${allDocs[i].data()['title']}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  "${allDocs[i].data()['body']}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text("Update Notes"),
                                            content: SizedBox(
                                              height: 300,
                                              width: 250,
                                              child: Form(
                                                key: updateKey,
                                                child: Column(
                                                  mainAxisSize:
                                                  MainAxisSize.min,
                                                  children: [
                                                    InkWell(
                                                      onTap: () async {
                                                        XFile? xFile =
                                                        await imagePicker.pickImage(
                                                            source:
                                                            ImageSource
                                                                .gallery,
                                                            imageQuality:
                                                            20);

                                                        Uint8List bytes =
                                                        await xFile!
                                                            .readAsBytes();

                                                        img =
                                                            base64Encode(bytes);

                                                        print(
                                                            "=========================");
                                                        print(img);
                                                        print(
                                                            "=========================");
                                                      },
                                                      child: CircleAvatar(
                                                        backgroundImage: (img !=
                                                            null)
                                                            ? MemoryImage(img
                                                        as Uint8List)
                                                            : null,
                                                        radius: 50,
                                                        child: Text(
                                                          (img != null)
                                                              ? ""
                                                              : "ADD",
                                                          style:
                                                          const TextStyle(
                                                            fontWeight:
                                                            FontWeight.bold,
                                                            fontSize: 25,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    TextFormField(
                                                      validator: (val) => (val!
                                                          .isEmpty)
                                                          ? "Enter title First..."
                                                          : null,
                                                      onSaved: (val) {
                                                        title = val;
                                                      },
                                                      controller:
                                                      bookUpDateController,
                                                      decoration: const InputDecoration(
                                                          border:
                                                          OutlineInputBorder(),
                                                          hintText:
                                                          "Enter title Here....",
                                                          labelText: "title"),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    TextFormField(
                                                      textInputAction:
                                                      TextInputAction.done,
                                                      validator: (val) => (val!
                                                          .isEmpty)
                                                          ? "Enter body First..."
                                                          : null,
                                                      onSaved: (val) {
                                                        body = val;
                                                      },
                                                      controller:
                                                      authorUpDateController,
                                                      decoration: const InputDecoration(
                                                          border:
                                                          OutlineInputBorder(),
                                                          hintText:
                                                          "Enter body Here....",
                                                          labelText: "body"),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            actions: [
                                              ElevatedButton(
                                                onPressed: () async {
                                                  if (updateKey.currentState!
                                                      .validate()) {
                                                    updateKey.currentState!
                                                        .save();
                                                  }

                                                  Map<String, dynamic> recode =
                                                  {
                                                    "title": title,
                                                    "body": body,
                                                    "image": img,
                                                  };

                                                  await FirebaseDBHelpers
                                                      .firebaseDBHelpers
                                                      .updateBook(
                                                      data: recode,
                                                      id: allDocs[i].id);

                                                  Navigator.of(context).pop();

                                                  setState(() {
                                                    bookUpDateController
                                                        .clear();
                                                    authorUpDateController
                                                        .clear();

                                                    title = null;
                                                    body = null;
                                                    img = null;
                                                  });

                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        "Notes update successfully...",
                                                      ),
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                    ),
                                                  );
                                                },
                                                child: const Text("update"),
                                              ),
                                              OutlinedButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text("Close"),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Not in stock'),
                                              content: const Text(
                                                  'This item is no longer available'),
                                              actions: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    FirebaseDBHelpers
                                                        .firebaseDBHelpers
                                                        .deleteBook(
                                                        id: allDocs[i].id);

                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("YES"),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("NO"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            return Container();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text("Add"),
        icon: const Icon(Icons.add),
        onPressed: () async {
          validete(context);
        },
      ),
    );
  }

  validete(context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Author Add"),
            content: SizedBox(
              height: 300,
              width: 250,
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        XFile? xFile = await imagePicker.pickImage(
                            source: ImageSource.gallery, imageQuality: 20);

                        Uint8List bytes = await xFile!.readAsBytes();

                        img = base64Encode(bytes);

                        print("=========================");
                        print(img);
                        print("=========================");
                      },
                      child: CircleAvatar(
                        backgroundImage: (img != null)
                            ? MemoryImage(img as Uint8List)
                            : null,
                        backgroundColor: Colors.grey,
                        radius: 50,
                        child: Text(
                          (img != null) ? "" : "ADD",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        validator: (val) {
                          if (val!.isEmpty) {
                            return "Enter The title...";
                          }
                          return null;
                        },
                        onSaved: (val) {
                          title = val;
                        },
                        controller: bookController,
                        decoration: const InputDecoration(
                          hintText: "Enter The title...",
                          label: Text("title"),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        validator: (val) {
                          if (val!.isEmpty) {
                            return "Enter The body...";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.name,
                        onSaved: (val) {
                          body = val;
                        },
                        controller: authorController,
                        decoration: const InputDecoration(
                          hintText: "Enter The Author Name ...",
                          label: Text("Author Name"),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                  }

                  Map<String, dynamic> recode = {
                    "title": title,
                    "body": body,
                    "image": img
                  };

                  await FirebaseDBHelpers.firebaseDBHelpers
                      .insertBook(data: recode);

                  setState(() {
                    Navigator.pop(context);

                    bookController.clear();
                    authorController.clear();

                    title = null;
                    body = null;
                    img = null;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Recode inserted successfully..."),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text("Insert"),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Close"),
              ),
            ],
          );
        });
  }
}