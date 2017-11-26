raw_config = File.read("#{Rails.root}/config/answers.yml")
ANSWERS = YAML.load(raw_config)
