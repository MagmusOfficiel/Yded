class UserYded {
  late String _email;
  final String _name;
  final int _energy;
  final Map<String, int> _stats;
  final String _specialisation;
  final int _level;
  final int _money;
  final int _percent;
  final int _points;
  final int _ultime;
  final String _role;
  final String _element;

  UserYded({
    required String email,
    required String name,
    required int energy,
    required Map<String, int> stats,
    required String specialisation,
    required int level,
    required int money,
    required int percent,
    required int points,
    required String element,
    required int ultime,
    required String role,
  })  : _email = email,
        _name = name,
        _energy = energy,
        _stats = stats,
        _specialisation = specialisation,
        _level = level,
        _money = money,
        _percent = percent,
        _points = points,
        _ultime = ultime,
        _element = element,
        _role = role;

  String get email => _email;
  String get name => _name;
  int get energy => _energy;
  Map<String, int> get stats => _stats;
  String get specialisation => _specialisation;
  int get level => _level;
  String get element => _element;
  int get money => _money;
  int get percent => _percent;
  int get points => _points;
  int get ultime => _ultime;
  String get role => _role;

  set setEmail(String email) => _email = email;

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'energy': energy,
      'stats': stats,
      'specialisation': specialisation,
      'level': level,
      'money': money,
      'percent': percent,
      'points': points,
      'ultime': ultime,
      'role': role,
      'element': element,
    };
  }
}