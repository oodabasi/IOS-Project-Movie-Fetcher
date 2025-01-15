// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:qqq/services/tmdb_api_service.dart'; // Adjust to your path
import 'package:qqq/models/movie.dart'; // Make sure you import the Movie model

class PersonMoviesScreen extends StatefulWidget {
  final int personId;
  final String personName;

  const PersonMoviesScreen({
    Key? key,
    required this.personId,
    required this.personName,
  }) : super(key: key);

  @override
  _PersonMoviesScreenState createState() => _PersonMoviesScreenState();
}

class _PersonMoviesScreenState extends State<PersonMoviesScreen> {
  final TMDBApiService _apiService = TMDBApiService();
  late Future<List<Movie>> _personMovies; // Change to Future<List<Movie>>

  @override
  void initState() {
    super.initState();
    _personMovies = _apiService.fetchPersonMovies(widget.personId); // Correct API call
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.personName),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Movie>>( // Adjust the type here to List<Movie>
        future: _personMovies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final personMovies = snapshot.data ?? []; // Handle the case where there is no data

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Movies by this Actor',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (personMovies.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true, // Prevent overflow by limiting the list's height
                      physics: NeverScrollableScrollPhysics(), // Disable scroll inside the child list
                      itemCount: personMovies.length,
                      itemBuilder: (context, index) {
                        final movie = personMovies[index];
                        final posterPath = movie.posterPath;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                          leading: posterPath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    'https://image.tmdb.org/t/p/w342$posterPath',
                                    width: 80,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.image_not_supported,
                                        size: 80,
                                        color: Colors.white,
                                      );
                                    },
                                  ),
                                )
                              : const Icon(
                                  Icons.movie,
                                  size: 80,
                                  color: Colors.white,
                                ),

                          title: Text(
                            movie.title, // Movie title
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            movie.releaseDate, // 'Unknown Release Date',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          onTap: () {
                            // Handle movie tap if necessary
                          },
                        );
                      },
                    )
                  else
                    const Text(
                      'No movies found for this actor.',
                      style: TextStyle(color: Colors.white70),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
