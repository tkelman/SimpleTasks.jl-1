module TestTasks

using SimpleTasks.Types

import SimpleTasks.Tasks.DaemonTask
import SimpleTasks.Tasks.BasicTask
import SimpleTasks.Services.Datasource

export TEST_ID, TEST_TASK_NAME, TEST_BASE_DIRECTORY, TEST_INPUTS
export make_valid_basic_info

export MockTaskNoExecute, MockTaskExecute
export make_valid_task_execute, make_valid_task_no_execute

const TEST_ID = 1
const TEST_TASK_NAME = "test_name"
const TEST_BASE_DIRECTORY = "base_directory"
const TEST_INPUTS = ["input_1", "input_2"]
function make_valid_basic_info()
    return BasicTask.Info(TEST_ID, TEST_TASK_NAME, TEST_BASE_DIRECTORY,
        TEST_INPUTS)
end

type MockTaskNoExecute <: DaemonTaskDetails
    basic_info::BasicTask.Info
    payload_info::AbstractString
end

type MockTaskExecute <: DaemonTaskDetails
    basic_info::BasicTask.Info
    payload_info::AbstractString
end
# register a registered test task
function DaemonTask.execute(task::MockTaskExecute,
        datasource::DatasourceService)
    println("executing")
end

function make_valid_task_no_execute()
    return MockTaskNoExecute(make_valid_basic_info(),
        "Mock Task No Execute")
end

function make_valid_task_execute()
    return MockTaskExecute(make_valid_basic_info(),
        "Mock Task Execute")
end

end # module MockTasks
