require 'errors/action_forbidden_from_regular_subdomain_error'

module TeamPlaybook
  module TeamOnlyActions
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do

        class_attribute :team_only_actions
        self.team_only_actions = []

        before_filter :ensure_action_is_allowed_for_subdomain

        def ensure_action_is_allowed_for_subdomain
          team_only_action_names = self.team_only_actions.map(&:to_s)

          all_actions_are_team_only = team_only_action_names.include? "all"
          action_is_team_only = team_only_action_names.include? action_name
          request_is_from_regular_subdomain = !has_team_subdomain?

          request_should_be_from_team_subdomain = (action_is_team_only or all_actions_are_team_only)

          should_raise_error = (request_should_be_from_team_subdomain and request_is_from_regular_subdomain)

          raise ActionForbiddenFromRegularSubdomain if should_raise_error
        end
      end
    end

    module ClassMethods
      def team_subdomain_only(actions = [])
        self.team_only_actions = [actions] if not actions.kind_of? Array
        self.team_only_actions = actions if actions.kind_of? Array
      end
    end
  end

end