import Mix.Config

# 默认日志级别为 :debug。
config :logger, level: :debug

# 默认操作的文件们为开发/测试文件。
config :text_state_server,
  state_file: "files/config.txt",
  tmp_file2: "files/tmp_file2",
  tmp_file3: "files/tmp_file3",
  # 默认端口为 21337。
  port: 21337

import_config "#{Mix.env()}.exs"
