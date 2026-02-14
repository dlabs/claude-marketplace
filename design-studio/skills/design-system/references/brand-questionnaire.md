# Brand Questionnaire

Question bank, batching rules, and branching logic for the brand discovery Q&A process. Used by the **brand-builder** agent during the discovery phase.

---

## Batching Rules

- Ask **2-3 questions per round** (never more than 3)
- Run **3-4 rounds** of Q&A (~8-12 questions total)
- **Minimum 6 questions** for a viable brand synthesis
- **Maximum 12 questions** before synthesis (fatigue threshold)
- After each batch, provide a **brief summary** of developing understanding
- After core Q&A (~8 questions), offer **reference gathering** (URLs, images, text descriptions)
- User can paste URLs or images at **any point** — pause Q&A to analyze them

### Round Progression

| Round | Category | Questions | Purpose |
|-------|----------|-----------|---------|
| 1 | Business & Positioning | 2-3 | Establish what the product/business is |
| 2 | Audience & Psychology | 2 | Understand who the brand serves |
| 3 | Personality & Voice | 2-3 | Define how the brand communicates |
| 4 | Visual Direction | 1-2 | Get concrete visual preferences |

After round 4, transition to reference gathering or synthesis.

### Between-Round Summaries

After each round, provide a 2-3 sentence summary of what you've learned so far. Example:

> "So far I understand you're building a developer-focused deployment tool that prioritizes reliability over flash. Your audience values clarity and speed — they're frustrated by complex, jargon-heavy tools. Let me ask about your brand's personality..."

---

## Question Bank

### Category 1: Business & Positioning

Pick 2-3 from this category for Round 1.

#### Q1: Core Product
- **Ask:** "What does your product or business do? Give me the elevator pitch."
- **Why it matters:** Establishes the fundamental offering and frames all subsequent brand decisions
- **What to infer:** Industry, complexity level, B2B vs B2C, technical depth

#### Q2: Differentiation
- **Ask:** "What makes you different from alternatives or competitors?"
- **Why it matters:** Unique positioning drives brand personality and visual distinction
- **What to infer:** Value proposition, competitive landscape, positioning strategy

#### Q3: Stage & Ambition
- **Ask:** "Where are you now — early idea, launched product, growing business? And where do you want to be?"
- **Why it matters:** Stage affects brand maturity level (scrappy startup vs. established authority)
- **What to infer:** Visual polish level, tone formality, how aspirational vs. grounded

#### Q4: Competitor Landscape
- **Ask:** "Who are your main competitors? What do you think of their branding?"
- **Why it matters:** Helps position visually — stand out from or align with the space
- **What to infer:** Category norms to follow or break, color/style avoidance

### Category 2: Audience & Psychology

Pick 1-2 from this category for Round 2.

#### Q5: Primary Audience
- **Ask:** "Describe your ideal user or customer. What do they do, and what do they care about?"
- **Why it matters:** Brand must resonate with specific people, not everyone
- **What to infer:** Demographics, technical level, emotional drivers, language register

#### Q6: Pain & Aspiration
- **Ask:** "What frustrates your audience about existing solutions? What would delight them?"
- **Why it matters:** Brand should address pain and promise the aspiration
- **What to infer:** Emotional tone (calming vs. empowering), messaging angles, visual mood

#### Q7: Trust Signals
- **Ask:** "What makes your audience trust a product in this space? Credentials, social proof, design quality, transparency?"
- **Why it matters:** Different audiences have different trust heuristics
- **What to infer:** Visual credibility markers, content strategy, formality level

### Category 3: Personality & Voice

Pick 2-3 from this category for Round 3.

#### Q8: Brand as a Person
- **Ask:** "If your brand were a person at a dinner party, how would they come across? What would they talk about? How would they talk?"
- **Why it matters:** Anthropomorphizing makes abstract personality concrete
- **What to infer:** Archetype, communication style, formality, humor level

#### Q9: Tone Spectrum
- **Ask:** "Rate your brand on these spectrums (1-5):"
  - Formal (1) ↔ Casual (5)
  - Serious (1) ↔ Playful (5)
  - Technical (1) ↔ Simple (5)
  - Reserved (1) ↔ Bold (5)
- **Why it matters:** Directly maps to `personality.tone_spectrum` values
- **What to infer:** Convert 1-5 to 0.0-1.0 scale: `(rating - 1) / 4`

#### Q10: Voice Examples
- **Ask:** "Give me a sentence or phrase that sounds like your brand. Then give me one that absolutely does NOT."
- **Why it matters:** Concrete examples ground abstract personality work
- **What to infer:** Vocabulary level, sentence structure preferences, taboo words/tones

