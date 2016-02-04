ViewerType = GraphQL::ObjectType.define do

  # Hack to support root queries
  name 'Viewer'
  description 'Support unassociated root queries that fetches collections. Supports fetching sections and users collection'
  interfaces [NodeIdentification.interface]

  # `id` exposes the UUID
  global_id_field :id

  # Fetch all sections
  connection :sections, SectionType.connection_type do
    argument :filter, types.String
    description 'Section connection to fetch paginated sections collection.'
    resolve ->(object, args, ctx){
      args["filter"] ? Section.send(args["filter"]).includes(:user) : Section.includes(:user)
    }
  end

end
