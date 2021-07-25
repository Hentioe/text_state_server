import Config

if config_env() == :prod do
  Dotenv.load!(".env")

  config :text_state_server,
    state_file: System.fetch_env!("TEXT_STATE_SERVER_STATE_FILE"),
    tmp_file2: System.fetch_env!("TEXT_STATE_SERVER_TMP_FILE2"),
    tmp_file3: System.fetch_env!("TEXT_STATE_SERVER_TMP_FILE3"),
    port: "TEXT_STATE_SERVER_PORT" |> System.fetch_env!() |> String.to_integer()
end
