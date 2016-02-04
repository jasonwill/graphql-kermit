var Relay = require('react-relay');
/*
  Route: Sections
  Root query to fetch sections collection
  params: {}
*/

var SectionsRoute = {
  queries: {
    root: () => Relay.QL` query {
      root
    } `,
  },
  params: {
  },
  name: 'SectionsRoute',
}

module.exports = SectionsRoute;
