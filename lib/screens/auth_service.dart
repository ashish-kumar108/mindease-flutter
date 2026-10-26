import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  //instance of firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //instance of google sign in
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
    // For web, we need to specify the client ID
    clientId: kIsWeb ? '707355438584-your-web-client-id.apps.googleusercontent.com' : null,
  ); 
 
  Future<User?> signWithGoogleAccount() async {
    try {
      developer.log('Starting Google Sign-In...');
      
      // Try silent sign-in first
      final GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
      
      // If silent sign-in fails, do interactive sign-in
      if (googleUser == null) {
        developer.log('Silent sign-in failed, attempting interactive sign-in...');
        try {
          final result = await _googleSignIn.signIn();
          if (result == null) {
            developer.log('User cancelled Google Sign-In');
            return null;
          }
          return await _signInWithGoogleUser(result);
        } on Exception catch (e) {
          developer.log('Interactive Google Sign-In failed: $e');
          throw GoogleSignInException(e.toString());
        }
      }
      
      return await _signInWithGoogleUser(googleUser);
    } on GoogleSignInException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      developer.log('Firebase Auth Error: ${e.code} - ${e.message}');
      throw GoogleSignInException('Firebase Error (${e.code}): ${e.message}');
    } catch (e) {
      developer.log('Google Sign-In Error: $e');
      throw GoogleSignInException('Sign-In Error: $e');
    }
  }
  
  Future<User?> _signInWithGoogleUser(GoogleSignInAccount googleUser) async {
    try {
      developer.log('Google user signed in: ${googleUser.email}');
      
      //obtain auth tokens from signed in google Account
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      developer.log('Google authentication obtained');
      
      if (googleAuth.idToken == null) {
        developer.log('Error: ID token is null');
        return null;
      }
      
      //create a creds for firebase using google auth tokens
      final OAuthCredential cred = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      
      //sign in to firebase with google credential
      final UserCredential userCred = await _auth.signInWithCredential(cred);
      
      developer.log('Firebase sign-in successful: ${userCred.user?.email}');
      
      return userCred.user;
    } catch (e) {
      developer.log('Error during Firebase sign-in: $e');
      return null;
    }
  } 
  //sign out method
  Future<void> signOut() async {
    try {
      developer.log('Signing out user...');
      //sign out from firebase
      await _auth.signOut();
      //sign out from google
      await _googleSignIn.signOut();
      developer.log('User signed out successfully');
    } catch (e) {
      developer.log('Sign out error: $e');
    }
  } 
}

// Custom exception for Google Sign-In errors
class GoogleSignInException implements Exception {
  final String message;
  GoogleSignInException(this.message);
  @override
  String toString() => message;
} 