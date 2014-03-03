threads Integer(ENV['MIN_THREADS']  || 1), Integer(ENV['MAX_THREADS'] || 16)
workers Integer(ENV['PUMA_WORKERS'] || 3)

port        ENV['PORT']     || 0 # using 0 tells the OS to grab first open port
environment ENV['RACK_ENV'] || 'development'
preload_app!

Thread.abort_on_exception = true

on_worker_boot do
end
