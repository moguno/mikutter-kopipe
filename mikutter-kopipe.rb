# coding:UTF-8

Plugin.create(:mikutter_kopipe) {
  require "yaml"
  require "erb"

  def kopipe_dir()
    File.join(Environment::CONFROOT, 'kopipe')
  end

  def eval_erb(erb_code, message, name, screen_name)
    erb = ERB.new(erb_code, 2)
    erb.result(binding)
  end

  def register_command(slug, yaml)
    command("kopipe_#{slug}".to_sym,
            condition: lambda { |opt| true },
            name: yaml["title"],
            visible: true,
            role: :timeline) { |opt|

              opt.messages.each { |msg|
                erb_message = yaml["text"].sample.untaint
                message = eval_erb(erb_message, msg[:message], msg[:user][:name], msg[:user][:idname])

                Service.primary.post(message: message)
              }
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
