// models/planning.dart
class Planning {
  int? id;
  String nomCoach;
  String nomClient;
  String salle;
  String typeSeance;
  String heureDebut;
  String heureFin;
  DateTime dateSeance; // Ajout de la date
  String? description;

  Planning({
    this.id,
    required this.nomCoach,
    required this.nomClient,
    required this.salle,
    required this.typeSeance,
    required this.heureDebut,
    required this.heureFin,
    required this.dateSeance, // Nouveau champ
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomCoach': nomCoach,
      'nomClient': nomClient,
      'salle': salle,
      'typeSeance': typeSeance,
      'heureDebut': heureDebut,
      'heureFin': heureFin,
      'dateSeance': dateSeance.toIso8601String(), // Conversion en String
      'description': description,
    };
  }

  factory Planning.fromMap(Map<String, dynamic> map) {
    return Planning(
      id: map['id'],
      nomCoach: map['nomCoach'],
      nomClient: map['nomClient'],
      salle: map['salle'],
      typeSeance: map['typeSeance'],
      heureDebut: map['heureDebut'],
      heureFin: map['heureFin'],
      dateSeance: DateTime.parse(map['dateSeance']), // Parsing de la date
      description: map['description'],
    );
  }

  // Méthode pour obtenir l'heure de début en DateTime
  DateTime get startDateTime {
    final timeParts = heureDebut.split(':');
    return DateTime(
      dateSeance.year,
      dateSeance.month,
      dateSeance.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }

  // Méthode pour obtenir l'heure de fin en DateTime
  DateTime get endDateTime {
    final timeParts = heureFin.split(':');
    return DateTime(
      dateSeance.year,
      dateSeance.month,
      dateSeance.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }
}