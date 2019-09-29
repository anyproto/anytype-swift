# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'AnyType' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for AnyType
	pod 'Textile'
	
end

class TargetSanitizer
  class << self
    def disable_bitcode(target)
      target.build_configurations.each do |config|
        config.build_settings['ENABLE_BITCODE'] = 0
      end
    end
    def disable_warnings(target)
      sources = target.source_build_phase
      source_files = sources.files
      unless source_files.nil?
        target.add_file_references(source_files.map(&:file_ref), '-w')
      end
    end

    def disable_analyze_action(target)
      target.build_configurations.each do |config|
        config.build_settings['OTHER_CFLAGS'] = "$(inherited) -Qunused-arguments -Xanalyzer -analyzer-disable-all-checks"
      end
    end
    def copy_symroot(build_configurations, from, to) # build configuration names
      from_configuration = build_configurations.select{|b| b.name == from}.first
      to_configuration = build_configurations.select{|b| b.name == to}.first

      if from_configuration && to_configuration
        to_configuration.build_settings['SYMROOT'] = from_configuration.build_settings['SYMROOT']
      end
    end
  end
end

class ProjectSanitizer
  class << self
    def copy_release_to_public_beta(project)
      copy_symroot(project.build_configurations, 'Release', 'PublicBeta')
    end
  end
end

class SwiftSanitizer
  class << self
    SWIFT_VERSION = '5.1'
    def set_swift_version(target)
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = SWIFT_VERSION
      end
    end
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    # disble bitcode for now.
    TargetSanitizer.disable_bitcode(target)

    # if we would like to forget about warnings from pods, uncomment it.
    TargetSanitizer.disable_warnings(target)

    # disable analyze action for pods is a great idea!
    TargetSanitizer.disable_analyze_action(target)

    # maybe later we need it.
    # some pods don't have right swift version.
    # SwiftSanitizer.set_swift_version(target)

  end
  # maybe later we want another configuration "PublicBeta".
  # TargetSanitizer.copy_release_to_public_beta(installer.pods_project)
end
