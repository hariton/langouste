#!/usr/bin/env ruby

require 'rubygems'
require 'mechanize'

class Langouste
  attr_accessor :from_lang, :to_lang, :service, :config

  @@config_path = File.join(File.expand_path(File.dirname(__FILE__)), '../config/langouste.yaml')

  def self.config
    @@config ||= YAML.load(File.open(@@config_path))
  end

  def self.config=(config)
    @@config = config
  end

  def initialize(options = {})
    options = {
      :from_lang  => :russian,
      :to_lang    => :english,
      :service    => :google,
      :config     => @@config_path
    }.merge options

    Langouste.config = YAML.load(File.open(options[:config]))

    @from_lang   = deabbreviate_language(options[:from_lang])
    @to_lang     = deabbreviate_language(options[:to_lang])
    @service     = deabbreviate_service(options[:service])
    @config      = Langouste.config[@service]
  end

  def translate(input_text)

    output_text = ''

    begin
      input_form = config['input']['form']
    rescue
      raise "Bad service: '#{service}'"
    end

    # если у переводчика нет нужных языков - запрос не выполняется
    if input_form['to'] and input_form['from']
      return '' unless input_form['to']['languages'][to_lang] and input_form['from']['languages'][from_lang]
    elsif input_form['directions']
      return '' unless input_form['directions']['directions']["#{from_lang}-#{to_lang}".to_sym]
    else
      raise "Bad YAML-config for service: '#{service}'"
    end

    agent = Mechanize.new {|a| a.user_agent_alias = 'Linux Konqueror'}

    agent.get(config['url']) do |page|

      translated_page = page.form_with(input_form['selector']) do |form|

        text = form.field_with(input_form['text']['selector'])
        text.value = input_text

        if input_form['directions'] and input_form['directions']['field']['selector']

          value = input_form['directions']['directions']["#{from_lang}-#{to_lang}".to_sym]
          direction = form.field_with(input_form['directions']['field']['selector'])
          direction.option_with(:value => value).select

        else

          if input_form['from'] and input_form['from']['field'] and input_form['from']['field']['selector']

            value = input_form['from']['languages'][from_lang]
            from_lang = form.field_with(input_form['from']['field']['selector'])
            from_lang.option_with(:value => value).select

          end

          if input_form['to'] and input_form['to']['field'] and input_form['to']['field']['selector']

            value = input_form['to']['languages'][to_lang]
            to_lang = form.field_with(input_form['to']['field']['selector'])
            to_lang.option_with(:value => value).select

          end

        end

      end.submit

      output_text = if config['output']['xpath']
        xpath = config['output']['xpath']
        translated_page.search(xpath)
      else
        output_form = config['output']['form']
        translated_page.form_with(output_form['selector']).field_with(output_form['text']['selector']).value
      end

    end

    output_text.to_s
  end

  def self.list(config_path = nil)
    Langouste.config.keys.select{|k| k.is_a?(Symbol)}
  end

  private

  def deabbreviate_language(language)
    Langouste.config['abbreviations']['languages'][language] || language
  end

  def deabbreviate_service(services)
    Langouste.config['abbreviations']['services'][services] || services
  end

end
