Datadog.configure do |c|
    # This will activate auto-instrumentation for Rails
    c.tracing.instrument :rails, service_name: 'store-frontend'
    c.tracing.instrument :active_support, cache_service: 'store-frontend-cache'
    c.tracing.instrument :active_record, service_name: 'store-frontend-sqlite'
    # Make sure requests are also instrumented
    c.tracing.instrument :http, service_name: 'store-frontend'
  end