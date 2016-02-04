module SectionVoteMutations
  Create = GraphQL::Relay::Mutation.define do
    name "CreateSectionVote"

    input_field :votable_id, !types.ID

    return_field :section, SectionType

    resolve -> (inputs, ctx) {
      votable = NodeIdentification.object_from_id_proc.call(inputs[:votable_id], ctx)
      user = ctx[:current_user]
      votable.votes.create({
        user: user
      })

      { section: NodeIdentification.object_from_id_proc.call(inputs[:votable_id], ctx) }
    }
  end

  Destroy = GraphQL::Relay::Mutation.define do
    name "DestroySectionVote"

    input_field :votable_id, !types.ID

    return_field :section, SectionType

    resolve -> (inputs, ctx) {
      votable = NodeIdentification.object_from_id_proc.call(inputs[:votable_id], ctx)
      user = ctx[:current_user]
      vote = user.votes.where({
        votable: votable
      }).first
      vote.destroy

      { section: NodeIdentification.object_from_id_proc.call(inputs[:votable_id], ctx) }
    }
  end
end

