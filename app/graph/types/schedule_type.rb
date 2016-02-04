ScheduleType = GraphQL::ObjectType.define do
  name "Schedule"
  description "A section schedule, returns day and time that the course occurs"

  interfaces [NodeIdentification.interface]
  # `id` exposes the UUID
  global_id_field :id

  # Expose fields from the model
  #field :name, types.String, "The name of this user"
  #field :email, types.String,  "The email of this user"
  #field :created_at, types.String,  "The date this user created an account"

end
