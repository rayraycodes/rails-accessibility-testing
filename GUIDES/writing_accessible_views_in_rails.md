# Writing Accessible Views in Rails

This guide shows you how to write accessible Rails views that pass Rails A11y checks and meet WCAG 2.1 AA standards.

## Core Principles

1. **Semantic HTML** - Use the right elements for the job
2. **Clear Structure** - Logical heading hierarchy and landmarks
3. **Accessible Forms** - Proper labels and error associations
4. **Descriptive Content** - Alt text, link text, and button labels
5. **Keyboard Navigation** - Everything works without a mouse

## Forms

### ✅ Good: Proper Labels

```erb
<%= form_with model: @user do |f| %>
  <%= f.label :email, "Email Address" %>
  <%= f.email_field :email %>
  
  <%= f.label :password, "Password" %>
  <%= f.password_field :password %>
<% end %>
```

### ❌ Bad: Missing Labels

```erb
<%= form_with model: @user do |f| %>
  <%= f.email_field :email %>  <!-- No label! -->
  <%= f.password_field :password %>  <!-- No label! -->
<% end %>
```

### Alternative: aria-label

For icon-only inputs, use `aria-label`:

```erb
<%= f.search_field :query, aria: { label: "Search" } %>
```

### Form Errors

Associate error messages with inputs:

```erb
<%= form_with model: @user do |f| %>
  <%= f.label :email %>
  <%= f.email_field :email, 
      aria: { 
        describedby: "email-error",
        invalid: @user.errors[:email].any?
      } %>
  <% if @user.errors[:email].any? %>
    <div id="email-error" class="error">
      <%= @user.errors[:email].first %>
    </div>
  <% end %>
<% end %>
```

## Images

### ✅ Good: Descriptive Alt Text

```erb
<%= image_tag "logo.png", alt: "Company Logo" %>

<!-- For decorative images -->
<%= image_tag "decoration.png", alt: "" %>
```

### ❌ Bad: Missing Alt

```erb
<%= image_tag "logo.png" %>  <!-- Missing alt! -->
```

### When to Use Empty Alt

Use `alt=""` only for purely decorative images:

```erb
<!-- Decorative border -->
<%= image_tag "border.png", alt: "" %>

<!-- Spacer image -->
<%= image_tag "spacer.gif", alt: "" %>
```

## Links and Buttons

### ✅ Good: Descriptive Text

```erb
<%= link_to "Read More", article_path(@article) %>

<%= button_to "Submit", submit_path, method: :post %>
```

### ❌ Bad: Generic or Missing Text

```erb
<%= link_to "Click here", article_path(@article) %>  <!-- Generic! -->
<%= link_to article_path(@article) do %>
  <i class="icon"></i>  <!-- No accessible name! -->
<% end %>
```

### Icon-Only Links/Buttons

For icon-only interactive elements, use `aria-label`:

```erb
<%= link_to article_path(@article), aria: { label: "Read article" } do %>
  <i class="icon-read"></i>
<% end %>

<%= button_tag type: "submit", aria: { label: "Close dialog" } do %>
  <i class="icon-close"></i>
<% end %>
```

### Visually Hidden Text

Alternative approach using CSS:

```erb
<%= link_to article_path(@article) do %>
  <i class="icon-read"></i>
  <span class="visually-hidden">Read article</span>
<% end %>
```

```css
.visually-hidden {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border-width: 0;
}
```

## Headings

### ✅ Good: Proper Hierarchy

```erb
<h1>Page Title</h1>
  <h2>Section Title</h2>
    <h3>Subsection Title</h3>
  <h2>Another Section</h2>
```

### ❌ Bad: Skipped Levels

```erb
<h1>Page Title</h1>
  <h3>Subsection</h3>  <!-- Skipped h2! -->
```

### ❌ Bad: Multiple H1s

```erb
<h1>Main Title</h1>
<h1>Another Title</h1>  <!-- Should be h2! -->
```

### Rails Helper

Use a helper to manage heading levels:

```ruby
# app/helpers/application_helper.rb
def heading(text, level: 2)
  content_tag("h#{level}", text)
end
```

## Landmarks

### ✅ Good: Semantic Structure

