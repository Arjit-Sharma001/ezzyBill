import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Firebase instances following naming conventions
final FirebaseAuth auth = FirebaseAuth.instance;
final FirebaseFirestore firestore = FirebaseFirestore.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
final FacebookAuth facebookAuth = FacebookAuth.instance;

// Firestore collection name constant
const String usersCollection = "users";

// Reactive user stream to track auth changes (better than static currentUser)
Stream<User?> get userStream => auth.authStateChanges();

// Safe getter for current user
User? get currentUser => auth.currentUser;
