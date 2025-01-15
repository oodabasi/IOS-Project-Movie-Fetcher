import 'package:flutter/material.dart';
import '../models/movie.dart';
import './movie_details_screen.dart';
import '../services/tmdb_api_service.dart'; // Assuming you have the API service

class LatestMoviesScreen extends StatefulWidget {
  const LatestMoviesScreen({Key? key}) : super(key: key);

  @override
  _LatestMoviesScreenState createState() => _LatestMoviesScreenState();
}

class _LatestMoviesScreenState extends State<LatestMoviesScreen> {
  List<Movie> _movies = []; // Your movie list from the API

  List<Movie> _favorites = [];

  // Add a movie to favorites
  void addFavorite(Movie movie) {
    setState(() {
      if (!_favorites.contains(movie)) {
        _favorites.add(movie);
      }
    });
  }

  // Remove a movie from favorites
  void removeFavorite(Movie movie) {
    setState(() {
      _favorites.remove(movie);
    });
  }

  @override
  void initState() {
    super.initState();
    // Fetch latest movies from the API (replace with your API service)
    TMDBApiService().fetchLatestMovies().then((movies) {
      setState(() {
        _movies = movies;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Latest Movies'),
        backgroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: _movies.length,
        itemBuilder: (context, index) {
          final movie = _movies[index];
          return ListTile(
            contentPadding: const EdgeInsets.all(8.0),
            leading: Image.network(
              'https://image.tmdb.org/t/p/w342${movie.posterPath}',
              width: 60,
              height: 90,
              fit: BoxFit.cover,
            ),
            title: Text(
              movie.title,
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailsScreen(
                    movie: movie,
                    addFavorite: addFavorite,
                    removeFavorite: removeFavorite,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
