import '../../domain/entities/quote_item.dart';

class LocalQuoteDataSource {
  const LocalQuoteDataSource();

  List<QuoteItem> loadQuotes() {
    return const [
      QuoteItem(
        id: 'q01',
        text:
            'The happiness of your life depends upon the quality of your thoughts.',
        author: 'Marcus Aurelius',
        category: 'Wisdom',
      ),
      QuoteItem(
        id: 'q02',
        text: 'No man is free who is not master of himself.',
        author: 'Epictetus',
        category: 'Wisdom',
      ),
      QuoteItem(
        id: 'q03',
        text: 'Luck is what happens when preparation meets opportunity.',
        author: 'Seneca',
        category: 'Motivation',
      ),
      QuoteItem(
        id: 'q04',
        text: 'Well done is better than well said.',
        author: 'Benjamin Franklin',
        category: 'Action',
      ),
      QuoteItem(
        id: 'q05',
        text: 'Lost time is never found again.',
        author: 'Benjamin Franklin',
        category: 'Focus',
      ),
      QuoteItem(
        id: 'q06',
        text: 'Nothing great was ever achieved without enthusiasm.',
        author: 'Ralph Waldo Emerson',
        category: 'Motivation',
      ),
      QuoteItem(
        id: 'q07',
        text: 'It is not length of life, but depth of life.',
        author: 'Ralph Waldo Emerson',
        category: 'Life',
      ),
      QuoteItem(
        id: 'q08',
        text: 'Go confidently in the direction of your dreams.',
        author: 'Henry David Thoreau',
        category: 'Courage',
      ),
      QuoteItem(
        id: 'q09',
        text:
            'Success is not final, failure is not fatal: it is the courage to continue that counts.',
        author: 'Winston Churchill',
        category: 'Courage',
      ),
      QuoteItem(
        id: 'q10',
        text: 'The secret of getting ahead is getting started.',
        author: 'Mark Twain',
        category: 'Action',
      ),
      QuoteItem(
        id: 'q11',
        text:
            'You cannot escape the responsibility of tomorrow by evading it today.',
        author: 'Abraham Lincoln',
        category: 'Action',
      ),
      QuoteItem(
        id: 'q12',
        text:
            'Always bear in mind that your own resolution to succeed is more important than any other.',
        author: 'Abraham Lincoln',
        category: 'Motivation',
      ),
      QuoteItem(
        id: 'q13',
        text: 'The only way to have a friend is to be one.',
        author: 'Ralph Waldo Emerson',
        category: 'Life',
      ),
      QuoteItem(
        id: 'q14',
        text: 'Diligence is the mother of good luck.',
        author: 'Benjamin Franklin',
        category: 'Focus',
      ),
      QuoteItem(
        id: 'q15',
        text: 'He who is brave is free.',
        author: 'Seneca',
        category: 'Courage',
      ),
      QuoteItem(
        id: 'q16',
        text:
            'First say to yourself what you would be; and then do what you have to do.',
        author: 'Epictetus',
        category: 'Action',
      ),
      QuoteItem(
        id: 'q17',
        text: 'To improve is to change; to be perfect is to change often.',
        author: 'Winston Churchill',
        category: 'Growth',
      ),
      QuoteItem(
        id: 'q18',
        text: 'Every artist was first an amateur.',
        author: 'Ralph Waldo Emerson',
        category: 'Growth',
      ),
      QuoteItem(
        id: 'q19',
        text: 'It takes a great man to be a good listener.',
        author: 'Calvin Coolidge',
        category: 'Wisdom',
      ),
      QuoteItem(
        id: 'q20',
        text: 'Do what you can, with what you have, where you are.',
        author: 'Theodore Roosevelt',
        category: 'Action',
      ),
      QuoteItem(
        id: 'q21',
        text: 'Believe you can and you are halfway there.',
        author: 'Theodore Roosevelt',
        category: 'Motivation',
      ),
      QuoteItem(
        id: 'q22',
        text:
            'Keep your face always toward the sunshine—and shadows will fall behind you.',
        author: 'Walt Whitman',
        category: 'Life',
      ),
      QuoteItem(
        id: 'q23',
        text: 'Act as if what you do makes a difference. It does.',
        author: 'William James',
        category: 'Action',
      ),
      QuoteItem(
        id: 'q24',
        text:
            'The greatest discovery of my generation is that a human being can alter his life by altering his attitudes.',
        author: 'William James',
        category: 'Growth',
      ),
      QuoteItem(
        id: 'q25',
        text:
            'Be not afraid of going slowly; be afraid only of standing still.',
        author: 'Chinese Proverb',
        category: 'Growth',
      ),
      QuoteItem(
        id: 'q26',
        text: 'A journey of a thousand miles begins with a single step.',
        author: 'Lao Tzu',
        category: 'Motivation',
      ),
      QuoteItem(
        id: 'q27',
        text:
            'Knowing others is intelligence; knowing yourself is true wisdom.',
        author: 'Lao Tzu',
        category: 'Wisdom',
      ),
      QuoteItem(
        id: 'q28',
        text: 'Energy and persistence conquer all things.',
        author: 'Benjamin Franklin',
        category: 'Focus',
      ),
      QuoteItem(
        id: 'q29',
        text: 'Concentrate all your thoughts upon the work in hand.',
        author: 'Alexander Graham Bell',
        category: 'Focus',
      ),
      QuoteItem(
        id: 'q30',
        text:
            'Courage is resistance to fear, mastery of fear—not absence of fear.',
        author: 'Mark Twain',
        category: 'Courage',
      ),
    ];
  }
}
