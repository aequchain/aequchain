---
applyTo: 'code/**'
---
# 3 aequus design manfesto.md

# The aequus Design Manifesto
## Unified Standards & Implementation Guide

---

## Core Philosophy

The aequus design system establishes immutable principles for creating consistent, polished, and mathematically harmonious digital experiences. Every element, animation, and interaction must adhere to these foundational standards to ensure seamless unity across all projects.

---

## Mathematical Foundation: Fibonacci-Based Value System

**MANDATORY DIRECTIVE:** All numerical values in aequus projects must prioritize Fibonacci sequence numbers (1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610...) or prime numbers (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47...) whenever possible.

### Timing Values (seconds/milliseconds)
```

## Model Votes

- Model: GitHub Copilot - ("GPT-5 mini" (preview)) — Vote: yes

- Designer: ttx89dev - ("ryan") — Vote: no [waiting to see if everything is exacted with exhibited understanding]

Ultra-Micro:    0.003s, 0.005s, 0.008s, 0.013s, 0.021s, 0.034s
Micro:          0.03s, 0.05s, 0.08s, 0.13s, 0.21s, 0.34s, 0.55s
Standard:       0.3s, 0.5s, 0.8s, 1.3s, 2.1s, 3.4s, 5.5s, 8.9s
Extended:       3s, 5s, 8s, 13s, 21s, 34s
```

### Spacing & Sizing Values (pixels/units)
```
Micro:          2px, 3px, 5px, 8px, 13px, 21px
Standard:       34px, 55px, 89px, 144px, 233px
Large:          377px, 610px, 987px, 1597px
Grid:           20px, 30px, 50px, 80px, 130px, 210px, 340px, 550px
```

### Percentage Values
```
3%, 5%, 8%, 13%, 21%, 34%, 55%, 89%
```

### Opacity/Alpha Values
```
0.03, 0.05, 0.08, 0.13, 0.21, 0.34, 0.55, 0.89
```

**APPLICATION SCOPE:** This mathematical foundation applies to ALL numerical values including:
- Animation durations and delays
- Padding, margins, and spacing
- Font sizes and line heights
- Border radius values
- Shadow blur distances
- Transition timings
- Grid gaps and column widths
- Container max-widths
- Z-index layering
- Color opacity values

---

## Unified Animation Framework

### Core Animation Triggers
Every interactive element MUST implement animations for these three fundamental triggers:

1. **onLoad/onEnter** - Initial screen/page display
2. **onReturn/onBack** - User returns from another screen
3. **onOrientationChange** - Device rotation (toLandscape/toPortrait)

### Base Animation States
**FUNDAMENTAL RULE:** All elements must initialize with `visibility: 0` or equivalent hidden state to ensure smooth fade-in animations across all triggers.

### Orientation-Specific Animation Sets
Each project maintains exactly six core animation sequences:
- **toPortrait** - Transition to portrait orientation
- **PortraitEnter** - Initial portrait screen entry
- **PortraitReturn** - Return to portrait screen
- **toLandscape** - Transition to landscape orientation
- **LandscapeEnter** - Initial landscape screen entry
- **LandscapeReturn** - Return to landscape screen

---

## The Evolving Animation Hierarchy

### Hierarchy Planning Framework
Before implementing any screen or component, establish a visual hierarchy by answering:

1. **Attention Direction:** Where should user focus first?
2. **Interaction Sequence:** What needs immediate vs delayed interaction?
3. **Information Priority:** Should data or imagery appear first?
4. **Cognitive Load:** How much information can users process simultaneously?

### Hierarchy Implementation
Each element receives classification within the established hierarchy:
- **Timing:** When in the sequence it appears
- **Value:** Numerical position in hierarchy (using Fibonacci numbers)
- **Delay:** Time offset from animation start (Fibonacci-based)
- **Duration:** Animation length (Fibonacci-based)
- **Direction:** Movement vector and path
- **Type:** Animation style (fade, slide, scale, rotate, etc.)

