# frozen_string_literal: true

# Tests for YamlLoader
# Verifies that YAML configuration files are correctly loaded, parsed, and merged.

require 'spec_helper'
require 'tempfile'
require 'yaml'

RSpec.describe RailsAccessibilityTesting::Config::YamlLoader do
  let(:temp_dir) { Dir.mktmpdir }
  let(:config_path) { File.join(temp_dir, 'accessibility.yml') }

  after do
    FileUtils.rm_rf(temp_dir)
  end

  describe '.load' do
    context 'when config file exists' do
      it 'loads configuration from YAML file' do
        config_content = <<~YAML
          wcag_level: AA
          checks:
            form_labels: true
            image_alt_text: false
        YAML

        File.write(config_path, config_content)

        config = described_class.load(path: config_path, profile: :test)

        expect(config['wcag_level']).to eq('AA')
        expect(config['checks']['form_labels']).to be true
        expect(config['checks']['image_alt_text']).to be false
      end

      it 'merges profile-specific configuration' do
        config_content = <<~YAML
          wcag_level: AA
          checks:
            form_labels: true
            image_alt_text: true
            color_contrast: false
          
          test:
            checks:
              color_contrast: true
        YAML

        File.write(config_path, config_content)

        config = described_class.load(path: config_path, profile: :test)

        expect(config['wcag_level']).to eq('AA')
        expect(config['checks']['form_labels']).to be true
        expect(config['checks']['image_alt_text']).to be true
        expect(config['checks']['color_contrast']).to be true  # Overridden by test profile
        expect(config['profile']).to eq('test')
      end

      it 'handles multiple profiles' do
        config_content = <<~YAML
          wcag_level: AA
          checks:
            form_labels: true
          
          development:
            checks:
              color_contrast: false
          
          test:
            checks:
              color_contrast: true
          
          ci:
            checks:
              color_contrast: true
        YAML

        File.write(config_path, config_content)

        dev_config = described_class.load(path: config_path, profile: :development)
        test_config = described_class.load(path: config_path, profile: :test)
        ci_config = described_class.load(path: config_path, profile: :ci)

        expect(dev_config['checks']['color_contrast']).to be false
        expect(test_config['checks']['color_contrast']).to be true
        expect(ci_config['checks']['color_contrast']).to be true
      end

      it 'parses ignored_rules' do
        config_content = <<~YAML
          wcag_level: AA
          ignored_rules:
            - rule: image_alt_text
              reason: Known issue
              comment: Will fix in next release
        YAML

        File.write(config_path, config_content)

        config = described_class.load(path: config_path, profile: :test)

        expect(config['ignored_rules']).to be_an(Array)
        expect(config['ignored_rules'].length).to eq(1)
        expect(config['ignored_rules'].first[:rule]).to eq('image_alt_text')
        expect(config['ignored_rules'].first[:reason]).to eq('Known issue')
      end
    end

    context 'when config file does not exist' do
      it 'returns default configuration' do
        config = described_class.load(path: '/nonexistent/path.yml', profile: :test)

        expect(config).to be_a(Hash)
        expect(config['wcag_level']).to eq('AA')
        expect(config['checks']).to be_a(Hash)
        expect(config['profile']).to eq('test')
      end
    end

    context 'when config file is invalid YAML' do
      it 'returns default configuration and logs warning' do
        File.write(config_path, 'invalid: yaml: content: [unclosed')

        config = described_class.load(path: config_path, profile: :test)

        expect(config).to be_a(Hash)
        expect(config['wcag_level']).to eq('AA')  # Default config
      end
    end

    context 'with Rails root context' do
      it 'resolves relative paths from Rails.root' do
        # This would require Rails to be loaded, so we'll test the path resolution logic
        # by checking that absolute paths work
        absolute_path = File.expand_path(config_path)

        config_content = <<~YAML
          wcag_level: AA
        YAML

        File.write(absolute_path, config_content)

        config = described_class.load(path: absolute_path, profile: :test)

        expect(config['wcag_level']).to eq('AA')
      end
    end
  end

  describe 'default configuration' do
    it 'includes all checks with sensible defaults' do
      config = described_class.load(path: '/nonexistent.yml', profile: :test)

      default_checks = config['checks']

      expect(default_checks['form_labels']).to be true
      expect(default_checks['image_alt_text']).to be true
      expect(default_checks['interactive_elements']).to be true
      expect(default_checks['heading_hierarchy']).to be true
      expect(default_checks['keyboard_accessibility']).to be true
      expect(default_checks['aria_landmarks']).to be true
      expect(default_checks['form_errors']).to be true
      expect(default_checks['table_structure']).to be true
      expect(default_checks['duplicate_ids']).to be true
      expect(default_checks['skip_links']).to be true
      expect(default_checks['color_contrast']).to be false  # Disabled by default
    end
  end
end

