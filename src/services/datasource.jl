module Datasource

using ...Julitasks.Types

export get, put

"""
    get(datasource::DatasourceService, key::AbstractString; force::Bool=false)

Get in input from remote. Optionally override the cache.
"""
function get(datasource::DatasourceService, key::AbstractString;
        override_cache::Bool=false)
    error("get is not implemented for $datasource")
end

"""
    get{String <: AbstractString}(datasource::DatasourceService,
        key::Array{AbstractString, 1};

Get in multiple inputs from remote. Optionally override the cache.
"""
# Using parametrics because as of 0.4.6 can not promote Array{ASCIIString, 1}
# to Array{AbstractString, 1}
function get{String <: AbstractString}(datasource::DatasourceService,
        keys::Array{String, 1}; override_cache::Bool=false)
    return map((key) -> Datasource.get(datasource, key;
        override_cache=override_cache), keys)
end

"""
    put!(datasource::DatasourceService, key::AbstractString,
        new_value::Union{IO, Void}=nothing; only_cache::Bool=false)

Put in a new object from cache into remote, optionally put a new object into
cache first.
"""
function put!(datasource::DatasourceService, key::AbstractString,
        new_value::Union{IO, Void}=nothing; only_cache::Bool=false)
    error("put! is not implemented for $datasource")
end

"""
    put!{String <: AbstractString, I <: IO}(
        datasource::DatasourceService, keys::Array{String, 1},
        new_values::Array{I, 1}; only_cache::Bool=false)

Put multiple outputs we have in cache to remote, optionally put a new object
into cache first.
"""
# Using parametrics because as of 0.4.6 can not promote Array{ASCIIString, 1}
# to Array{AbstractString, 1}
function put!{String <: AbstractString, I <: IO}(
        datasource::DatasourceService, keys::Array{String, 1},
        new_values::Array{I, 1}; only_cache::Bool=false)
    return map((index) -> Datasource.put!(datasource, keys[index],
        new_values[index]; only_cache=only_cache), 1:length(keys))
end

function put!{String <: AbstractString}(
        datasource::DatasourceService, keys::Array{String, 1};
        only_cache::Bool=false)
    return map((index) -> Datasource.put!(datasource, keys[index],
        nothing; only_cache=only_cache), 1:length(keys))
end

end # module Datasource
