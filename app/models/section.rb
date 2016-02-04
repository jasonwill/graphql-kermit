class Section < ActiveRecord::Base

  # Slug for sections
  #acts_as_url :title, url_attribute: :slug

  belongs_to :user
  has_many :comments
  has_many :votes, as: :votable

  #has_many :schedules, dependent: :destroy

  include Votable

  validates_presence_of :year, :term

  scope :by_term, ->(term,year) { where(year: year, term: term) }
  
  #default_scope { includes(:schedules).where("long_name NOT LIKE '%GHOST%'").order('course_code ASC, section_code ASC') }
  
  before_create :stamp
  
  #def to_param
  #  slug # or whatever you set :url_attribute to
  #end

  def self.popular
    order(votes_count: :desc, comments_count: :desc)
  end

  def course_with_section
    section_code.to_i > 0 ? "#{course_code}-#{section_code}" : course_code
  end
  
  
  def self.refresh
    #~ Query for sections in PowerCampus
    last_section_updated_at = Section.any? ? Section.order('imported_at DESC').limit(1).first.updated_at : Time.now-1.year   

    pc_sections = PC.fetch_sections(last_section_updated_at) 
  
    #~ Find all instructors and schedules for all fetched sections (from PowerCampus)
    pc_sections_instructors = PC.fetch_instructors_by_sections(pc_sections.map(&:section_id)) 
    pc_sections_schedules = PC.fetch_schedules_by_sections(pc_sections.map(&:section_id)) 
    pc_sections_registrations = PC.fetch_registrations_by_sections(pc_sections.map(&:section_id)) 
  
    pc_sections.each do |s|
     
      i = pc_sections_instructors.select {|i| i.section_id == s.section_id } # Check to see if any instructors are listed for this section in PowerCampus 
      sch = pc_sections_schedules.select {|i| i.section_id == s.section_id }
      reg = pc_sections_registrations.select {|i| i.section_id == s.section_id }
      
      import(s,i,sch,reg)
  
    end
  
  end
    
    
  def self.import(source_section,source_instructorings,source_schedules,source_registrations)
    
    #~ Locate or create a new section based on the external identifier
      s = find_or_initialize_by(ext_id: source_section.section_id, year: source_section.year, term: source_section.term, course_code: source_section.course_code, section_code: source_section.section_code)
    
      s.long_name = source_section.long_name
      s.short_name = source_section.short_name
      s.category = source_section.category
      s.department = source_section.department
      s.department_code = source_section.department_code
      s.program = source_section.program

      begin
        if source_section.description != nil and source_section.description != '' and source_section.description.force_encoding('UTF-8')
          s.description = source_section.description.force_encoding('UTF-8').encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
        end
      rescue
        p ("!!! Bad encoding contained in description :: section #{source_section.section_id}")
      end
      
      s.event_type = source_section.event_type
      s.credit_type = source_section.credit_type
      s.credits = source_section.credits
      s.min_participants = source_section.min_participants
      s.max_participants = source_section.max_participants
      s.adds = source_section.adds
      s.drops = source_section.drops
      s.waitlist = source_section.waitlist
      s.enrollment_status = source_section.enrollment_status
      s.ext_creator_ref = source_section.creator_ref
    
      case source_section.event_status
      when "A"
        s.event_status = 'active'
      when "P"
        s.event_status = 'pending'
      when "C"
        s.event_status = 'cancelled'
      end
    
      if s.new_record?
        s.imported_at = Time.now
      end  
    
      if s.save
        
        #~ Persist all instructor relationships for this section
        if source_instructorings and source_instructorings.length > 0
        
          s.instructorings.destroy_all
        
          source_instructorings.each do |ins| # For each instructor for the section
            if !ins.blank? 
              powercampus_instructor_id = ins.pc_id.to_i.to_s
            
              if !User.find_by(ext_ref: powercampus_instructor_id)
                user = User.find_or_init_by_pc_id(powercampus_instructor_id)
              else
                user = User.find_by(ext_ref: powercampus_instructor_id)
              end
              
              ida_instructor_id = user ? user.id : nil
              
              if instructoring = Instructoring.where(section_id: s.id, instructor_ext_ref: powercampus_instructor_id).first_or_create
                instructoring.update_attribute(:user_id, ida_instructor_id)
              end 
              
            end
          end
          
        end
        
        #~  Persist any applicable schedules for the section
        if source_schedules and source_schedules.length > 0
          
          s.schedules.destroy_all
          
          source_schedules.each do |sch| #For each schedule for the section
            schedule = Schedule.where(section_id: s.id, days: sch.days).first_or_create
      
            schedule.days = sch.days
           # schedule.starts_at = source_section.starts_at - Time.zone_offset(Time.now.zone) ### THIS WORKS FOR 'PDT' BUT NOT FOR 'PST'
            schedule.starts_at = source_section.starts_at - Time.zone_offset('PST')
            schedule.ends_at = source_section.ends_at - Time.zone_offset('PST')

            schedule.session_start_time = sch.start_time - Time.zone_offset('PST')
            schedule.session_end_time = sch.end_time - Time.zone_offset('PST')

            schedule.room = sch.room

            #~ Persist the location (building) where the section occurs (part of the schedule record)
            if building = Building.where(ext_id: sch.building_id).first
              schedule.building_id = building.id
            end

            schedule.save
          end
        end #~source_schedules.each
        
        #~  Persist any applicable registrations for the section
        if source_registrations and source_registrations.length > 0
          
          #s.registrations.destroy_all
          
          source_registrations.each do |reg|
            
            powercampus_student_id = reg.pc_id.to_i.to_s
          
            if !User.find_by(ext_ref: powercampus_student_id)
              user = User.find_or_init_by_pc_id(powercampus_student_id)
            else
              user = User.find_by(ext_ref: powercampus_student_id)
            end
            
            ida_student_id = user ? user.id : nil
            
            registration = Registration.where(section_id: s.id, student_ext_ref: powercampus_student_id).first_or_create
            
            registration.user_id = ida_student_id
           
            registration.adw_status = reg.adw_status
            registration.prereg = (reg.prereg == 'PRE' ? true : false) 
            registration.status_updated_at = reg.status_date
            registration.ext_id = reg.registration_id
            registration.ext_creator_ref = reg.updated_by
            registration.ext_last_updater_ref = reg.updated_by
            registration.attend_status = reg.attend_status
            registration.last_attended_at = reg.last_attended_at
            
            registration.save
          end
        end #~source_registrations.each
        
    end #! if section saved
    
  end
  
  private
  
  def stamp
    self.uuid = SecureRandom.hex(9)
  end
  
end
