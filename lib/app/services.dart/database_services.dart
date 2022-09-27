
import 'package:cloud_firestore/cloud_firestore.dart';



class DatabaseServices {
    CollectionReference userCollection =
    FirebaseFirestore.instance.collection('Users');


}