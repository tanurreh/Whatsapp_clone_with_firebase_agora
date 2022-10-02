
import 'package:cloud_firestore/cloud_firestore.dart';



class DatabaseServices {
    CollectionReference userCollection =
    FirebaseFirestore.instance.collection('Users');
    CollectionReference statusCollection =
    FirebaseFirestore.instance.collection('status');
    CollectionReference groupCollection =
    FirebaseFirestore.instance.collection('groups');
    CollectionReference callCollection =
    FirebaseFirestore.instance.collection('call');

}