every 1.minute do
  runner "ColorWorker.perform_async(:everyone_report, nil)"
end