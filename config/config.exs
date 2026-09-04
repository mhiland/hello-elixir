import Config

# The HTTP client behind HelloWorld.Fetcher. Tests swap in a Mox mock.
config :hello_world, http_client: HelloWorld.HTTPClient.HTTPoison

if config_env() == :test do
  config :hello_world, http_client: HelloWorld.HTTPClient.Mock
end
