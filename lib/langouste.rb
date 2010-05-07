#!/usr/bin/env ruby

require 'rubygems'
require 'mechanize'
require 'symboltable'

# Translation through various online services
module Langouste

  # Singleton configuration class
  class Configuration
    attr_accessor :path, :data

    def initialize(path = nil)
      @path = path || File.join(File.expand_path(File.dirname(__FILE__)), '../config/langouste.yaml')
      @data = SymbolTable.new YAML.load_file @path
    end

    def self.instance(path = nil)
        @__instance__ ||= new
    end

    def self.list(config_path = nil)
      Configuration.instance(config_path).data.services.keys
    end

  end

  # Langouste translator
  class Translator
    attr_accessor :service, :from_lang, :to_lang

    def initialize(options = {})
      options = {
        :from_lang  => :russian,
        :to_lang    => :english,
        :service    => :google,
        :path       => nil
      }.merge options

      config = Configuration.instance(options[:path])

      @service     = deabbreviate_service(options[:service])
      @from_lang   = deabbreviate_language(options[:from_lang])
      @to_lang     = deabbreviate_language(options[:to_lang])
      @direction   = "#{@from_lang}-#{@to_lang}"
      @config      = config.data.services[@service]

    end

    def translate(input_text)

      return '' if not has_languages? or input_text.empty?

      agent = Mechanize.new {|a| a.user_agent_alias = 'Linux Konqueror'}

      input_form = @config.input.form
      page = agent.get(@config.url)
      translated_page = page.form_with(input_form.selector) do |form|
        fill_form form, input_form, input_text
      end.submit

      get_translation translated_page, @config.output

    end

    private

    def deabbreviate_language(language)
      Configuration.instance.data.abbreviations.languages[language] || language
    end

    def deabbreviate_service(service)
      Configuration.instance.data.abbreviations.services[service] || service
    end

    def has_languages?
      input_form = @config.input.form
      if input_form.to and input_form.from
        return false unless input_form.to.languages[@to_lang] and input_form.from.languages[@from_lang]
      elsif input_form.directions
        return false unless input_form.directions.directions[@direction]
      end
      return true
    end

    def fill_form(form, config_form, input_text)
      to, from, directions, text = config_form.to, config_form.from, config_form.directions, config_form.text

      if directions and directions.field and directions.field.selector
        set_field_option form.field_with(directions.field.selector), directions.directions[@direction]
      else
        if from and from.field and from.field.selector
          set_field_option form.field_with(from.field.selector), from.languages[@from_lang]
        end
        if to and to.field and to.field.selector
          set_field_option form.field_with(to.field.selector), to.languages[@to_lang]
        end
      end

      form_text_field = form.field_with(text.selector)
      form_text_field.value = input_text
    end

    def set_field_option(field, value)
      field.option_with(:value => value).select
    end

    def get_translation(page, config_output)

      translation = if config_output.xpath
        page.search(config_output.xpath)
      else
        output_form = config_output.form
        page.form_with(output_form.selector).field_with(output_form.text.selector).value
      end

      translation ? translation.to_s : ''
    end

  end

end
