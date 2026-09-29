import '../models/deck_model.dart';
import '../models/flashcard_model.dart';

/// Immutable bundle used to seed useful study content on first launch.
class StarterContent {
  const StarterContent({
    required this.decks,
    required this.cards,
  });

  final List<DeckModel> decks;
  final List<FlashcardModel> cards;
}

/// Builds the app's built-in starter decks.
///
/// IDs are deterministic so seeding is idempotent even if the app is closed
/// halfway through the initial write. The dates are intentionally old so that
/// user-created decks naturally appear above starter content.
StarterContent buildStarterContent() {
  final deckSpecs = <_StarterDeckSpec>[
    _StarterDeckSpec(
      id: 'starter_cs_basics',
      title: 'Computer Science Basics',
      createdAt: DateTime.utc(2025, 1, 7),
      cards: const [
        _StarterCardSpec(
          'What is an algorithm?',
          'A finite sequence of well-defined steps used to solve a problem or perform a computation.',
          'Fundamentals',
        ),
        _StarterCardSpec(
          'What does CPU stand for?',
          'Central Processing Unit.',
          'Hardware',
        ),
        _StarterCardSpec(
          'What is RAM?',
          'Random Access Memory: fast, volatile memory used to hold data and programs currently in use.',
          'Hardware',
        ),
        _StarterCardSpec(
          'What is the difference between hardware and software?',
          'Hardware is the physical equipment; software is the set of programs and instructions that run on it.',
          'Fundamentals',
        ),
        _StarterCardSpec(
          'What is an operating system?',
          'System software that manages hardware resources and provides services for applications.',
          'Operating Systems',
        ),
        _StarterCardSpec(
          'What is a database?',
          'An organized collection of data that can be stored, queried, and updated efficiently.',
          'Databases',
        ),
        _StarterCardSpec(
          'What does binary mean in computing?',
          'A base-2 number system that represents values using only 0 and 1.',
          'Data Representation',
        ),
        _StarterCardSpec(
          'What is a computer network?',
          'A group of connected devices that communicate and share data or resources.',
          'Networking',
        ),
      ],
    ),
    _StarterDeckSpec(
      id: 'starter_general_knowledge',
      title: 'General Knowledge',
      createdAt: DateTime.utc(2025, 1, 6),
      cards: const [
        _StarterCardSpec(
          'What is the largest ocean on Earth?',
          'The Pacific Ocean.',
          'Geography',
        ),
        _StarterCardSpec(
          'Which planet is known as the Red Planet?',
          'Mars.',
          'Space',
        ),
        _StarterCardSpec(
          'What is the largest continent by land area?',
          'Asia.',
          'Geography',
        ),
        _StarterCardSpec(
          'Who wrote Romeo and Juliet?',
          'William Shakespeare.',
          'Literature',
        ),
        _StarterCardSpec(
          'What is the currency of Japan?',
          'The Japanese yen.',
          'World',
        ),
        _StarterCardSpec(
          'Which organ pumps blood around the human body?',
          'The heart.',
          'Human Body',
        ),
        _StarterCardSpec(
          'How many sides does a hexagon have?',
          'Six.',
          'Mathematics',
        ),
        _StarterCardSpec(
          'What is the freezing point of pure water at standard atmospheric pressure?',
          '0°C (32°F).',
          'Science',
        ),
      ],
    ),
    _StarterDeckSpec(
      id: 'starter_english_vocabulary',
      title: 'English Vocabulary',
      createdAt: DateTime.utc(2025, 1, 5),
      cards: const [
        _StarterCardSpec(
          'What does “concise” mean?',
          'Giving a lot of information clearly in only a few words; brief but complete.',
          'Vocabulary',
        ),
        _StarterCardSpec(
          'What does “ambiguous” mean?',
          'Open to more than one interpretation; not completely clear.',
          'Vocabulary',
        ),
        _StarterCardSpec(
          'What does “resilient” mean?',
          'Able to recover quickly from difficulty or change.',
          'Vocabulary',
        ),
        _StarterCardSpec(
          'What does “meticulous” mean?',
          'Very careful and precise, with close attention to detail.',
          'Vocabulary',
        ),
        _StarterCardSpec(
          'What does “inevitable” mean?',
          'Certain to happen; unavoidable.',
          'Vocabulary',
        ),
        _StarterCardSpec(
          'What does “pragmatic” mean?',
          'Focused on practical results rather than theory or ideals alone.',
          'Vocabulary',
        ),
        _StarterCardSpec(
          'What does “coherent” mean?',
          'Logical, consistent, and easy to understand as a whole.',
          'Vocabulary',
        ),
        _StarterCardSpec(
          'What does “diligent” mean?',
          'Showing steady, careful, and persistent effort.',
          'Vocabulary',
        ),
      ],
    ),
    _StarterDeckSpec(
      id: 'starter_mathematics',
      title: 'Mathematics',
      createdAt: DateTime.utc(2025, 1, 4),
      cards: const [
        _StarterCardSpec(
          'What is the Pythagorean theorem?',
          'For a right triangle, a² + b² = c², where c is the hypotenuse.',
          'Geometry',
        ),
        _StarterCardSpec(
          'What is the formula for the area of a circle?',
          'A = πr².',
          'Geometry',
        ),
        _StarterCardSpec(
          'What is a prime number?',
          'An integer greater than 1 with exactly two positive divisors: 1 and itself.',
          'Number Theory',
        ),
        _StarterCardSpec(
          'What is 15% of 200?',
          '30.',
          'Percentages',
        ),
        _StarterCardSpec(
          'What is the slope formula for two points (x₁, y₁) and (x₂, y₂)?',
          'm = (y₂ − y₁) / (x₂ − x₁), provided x₂ ≠ x₁.',
          'Algebra',
        ),
        _StarterCardSpec(
          'What is the value of 2⁵?',
          '32.',
          'Exponents',
        ),
        _StarterCardSpec(
          'What is the mean of 4, 6, 8, and 10?',
          '7.',
          'Statistics',
        ),
        _StarterCardSpec(
          'What is the probability of getting heads on one fair coin toss?',
          '1/2, or 50%.',
          'Probability',
        ),
      ],
    ),
    _StarterDeckSpec(
      id: 'starter_world_capitals',
      title: 'World Capitals',
      createdAt: DateTime.utc(2025, 1, 3),
      cards: const [
        _StarterCardSpec(
            'What is the capital of Pakistan?', 'Islamabad.', 'Asia'),
        _StarterCardSpec('What is the capital of Japan?', 'Tokyo.', 'Asia'),
        _StarterCardSpec('What is the capital of France?', 'Paris.', 'Europe'),
        _StarterCardSpec(
            'What is the capital of Canada?', 'Ottawa.', 'North America'),
        _StarterCardSpec(
            'What is the capital of Australia?', 'Canberra.', 'Oceania'),
        _StarterCardSpec(
            'What is the capital of Brazil?', 'Brasília.', 'South America'),
        _StarterCardSpec(
            'What is the capital of Türkiye?', 'Ankara.', 'Europe / Asia'),
        _StarterCardSpec('What is the capital of Egypt?', 'Cairo.', 'Africa'),
      ],
    ),
    _StarterDeckSpec(
      id: 'starter_science',
      title: 'Science',
      createdAt: DateTime.utc(2025, 1, 2),
      cards: const [
        _StarterCardSpec(
          'What is photosynthesis?',
          'The process by which plants and some other organisms use light energy to make sugars from carbon dioxide and water.',
          'Biology',
        ),
        _StarterCardSpec(
          'What is the chemical symbol for gold?',
          'Au.',
          'Chemistry',
        ),
        _StarterCardSpec(
          'What force pulls objects toward Earth?',
          'Gravity.',
          'Physics',
        ),
        _StarterCardSpec(
          'What is the basic unit of life?',
          'The cell.',
          'Biology',
        ),
        _StarterCardSpec(
          'What is H₂O commonly called?',
          'Water.',
          'Chemistry',
        ),
        _StarterCardSpec(
          'What is the SI unit of force?',
          'The newton (N).',
          'Physics',
        ),
        _StarterCardSpec(
          'Which gas do humans primarily take in for cellular respiration?',
          'Oxygen.',
          'Biology',
        ),
        _StarterCardSpec(
          'What is the center of an atom called?',
          'The nucleus.',
          'Chemistry',
        ),
      ],
    ),
    _StarterDeckSpec(
      id: 'starter_programming_fundamentals',
      title: 'Programming Fundamentals',
      createdAt: DateTime.utc(2025, 1, 1),
      cards: const [
        _StarterCardSpec(
          'What is a variable?',
          'A named storage location or binding used to hold a value that a program can work with.',
          'Basics',
        ),
        _StarterCardSpec(
          'What is a function?',
          'A reusable block of code designed to perform a specific task, optionally receiving inputs and returning a result.',
          'Functions',
        ),
        _StarterCardSpec(
          'What is a conditional statement?',
          'A control structure that chooses which code to execute based on whether a condition is true or false.',
          'Control Flow',
        ),
        _StarterCardSpec(
          'What is a loop?',
          'A control structure that repeats a block of code while a condition holds or for a defined sequence of values.',
          'Control Flow',
        ),
        _StarterCardSpec(
          'What is an array?',
          'A collection that stores multiple values in an ordered structure, usually accessed by index.',
          'Data Structures',
        ),
        _StarterCardSpec(
          'What is a Boolean value?',
          'A logical value with two states: true or false.',
          'Data Types',
        ),
        _StarterCardSpec(
          'What is debugging?',
          'The process of finding, understanding, and fixing defects in a program.',
          'Development',
        ),
        _StarterCardSpec(
          'What is pseudocode?',
          'A language-independent, human-readable description of an algorithm using programming-like structure.',
          'Problem Solving',
        ),
      ],
    ),
  ];

  final decks = <DeckModel>[];
  final cards = <FlashcardModel>[];

  for (final deck in deckSpecs) {
    decks.add(
      DeckModel(
        id: deck.id,
        title: deck.title,
        createdAt: deck.createdAt,
      ),
    );

    for (var index = 0; index < deck.cards.length; index++) {
      final spec = deck.cards[index];
      final timestamp = deck.createdAt.add(Duration(minutes: index));

      cards.add(
        FlashcardModel(
          id: '${deck.id}_card_${index + 1}',
          deckId: deck.id,
          question: spec.question,
          answer: spec.answer,
          category: spec.category,
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
      );
    }
  }

  return StarterContent(decks: decks, cards: cards);
}

class _StarterDeckSpec {
  const _StarterDeckSpec({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.cards,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final List<_StarterCardSpec> cards;
}

class _StarterCardSpec {
  const _StarterCardSpec(this.question, this.answer, this.category);

  final String question;
  final String answer;
  final String category;
}
