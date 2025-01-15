
class Movie {
  final int id;
  final String title;
  final String posterPath;
  final String overview;
  final String releaseDate;
  final int budget;
  final int runtime;
  final List<int> genreIds; // Genre IDs
  final List<String> cast;
  final double voteAverage; // Vote average

  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.overview,
    required this.releaseDate,
    required this.budget,
    required this.runtime,
    required this.genreIds,
    required this.cast,
    required this.voteAverage,
  });

  // Computed property to get genres as a comma-separated string
  String get genres => genreIds.map(getGenreFromId).join(', ');

  // Factory constructor to create a Movie from a JSON map
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      posterPath: json['poster_path'] ?? '',
      overview: json['overview'] ?? '',
      releaseDate: json['release_date'] ?? '',
      budget: json['budget'] ?? 0,
      runtime: json['runtime'] ?? 0,
      genreIds: (json['genre_ids'] != null)
          ? List<int>.from(json['genre_ids'])
          : [],
      cast: (json['cast'] != null)
          ? List<String>.from(json['cast'])
          : [],
      voteAverage: (json['vote_average'] != null)
          ? json['vote_average'].toDouble()
          : 0.0,
    );
  }

  // Method to convert a Movie object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster_path': posterPath,
      'overview': overview,
      'release_date': releaseDate,
      'budget': budget,
      'runtime': runtime,
      'genre_ids': genreIds,
      'cast': cast,
      'vote_average': voteAverage,
    };
  }
}

// Genre mapping
Map<int, String> genreMap = {
  28: 'Action',
  12: 'Adventure',
  16: 'Animation',
  35: 'Comedy',
  80: 'Crime',
  99: 'Documentary',
  18: 'Drama',
  10751: 'Family',
  14: 'Fantasy',
  36: 'History',
  27: 'Horror',
  10402: 'Music',
  9648: 'Mystery',
  10749: 'Romance',
  878: 'Science Fiction',
  10770: 'TV Movie',
  53: 'Thriller',
  10752: 'War',
  37: 'Western',
};

// Helper function to get genre names from IDs
String getGenreFromId(int genreId) {
  return genreMap[genreId] ?? 'Unknown';
}