#### Q11: Brand Traits
- **Ask:** "Pick 3-5 words that should come to mind when someone interacts with your brand."
- **Why it matters:** Directly maps to `personality.traits`
- **What to infer:** Visual mood, color temperature, spacing density, typography weight

### Category 4: Visual Direction

Pick 1-2 from this category for Round 4.

#### Q12: Visual References
- **Ask:** "Name 2-3 brands or websites whose visual style you admire. They don't need to be in your industry."
- **Why it matters:** Concrete references are more reliable than abstract descriptions
- **What to infer:** Color preferences, layout density, typography style, animation level

#### Q13: Light or Dark, Minimal or Bold
- **Ask:** "Quick gut checks: Dark mode or light? Minimal and clean, or bold and expressive?"
- **Why it matters:** Narrows the visual design space dramatically
- **What to infer:** Background colors, contrast levels, visual weight, spacing

#### Q14: Must-Haves and Must-Avoids
- **Ask:** "Anything your brand's visual style MUST have? Anything it must absolutely avoid?"
- **Why it matters:** Constraints are more useful than preferences for design decisions
- **What to infer:** Hard requirements and anti-patterns to respect

#### Q15: Color Associations
- **Ask:** "Any colors you associate with your brand, or colors you want to avoid?"
- **Why it matters:** Users often have strong color opinions even without a formal brand
- **What to infer:** Primary palette direction, cultural associations, competitor avoidance

---

## Branching Logic

### Skip Rules

- If user provides a detailed seed description (>50 words), skip Q1 (Core Product) and infer from the seed
- If user mentions competitors in the seed, skip Q4 (Competitor Landscape)
- If user pastes a URL before Q12, skip Q12 (Visual References) — the URL IS the reference
- If user explicitly says "I don't have competitors" or "this is brand new," skip Q4

### Expand Rules

- If Q8 (Brand as a Person) gets a vague answer ("professional but friendly"), follow up: "Professional-friendly covers a wide range — think McKinsey consultant vs. helpful barista. Which end?"
- If tone spectrum ratings are all middle (all 3s), push: "All-3s usually means 'I haven't decided.' Can you push at least 2 of these to a 2 or 4?"
- If the user's visual references contradict their personality answers, surface the conflict (see Conflict Handling below)

### Early Exit

If the user says "that's enough" or "just go with what you have" after at least 6 questions:
- Summarize current understanding
- List what you'll infer/assume for unanswered areas
- Ask for a final confirmation before synthesis

---

## Reference Gathering

After core Q&A (~8 questions), transition to reference gathering:

> "Great — I have a solid picture of your brand's personality and audience. Before I synthesize everything, want to share any reference material? You can:
> - **Paste a URL** — I'll analyze the visual patterns (colors, fonts, layout)
> - **Share an image** — I'll analyze the mood, colors, and composition
> - **Describe a vibe** — just write what you're imagining
>
> Or say 'synthesize' to proceed with what we have."

### URL Analysis

When the user pastes a URL:
1. Use **WebFetch** to fetch the page
2. Extract: dominant colors (from CSS/meta tags), font families, layout pattern (sidebar/centered/full-width), visual density, dark/light mode
3. Present findings: "From {url} I extracted: dark palette with blue accents (#1e3a5f, #3b82f6), Inter font, centered layout with generous whitespace, card-based sections."
4. Ask: "Want me to incorporate these patterns into your brand, or was this just for reference?"

### Image Analysis

When the user shares an image:
1. Use **Read** tool (multimodal) to analyze the image
2. Extract: dominant colors, color temperature (warm/cool), composition style, mood/feeling, visual weight
3. Present findings: "From this image I see: warm earthy tones (terracotta, cream, sage), organic shapes, balanced composition, calm and grounded mood."
4. Ask: "Should these qualities influence your brand's visual direction?"

### Conflict Handling

If reference analysis contradicts Q&A answers:
- Surface it explicitly: "You described your brand as playful and casual, but your reference URLs are all corporate and formal. Which direction should we go?"
- Don't average or compromise — make the user choose
- If the user says "both," help them find the synthesis: "So professional credibility with approachable warmth — like Stripe or Linear?"

---

## Synthesis Transition

After all Q&A and references are gathered:

1. Present a **full brand summary** covering all sections of `brand.json`
2. Highlight any **inferences** you made (areas the user didn't explicitly address)
3. Ask for **approval** before writing any files
4. If the user wants changes, adjust and re-present

The synthesis summary should cover:
- Identity (name, tagline, industry, description)
- Audience (primary, pain points, aspirations)
- Personality (archetype, traits, tone spectrum, voice examples)
- Visual principles (2-3 principles derived from the conversation)
- Visual identity (colors with meanings, typography with rationale, spacing, radii, shadows)