```erb
<body>
  <header>
    <nav>
      <!-- Navigation -->
    </nav>
  </header>
  
  <main>
    <%= yield %>
  </main>
  
  <footer>
    <!-- Footer content -->
  </footer>
</body>
```

### ARIA Landmarks

If you can't use semantic HTML:

```erb
<div role="main">
  <%= yield %>
</div>

<div role="navigation">
  <!-- Navigation -->
</div>
```

## Tables

### ✅ Good: Proper Headers

```erb
<table>
  <thead>
    <tr>
      <th>Name</th>
      <th>Email</th>
      <th>Role</th>
    </tr>
  </thead>
  <tbody>
    <% @users.each do |user| %>
      <tr>
        <td><%= user.name %></td>
        <td><%= user.email %></td>
        <td><%= user.role %></td>
      </tr>
    <% end %>
  </tbody>
</table>
```

### With Caption

```erb
<table>
  <caption>User Directory</caption>
  <thead>
    <!-- ... -->
  </thead>
</table>
```

## Skip Links

Add skip navigation links:

```erb
<a href="#main-content" class="skip-link">Skip to main content</a>

<header>
  <!-- Navigation -->
</header>

<main id="main-content">
  <%= yield %>
</main>
```

```css
.skip-link {
  position: absolute;
  top: -40px;
  left: 0;
  background: #000;
  color: #fff;
  padding: 8px;
  text-decoration: none;
  z-index: 100;
}

.skip-link:focus {
  top: 0;
}
```

## Modals and Dialogs

### ✅ Good: Focusable Elements

```erb
<div role="dialog" aria-labelledby="modal-title">
  <h2 id="modal-title">Confirm Action</h2>
  <p>Are you sure?</p>
  <button>Cancel</button>
  <button>Confirm</button>
</div>
```

### Focus Management

Use JavaScript to trap focus:

```javascript
// Trap focus in modal
const modal = document.querySelector('[role="dialog"]');
const focusableElements = modal.querySelectorAll(
  'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
);
const firstElement = focusableElements[0];
const lastElement = focusableElements[focusableElements.length - 1];

firstElement.focus();
```

## Color and Contrast

### ✅ Good: Sufficient Contrast

```erb
<!-- Dark text on light background -->
<p style="color: #000; background: #fff;">Readable text</p>

<!-- Light text on dark background -->
<p style="color: #fff; background: #000;">Readable text</p>
```

### ❌ Bad: Low Contrast

```erb
<!-- Hard to read -->
<p style="color: #ccc; background: #fff;">Poor contrast</p>
```

### Tools

- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- Browser DevTools (Chrome Lighthouse)

## Common Patterns

### Breadcrumbs

```erb
<nav aria-label="Breadcrumb">
  <ol>
    <li><%= link_to "Home", root_path %></li>
    <li><%= link_to "Products", products_path %></li>
    <li aria-current="page"><%= @product.name %></li>
  </ol>
</nav>
```

### Error Messages

```erb
<% if @user.errors.any? %>
  <div role="alert" aria-live="polite">
    <h2>Please fix the following errors:</h2>
    <ul>
      <% @user.errors.full_messages.each do |message| %>
        <li><%= message %></li>
      <% end %>
    </ul>
  </div>
<% end %>
```

### Loading States

```erb
<button aria-busy="true" aria-label="Loading...">
  <span class="spinner"></span>
  <span class="visually-hidden">Loading</span>
</button>
```

## Testing Your Views

Run Rails A11y checks:

```bash
# Run all system tests
bundle exec rspec spec/system/

# Check specific routes
bundle exec rails_a11y check --routes home_path about_path
```

## Resources

- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [WebAIM](https://webaim.org/) - Accessibility resources
- [A11y Project](https://www.a11yproject.com/) - Community-driven
- [MDN Accessibility](https://developer.mozilla.org/en-US/docs/Web/Accessibility)

## Next Steps

- **Run checks regularly** - Catch issues early
- **Review with screen readers** - Test with NVDA, JAWS, or VoiceOver
- **Keyboard testing** - Navigate without a mouse
- **Color blindness** - Test with color blindness simulators

---

**Remember:** Accessibility isn't optional—it's a requirement. These practices make your app usable for everyone.

