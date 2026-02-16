module Responses
  class AddMarkIdAfterSave
    include Interactor

    def call(response: context.response, mark_id: context.mark.id)
      if response
        response.update!(mark_id: mark_id)
        context.response = response
      else
        context.fail!(error: "Response not found")
      end
    end
  end
end
