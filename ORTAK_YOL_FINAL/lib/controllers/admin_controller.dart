import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/driver_model.dart';
import '../models/payout_model.dart';
import '../models/ride_model.dart';

class AdminController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final RxList<Driver> drivers = <Driver>[].obs;
  final RxList<Payout> payouts = <Payout>[].obs;
  final RxList<Ride> rides = <Ride>[].obs;
  final RxList<Map<String, dynamic>> penalties = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedStatus = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDrivers();
    fetchPayouts();
    fetchPenalties();
    fetchRides();
  }

  Future<void> fetchDrivers() async {
    try {
      isLoading.value = true;
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('drivers')
          .orderBy('createdAt', descending: true)
          .get();

      drivers.value = snapshot.docs
          .map((doc) => Driver.fromFirestore(doc))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch drivers');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPayouts() async {
    try {
      isLoading.value = true;
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('payouts')
          .orderBy('createdAt', descending: true)
          .get();

      payouts.value = snapshot.docs
          .map((doc) => Payout.fromFirestore(doc))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch payouts');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateDriverStatus(String driverId, DriverStatus status) async {
    try {
      isLoading.value = true;
      
      await _firestore.collection('drivers').doc(driverId).update({
        'status': status.toString().split('.').last,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      Get.snackbar('Success', 'Driver status updated successfully');
      fetchDrivers();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update driver status');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePayoutStatus(String payoutId, PayoutStatus status) async {
    try {
      isLoading.value = true;
      
      Map<String, dynamic> updateData = {
        'status': status.toString().split('.').last,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (status == PayoutStatus.completed) {
        updateData['completedAt'] = DateTime.now().toIso8601String();
      }

      await _firestore.collection('payouts').doc(payoutId).update(updateData);

      Get.snackbar('Success', 'Payout status updated successfully');
      fetchPayouts();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update payout status');
    } finally {
      isLoading.value = false;
    }
  }

  List<Driver> get filteredDrivers {
    if (selectedStatus.value == 'all') return drivers;
    
    return drivers.where((driver) {
      return driver.status.toString().split('.').last == selectedStatus.value;
    }).toList();
  }

  List<Payout> get pendingPayouts {
    return payouts.where((payout) => payout.status == PayoutStatus.pending).toList();
  }

  int getDriversCountByStatus(DriverStatus status) {
    return drivers.where((driver) => driver.status == status).length;
  }

  double getTotalPayoutsByStatus(PayoutStatus status) {
    return payouts
        .where((payout) => payout.status == status)
        .fold(0.0, (total, payout) => total + payout.amount);
  }

  Future<void> fetchPenalties() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('penalties')
          .orderBy('createdAt', descending: true)
          .get();

      penalties.value = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      // Collection might not exist yet
    }
  }

  int get pendingPenaltiesCount {
    return penalties.where((p) => p['status'] == 'pending').length;
  }

  Future<void> fetchRides() async {
    try {
      isLoading.value = true;
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('rides')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      rides.value = snapshot.docs
          .map((doc) => Ride.fromFirestore(doc))
          .toList();
    } catch (e) {
      Get.snackbar('Hata', 'Yolculuklar yüklenemedi');
    } finally {
      isLoading.value = false;
    }
  }

  double get totalCommission {
    return rides
        .where((r) => r.status == RideStatus.completed)
        .fold(0.0, (sum, r) => sum + r.commission);
  }

  double get totalGrossRevenue {
    return rides
        .where((r) => r.status == RideStatus.completed)
        .fold(0.0, (sum, r) => sum + r.grossTotal);
  }

  Map<String, int> get segmentDistribution {
    Map<String, int> dist = {};
    for (var ride in rides.where((r) => r.status == RideStatus.completed)) {
      final label = ride.segmentLabel;
      dist[label] = (dist[label] ?? 0) + 1;
    }
    return dist;
  }
}
