namespace :websocket_rails do

  def args
    fetch(:websocket_rails_args, "")
  end

  def websocket_rails_roles
    fetch(:websocket_rails_server_role, :app)
  end

  desc 'Stop the websocket_rails process'
  task :stop do
    on roles(websocket_rails_roles) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          begin
            execute :rake, 'websocket_rails:stop_server', args
          rescue
            nil
          end
        end
      end
    end
  end

  desc 'Start the websocket_rails process'
  task :start do
    on roles(websocket_rails_roles) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'websocket_rails:start_server', args
        end
      end
    end
  end

  desc 'Restart the websocket_rails process'
  task :restart do
    on roles(websocket_rails_roles) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          invoke 'websocket_rails:stop'
          invoke 'websocket_rails:start'
        end
      end
    end
  end

end