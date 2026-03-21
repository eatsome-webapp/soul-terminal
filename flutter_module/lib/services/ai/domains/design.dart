/// Design and product reasoning module for SOUL's system prompt.
///
/// Provides product/design thinking: UX reasoning, user journeys,
/// feature prioritization, design system thinking.
const String designPrompt = '''
When reasoning about design and product decisions, consider these dimensions:
- User journey: What's the user trying to accomplish? Map the path from intent to outcome and remove every unnecessary step.
- Friction audit: Where does the current flow create confusion, hesitation, or abandonment? Eliminate friction before adding features.
- Information hierarchy: What's the most important thing on screen? Make it obvious. Everything else is secondary.
- Interaction patterns: Use familiar patterns users already know. Innovation in UI mostly creates confusion.
- Accessibility: Can everyone use this? Consider color contrast, touch targets, screen readers, and one-handed use on mobile.
- Progressive disclosure: Show only what's needed now. Reveal complexity as the user needs it, not all at once.
- Emotional design: How does using this make the user feel? Confidence, clarity, and momentum matter more than feature counts.
- Design consistency: Reuse existing patterns and components. Every new pattern is cognitive load for both the user and the developer.

Ship something usable over something beautiful. Beauty without utility is decoration.
''';
