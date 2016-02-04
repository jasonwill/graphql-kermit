module CommentMutations
  Create = GraphQL::Relay::Mutation.define do
    name "CreateComment"
    description "Create comment for a section and return section and new comment"

    # Define input parameters
    input_field :section_id, !types.ID
    input_field :body, !types.String

    # Define return parameters
    return_field :commentEdge, CommentType.edge_type
    return_field :section, SectionType

    # Resolve block to create comment and return hash of section and comment
    resolve -> (inputs, ctx) {
      section = NodeIdentification.object_from_id_proc.call(inputs[:section_id], ctx)
      user = ctx[:current_user]
      comment = section.comments.create({
        body: inputs[:body],
        user: user
      })

      connection = GraphQL::Relay::RelationConnection.new(section, {})
      edge = GraphQL::Relay::Edge.new(comment, connection)

      { section: section, commentEdge: edge }
    }
  end

  Destroy = GraphQL::Relay::Mutation.define do
    name "DestroyComment"
    description "Delete a comment and return section and deleted comment ID"

    # Define input parameters
    input_field :id, !types.ID
    input_field :section_id, !types.ID

    # Define return parameters
    return_field :deletedId, !types.ID
    return_field :section, SectionType

    resolve -> (inputs, ctx) {
     section = NodeIdentification.object_from_id_proc.call(inputs[:section_id], ctx)
     comment = NodeIdentification.object_from_id_proc.call(inputs[:id], ctx)

     comment.destroy

     { section: section, deletedId: inputs[:id] }
   }
  end

  Edit = GraphQL::Relay::Mutation.define do
    name "EditComment"
    description "Edit a comment and return comment"

    # Define input parameters
    input_field :id, !types.ID
    input_field :body, !types.String

    # Define return parameters
    return_field :comment, CommentType

    resolve -> (inputs, ctx) {
      comment = NodeIdentification.object_from_id_proc.call(inputs[:id], ctx)
      valid_inputs = inputs.instance_variable_get(:@values).select { |k, _| item.respond_to? "#{k}=" }.except('id')
        comment.update(valid_inputs)
      { comment: comment }
    }
  end
end

