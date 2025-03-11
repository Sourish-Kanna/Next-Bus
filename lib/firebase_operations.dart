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
  Future<void> _logActivity(String action, String userId, String description) async {
    final logRef = _firestore.collection('activityLogs').doc("$action by $userId");
    await logRef.set({
      'action': action,
      'userId': userId,
      'description': description,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// **Add a new bus route (Atomic)**
  Future<void> addRoute(String routeName, List<String> stops, List<String> timings, String userId) async {
    final routeRef = _firestore.collection('busRoutes').doc(routeName);
    final stopRefs = stops.map((stop) => _firestore.collection('busStops').doc(stop)).toList();

    // **Read all documents BEFORE transaction**
    final routeDoc = await routeRef.get();
    final stopDocs = await Future.wait(stopRefs.map((ref) => ref.get()));

    return _firestore.runTransaction((transaction) async {
      List<Map<String, String>> newTimingObjects =
      timings.map((time) => {'time': time, 'addedBy': userId}).toList();

      // **Fix: Handle dynamic types properly**
      if (routeDoc.exists) {
        List<String> existingStops = List<String>.from(routeDoc.data()?['stops'] ?? []);

        List<Map<String, dynamic>> existingTimingsDynamic =
        List<Map<String, dynamic>>.from(routeDoc.data()?['timings'] ?? []);

        List<Map<String, String>> existingTimings = existingTimingsDynamic
            .map((timing) => {
          'time': timing['time'] as String? ?? '',
          'addedBy': timing['addedBy'] as String? ?? '',
        })
            .toList();

        if (existingStops == stops && existingTimings == newTimingObjects) {
          return; // 🔥 No changes, skip update
        }
      }

      // **Write new route data**
      transaction.set(
        routeRef,
        {
          'routeName': routeName,
          'stops': stops,
          'timings': newTimingObjects,
          'updatedBy': userId,
          'lastUpdated': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // **Write stop data**
      for (int i = 0; i < stops.length; i++) {
        final stopRef = stopRefs[i];
        final stopDoc = stopDocs[i];

        if (!stopDoc.exists) {
          transaction.set(stopRef, {'stopName': stops[i], 'routes': [routeName]});
        } else {
          transaction.update(stopRef, {'routes': FieldValue.arrayUnion([routeName])});
        }
      }
    }).then((_) async {
      // ✅ Logging after transaction completes
      await _logActivity("Added Route $routeName", userId, "Route: $routeName with stops: ${stops.join(', ')}");
    }).catchError((error) {
      // ❌ Handle errors properly
      debugPrint("Failed to add route: $error");
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
      await _logActivity("Removed Route $routeName", userId, "Route: $routeName deleted");
    }).catchError((error) {
      // ❌ Handle errors properly
      debugPrint("Failed to remove route: $error");
    });
  }

  /// **Add a new bus timing (Atomic)**
  Future<void> addBusTiming(String routeName, String time, String userId) async {
    return _firestore.runTransaction((transaction) async {
      final routeRef = _firestore.collection('busRoutes').doc(routeName);
      final routeDoc = await transaction.get(routeRef);

      if (!routeDoc.exists) return;

      List<Map<String, dynamic>> timings = List<Map<String, dynamic>>.from(routeDoc.data()?['timings'] ?? []);

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
      await _logActivity("Added Bus Timing for $routeName", userId, "Added $time to route: $routeName");
    }).catchError((error) {
      // ❌ Handle errors properly
      debugPrint("Failed to add time: $error");
    });
  }

  /// **Delete a bus timing (Atomic)**
  Future<void> deleteBusTiming(String routeName, String time, String userId) async {
    return _firestore.runTransaction((transaction) async {
      final routeRef = _firestore.collection('busRoutes').doc(routeName);
      final routeDoc = await transaction.get(routeRef);

      if (!routeDoc.exists) return;

      List<Map<String, dynamic>> timings = List<Map<String, dynamic>>.from(routeDoc.data()?['timings'] ?? []);

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
      await _logActivity("Deleted Bus Timing for $routeName", userId, "Removed $time from route: $routeName");
    }).catchError((error) {
      // ❌ Handle errors properly
      debugPrint("Failed to remove time: $error");
    });
  }

  /// **Update a bus timing (Atomic)**
  Future<void> updateBusTiming(String routeName, String oldTime, String newTime, String userId) async {
    return _firestore.runTransaction((transaction) async {
      final routeRef = _firestore.collection('busRoutes').doc(routeName);
      final routeDoc = await transaction.get(routeRef);

      if (!routeDoc.exists) return;

      List<Map<String, dynamic>> timings = List<Map<String, dynamic>>.from(routeDoc.data()?['timings'] ?? []);

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
      await _logActivity("Updated Bus Timing for $routeName", userId, "Changed $oldTime to $newTime on route: $routeName");
    }).catchError((error) {
      // ❌ Handle errors properly
      debugPrint("Failed to update time: $error");
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
