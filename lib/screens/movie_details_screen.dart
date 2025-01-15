import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // For displaying rating stars
import 'package:url_launcher/url_launcher.dart'; // To open external links
import '../models/movie.dart';
import '../services/tmdb_api_service.dart';
import 'person_movies_screen.dart';

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;
  final Function addFavorite; // Function to add to favorites
  final Function removeFavorite; // Function to remove from favorites

  const MovieDetailsScreen({
    Key? key,
    required this.movie,
    required this.addFavorite,
    required this.removeFavorite,
  }) : super(key: key);

  @override
  _MovieDetailsScreenState createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final TMDBApiService _apiService = TMDBApiService();
  late Future<Map<String, dynamic>> _movieDetails;
  bool isFavorite = false;
  String? trailerUrl;

  @override
  void initState() {
    super.initState();
    _movieDetails = _apiService.fetchMovieDetails(widget.movie.id);
    _checkIfFavorite();
  }

  // Check if the movie is favorited
  Future<void> _checkIfFavorite() async {
    setState(() {
      isFavorite = widget.addFavorite == widget.addFavorite;
    });
  }

  // Toggle favorite status
  Future<void> _toggleFavorite() async {
    if (isFavorite) {
      widget.removeFavorite(widget.movie);
    } else {
      widget.addFavorite(widget.movie);
    }
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.movie.title),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: const Color.fromARGB(255, 28, 126, 255),
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _movieDetails,
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

          final movieDetails = snapshot.data!;
          final cast = movieDetails['credits']['cast'] ?? []; // Safe cast retrieval
          final backdropPath = movieDetails['backdrop_path'];
          final voteAverage = widget.movie.voteAverage;

          final videos = movieDetails['videos'];
          if (videos != null &&
              videos['results'] != null &&
              videos['results'].isNotEmpty) {
            trailerUrl = videos['results']
                .firstWhere(
                  (video) => video['type'] == 'Trailer',
                  orElse: () => null,
                )?['key'];
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Backdrop image
                  if (backdropPath != null)
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                              'https://image.tmdb.org/t/p/w1280$backdropPath'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    widget.movie.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Overview
                  Text(
                    widget.movie.overview,
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Rating stars
                  Row(
                    children: [
                      const Text(
                        'Rating: ',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      RatingBar.builder(
                        initialRating: voteAverage / 2, // Convert to 5-star scale
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 24,
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Watch Trailer button
                  if (trailerUrl != null)
                    GestureDetector(
                      onTap: () {
                        final youtubeUrl =
                            'https://www.youtube.com/watch?v=$trailerUrl';
                        _launchURL(youtubeUrl);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 28, 126, 255),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Watch Trailer',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Cast list
                  const Text(
                    'Cast',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (cast.isNotEmpty)
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: cast.length,
                        itemBuilder: (context, index) {
                          final actor = cast[index];
                          return GestureDetector(
                            onTap: () {
                              final actorId = actor['id']; // Get the actor's ID
                              final personName = actor['name']; // Get the actor's name
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PersonMoviesScreen(
                                    personId: actorId, // Pass the actorId
                                    personName: personName, // Pass the personName
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: actor['profile_path'] != null
                                        ? Image.network(
                                            'https://image.tmdb.org/t/p/w342${actor['profile_path']}',
                                            width: 80,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          )
                                        : const Icon(
                                            Icons.person,
                                            size: 80,
                                            color: Colors.white,
                                          ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    actor['name'] ?? 'Unknown',
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    const Text(
                      'No cast information available.',
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

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
