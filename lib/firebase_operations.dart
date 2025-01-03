import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() {
    return _instance;
  }

  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add a new route to Firestore and update the related stops.
  Future<void> addRoute(String routeName, List<String> stops,
      List<String> timings) async {
    try {
      await _firestore.collection('busRoutes').doc(routeName).set({
        'routeName': routeName,
        'stops': stops,
        'timings': timings,
        'clusteredTimings': [],
        'Last Updated': FieldValue.serverTimestamp(),
      },
      SetOptions()
      );

      // Update each stop to include this route
      for (String stop in stops) {
        final stopRef = _firestore.collection('busStops').doc(stop);

        // Check if the stop document exists, create it if not
        final stopDoc = await stopRef.get();
        if (!stopDoc.exists) {
          await stopRef.set({
            'stopName': stop,
            'routes': [routeName],
          });
        } else {
          // Add routeName to the existing 'routes' array
          await stopRef.update({
            'routes': FieldValue.arrayUnion([routeName]),
          });
        }
      }
      print("Route added successfully!");
    } catch (e) {
      print("Error adding route: $e");
    }
  }

  /// Remove a route from Firestore and update the related stops.
  Future<void> removeRoute(String routeName) async {
    try {
      // Get the route document to retrieve the associated stops
      final routeDoc = await _firestore.collection('busRoutes').doc(routeName).get();
      if (!routeDoc.exists) {
        print("Route not found!");
        return;
      }

      List<String> stops = List<String>.from(routeDoc.data()?['stops'] ?? []);
      // Remove the route from the busRoutes collection
      await _firestore.collection('busRoutes').doc(routeName).delete();

      // Remove the routeName from each stop's 'routes' array
      for (String stop in stops) {
        await _firestore.collection('busStops').doc(stop).update({
          'routes': FieldValue.arrayRemove([routeName]),
        });
      }
      print("Route removed successfully!");
    } catch (e) {
      print("Error removing route: $e");
    }
  }

  /// Get all routes passing through a specific stop.
  Future<List<Map<String, dynamic>>> getRoutesByStop(String stopName) async {
    try {
      // Get the stop document
      final stopDoc = await _firestore.collection('busStops').doc(stopName).get();
      if (!stopDoc.exists) {
        print("Stop not found!");
        return [];
      }

      // Get route IDs from the stop document
      List<String> routeIds = List<String>.from(stopDoc.data()?['routes'] ?? []);

      // Fetch the route details from busRoutes collection
      final routeDocs = await Future.wait(routeIds.map((id) =>
          _firestore.collection('busRoutes').doc(id).get()));

      return routeDocs.map((doc) => doc.data()!).toList();
    } catch (e) {
      print("Error fetching routes by stop: $e");
      return [];
    }
  }

  /// Get all stops for a specific route.
  Future<List<Map<String, dynamic>>> getStopsByRoute(String routeName) async {
    try {
      // Get the route document
      final routeDoc = await _firestore.collection('busRoutes').doc(routeName).get();
      if (!routeDoc.exists) {
        print("Route not found!");
        return [];
      }

      // Get stop names from the route document
      List<String> stopNames = List<String>.from(routeDoc.data()?['stops'] ?? []);

      // Fetch the stop details from busStops collection
      final stopDocs = await Future.wait(stopNames.map((name) =>
          _firestore.collection('busStops').doc(name).get()));

      return stopDocs.map((doc) => doc.data()!).toList();
    } catch (e) {
      print("Error fetching stops by route: $e");
      return [];
    }
  }

  /// Update clustered timings for a specific route.
  Future<void> updateClusteredTimings(String routeName, List<String> clusteredTimings) async {
    try {
      // Update the route document
      await _firestore.collection('busRoutes').doc(routeName).update({
        'clusteredTimings': clusteredTimings,
      });
      print("Clustered timings updated for $routeName");
    } catch (e) {
      print("Error updating clustered timings: $e");
    }
  }

  /// Add a new bus timing to a specific route.
  Future<void> addBusTiming(String routeName, String time, String addedBy) async {
    try {
      // Add new bus timing to the busTimings subcollection under a route
      await _firestore.collection('busRoutes').doc(routeName).collection('busTimings').add({
        'time': time,
        'addedBy': addedBy,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("Bus timing added successfully!");
    } catch (e) {
      print("Error adding bus timing: $e");
    }
  }

  /// Get all bus timings for a specific route.
  Future<List<Map<String, dynamic>>> getBusTimings(String routeName) async {
    try {
      final busTimingsSnapshot = await _firestore
          .collection('busRoutes')
          .doc(routeName)
          .collection('busTimings')
          .get();

      return busTimingsSnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error fetching bus timings: $e");
      return [];
    }
  }
}
