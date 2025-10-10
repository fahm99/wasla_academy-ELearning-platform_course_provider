import 'package:equatable/equatable.dart';

abstract class NavigationState extends Equatable {
  const NavigationState();

  @override
  List<Object?> get props => [];
}

class NavigationLoaded extends NavigationState {
  final int currentTabIndex;

  const NavigationLoaded({
    required this.currentTabIndex,
  });

  @override
  List<Object?> get props => [currentTabIndex];
}
