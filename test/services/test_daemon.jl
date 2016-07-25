module TestDaemonService

using Base.Test
using JulitasksTests.Utils.TestTasks
using JulitasksTests.Utils.MockServices
using Julitasks.Services.Daemon

import Julitasks.Services.Queue
import Julitasks.Services.Bucket
import Julitasks.Services.Datasource
import Julitasks.Tasks.DaemonTask
import JSON

function test_register_no_execute_method()
    daemon = DaemonService(MockQueueService(),
        MockBucketService(),
        MockDatasourceService(), 10)
    @test_throws Exception Daemon.register!(daemon,
        TEST_TASK_NAME, MockTaskNoExecute)
end

function test_register_with_execute_method()
    daemon = DaemonService(MockQueueService(),
        MockBucketService(),
        MockDatasourceService(), 10)
    exception = nothing
    try
         Daemon.register!(daemon, TEST_TASK_NAME, MockTaskExecute)
    catch e
        exception = e
    end
    @test exception == nothing
end

function test_parse_empty()
    daemon = DaemonService(MockQueueService(),
        MockBucketService(),
        MockDatasourceService(), 10)
    @test_throws ArgumentError Daemon.parse(daemon, " ")
end

function test_parse_no_basic_info()
    daemon = DaemonService(MockQueueService(),
        MockBucketService(),
        MockDatasourceService(), 10)
    task = make_valid_task_execute()
    dict = JSON.parse(JSON.json(task))
    delete!(dict, "basicInfo")
    @test_throws KeyError Daemon.parse(daemon, JSON.json(dict))
end

function test_parse_no_payload_info()
    daemon = DaemonService(MockQueueService(),
        MockBucketService(),
        MockDatasourceService(), 10)
    task = make_valid_task_execute()
    Daemon.register!(daemon, TEST_TASK_NAME, typeof(task))
    dict = JSON.parse(JSON.json(task))
    delete!(dict, "payloadInfo")
    @test_throws KeyError Daemon.parse(daemon, JSON.json(dict))
end

function test_parse_task_not_registered()
    daemon = DaemonService(MockQueueService(),
        MockBucketService(),
        MockDatasourceService(), 10)
    task = make_valid_task_execute()
    dict = JSON.parse(JSON.json(task))

    @test_throws ErrorException Daemon.parse(daemon, JSON.json(dict))
end

function test_parse_good()
    daemon = DaemonService(MockQueueService(),
        MockBucketService(),
        MockDatasourceService(), 10)
    task = make_valid_task_execute()
    Daemon.register!(daemon, TEST_TASK_NAME, typeof(task))
    dict = JSON.parse(JSON.json(task))
    parsed_task = Daemon.parse(daemon, JSON.json(dict))
    @test parsed_task != nothing
    @test parsed_task.basicInfo.name == task.basicInfo.name
    @test parsed_task.basicInfo.id == task.basicInfo.id
    @test parsed_task.payloadInfo == task.payloadInfo

end

function __init__()
    test_register_no_execute_method()
    test_register_with_execute_method()

    test_parse_empty()
    test_parse_no_basic_info()
    test_parse_task_not_registered()
    test_parse_good()
end

end #module TestDaemon
