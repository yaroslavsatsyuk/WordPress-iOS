#!/usr/bin/env ruby

require 'xcodeproj'
require 'cocoapods'
require 'fileutils'
require 'json'

def inject_build_time_profiling_build_phases(project_path, output_hash = {})
    project = Xcodeproj::Project.open(project_path)

    log_time_before_build_phase_name = '[Prefix placeholder] Log time before build'.freeze
    log_time_after_build_phase_name = '[Prefix placeholder] Log time after build'.freeze

    puts "Patching project at path: #{project_path}"
    puts
    project.targets.each do |target|
        puts "Target: #{target.name}"

        puts "Writing JSON content"
        File.open("#{$build_time_logs_output_directory}/#{target.name}.json","w") do |f|
            f.write(JSON.pretty_generate({ start: nil, end: nil, difference: nil }))
        end

        first_build_phase = create_leading_build_phase(target, log_time_before_build_phase_name)
        last_build_phase = create_trailing_build_phase(target, log_time_after_build_phase_name)

        puts
    end

    project.save

    puts "Finished patching project at path: #{project_path}"
    puts

    output_hash
end

def create_leading_build_phase(target, build_phase_name)
    remove_existing_build_phase(target, build_phase_name)

    build_phase = create_build_phase(target, build_phase_name)

    shift_build_phase_leftwards(target, build_phase)

    is_build_phase_leading = true

    inject_shell_code_into_build_phase(target, build_phase, is_build_phase_leading)

    return build_phase
end

def create_trailing_build_phase(target, build_phase_name)
    remove_existing_build_phase(target, build_phase_name)

    build_phase = create_build_phase(target, build_phase_name)

    is_build_phase_leading = false

    inject_shell_code_into_build_phase(target, build_phase, is_build_phase_leading)

    return build_phase
end

def remove_existing_build_phase(target, build_phase_name)
    existing_build_phase = target.shell_script_build_phases.find do |build_phase|
        !build_phase.name.nil? && build_phase.name.end_with?(build_phase_name)
        # We use `end_with` instead of `==`, because `cocoapods` adds its `[CP]` prefix to a `build_phase_name`
    end

    if !existing_build_phase.nil?
        puts "deleting build phase #{existing_build_phase.name}"

        target.build_phases.delete(existing_build_phase)
    end
end

def create_build_phase(target, build_phase_name)
    puts "creating build phase: #{build_phase_name}"

    build_phase = Pod::Installer::UserProjectIntegrator::TargetIntegrator
        .create_or_update_build_phase(target, build_phase_name)

    return build_phase
end

def shift_build_phase_leftwards(target, build_phase)
    puts "moving build phase leftwards: #{build_phase.name}"

    target.build_phases.unshift(build_phase).uniq! unless target.build_phases.first == build_phase
end

def inject_shell_code_into_build_phase(target, build_phase, is_build_phase_leading)
    start_or_end = is_build_phase_leading ? "start" : "end"

    ruby_script = <<~RUBY
        require 'json'
        filename = '#{$build_time_logs_output_directory}/#{target.name}.json'
        hash = JSON.parse(File.read(filename))
        now = Time.now.to_f
        hash['#{start_or_end}'] = now
        if '#{start_or_end}' == 'end' && !hash['start'].nil? then
            hash['difference'] = now - hash['start']
            File.open('#{$build_time_logs_output_directory}/results.txt', 'a') { |f| f.puts '#{target.name} : ' + hash['difference'].to_s }
        end
        File.open(filename,'w') { |f| f.write(JSON.pretty_generate(hash)) }
    RUBY

    build_phase.shell_script = <<~SH
        ruby -e "#{ruby_script.gsub("\n",";")}"
    SH
end

def parse_arguments
    $build_time_logs_output_directory = ARGV[0]

    if $build_time_logs_output_directory.to_s.empty? || ! $build_time_logs_output_directory.start_with?("/")
        puts "Error: you should pass a full path to a output file as an script's argument. Example:"
        puts "$ruby prepare-for-target-build-time-profiling.rb /path/to/script/output.txt"
        puts
        exit 1
    end
end

def print_arguments
    puts "Arguments:"
    puts "Output path: #{$build_time_logs_output_directory}"
    puts
end

def clean_up_before_script
    if File.exist?($build_time_logs_output_directory)
        FileUtils.rm_rf($build_time_logs_output_directory)
    end

    unless File.directory?($build_time_logs_output_directory)
        FileUtils.mkdir_p($build_time_logs_output_directory)
    end
end

def main 
    parse_arguments
    print_arguments
    clean_up_before_script
    inject_build_time_profiling_build_phases("WordPress/WordPress.xcodeproj")
    inject_build_time_profiling_build_phases("Pods/Pods.xcodeproj")
end

# arguments:
$build_time_logs_output_directory

main
