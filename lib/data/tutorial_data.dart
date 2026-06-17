/// Tutorial v1 step definitions.
class TutorialData {
  TutorialData._();

  static const currentVersion = 1;

  static const steps = <TutorialStep>[
    TutorialStep(
      id: 'welcome',
      title: 'Welcome to Egg Hatchers!',
      body:
          'Hatch animals, earn coins, upgrade your team, and take on bosses.',
      icon: '🐣',
    ),
    TutorialStep(
      id: 'coins',
      title: 'Animals earn coins',
      body:
          'Every animal you hatch makes coins over time. More animals means more income.',
      icon: '🪙',
    ),
    TutorialStep(
      id: 'shop',
      title: 'Buy eggs',
      body:
          'Use coins to buy eggs from the Shop. Better eggs can hatch stronger animals.',
      icon: '🛒',
    ),
    TutorialStep(
      id: 'upgrade',
      title: 'Upgrade your animals',
      body:
          'Upgrading animals makes them earn more coins. Special mutations can make them even stronger.',
      icon: '⬆️',
    ),
    TutorialStep(
      id: 'collection',
      title: 'Build your collection',
      body:
          'Your Collection shows every animal you have found. Some rare animals come from bosses and secrets.',
      icon: '📚',
    ),
    TutorialStep(
      id: 'quests',
      title: 'Complete quests',
      body: 'Quests give extra rewards and help guide what to do next.',
      icon: '🎯',
    ),
    TutorialStep(
      id: 'battles',
      title: 'Battle bosses',
      body:
          'Use Auto Battle to send an animal off over time, or Manual Battle to dodge rotten eggs yourself.',
      icon: '⚔️',
    ),
    TutorialStep(
      id: 'rebirth',
      title: 'Rebirth later',
      body:
          'When you earn enough lifetime coins, Rebirth resets your progress for a permanent income boost.',
      icon: '🔄',
    ),
    TutorialStep(
      id: 'explore',
      title: "You're ready!",
      body: 'Keep hatching, upgrading, battling, and discovering secrets.',
      icon: '✨',
      isLast: true,
    ),
  ];
}

class TutorialStep {
  const TutorialStep({
    required this.id,
    required this.title,
    required this.body,
    this.icon,
    this.isLast = false,
  });

  final String id;
  final String title;
  final String body;
  final String? icon;
  final bool isLast;
}
