require 'cocoapods-core'
require 'pathname'

module Pod
  class Podfile

    module DSL

      # Default root path. #TODO: Get from config.
      def default_pod_develop_path
        unless instance_variable_defined? :@default_pod_develop_path
          @default_pod_develop_path = "../../shared/"
        end
        return @default_pod_develop_path
      end
            # Hash of paths to projects for development pods.
            def pod_develop_paths
              unless instance_variable_defined? :@pod_develop_paths
                @pod_develop_paths = Hash.new()
              end
              return @pod_develop_paths
            end

      # Add or change path to development pod projects.
      def pod_develop(name, path = nil)
        if path.nil?
          path = default_pod_develop_path + name
        end
        pod_develop_paths[name] = path
      end

      alias_method :original_pod_impl, :pod
      def pod(name = nil, *requirements, &block)
        path = pod_develop_paths[name]
        if path.nil?
          original_pod_impl(name, *requirements, &block)
        else
          original_pod_impl name, :path => path
        end
      end

    end
  end
end

module Pod
  class Installer
    # don't share development pod schemes (we will be importing the whole project)
    define_method(:share_development_pod_schemes) do 
      #nothing
    end
  end
end

module CocoaPodsDevelop

  Pod::HooksManager.register('cocoapods-develop', :post_install) do |installer, _|

      # Find all the workspaces in the root directory for the Podfile

      projroot = Pathname(installer.sandbox_root).dirname.to_s
      workspaces = Dir.glob(projroot + "/*.xcworkspace")

      unless workspaces.count != 1

        workspace_path = Pathname.new(workspaces[0])

        development_pods_projects = installer.sandbox.development_pods.flat_map do |k, v|
          root_proj_path = Pathname.new(v + "/" + k + ".xcodeproj")
          nested_proj_path = Pathname.new(v + "/" + k + "/" + k + ".xcodeproj")
          if Dir.exists?(root_proj_path)
            root_proj_path
          else Dir.exists?(nested_proj_path)
            nested_proj_path
          end
        end

        user_project_paths = installer.umbrella_targets.map { |at| at.user_project_path }.uniq
        all_projects_for_installer = (user_project_paths + [installer.sandbox.project_path] + development_pods_projects).uniq

        allowed_file_references = all_projects_for_installer
        .map { |proj| proj.relative_path_from(Pathname.getwd)}
        .map { |proj| Xcodeproj::Workspace::FileReference.new(proj) }

        if workspace_path.exist?
          workspace = Xcodeproj::Workspace.new_from_xcworkspace(workspace_path)
          unless workspace.file_references == allowed_file_references
            workspace = Xcodeproj::Workspace.new(*allowed_file_references)
            workspace.save_as(workspace_path)
          end
        else
          workspace = Xcodeproj::Workspace.new(*allowed_file_references)
          workspace.save_as(workspace_path)
        end

      else
        # error message
      end
    end
  end