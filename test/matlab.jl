function check_pressure_status(sol, gm)
    for (idx,val) in sol["junction"]
        @test val["p"] <= gm.ref[:nw][gm.cnw][:junction][parse(Int64,idx)]["pmax"]
        @test val["p"] >= gm.ref[:nw][gm.cnw][:junction][parse(Int64,idx)]["pmin"]
    end
end

function check_ratio(sol, gm)
    for (idx,val) in sol["connection"]
        k = parse(Int64,idx)
        connection = gm.ref[:nw][gm.cnw][:connection][parse(Int64,idx)]
        if connection["type"] == "compressor" || connection["type"] == "control_valve"          
            @test val["ratio"] <= connection["c_ratio_max"] + 1e-6
            @test val["ratio"] >= connection["c_ratio_min"] - 1e-6
        end
    end
end

#Check the second order code model on load shedding
@testset "test misocp ls" begin
    @testset "gaslib 40 case" begin
        result = run_ls("../test/data/matlab/gaslib40-ls.m", MISOCPGasModel, cvx_minlp_solver)
        @test result["status"] == :LocalOptimal || result["status"] == :Optimal
        @test isapprox(result["objective"]*result["solution"]["baseQ"], 516.053240741; atol = 1e-2)
     end      
end


#Check the second order code model
@testset "test misocp gf" begin
    @testset "gaslib 40" begin
        data = GasModels.parse_file("../test/data/matlab/gaslib40.m")  
        result = run_gf("../test/data/matlab/gaslib40.m", MISOCPGasModel, cvx_minlp_solver)
        @test result["status"] == :LocalOptimal || result["status"] == :Optimal
        @test isapprox(result["objective"], 0; atol = 1e-6)
        gm = GasModels.build_generic_model(data, MINLPGasModel, GasModels.post_gf)        
        check_pressure_status(result["solution"], gm)
        check_ratio(result["solution"], gm)             
    end 
    
    # @testset "24 pipe" begin
    #     data = GasModels.parse_file("../test/data/matlab/24-pipe-benchmark.m")  
    #     result = run_gf("../test/data/matlab/24-pipe-benchmark.m", MISOCPGasModel, cvx_minlp_solver)
    #     println(result["status"])
        
    #     @test result["status"] == :LocalOptimal || result["status"] == :Optimal
    #     @test isapprox(result["objective"], 0; atol = 1e-6)
    #     gm = GasModels.build_generic_model(data, MINLPGasModel, GasModels.post_gf)        
        #  check_pressure_status(result["solution"], gm)
        #  check_ratio(result["solution"], gm)             
    # end      
end







