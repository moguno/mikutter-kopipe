# coding:UTF-8

Plugin.create(:mikutter_kopipe) {
  require "yaml"

  def kopipe_dir()
    File.join(Environment::CONFROOT, 'kopipe')
  end

  def register_command(slug, yaml)
    command("kopipe_#{slug}".to_sym,
            condition: lambda { |opt| true },
            name: yaml["title"],
            visible: true,
            role: :timeline) { |opt|
              message = yaml["text"].sample

              Service.primary.post(message: message)
            }
  end

  on_boot { |service|
    Dir.glob(File.join(kopipe_dir, "*.yaml")) { |file|
      begin
        yaml = File.open(file) { |fp| YAML.load(fp) }

        register_command(File.basename(file), yaml)        
      rescue => e
        puts e
        puts e.backtrace
      end
    }
  }
}
