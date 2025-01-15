import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../models/movie.dart';


class TMDBApiService {
  static const String apiKey = '20d5092a928c73f98b8e8e3d8dbb4d1e';
  static const String baseUrl = 'https://api.themoviedb.org/3';

  // Fetch latest movies
  Future<List<Movie>> fetchLatestMovies() async {
    try {
      final response = await http.get(Uri.parse(
          '$baseUrl/movie/now_playing?api_key=$apiKey&page=1'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Movie> movies = (data['results'] as List)
            .map((movieJson) => Movie.fromJson(movieJson))
            .toList();
        return movies;
      } else {
        print("Failed to fetch data: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  // Fetch top-rated movies
  Future<List<Movie>> fetchTopMovies() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/movie/top_rated?api_key=$apiKey'));
      if (response.statusCode == 200) {
        final List<dynamic> results = jsonDecode(response.body)['results'];
        return results.map((movie) => Movie.fromJson(movie)).toList();
      } else {
        throw Exception('Failed to load top movies');
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  // Search movies by query
  Future<List<Movie>> searchMovies(String query) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/search/movie?api_key=$apiKey&query=$query'));
      if (response.statusCode == 200) {
        final List<dynamic> results = jsonDecode(response.body)['results'];
        return results.map((movie) => Movie.fromJson(movie)).toList();
      } else {
        throw Exception('Failed to search movies');
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  // Fetch movie details, including cast and videos
  Future<Map<String, dynamic>> fetchMovieDetails(int movieId) async {
    try {
      final response = await http.get(Uri.parse(
          '$baseUrl/movie/$movieId?api_key=$apiKey&append_to_response=credits,videos'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch movie details');
      }
    } catch (e) {
      print("Error: $e");
      return {};
    }
  }

  // Fetch movies of a specific person
  Future<List<Movie>> fetchPersonMovies(int personId) async {
    try {
      final response = await http.get(Uri.parse(
          '$baseUrl/person/$personId/movie_credits?api_key=$apiKey'));
      if (response.statusCode == 200) {
        final List<dynamic> results = jsonDecode(response.body)['cast'];
        return results.map((movie) => Movie.fromJson(movie)).toList();
      } else {
        throw Exception('Failed to fetch person movies');
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  // Launch URL utility function
  Future<void> launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

