import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:task_management_flutter/core/network/network_info.dart';

part 'network_provider.g.dart';

@riverpod
Connectivity connectivity(Ref ref){
  return Connectivity();
}

@riverpod
NetworkInfo networkInfo(Ref ref){
  return NetworkInfoImpl(ref.watch(connectivityProvider));
}

@riverpod
Stream networkStatus(Ref ref){
  final networkInfo = ref.watch(networkInfoProvider);
  return networkInfo.onConnectivityChanged;
}