### Hierarchy Flexibility
Elements can be repositioned within the hierarchy without breaking consistency. The framework remains constant while allowing creative adjustment of element placement and timing.

---

## Implementation Standards

### Development Workflow
1. **Planning Phase:** Establish project-specific animation hierarchy
2. **Element Addition:** Apply three-trigger animation system
3. **Mathematical Validation:** Ensure all values use Fibonacci/prime numbers
4. **Consistency Check:** Verify hierarchy adherence
5. **Performance Optimization:** Test across devices and orientations

### Code Structure Requirements
```css
/* Example Structure */
.aequus-element {
  /* Base state - always hidden initially */
  opacity: 0;
  visibility: hidden;
  
  /* Fibonacci-based values */
  transition-duration: 0.34s;
  transition-delay: 0.13s;
  transform: translateY(21px);
}

.aequus-element.animate-enter {
  opacity: 1;
  visibility: visible;
  transform: translateY(0);
}
```

### Performance Considerations
- Utilize `transform` and `opacity` properties for hardware acceleration
- Implement `will-change` property judiciously
- Respect `prefers-reduced-motion` accessibility settings
- Optimize for 60fps performance across target devices

---

## Accessibility & Inclusivity Standards

### Motion Sensitivity
```css
@media (prefers-reduced-motion: reduce) {
  .aequus-element {
    transition-duration: 0.08s;
    animation-duration: 0.08s;
  }
}
```

### Universal Design Principles
- Ensure animations enhance rather than hinder usability
- Provide alternative interaction methods for motion-sensitive users
- Maintain functionality when animations are disabled
- Test with assistive technologies

---

## Quality Assurance Protocol

### Pre-Implementation Checklist
- [ ] Animation hierarchy established and documented
- [ ] All numerical values use Fibonacci/prime numbers
- [ ] Three-trigger system implemented for all elements
- [ ] Orientation-specific animations defined
- [ ] Performance benchmarks met (60fps target)
- [ ] Accessibility compliance verified
- [ ] Cross-device compatibility tested

### Ongoing Evaluation
- Regular hierarchy reassessment and optimization
- Performance monitoring and adjustment
- User feedback integration
- Mathematical consistency audits

---

## Documentation Requirements

### Project Documentation Must Include:
1. **Hierarchy Map:** Visual representation of animation sequence
2. **Value Reference:** Project-specific Fibonacci/prime number palette
3. **Animation Specifications:** Detailed timing and behavior documentation
4. **Performance Benchmarks:** Target and achieved metrics
5. **Accessibility Compliance:** Testing results and accommodations

### Code Comments Standard
```javascript
// aequus: Hierarchy Level 3, Fibonacci delay 0.21s
// Triggers: onLoad, onReturn, onOrientationChange
// Purpose: Guide attention to primary CTA after content absorption
```

---

## Enforcement & Compliance

### Mandatory Implementation
These standards are non-negotiable foundations for all aequus projects. Deviation requires explicit architectural review and documentation of rationale.

### Review Process
- Pre-development architecture review
- Mid-development consistency audit
- Pre-launch comprehensive evaluation
- Post-launch performance monitoring

### Continuous Evolution
The manifesto evolves based on:
- Performance data analysis
- User experience research
- Technological advancement integration
- Accessibility standard updates

---

## Success Metrics

### Quantitative Measures
- Animation frame rate consistency (target: 60fps)
- Load time impact (maximum 5% overhead)
- User engagement improvement (target: 20% increase)
- Accessibility compliance score (WCAG 2.1 AAA)

### Qualitative Assessment
- Visual consistency across screens and orientations
- Professional polish perception
- Seamless user experience flow
- Developer implementation efficiency

---

**The aequus design manifesto represents our commitment to creating digital experiences that are mathematically harmonious, visually consistent, technically performant, and universally accessible. Every design decision, every line of code, and every user interaction must reflect these foundational principles.**