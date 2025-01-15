import 'package:flutter/material.dart';
import '../models/movie.dart';
import './movie_details_screen.dart';
import '../services/tmdb_api_service.dart'; // Assuming you have the API service
import './FavoritesPage.dart';

class MovieSearchScreen extends StatefulWidget {
  final String query; // Passing query to search for movies

  const MovieSearchScreen({Key? key, required this.query}) : super(key: key);

  @override
  _MovieSearchScreenState createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends State<MovieSearchScreen> {
  List<Movie> _movies = []; // Your movie list from the API
  List<Movie> _favorites = []; // List to store favorites

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
    // Search for movies immediately when the screen is loaded using the provided query
    searchMovies(widget.query);
  }

  // Function to search movies using the TMDB API
  void searchMovies(String query) {
    TMDBApiService().searchMovies(query).then((movies) {
      setState(() {
        _movies = movies;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Search Movies: ${widget.query}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.favorite,
              color: Colors.white,
            ),
            onPressed: () {
              // Navigate to FavoritesPage and pass the favorites list
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesPage(favorites: _favorites),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Box with dark theme
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search for a movie...',
                hintStyle: TextStyle(color: Colors.white60),
                filled: true,
                fillColor: Color.fromARGB(255, 94, 94, 94),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (query) {
                // If the user is typing, trigger a search
                searchMovies(query);
              },
            ),
          ),
          Expanded(
            child: _movies.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  )
                : ListView.builder(
                    itemCount: _movies.length,
                    itemBuilder: (context, index) {
                      final movie = _movies[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              'https://image.tmdb.org/t/p/w342${movie.posterPath}',
                              width: 60,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey,
                                  width: 60,
                                  height: 90,
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                          title: Text(
                            movie.title,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            movie.releaseDate,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MovieDetailsScreen(
                                  movie: movie,
                                  addFavorite: addFavorite, // Pass the addFavorite function
                                  removeFavorite: removeFavorite, // Pass the removeFavorite function
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
