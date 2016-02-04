import Relay from 'react-relay';

export default class extends Relay.Mutation  {

  getMutation() {
    return Relay.QL`mutation{DestroySectionVote}`;
  }

  getFatQuery() {
    return Relay.QL`
      fragment on DestroySectionVotePayload {
      section {
        votes_count,
        voted
      }
    }
    `;
  }

  getConfigs() {
    return [
      {
        type: 'FIELDS_CHANGE',
        fieldIDs: {
          section: this.props.section.id
        }
      }
    ];
  }

  getVariables() {
    return {
      votable_type: this.props.votable_type,
      votable_id: this.props.section.id
    };
  }

  getOptimisticResponse() {
    const {section} = this.props;
    return {
      section: {
        id: section.id,
        votes_count: parseInt(section.votes_count) - 1,
        voted: false
      }
    };
  }
}
