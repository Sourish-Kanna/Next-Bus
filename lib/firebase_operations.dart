import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() {
    return _instance;
  }

  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// **Logs user activities in the "logs" collection**
  Future<void> _logActivity(String action, String userId, String details) async {
    await _firestore.collection('activityLogs').add({
      'action': action,
      'userId': userId,
      'details': details,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// **Add a new bus route (Atomic)**
  Future<void> addRoute(String routeName, List<String> stops, List<String> timings, String userId) async {
    return _firestore.runTransaction((transaction) async {
      final routeRef = _firestore.collection('busRoutes').doc(routeName);
      final routeDoc = await transaction.get(routeRef);

      if (routeDoc.exists) {
        // Get existing data and check if it's the same
        List<String> existingStops = List<String>.from(routeDoc.data()?['stops'] ?? []);
        List<Map<String, String>> existingTimings = List<Map<String, String>>.from(routeDoc.data()?['timings'] ?? []);

        List<Map<String, String>> newTimingObjects = timings.map((time) => {'time': time, 'addedBy': userId}).toList();

        if (existingStops == stops && existingTimings == newTimingObjects) {
          return; // 🔥 No changes, skip update
        }
      }

      transaction.set(routeRef, {
        'routeName': routeName,
        'stops': stops,
        'timings': timings.map((time) => {'time': time, 'addedBy': userId}).toList(),
        'updatedBy': userId,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      for (String stop in stops) {
        final stopRef = _firestore.collection('busStops').doc(stop);
        final stopDoc = await transaction.get(stopRef);

        if (!stopDoc.exists) {
          transaction.set(stopRef, {'stopName': stop, 'routes': [routeName]});
        } else {
          transaction.update(stopRef, {'routes': FieldValue.arrayUnion([routeName])});
        }
      }

      // await _logActivity(transaction, "Added Route", userId, "Route: $routeName with stops: ${stops.join(', ')}");
    }).then((_) async {
      await _logActivity("Added Route", userId, "Route: $routeName with stops: ${stops.join(', ')}");
    });
  }

  /// **Remove a bus route (Atomic)**
  Future<void> removeRoute(String routeName, String userId) async {
    return _firestore.runTransaction((transaction) async {
      final routeRef = _firestore.collection('busRoutes').doc(routeName);
      final routeDoc = await transaction.get(routeRef);

      if (!routeDoc.exists) return;

      transaction.delete(routeRef);

      List<String> stops = List<String>.from(routeDoc.data()?['stops'] ?? []);
      for (String stop in stops) {
        final stopRef = _firestore.collection('busStops').doc(stop);
        transaction.update(stopRef, {'routes': FieldValue.arrayRemove([routeName])});
      }

    }).then((_) async {
      await _logActivity("Removed Route", userId, "Route: $routeName deleted");
    });
  }

  /// **Add a new bus timing (Atomic)**
  Future<void> addBusTiming(String routeName, String time, String userId) async {
    return _firestore.runTransaction((transaction) async {
      final routeRef = _firestore.collection('busRoutes').doc(routeName);
      final routeDoc = await transaction.get(routeRef);

      if (!routeDoc.exists) return;

      List<Map<String, String>> timings = List<Map<String, String>>.from(routeDoc.data()?['timings'] ?? []);

      if (timings.any((entry) => entry['time'] == time)) {
        return; // 🔥 No changes, skip update
      }

      timings.add({'time': time, 'addedBy': userId});

      transaction.update(routeRef, {
        'timings': timings,
        'updatedBy': userId,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

    }).then((_) async {
      await _logActivity("Added Bus Timing", userId, "Added $time to route: $routeName");
    });
  }

  /// **Delete a bus timing (Atomic)**
  Future<void> deleteBusTiming(String routeName, String time, String userId) async {
    return _firestore.runTransaction((transaction) async {
      final routeRef = _firestore.collection('busRoutes').doc(routeName);
      final routeDoc = await transaction.get(routeRef);

      if (!routeDoc.exists) return;

      List<Map<String, String>> timings = List<Map<String, String>>.from(routeDoc.data()?['timings'] ?? []);

      if (!timings.any((entry) => entry['time'] == time)) {
        return; // 🔥 No changes, skip update
      }

      timings.removeWhere((entry) => entry['time'] == time);

      transaction.update(routeRef, {
        'timings': timings,
        'updatedBy': userId,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

    }).then((_) async {
      await _logActivity("Deleted Bus Timing", userId, "Removed $time from route: $routeName");
    });
  }

  /// **Update a bus timing (Atomic)**
  Future<void> updateBusTiming(String routeName, String oldTime, String newTime, String userId) async {
    return _firestore.runTransaction((transaction) async {
      final routeRef = _firestore.collection('busRoutes').doc(routeName);
      final routeDoc = await transaction.get(routeRef);

      if (!routeDoc.exists) return;

      List<Map<String, String>> timings = List<Map<String, String>>.from(routeDoc.data()?['timings'] ?? []);

      int index = timings.indexWhere((timing) => timing['time'] == oldTime);
      if (index == -1 || timings[index]['time'] == newTime) {
        return; // 🔥 No changes, skip update
      }

      timings[index]['time'] = newTime;
      timings[index]['addedBy'] = userId;

      transaction.update(routeRef, {
        'timings': timings,
        'updatedBy': userId,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

    }).then((_) async {
      await _logActivity("Updated Bus Timing", userId, "Changed $oldTime to $newTime on route: $routeName");
    });
  }

  /// **Get all bus timings for a route**
  Future<List<String>> getBusTimings(String routeName) async {
    try {
      final routeDoc = await _firestore.collection('busRoutes').doc(routeName).get();
      if (!routeDoc.exists) return [];

      List<dynamic> timings = routeDoc.data()?['timings'] ?? [];
      return timings.map((entry) => (entry as Map<String, dynamic>)['time'] as String).toList();
    } catch (e) {
      debugPrint("Error fetching bus timings: $e");
      return [];
    }
  }
}
