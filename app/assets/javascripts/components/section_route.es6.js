var Relay = require('react-relay');
var Section = require('./section.es6.js');

/*
  Route: Section Show page
  Root node query for a single section
  params: {section_id}
*/

var SectionRoute = {
  queries: {
    section: () => Relay.QL` query {
      node(id: $sectionId)
    } `,
  },
  params: {
    sectionId: window.location.pathname.split('/')[2]
  },
  name: 'SectionRoute',
}

module.exports = SectionRoute;
