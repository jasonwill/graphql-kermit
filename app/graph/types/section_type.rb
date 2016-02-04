include ActionView::Helpers::TextHelper

SectionType = GraphQL::ObjectType.define do
  name "Section"
  description "A single section entry returns a section with instructor, total votes and comments"
  interfaces [NodeIdentification.interface]
  # `id` exposes the UUID
  global_id_field :id

  # Expose fields associated with Section model
  field :term, types.String
  field :course_code, types.String
  field :section_code, types.String
  field :long_name, types.String
  field :short_name, types.String
  field :description, types.String
  field :category, types.String
  field :department, types.String
  field :program, types.String
  field :uuid, types.String
  field :created_at, types.String

  field :comments_count, types.String,  "The total numner of comments on this section"
  field :votes_count, types.String,  "The total numner of votes on this section"

  field :user, UserType, "Owner of this section"
   #field :schedule, ScheduleType, "Schedule of this section"

  # Define a connection on comments
  connection :comments, CommentType.connection_type do
    description "All comments association with this section. Returns comments collection and accepts arguments."
    resolve ->(section, args, ctx){
      section.comments.includes(:user)
    }
  end

  # Custom field using resolve block
  field :excerpt do
    type types.String
    description "The short description of this section"
    resolve -> (section, arguments, ctx) {
      truncate(section.description, length: 150, escape: false)
    }
  end

  # Custom field using resolve block
  field :voted do
    type types.Boolean
    description "The short description of this section"
    resolve -> (section, arguments, ctx) {
      ctx[:current_user] ? section.voted?(ctx[:current_user].id) : false
    }
  end

  field :formatted_description do
    type types.String
    description "The body of this section"
    resolve -> (section, arguments, ctx) {
      simple_format(section.description)
    }
  end

end
