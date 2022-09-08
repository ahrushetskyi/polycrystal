class CrystalModule
    class SomeThing
        def some_method
            69.0
        end
    end

    class CrystalClass
        def crystal_method
            return 42
        end

        def return_object
            SomeThing.new
        end

        def recv_arg(arg : Int64) : Void
            puts "Received #{arg}"
        end
    end
end

puts CrystalModule::CrystalClass.new.return_object.some_method
