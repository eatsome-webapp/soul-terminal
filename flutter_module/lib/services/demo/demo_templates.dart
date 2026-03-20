/// Pre-loaded response templates for demo mode.
///
/// These templates provide strategic analysis without an API key,
/// using placeholder substitution from user input keywords.
class DemoTemplates {
  /// SOUL's opening message (pre-loaded, no API call)
  static const String openingMessage =
      'Hey. Vertel me over je project — wat bouw je, en waarom?';

  /// Interaction 1: User describes project -> strategic analysis
  static const String strategicAnalysis = '''
## {{project_name}} — Eerste Analyse

### Marktpositie
Je bouwt in de **{{domain}}** ruimte. Dat betekent dat je concurreert met gevestigde spelers, maar ook dat er bewezen vraag is. De sleutel is differentiatie — niet beter, maar anders.

### Top 3 Risico's
1. **Markt-timing** — Te vroeg is even dodelijk als te laat. Valideer of je doelgroep *nu* actief naar een oplossing zoekt.
2. **Technische complexiteit** — Elke feature die je toevoegt verdubbelt je onderhoudslast. Houd het meedogenloos simpel.
3. **Gebruikersadoptie** — Bouwen is het makkelijke deel. De eerste 50 users overtuigen is waar het echte werk begint.

### MVP Scope Voorstel
Focus op deze 3 kernfuncties:
1. De ene feature die je product *uniek* maakt
2. Onboarding die in onder 2 minuten waarde levert
3. Feedback-loop zodat je van je eerste users leert

### Eerste 3 Milestones
1. **Week 1-2:** Werkend prototype van je kernfunctie
2. **Week 3-4:** Gebruikerstest met 5 echte mensen
3. **Week 5-6:** Launch MVP naar eerste 50 users
''';

  /// Interaction 2: Follow-up -> technical risk breakdown
  static const String technicalRisks = '''
## Technische Risico Analyse — {{project_name}}

### Stack Evaluatie
Je huidige aanpak ziet er solide uit voor een MVP. Maar let op deze valkuilen:

- **Over-engineering** — Gebruik geen microservices voor iets dat een monoliet aankan
- **Premature optimization** — Maak het eerst werkend, dan snel, dan schaalbaar
- **Dependency bloat** — Elke library die je toevoegt is een toekomstige security-update

### Ongeteste Aannames
1. Je doelgroep wil dit *genoeg* om ervoor te betalen
2. Je technische architectuur schaalt naar 10x je huidige plan
3. Je kunt dit onderhouden naast je andere verplichtingen

### Aanbeveling
Begin met de riskantste aanname. Valideer die EERST, bouw daarna pas verder. De meeste startups falen niet door slechte techniek — ze falen door iets te bouwen dat niemand wil.
''';

  /// Interaction 3: Next steps -> concrete milestone plan
  static const String milestonePlan = '''
## Actieplan — {{project_name}}

### Deze Week
- [ ] Definieer je "done" criteria voor de MVP — wat moet er werken?
- [ ] Identificeer 5 potentiële early adopters en neem contact op
- [ ] Zet je development environment op en maak je eerste commit

### Eerste Milestone: Werkend Prototype
**Deadline:** 2 weken
**Doel:** Een werkende versie die je aan iemand kunt laten zien
**Klaar wanneer:** Een niet-technisch persoon kan de kernflow voltooien zonder hulp

---

*Dit was je gratis preview. Verbind je API key voor de volledige SOUL-ervaring — dan word ik je echte co-founder.*
''';

  /// Extract keywords from user input to fill template placeholders.
  ///
  /// Returns a map of placeholder name -> extracted value.
  static Map<String, String> extractKeywords(String userInput) {
    final keywords = <String, String>{};

    // Extract project name: first quoted phrase, or first capitalized word, or first 3 words
    final quotedMatch = RegExp(r'"([^"]+)"').firstMatch(userInput);
    if (quotedMatch != null) {
      keywords['project_name'] = quotedMatch.group(1)!;
    } else {
      final capitalizedMatch =
          RegExp(r'\b([A-Z][a-zA-Z0-9]+)\b').firstMatch(userInput);
      if (capitalizedMatch != null) {
        keywords['project_name'] = capitalizedMatch.group(1)!;
      } else {
        final words = userInput.split(RegExp(r'\s+')).take(3).join(' ');
        keywords['project_name'] = words.isNotEmpty ? words : 'Jouw Project';
      }
    }

    // Extract domain based on keyword presence
    final lower = userInput.toLowerCase();
    if (lower.contains('ai') || lower.contains('machine learning') || lower.contains('llm')) {
      keywords['domain'] = 'AI/ML';
    } else if (lower.contains('saas') || lower.contains('platform')) {
      keywords['domain'] = 'SaaS';
    } else if (lower.contains('mobile') || lower.contains('app')) {
      keywords['domain'] = 'mobile app';
    } else if (lower.contains('web') || lower.contains('website')) {
      keywords['domain'] = 'web';
    } else if (lower.contains('game') || lower.contains('gaming')) {
      keywords['domain'] = 'gaming';
    } else if (lower.contains('e-commerce') || lower.contains('shop') || lower.contains('winkel')) {
      keywords['domain'] = 'e-commerce';
    } else if (lower.contains('fintech') || lower.contains('betaling') || lower.contains('payment')) {
      keywords['domain'] = 'fintech';
    } else if (lower.contains('health') || lower.contains('gezondheid') || lower.contains('medical')) {
      keywords['domain'] = 'healthtech';
    } else {
      keywords['domain'] = 'tech';
    }

    return keywords;
  }
}
