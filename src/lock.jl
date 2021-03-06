include("etcdserver.jl")

lock_prefix(etcd::EtcdServer,
            lock::String) = "http://$(etcd.ip):$(etcd.port)/mod/$(etcd.version)/lock/$(lock)"

# blocking until lock is available
# TODO should add an async lock
function lock_acquire(etcd::EtcdServer,lock::String;ttl::Union(Int,Nothing)=nothing)
    if is(ttl,nothing)
        warn("Must specify an integer value for lock ttl")
    else
        etcd_request(:post,lock_prefix(etcd,lock),{"ttl"=>ttl}) |>
        check_etcd_error
    end
end

function lock_renew(etcd::EtcdServer,lock::String;
                    index::Union(Int,Nothing)=nothing,
                    ttl::Union(Int,Nothing)=nothing)

    if is(index,nothing) && is(ttl,nothing)
        warn("Must specify an integer value for lock index and ttl")
    else
        etcd_request(:put,lock_prefix(etcd,lock),{"index"=>index,
                                                          "ttl"=>ttl}) |>
        check_etcd_error
    end
end

function lock_release(etcd::EtcdServer,lock::String;
                      index::Union(Int,Nothing)=nothing)
    if is(index,nothing)
        warn("Must specify an integer value for lock index")
    else
        etcd_request(:delete,lock_prefix(etcd,lock),{"index"=>index}) |>
        check_etcd_error
    end
end

function lock_retrieve(etcd::EtcdServer,lock::String)
    etcd_request(:get,lock_prefix(etcd,lock),{"field"=>"index"}) |>
    check_etcd_error
end
