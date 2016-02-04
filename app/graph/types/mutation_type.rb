MutationType = GraphQL::ObjectType.define do
  name 'Mutation'

  field :EditComment, field: CommentMutations::Edit.field
  field :DestroyComment, field: CommentMutations::Destroy.field
  field :CreateComment, field: CommentMutations::Create.field

  field :DestroySectionVote, field: SectionVoteMutations::Destroy.field
  field :CreateSectionVote, field: SectionVoteMutations::Create.field
end
