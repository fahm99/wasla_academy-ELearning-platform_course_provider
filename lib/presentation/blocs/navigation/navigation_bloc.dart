import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_event.dart';
import 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationLoaded(currentTabIndex: 0)) {
    on<NavigationTabChanged>(_onTabChanged);
  }

  void _onTabChanged(
    NavigationTabChanged event,
    Emitter<NavigationState> emit,
  ) {
    emit(NavigationLoaded(currentTabIndex: event.index));
  }
}
