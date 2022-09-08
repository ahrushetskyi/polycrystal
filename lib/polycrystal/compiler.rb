# frozen_string_literal: true

module Polycrystal
  class Compiler
    attr_reader :build_path, :registry

    def initialize(build_path:, registry: Polycrystal::Registry.instance)
      @build_path = build_path
      @registry = registry
      # load anyolite
      add_anyolite
    end

    def prepare
      # load anyolite
      add_anyolite
      # write crystal entrypoint
      in_file.write(entrypoint)
      in_file.close
    end

    def execute
      # run compiler
      puts command
      raise 'Failed to compile crystal module' unless system(command)

      outfile
    end

    def add_anyolite
      registry.register(
        path: find_anyolite,
        file: 'anyolite/anyolite',
        unshift: true
      )
    end

    def crystal_paths
      registry.map(&:path).select { |p| p&.length&.positive? }
    end

    def crystal_files
      registry.map(&:file).select { |p| p&.length&.positive? }
    end

    def crystal_modules
      registry.select { |m| m.modules&.size&.positive? }.flat_map(&:modules)
    end

    def entrypoint
      <<~CRYSTAL
        #{requires.join("\n")}

        FAKE_ARG = "polycrystal"

        fun __polycrystal_init
            GC.init
            ptr = FAKE_ARG.to_unsafe
            LibCrystalMain.__crystal_main(1, pointerof(ptr))
            puts "Polycrystal init"
        end

        fun __polycrystal_module_run
            puts "Polycrystal module run"
            rbi = Anyolite::RbInterpreter.new#{' '}
            Anyolite::HelperClasses.load_all(rbi)
        #{pad_lines(wraps, 4).join("\n")}
        end
      CRYSTAL
    end

    def wraps
      crystal_modules.map do |mod|
        "Anyolite.wrap rbi, #{mod}"
      end
    end

    def requires
      crystal_files.map do |f|
        "require \"#{f.sub(/\.cr$/, '')}\""
      end
    end

    def command
      "#{include_paths} #{anyolite_glue} #{compiler_cmd} build #{in_file.path} --link-flags \"#{crystal_link_flags}\" -o #{outfile} --release " \
        '-Danyolite_implementation_ruby_3 -Duse_general_object_format_chars -Dexternal_ruby'
    end

    def crystal_link_flags
        case RUBY_PLATFORM
        when /darwin/
            "-dynamic -bundle"
        when /linux/
            "-shared -pie"
        else
            raise "Unknown platform"
        end
    end

    def pad_line(line, n)
      "#{' ' * n}#{line}"
    end

    def pad_lines(lines, n)
      lines.map { |l| pad_line(l, n) }
    end

    def in_file
      @in_file ||= File.new(File.expand_path("#{build_path}/polycrystal_module.cr"), 'w')
    end

    def outfile
      File.expand_path("#{build_path}/polycrystal_module.#{lib_ext}")
    end

    def lib_ext
        case RUBY_PLATFORM
        when /darwin/
            "bundle"
        when /linux/
            "so"
        else
            raise "Unknown platform"
        end
    end

    def include_paths
      existing = `#{compiler_cmd} env`.split("\n").find { |line| line.start_with?('CRYSTAL_PATH') }
      [existing, *crystal_paths].join(':')
    end

    def anyolite_glue
      # "DLDFLAGS"=>"-L/Users/ahrushetskyi/.rbenv/versions/3.0.4/lib  -Wl,-undefined,dynamic_lookup -Wl,-multiply_defined,suppress"
      env = "-L#{RbConfig::CONFIG['libdir']} #{RbConfig::CONFIG['LIBRUBYARG_SHARED']} " \
            "#{File.expand_path("#{__dir__}/../../ext/polycrystal/data_helper.o")} " \
            "#{File.expand_path("#{__dir__}/../../ext/polycrystal/error_helper.o")} " \
            "#{File.expand_path("#{__dir__}/../../ext/polycrystal/return_functions.o")} " \
            "#{File.expand_path("#{__dir__}/../../ext/polycrystal/script_helper.o")} "

      "ANYOLITE_LINK_GLUE=\"#{env}\""
    end

    def compiler_cmd
      'crystal'
    end

    def find_anyolite
      default_path = File.expand_path("#{__dir__}/../../crystal")
      local_path = File.expand_path("#{build_path}/deps")
      if File.exist?("#{local_path}/anyolite/anyolite.cr")
        local_path
      elsif File.exist?("#{default_path}/anyolite/anyolite.cr")
        default_path
      else
        load_anyolite(local_path)
      end
    end

    def load_anyolite(local_path)
      FileUtils.mkdir_p(local_path)

      system("git clone -b external-ruby https://github.com/ahrushetskyi/anyolite.git #{local_path}/anyolite")

      local_path
    end
  end
end
