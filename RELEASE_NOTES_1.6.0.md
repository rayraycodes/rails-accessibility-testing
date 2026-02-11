# Release Notes for Version 1.6.0

## Summary

Version 1.6.0 addresses critical false positive issues in the static file scanner, particularly for Rails applications using ERB templates with dynamic form elements. This release significantly improves accuracy and reduces noise in accessibility testing reports.

## Key Improvements

### 🐛 **Fixed False Positives for Dynamic Form Elements**
- **Problem Solved**: The scanner was incorrectly flagging checkbox and radio button groups with ERB-generated IDs (e.g., `collection_answers_<%= question.id %>_<%= option.id %>_`) as missing labels or duplicate IDs.
- **Solution**: Enhanced ERB template processing to preserve dynamic ID structure instead of collapsing them, allowing accurate label-to-input matching.
- **Impact**: Eliminates false positives for common Rails patterns like checkbox groups in loops, making the scanner more reliable for real-world applications.

### 🔍 **Enhanced ERB Template Handling**
- Improved static analysis of ERB templates to correctly handle:
  - Dynamic IDs in form inputs
  - String interpolation in `label_tag` helpers
  - Raw HTML elements with ERB expressions in attributes
- The scanner now preserves the structure of dynamic IDs (using `ERB_CONTENT` placeholders) rather than collapsing them, enabling accurate accessibility checks.

### ✅ **Improved Accessibility Rule Accuracy**
- **Form Labels Check**: Now correctly matches labels to inputs with dynamic IDs from ERB templates
- **Duplicate ID Detection**: Intelligently excludes dynamic IDs from duplicate checking (prevents false positives for checkbox/radio groups)
- **Interactive Elements Check**: Fixed detection for links with `href="#"` - now only flags links that truly lack accessible names, avoiding false positives for valid anchor links

### 📝 **Better Test Integration**
- Refactored RSpec test file to properly assert on errors (tests now fail when accessibility errors are found)
- Extracted formatting logic into reusable helpers
- Warnings are displayed but don't fail tests (only errors cause failures)

### 📚 **Documentation Updates**
- Added comprehensive documentation on ERB template handling
- Updated architecture docs with details on dynamic ID processing
- Added examples for common Rails patterns

## Technical Details

The core improvement is in the `ErbExtractor` class, which now processes raw HTML elements with ERB in attributes before removing ERB tags. This preserves the structure of dynamic IDs like `collection_answers_ERB_CONTENT_ERB_CONTENT_` instead of collapsing them to just `collection_answers`, enabling accurate matching between inputs and labels.

## Impact

This release makes the static file scanner significantly more reliable for Rails applications, reducing false positives by correctly handling common ERB patterns. Teams can now trust the scanner results more, leading to faster development cycles and more accurate accessibility compliance reporting.


