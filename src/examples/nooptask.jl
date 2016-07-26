"""
    NoOpTask

This module includes the composite type NoOpDetails which includes both the
        generic DaemonTask.Info and an AbstractString as a payload
"""
module NoOpTask

using ...Julitasks.Types

import Julitasks.Tasks.DaemonTask
import Julitasks.Tasks.BasicTask
import Julitasks.Services.Datasource

export NoOpTaskDetails, NAME, execute, full_input_path, full_output_path

type NoOpTaskDetails <: DaemonTaskDetails
    basicInfo::BasicTask.Info
    payloadInfo::AbstractString
end

const NAME = "NO_OP"
const OUTPUT_FOLDER = "0_output"

function full_input_path(task::NoOpTaskDetails,
        input::AbstractString)
    return "$(task.basicInfo.baseDirectory)/$input"
end

function full_output_path(task::NoOpTaskDetails,
        input::AbstractString)
    path_end = rsearch(input, "/").start + 1

    return "$(task.basicInfo.baseDirectory)/$OUTPUT_FOLDER/" *
        "$(input[path_end:end])"
end

function DaemonTask.prepare(task::NoOpTaskDetails,
        datasource::DatasourceService)
    Datasource.get(datasource,
        map((input) -> full_input_path(task, input), task.basicInfo.inputs))
end

function DaemonTask.execute(task::NoOpTaskDetails,
        datasource::DatasourceService)
    inputs = task.basicInfo.inputs

    if length(inputs) == 0
        return DaemonTask.Result(true, [])
    end

    for input in inputs
        data_stream = Datasource.get(datasource, full_input_path(task, input))
        if data_stream != nothing
            data = readall(data_stream)
            println("Input: $input contains $(data[1:min(10, end)]) \nto\n" *
                "$(data[max(1, end-10):end])")
        end
    end

    # setting new values into the cache
    output_keys = map((input) -> full_output_path(task, input), inputs);
    output_streams = map((input) ->
        Datasource.get(datasource, full_input_path(task, input)), inputs)
    Datasource.put!(datasource, output_keys, output_streams; only_cache = true)

    return DaemonTask.Result(true, output_keys)
end

function DaemonTask.finalize(task::NoOpTaskDetails,
        datasource::DatasourceService, result::DaemonTask.Result)
    if !result.success
        println("Task $(task.basicInfo.id), $(task.basicInfo.name) was " *
            "not successful")
    else
        println("Task $(task.basicInfo.id), $(task.basicInfo.name) was " *
            "completed successfully, syncing outputs to remote datasource")
        Datasource.put!(datasource,
            map((output) -> full_output_path(task, output), result.outputs))
    end
end

end # module BlockMatchTask
