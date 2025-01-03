import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
      List<String> clusteredTimings = TimeBasedClustering().getClusterMeans(timings);
      print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
      print(clusteredTimings);
      print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
      await _firestore.collection('busRoutes').doc(routeName).set({
        'routeName': routeName,
        'stops': stops,
        'timings': timings,
        'clusteredTimings': clusteredTimings,
        'Last Updated': FieldValue.serverTimestamp(),
      },
      // SetOptions()
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


class TimeBasedClustering {
  final DateFormat _timeFormat = DateFormat("hh:mm a"); // 12-hour format with AM/PM

  // Function to convert time string in "hh:mm a" format to minutes since midnight
  int _timeToMinutes(String time) {
    try {
      final DateTime parsedTime = _timeFormat.parse(time);
      // Convert the time to minutes since midnight
      return parsedTime.hour * 60 + parsedTime.minute;
    } catch (e) {
      print("Error parsing time: $e");
      return -1;
    }
  }

  // Function to convert minutes since midnight to time in "hh:mm a" format
  String _minutesToTime(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    final period = hour >= 12 ? "PM" : "AM";
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final displayMinute = minute < 10 ? "0$minute" : minute.toString();
    return "$displayHour:$displayMinute $period";
  }

  // Function to perform time-based clustering (group timings into intervals)
  List<List<String>> clusterTimings(List<String> timings) {
    List<List<String>> clusters = [];
    if (timings.isEmpty) {
      return clusters;
    }

    // Sort timings by their minutes since midnight
    timings.sort((a, b) => _timeToMinutes(a).compareTo(_timeToMinutes(b)));

    // Create clusters based on time difference threshold (e.g., 15 minutes)
    int clusterThreshold = 5; // Cluster timings within 5 minutes of each other
    List<String> currentCluster = [timings[0]];

    for (int i = 1; i < timings.length; i++) {
      int previousTime = _timeToMinutes(timings[i - 1]);
      int currentTime = _timeToMinutes(timings[i]);

      // If the difference is within the threshold, add to current cluster
      if (currentTime - previousTime <= clusterThreshold) {
        currentCluster.add(timings[i]);
      } else {
        // If difference exceeds threshold, start a new cluster
        clusters.add(currentCluster);
        currentCluster = [timings[i]];
      }
    }

    // Add the last cluster
    if (currentCluster.isNotEmpty) {
      clusters.add(currentCluster);
    }

    return clusters;
  }

  // Function to calculate the mean of a list of times
  String calculateClusterMean(List<String> cluster) {
    int totalMinutes = 0;

    // Sum the total minutes of each time in the cluster
    for (String time in cluster) {
      totalMinutes += _timeToMinutes(time);
    }

    // Calculate the mean minutes
    int meanMinutes = totalMinutes ~/ cluster.length;

    // Convert the mean minutes back to time format
    return _minutesToTime(meanMinutes);
  }

  // Function to return the list of average times for each cluster
  List<String> getClusterMeans(List<String> timings) {
    List<List<String>> clusters = clusterTimings(timings);
    List<String> clusterMeans = [];

    // For each cluster, calculate the mean and add it to the result list
    for (var cluster in clusters) {
      clusterMeans.add(calculateClusterMean(cluster));
    }

    return clusterMeans;
  }
}

