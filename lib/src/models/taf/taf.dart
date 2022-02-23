part of models;

/// Parser for TAF reports.
class Taf extends Report with ModifierMixin {
  late final String _body;
  final List<String> _weatherChanges = <String>[];
  late MetarTime _time;
  int? _year, _month;

  Taf(String code, {int? year, int? month, bool truncate = false})
      : super(code, truncate, type: 'TAF') {
    _year = year;
    _month = month;

    _handleSections();

    // Parse the body groups.
    _parseBody();
  }

  /// Get the body part of the TAF.
  String get body => _body;

  /// Get the weather changes of the TAF.
  String get weatherChanges {
    if (_weatherChanges.isNotEmpty) {
      return _weatherChanges.join(' ');
    }

    return '';
  }

  @override
  void _handleTime(String group) {
    final match = MetarRegExp.TIME.firstMatch(group);
    _time = MetarTime(group, match, year: _year, month: _month);

    _concatenateString(_time);
  }

  /// Get the time of the TAF.
  MetarTime get time => _time;

  /// Parse the body section.
  void _parseBody() {
    final handlers = <GroupHandler>[
      GroupHandler(MetarRegExp.TYPE, _handleType),
      GroupHandler(MetarRegExp.MODIFIER, _handleModifier),
      GroupHandler(MetarRegExp.STATION, _handleStation),
      GroupHandler(MetarRegExp.TIME, _handleTime),
    ];

    final unparsed = parseSection(handlers, _body);
    _unparsedGroups.addAll(unparsed);
  }

  @override
  void _handleSections() {
    final keywords = <String>['FM', 'TEMPO', 'BECMG', 'PROB'];
    final sections = splitSentence(
      _rawCode,
      keywords,
      space: 'left',
      all: true,
    );

    _body = sections[0];
    if (sections.length > 1) {
      _weatherChanges.addAll(sections.sublist(1));
    }

    _sections.add(_body);
    _sections.add(_weatherChanges.join(' '));
  }
}
