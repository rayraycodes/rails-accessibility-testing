# Working with Designers and Content Authors

Accessibility is a team effort. This guide helps developers collaborate effectively with designers and content authors to build accessible Rails applications.

## The Team Approach

### Roles and Responsibilities

**Developers:**
- Implement accessible HTML structure
- Ensure technical accessibility (ARIA, semantics)
- Run automated checks
- Fix violations

**Designers:**
- Design with accessibility in mind
- Ensure sufficient color contrast
- Design keyboard-friendly interactions
- Create accessible component patterns

**Content Authors:**
- Write descriptive alt text
- Create clear link text
- Structure content logically
- Write accessible form labels

## For Designers

### Design Principles

#### 1. Color Contrast

**Requirement:** WCAG AA requires:
- Normal text: 4.5:1 contrast ratio
- Large text (18pt+ or 14pt+ bold): 3:1 contrast ratio

**Tools:**
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- [Stark](https://www.getstark.co/) - Figma/Sketch plugin
- Browser DevTools

**Example:**
```
✅ Good: #000000 on #FFFFFF (21:1)
✅ Good: #333333 on #FFFFFF (12.6:1)
❌ Bad: #CCCCCC on #FFFFFF (1.6:1)
```

#### 2. Focus States

**Requirement:** All interactive elements must have visible focus indicators.

**Design:**
- Clear, visible outline
- High contrast
- Consistent across components

**Example:**
```css
button:focus {
  outline: 3px solid #0066cc;
  outline-offset: 2px;
}
```

#### 3. Touch Targets

**Requirement:** Minimum 44x44px touch targets (mobile).

**Design:**
- Buttons large enough to tap easily
- Adequate spacing between interactive elements
- Consider thumb zones on mobile

#### 4. Text Sizing

**Requirement:** Text must be resizable up to 200% without loss of functionality.

**Design:**
- Use relative units (em, rem, %)
- Avoid fixed pixel sizes for text
- Test at 200% zoom

### Design System Patterns

#### Accessible Button Styles

```css
/* Primary button */
.btn-primary {
  background: #0066cc;
  color: #ffffff;
  padding: 12px 24px;
  min-height: 44px;  /* Touch target */
  border: 2px solid transparent;
}

.btn-primary:focus {
  outline: 3px solid #0066cc;
  outline-offset: 2px;
}

.btn-primary:hover {
  background: #0052a3;
}
```

#### Accessible Form Styles

```css
.form-label {
  display: block;
  margin-bottom: 8px;
  font-weight: 600;
}

.form-input {
  padding: 12px;
  border: 2px solid #ccc;
  border-radius: 4px;
}

.form-input:focus {
  outline: 3px solid #0066cc;
  outline-offset: 2px;
  border-color: #0066cc;
}

.form-error {
  color: #d32f2f;
  margin-top: 4px;
  font-size: 0.875rem;
}
```

### Component Specifications

When handing off designs, include:

1. **Color specifications** - Hex codes with contrast ratios
2. **Focus states** - How focus should look
3. **Error states** - How errors are displayed
4. **Loading states** - How loading is indicated
5. **Keyboard interactions** - Tab order, keyboard shortcuts

### Design Review Checklist

- [ ] All text meets contrast requirements
- [ ] Focus states are visible and clear
- [ ] Touch targets are at least 44x44px
- [ ] Color is not the only indicator (e.g., errors)
- [ ] Interactive elements are clearly identifiable
- [ ] Layout works at 200% zoom

## For Content Authors

### Writing Alt Text

#### Informative Images

**Good:**
```
Alt: "A red bicycle parked outside a coffee shop"
Alt: "Screenshot of the dashboard showing 5 active users"
```

**Bad:**
```
Alt: "Image"  <!-- Too generic -->
Alt: "Photo"  <!-- Not descriptive -->
Alt: "bicycle.jpg"  <!-- Filename, not description -->
```

#### Decorative Images

For purely decorative images, use empty alt:

```erb
<%= image_tag "border.png", alt: "" %>
```

#### Complex Images

For charts, graphs, or infographics:

```erb
<%= image_tag "chart.png", alt: "Bar chart showing sales increased 25% from Q1 to Q2" %>
```

Or provide a detailed description:

```erb
<figure>
  <%= image_tag "chart.png", alt: "Sales chart" %>
  <figcaption>Sales increased 25% from Q1 ($50k) to Q2 ($62.5k)</figcaption>
</figure>
```

### Writing Link Text

#### ✅ Good: Descriptive

```erb
<%= link_to "Read our privacy policy", privacy_path %>
<%= link_to "Download the user guide (PDF)", guide_path %>
```

#### ❌ Bad: Generic

```erb
<%= link_to "Click here", privacy_path %>  <!-- Generic! -->
<%= link_to "More", article_path(@article) %>  <!-- Vague! -->
<%= link_to "Read more", article_path(@article) %>  <!-- Repeated! -->
```

#### Context Matters

If link text is repeated, add context:

```erb
<article>
  <h2><%= @article.title %></h2>
  <p><%= @article.excerpt %></p>
  <%= link_to "Read full article: #{@article.title}", article_path(@article) %>
</article>
```

### Writing Form Labels

#### ✅ Good: Clear and Specific

```erb
<%= f.label :email, "Email Address" %>
<%= f.label :phone, "Phone Number (optional)" %>
<%= f.label :password, "Password (minimum 8 characters)" %>
```

#### ❌ Bad: Vague

```erb
<%= f.label :email, "Email" %>  <!-- Could be clearer -->
<%= f.label :field1, "Field 1" %>  <!-- Meaningless! -->
```

### Structuring Content

#### Use Headings Properly

```erb
<h1>Page Title</h1>
  <h2>Introduction</h2>
  <h2>Features</h2>
    <h3>Feature 1</h3>
    <h3>Feature 2</h3>
  <h2>Conclusion</h2>
```

#### Use Lists for Related Items

```erb
<ul>
  <li>First item</li>
  <li>Second item</li>
  <li>Third item</li>
</ul>
```

#### Use Semantic HTML

```erb
<article>
  <header>
    <h1>Article Title</h1>
    <p>By Author Name</p>
  </header>
  <main>
    <!-- Content -->
  </main>
  <footer>
    <p>Published on <%= @article.published_at %></p>
  </footer>
</article>
```

## Collaboration Workflows

### Design Handoff

1. **Designer provides:**
   - Design files with accessibility notes
   - Color specifications with contrast ratios
   - Component specifications
   - Focus state designs

2. **Developer reviews:**
   - Checks contrast ratios
   - Verifies touch target sizes
   - Confirms keyboard navigation
   - Tests with screen reader

3. **Feedback loop:**
   - Developer flags accessibility issues
   - Designer adjusts as needed
   - Iterate until accessible

### Content Review

1. **Content author provides:**
   - Alt text for images
   - Link text
   - Form labels
   - Heading structure

2. **Developer reviews:**
   - Runs Rails A11y checks
   - Verifies alt text quality
   - Checks link text clarity
   - Validates heading hierarchy

3. **Feedback loop:**
   - Developer suggests improvements
   - Content author revises
   - Final review before publish

### Testing Together

Schedule regular accessibility reviews:

1. **Design review** - Check designs for accessibility
2. **Content review** - Review alt text and copy
3. **Implementation review** - Test with screen readers
4. **Final review** - Full accessibility audit

## Tools for Collaboration

### Design Tools

- **Figma:** [A11y - Focus Orderer](https://www.figma.com/community/plugin/731310036527916373)
- **Sketch:** [Stark](https://www.getstark.co/)
- **Adobe XD:** Built-in contrast checker

### Communication

- **Slack/Teams:** Share accessibility reports
- **GitHub:** Comment on PRs with accessibility notes
- **Notion/Confluence:** Document accessibility patterns

### Testing

- **Browser DevTools:** Built-in accessibility inspector
- **axe DevTools:** Browser extension
- **WAVE:** Web accessibility evaluation tool

## Common Issues and Solutions

### Issue: Low Contrast Text

**Designer:** "But it looks better this way!"

**Solution:** Show the contrast ratio. Explain that 1 in 12 men have color blindness. Offer alternative colors that meet contrast requirements.

### Issue: Generic Link Text

**Content Author:** "But 'Click here' is clear in context!"

**Solution:** Explain that screen reader users navigate by links. Show how "Read privacy policy" is clearer than "Click here" out of context.

### Issue: Missing Alt Text

**Content Author:** "The image is decorative, why do I need alt text?"

**Solution:** Use empty alt (`alt=""`) for decorative images. This tells screen readers to skip the image.

## Resources

### For Designers

- [Inclusive Components](https://inclusive-components.design/)
- [A11y Project Checklist](https://www.a11yproject.com/checklist/)
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)

### For Content Authors

- [Alt Text Guide](https://www.a11yproject.com/posts/alt-text/)
- [Writing Link Text](https://www.a11yproject.com/posts/how-to-write-accessible-link-text/)
- [Heading Structure](https://www.a11yproject.com/posts/how-to-structure-headings/)

## Next Steps

1. **Schedule a team meeting** - Discuss accessibility goals
2. **Create style guide** - Document accessibility patterns
3. **Set up reviews** - Regular accessibility check-ins
4. **Share resources** - Provide training materials

---

**Remember:** Accessibility is everyone's responsibility. Working together makes it easier and more effective.

