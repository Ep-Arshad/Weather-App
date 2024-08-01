part of 'weather_bloc_bloc.dart';

abstract class WeatherBlocEvent extends Equatable {
  const WeatherBlocEvent();

  @override
  List<Object> get props => [];
}

// ignore: must_be_immutable
class FetchWeather extends WeatherBlocEvent {
  Position position;
  FetchWeather(this.position);

  @override
  List<Object> get props => [position];
}
